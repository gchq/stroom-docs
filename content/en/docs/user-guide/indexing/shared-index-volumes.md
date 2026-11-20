---
title: "Shared Index Volumes"
linkTitle: "Shared Index Volumes"
#weight:
date: 2026-11-20
tags:
  - volume
  - shard
description: >
  Storing Lucene index shards on a file system that every node can see, so that any node can search them or write to them.
---

A Lucene {{< glossary "Index" >}} is made up of index shards, and each shard is a directory of files in an index {{< glossary "Volume" >}}.
An index volume is one of two types:

* **Local** - A disk that only one node can see.
  The volume belongs to that node.
  Only that node can write to its shards or search them.
* **Shared** - One mount that every node can see, e.g. a network file system.
  The volume has no node.
  Any node can search its shards and any node can write to them.

Shared index volumes are new in v7.14.
Every index volume that existed before v7.14 is local and behaves as it always did.


## Why Use a Shared Volume

With local volumes a shard can only be reached through the node that wrote it.

* If a node is down, searches return no results from its shards until it is back.
* If a node is lost for good, so are its shards.
* The node that wrote the most shards does the most searching.

With a shared volume a shard does not belong to a node.

* A search does not depend on the node that wrote a shard being up.
* A node that is added to the cluster can search and write to the existing shards straight away.
* A node that dies does not take its shards with it.
  Another node takes them on, and the streams the dead node had not finished indexing are indexed again.


## Requirements

A shared volume must be a file system that:

* Is mounted at the same path on every node.
* Every node can read from and write to.
* Shows a file written by one node to the other nodes.

A relative path is resolved against the Stroom home directory of each node.

{{< warning >}}
Do not mark a volume as shared if its path is a separate disk on each node.
Each node would then only see the shards it wrote itself, and searches would lose results.
Stroom looks for this and logs an error, see [Checks on a Shared Volume]({{< relref "#checks-on-a-shared-volume" >}}).
{{< /warning >}}


## Creating a Shared Volume

Index volumes are managed from the main menu:

{{< stroom-menu "Administration" "Index Volumes" >}}

To add a shared volume to a {{< glossary "Volume Group" >}}, add a volume and set its _Type_ to _Shared_.
A shared volume has no _Node_, so that field is not shown.

To turn local volumes into a shared volume, edit one of them and change its _Type_ to _Shared_.
This is the way to do it when the nodes already have local volumes with the same path and that path is in fact one mount.
The volumes that the other nodes have in the group for that path are merged into the one shared volume, and their shards become shards of the shared volume.

The following rules apply:

* A shared volume cannot be made local again, because its shards may have been written by any node.
  Add a new local volume instead.
* A volume group cannot have a shared volume and a local volume with the same path.
  Mark the local volume as shared rather than adding a new one.
* A volume group can have both shared and local volumes.
  New shards are created on its shared volumes when it has any.
  If none of its shared volumes can take a shard, e.g. because they are all full, new shards are created on the node's local volumes.


### Checks on a Shared Volume

When a volume is marked as shared, each node checks that it can create the path and write to it.
The change is refused if any node cannot.
A node that cannot be reached cannot be checked, so Stroom names it and asks you to confirm the change.

After that, the job _Index Volume Status_ on each node keeps a marker file in each shared volume and looks for the markers of the other running nodes.
If a node cannot see the marker of another running node after 15 minutes, it logs an error that says the path is probably not the same mount on every node.
A node that is down is not expected to keep its marker fresh.


## Searching

A shard on a shared volume is searched by one of the nodes that are running, which need not be the node that wrote it.

* A closed shard is given to a running node that is chosen from the ID of the shard.
  A shard goes to the same node from one search to the next, which keeps the file cache of that node warm.
  When a node joins or leaves the cluster, only the shards that it gains or loses move.
* A shard that is open for writing is searched by the node that is writing to it, because only that node sees the documents that are not yet committed.
  If that node is not running, the shard is searched by another node as far as its last commit.

If a search cannot be started on a node, the shards on shared volumes that it would have searched are searched by other nodes.

A node that is writing to a shard replaces the files of the shard as it commits and merges.
Another node may be part way through reading those files, so the writer keeps what it has replaced for a period before it deletes it.
The period is set by the property `stroom.index.writer.replacedCommitRetention` and is 30 minutes by default.
It must be longer than the longest time that a search holds a shard open.
A longer period uses more disk space.


## Writing

Only one node can write to a shard at a time.
A node must hold a lease on a shard on a shared volume to write to it.

