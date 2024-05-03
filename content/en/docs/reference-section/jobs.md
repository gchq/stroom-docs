---
title: "Job Reference"
linkTitle: "Job Reference"
weight: 60
date: 2021-07-27
tags:
  - job
description: >
  List of Stroom's background jobs.
---

The jobs in the list are in the order they appear in the Stroom UI.


## Data Delete

Before data is physically removed from the database and file system it is marked as logically deleted by adding a flag to the metadata record in the database.
Data can be logically deleted by a user from the UI or via a process such as data retention.
Data is deleted logically as it is faster to do than a physical delete (important in the UI), and it also allows for data to be restored (undeleted) from the UI.
This job performs the actual physical deletion of data that has been marked logically deleted for longer than the duration configured with `stroom.data.store.deletePurgeAge`.
All data files associated with a metadata record are deleted from the file system before the metadata is physically removed from the database.


## Data Processor

Processes data by finding data that matches processing filters on each pipeline.
When enabled, each worker node asks the master node for data processing tasks.
The master node creates tasks based on processing filters added to the `Processors` screen of each pipeline and supplies them to the requesting workers.


## Node Status

How frequently we try write stats about node status including JVM and memory usage.


## Processor Task Creator

Create Processor Tasks from Processor Filters.


## Query History Clean

How frequently items in the query history are removed from the history if their age is older than `stroom.history.daysRetention` or if the number of items in the history exceeds `stroom.history.itemsRetention`.

---


## Account Maintenance

This job checks user accounts on the system and de-activates them under the following conditions:

* An unused account that has been inactive for longer than the age configured by `stroom.security.identity.passwordPolicy.neverUsedAccountDeactivationThreshold`.
* An account that has been inactive for longer than the age configured by `stroom.security.identity.passwordPolicy.unusedAccountDeactivationThreshold`.


## Analytic Executor: Scheduled Query

Run scheduled index query analytics periodically


## Analytic Executor: Table Builder

Analytic Executor: Table Builder


## Attribute Value Data Retention

Deletes Meta attribute values (additional and less valuable metadata) older than `stroom.data.meta.metaValue.deleteAge`.


## Elastic Index Retention

Logically delete indexed documents in Elasticsearch indexes based on the specified deletion query.


## File System Volume Status

Scans your data volumes to ensure they are available and determines how much free space they have.
Records this status in the Volume Status table.


## Index Shard Delete

How frequently index shards that have been logically deleted are physically deleted from the file system.


## Index Shard Retention

How frequently index shards that are older then their retention period are logically deleted.


## Index Volume Status

Scans your index volumes to ensure they are available and determines how much free space they have.
Records this status in the Index Volume Status table.


## Index Writer Cache Sweep

How frequently entries in the Index Shard Writer cache are evicted based on the time-to-live, time-to-idle and cache size settings.


## Index Writer Flush

How frequently in-memory changes to the index shards are flushed to the file system and committed to the index.


## Java Heap Histogram Statistics

How frequently heap histogram statistics will be captured.
This can be useful for diagnosing issues or seeing where memory is being used.
Each run will result in a JVM pause so car should be taken when running this on a production system.


## Orphan File Finder

Job to find files that do not exist in the meta store.


## Orphan Meta Finder

Job to find items in the meta store that have no associated data.


## Pipeline Destination Roll

How frequently rolling pipeline destinations, e.g. a Rolling File Appender are checked to see if they need to be rolled.
This frequency should be at least as short as the most frequent rolling frequency.


## Policy Based Data Retention

Run the policy based data retention rules over the data and logically delete and data that should no longer be retained.


## Processor Task Manager Disown Dead Tasks

Tasks that seem to be stuck processing due to the death of a processing node are disowned and added back to the task queue for processing after `stroom.processor.disownDeadTasksAfter`.


## Processor Task Manager Release Old Queued Tasks

Release queued tasks from old master nodes.


## Processor Task Queue Statistics

How frequently statistics about the state of the stream processing task queue are captured.


## Processor Task Retention

This job is responsible for cleaning up redundant processors, tasks and filters.
If it is not run then these will build up on the system consuming space in the database.

This job relies on the property `stroom.processor.deleteAge` to govern what is deemed _old_.
The `deleteAge` is used to derive the delete threshold, i.e. the current time minus `deleteAge`.

When the job runs it executes the following steps:

1. **Logically Delete Processor Tasks** - Logically delete all processor tasks belonging to processor filters that have been logically deleted.

1. **Logically Delete Processor Filters** - Logically delete old processor filters with a state of `COMPLETE` and no associated tasks.
   Filters are considered old if the last poll time is less than the delete threshold.

1. **Physically Delete Processor Tasks** - Physically delete all old processor tasks with a status of `COMPLETE` or `DELETED`.
   Tasks are considered old if they have no status time or the status time (the time the status was last changed) is less than the delete threshold.

1. **Physically Delete Processor Filters** - Physically delete all old processor filters that have already been logically deleted.
   Filters are considered old if the last update time is less than the delete threshold.
   A filter can be logically deleted either by the step above or explicitly by a user in the user interface.

1. **Physically Delete Processors** - Physically delete all old processors that have already been logically deleted.
   Processors are considered old if the last update time is less than the delete threshold.
   A processor can only be logically deleted by the user in the user interface.

Therefore for items not deleted by a user, there will be a delay equal to `deleteAge` before logical deletion, then another delay equal to `deleteAge` before final physical deletion.


## Property Cache Reload

Stroom's configuration properties can each be configured globally in the database.
This job controls the frequency that each node refreshes the values of its properties cache from the global database values.
See also [Properties]({{< relref "/docs/user-guide/properties.md" >}}).


## Ref Data Off-heap Store Purge

Purges all data older than the purge age defined by property `stroom.pipeline.purgeAge`.
See also [Reference Data]({{< relref "/docs/user-guide/pipelines/reference-data.md#purging-old-reference-data" >}}).


## SQL Stats Database Aggregation

This job controls the frequency that the database statistics aggregation process is run.
This process takes the entries in `SQL_STAT_VAL_SRC` and merges them into the main statistics tables `SQL_STAT_KEY` and `SQL_STAT_KEY`.
As this process is reliant on data flushed by the _SQL Stats In Memory Flush_ job it is advisable to schedule it to run after that, leaving some time for the in-memory flush to finish.


## SQL Stats In Memory Flush

SQL Statistics are initially held and aggregated in memory.
This job controls the frequency that the in memory statistics are flushed from the in memory buffer to the staging table `SQL_STAT_VAL_SRC` in the database.


## Solr Index Optimise

How frequently Solr index segments are explicitly optimised by merging them into one.


## Solr Index Retention

How frequently a process is run to delete items from the Solr indexes that don't meet the retention rule of that index.

