# Stroom Jobs
There are various jobs that run in the background within Stroom.
Among these are jobs that control pipeline processing, removing old files from the file system, checking the status of nodes and volumes etc.
Each task executes at a different time depending on the purpose of the task. There are three ways that a task can be executed:

 1. Scheduled jobs execute periodically according to a cron schedule.
    These include jobs such as cleaning the file system where Stroom only needs to perform this action once a day and can do so overnight.
 2. Frequency controlled jobs are executed every X seconds, minutes, hours etc.
    Most of the jobs that execute with a given frequency are status checking jobs that perform a short lived action fairly frequently.
 3. Distributed jobs are only applicable to stream processing with a pipeline.
    Distributed jobs are executed by a worker node as soon as a worker has available threads to execute a jobs and the task distributor has work available.

A list of task types and their execution method can be seen by opening _Monitoring/Jobs_ from the main menu.

![Tasks](tasks.png) TODO image

Expanding each task type allows you to configure how a task behaves on each node:

![Task Nodes](task-nodes.png) TODO image


#### Account Maintenance

This job checks user accounts on the system and de-activates them under the following conditions:

* An unused account that has been inactive for longer than the age configured by `stroom.security.identity.passwordPolicy.neverUsedAccountDeactivationThreshold`.
* An account that has been inactive for longer than the age configured by `stroom.security.identity.passwordPolicy.unusedAccountDeactivationThreshold`.

#### Attribute Value Data Retention

Deletes Meta attribute values older than `stroom.data.meta.metaValue.deleteAge`.

#### Data Delete

How frequently we physically delete data from the stream store that has been logically deleted for the duration configured with `stroom.data.store.deletePurgeAge`.

#### Data Processor

Distributes stream tasks to worker nodes for processing.
Stream tasks are created based on stream filters added to the Processors screen of each pipeline.

#### Feed Based Data Retention

TODO

#### File System Clean (deprecated)

TODO

#### File System Volume Status

Scans your data volumes to ensure they are available and determines how much free space they have.
Records this status in the Volume Status table.

#### Index Searcher Cache Refresh

TODO

#### Index Shard Delete

How frequently index shards that have been logically deleted are physically deleted from the file system.
#### Index Shard Retention


How frequently index shards that are older then their retention period are logically deleted.

#### Index Volume Status

Scans your index volumes to ensure they are available and determines how much free space they have.
Records this status in the Index Volume Status table.

#### Index Writer Cache Sweep

How frequently entries in the Index Shard Writer cache are evicted based on the time-to-live, time-to-idle and cache size settings.

#### Index Writer Flush

How frequently in-memory changes to the index shards are flushed to the file system and committed to the index.

#### Java Heap Histogram Statistics

How frequently heap histogram statistics will be captured.
This can be useful for diagnosing issues or seeing where memory is being used.
Each run will result in a JVM pause so car should be taken when running this on a production system.

#### Node Status

How frequently we try write stats about node status including JVM and memory usage.

#### Pipeline Destination Roll

How frequently rolling pipeline destinations, e.g. a Rolling File Appender are checked to see if they need to be rolled.
This frequency should be at least as short as the most frequent rolling frequency.

#### Policy Based Data Retention

How frequently the policy based data retention rules are checked to see if any data needs to be logically deleted.

#### Processor Task Queue Statistics

How frequently statistics about the state of the stream processing task queue are captured.

#### Processor Task Retention

How frequently failed and completed tasks are checked to see if they are older than the delete age threshold set by `stroom.processor.deleteAge`.
Any that are older than this threshold are deleted.

#### Property Cache Reload

Stroom's configuration properties can each be configured globally in the database.
This job controls the frequency that each node refreshes the values of its properties cache from the global database values.
See also [Properties](./properties.md).

#### Proxy Aggregation

If you front Stroom with an Stroom proxy which is configured to 'store' rather than 'store/forward', then this task when run will pick up all files in the proxy repository dir, aggregate them by feed and bring them into Stroom.
It uses the system property `stroom.proxyDir`.

#### Query History Clean

How frequently items in the query history are removed from the history if their age is older than `stroom.history.daysRetention` or if the number of items in the history exceeds `stroom.history.itemsRetention`.

#### Ref Data Off-heap Store Purge

Purges all data older than the purge age defined by property `stroom.pipeline.purgeAge`.
See also [Reference Data](./pipelines/reference-data.md#purging-old-reference-data).

#### Solr Index Optimise

How frequently Solr index segments are explicitly optimised by merging them into one.

#### Solr Index Retention

How frequently a process is run to delete items from the Solr indexes that don't meet the retention rule of that index.

#### SQL Stats Database Aggregation

This job controls the frequency that the database statistics aggregation process is run.
This process takes the entries in `SQL_STAT_VAL_SRC` and merges them into the main statistics tables `SQL_STAT_KEY` and `SQL_STAT_KEY`.
As this process is reliant on data flushed by the _SQL Stats In Memory Flush_ job it is advisable to schedule it to run after that, leaving some time for the in-memory flush to finish.

#### SQL Stats In Memory Flush

SQL Statistics are initially held and aggregated in memory.
This job controls the frequency that the in memory statistics are flushed from the in memory buffer to the staging table `SQL_STAT_VAL_SRC` in the database.

