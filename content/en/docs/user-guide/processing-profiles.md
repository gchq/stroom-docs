---
title: "Node Groups and Processing Profiles"
linkTitle: "Processing Profiles"
weight: 100
date: 2026-08-13
tags:
  - node
  - processing
description: >
  Controlling which nodes do the processing, when they do it, and how much of the cluster it may use.
---

By default a {{< glossary "Processor Filter" >}} may be processed by any node in the cluster, at any time, up to the limits set on the filter itself.
_Node Groups_ and _Processing Profiles_ let you be more selective than that.

* A **Node Group** is a named set of nodes.
* A **Processing Profile** names a node group and a set of periods, saying when processing may run and how many threads it may use in each period.
* A processor filter can then be given a profile.

Together these let you keep heavy processing off the nodes that serve the user interface, hold it back until a quiet time of day, or give it more of the cluster at the weekend.


## Node Groups

Node groups are managed from

{{< stroom-menu "Monitoring" "Node Groups" >}}

Each group has:

* **Node Group Name** - the name used to refer to the group from a processing profile.
* **Enabled** - whether the group is in use.
  A disabled group does no processing at all, whatever its profiles say.
* **Node Inclusion Behaviour** - whether the nodes you tick are included in the group or excluded from it.
* **Nodes** - the nodes to tick.

The inclusion behaviour is worth understanding.
Choosing _exclude_ means the group is everything except the nodes you tick, so nodes added to the cluster later join the group automatically.
Choosing _include_ means only the ticked nodes are in the group, and a new node has to be added deliberately.


## Processing Profiles

Processing profiles are managed from

{{< stroom-menu "Monitoring" "Processor Profiles" >}}

Each profile has:

* **Profile Name** - the name shown when choosing a profile on a processor filter.
* **Node Group** - the group of nodes that may process for this profile.
* **Processing Schedules** - one or more periods, described below.
* **Time Zone** - the time zone the periods are interpreted in.

Setting the time zone explicitly matters for a cluster whose nodes are not all in the same place, and for periods that should follow local working hours across daylight saving changes.


### Periods

Each period in the schedule has:

* **Active Days** - the days of the week the period applies to.
* **Start Time** and **End Time** - the time of day the period runs between.
  An end time that is not after the start time is treated as running into the following day, so a period can span midnight.
* **Limit Single Node Threads** and **Max Node Threads** - whether to cap the threads used on each node, and the cap.
* **Limit Total Cluster Threads** and **Max Cluster Threads** - whether to cap the threads used across the whole cluster, and the cap.

Leaving a limit unticked means that limit is not applied, i.e. the number of threads is unbounded for that period.

Periods are evaluated in order and the first one that matches the current day and time is used.


### When No Period Matches

{{% warning %}}
A filter that has been given a profile is processed **only** during the periods in that profile.

If no period matches the current day and time then no tasks are created for that filter.
The same is true if the profile has no periods at all, if its node group is disabled, or if the node asking for work is not in the group.
{{% /warning %}}

This is the behaviour you want for confining processing to a window, but it does mean a profile with an incomplete schedule will quietly stop a filter from processing.
A filter with no profile set is not restricted in this way.


## Using a Profile on a Filter

A profile is chosen on the processor filter itself, using the _Processing Profile_ field alongside the other filter settings such as _Max Processing Tasks_.

Task creation takes profiles into account, so tasks that no node is currently allowed to process are not added to the queue, and are released again if a profile stops allowing them.
Each profile is given a share of the tasks that are created, so that one busy profile does not starve the others.


{{% see-also %}}
* [Nodes]({{< relref "nodes" >}})
* [Jobs]({{< relref "jobs" >}})
{{% /see-also %}}