* A node claims the lease when it opens the shard for writing.
* It renews the lease while the shard is open.
  How often is set by `stroom.index.writer.shardLeaseRenewInterval`, which is 20 seconds by default.
* It gives the lease up when it closes the shard.
  Any node can then write to the shard.
* A lease that is not renewed runs out.
  How long that takes is set by `stroom.index.writer.shardLeaseDuration`, which is 1 minute by default.

When a node needs a shard to write to, it uses a closed shard that has room in it before it creates a new one.
A shard is therefore written to by different nodes over its life.
The _Node_ shown for a shard on a shared volume is the node that holds its lease, or the last one that did.

Shards on local volumes have no lease.


## When a Node Fails

### A Node That Cannot Renew Leases

A node that cannot reach the database cannot renew its leases.
Once it has been unable to renew a lease for three quarters of the lease duration it stops writing to the shard.
It discards the documents that it has not committed and it no longer changes any file in the shard.
The streams those documents came from are indexed again, see [Re-Indexed Streams]({{< relref "#re-indexed-streams" >}}).


### A Node That Has Died

A node that has died leaves its shards open, with leases that run out.
Until they are taken from it, new documents go to other shards.

Once a lease has been out of date for a grace period, the shard is taken from the node.
The shard is closed, any node can write to it again, and the streams the dead node had not committed are indexed again.
This is done by the job _Index Shard Stream Recovery_, which runs every minute.
The job must be enabled on every node that can reach the shared volume, because the streams of a shard that has been taken are recovered by one of the running nodes.

The grace period is set by `stroom.index.writer.shardLeaseTakeoverGrace` and is 5 minutes by default.
It is the margin for a node that was frozen rather than dead and wakes later, so it must be much longer than any pause a node could suffer.

A node that comes back after its shards have been taken does not commit what it had not committed, and does not change the files of those shards.


## Re-Indexed Streams

Documents are added to a shard as a stream is processed, but they are only safe once the shard has committed them.
Stroom records which streams have documents in a shard that are not yet committed.
This applies to shards on both shared and local volumes.

A stream is indexed again if:

* Its indexing task fails part way through the stream.
* A shard that holds some of its documents fails to commit.
* The writer of a shard that holds some of its documents stops without a final commit, e.g. because its node died or lost its lease.

When that happens:

1. The documents of the stream are removed from every shard that they were written to.
1. The processor task for the stream is put back to run again.
1. An _Error_ stream is written for the stream that says why.
   It is removed when the task next runs.

After three failed attempts the task is set to _Failed_ rather than run again.

{{< note >}}
A stream is no longer left part indexed with its task marked as complete.
A search may briefly see some of the documents of a stream that is about to be indexed again.
{{< /note >}}


### Limits

* Documents are removed by their stream ID.
  Removing a stream removes every document in the index that came from it.
* The index must have an indexed `StreamId` field for the documents of a stream to be found and removed.
* Only streams that are indexed by a {{< glossary "Processor Filter" "processor filter" >}} are recorded.


## Shard Housekeeping

A shard on a local volume is looked after by its own node.
A shard on a shared volume is looked after by one of the running nodes, which need not be the node that wrote it.
While a shard is open for writing, that is the node that is writing to it.
That node applies the retention period of the index to the shard, deletes its files once it has been deleted, and acts on requests to flush or delete it.
The jobs _Index Shard Retention_, _Index Shard Delete_ and _Index Shard Stream Recovery_ must therefore be enabled on every node that can reach the shared volume.


## Properties

All of these are under `stroom.index.writer`.

| Property                  | Default | Description                                                                                         |
|---------------------------|---------|-----------------------------------------------------------------------------------------------------|
| `replacedCommitRetention` | `PT30M` | How long a writer keeps the files it has replaced in a shard, for searches on other nodes to finish. |
| `shardLeaseDuration`      | `PT1M`  | How long a lease on a shard lasts if it is not renewed.                                             |
| `shardLeaseRenewInterval` | `PT20S` | How often a node renews its leases. This should be about a third of `shardLeaseDuration`.           |
| `shardLeaseTakeoverGrace` | `PT5M`  | How long a lease must have been out of date before the shard is taken from the node that held it.   |


{{< see-also >}}
* [Lucene Indexes]({{< relref "lucene" >}})
* [Jobs Reference]({{< relref "docs/reference-section/jobs" >}})
* [Version 7.14 Upgrade Notes]({{< relref "releases/v07.14/upgrade-notes#shared-index-volumes" >}})
{{< /see-also >}}
