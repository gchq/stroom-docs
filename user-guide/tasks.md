#Stroom Tasks
There are various tasks that run in the background within Stroom. Among these are tasks that control pipeline processing, removing old files from the file system, checking the status of nodes and volumes etc. Each task executes at a different time depending on the purpose of the task. There are three ways that a task can be executed:

 1. Scheduled tasks execute periodically according to a cron schedule. These include tasks such as cleaning the file system where Stroom only needs to perform this action once a day and can do so overnight.
 2. Frequency controlled tasks are executed every X seconds, minutes, hours etc. Most of the tasks that execute with a given frequency are status checking tasks that perform a short lived action fairly frequently.
 3. Distributed tasks are only applicable to stream processing with a pipeline. Distributed tasks are executed by a worker node as soon as a worker has available threads to execute a tasks and the task distributor has work available.

A list of task types and their execution method can be seen by opening 'Monitoring/Jobs' from the main menu.

![Tasks](tasks.png) TODO image

Expanding each task type allows you to configure how a task behaves on each node:

![Task Nodes](task-nodes.png) TODO image

#### Stream Task Retention

How frequently we try and delete completed stream tasks older than system property 
(stroom.streamTaskDeleteAge)

#### Proxy Aggregation

If you front Stroom with an Stroom proxy which is configured to 'store' rather
than 'store/forward', then this task when run will pick up all files in the proxy 
repository dir, aggregate them by feed and bring them into Stroom.
(It uses the system property stroom.proxyDir)

#### File System Clean

When you delete a stream in Stroom it only marks the database entry for the stream as deleted.
This is so deletes are instant as far as the user is concerned as it could take a while to 
delete data from the disk. The task when run deletes files on disk and database entries for 
streams that are marked as deleted. We don\u2019t have this feature turned on in production 
so that we can restore accidentally deleted items by making a manual update in the DB. It 
only needs to be run if you want to permanently delete files and free up storage.

#### Stream Retention

When feeds have a stream retention period set to anything other than 'Forever', 
this task when run will cycle around all feeds and mark streams as deleted that are older 
than the specified retention period.

#### Stream Delete

How frequently we physically delete streams that have been logically deleted based the age of the delete 
(stroom.streamDeletePurgeAge)

#### Stream Attributes Retention

How frequently we try and delete attributes older than system property 
(stroom.streamAttributeDatabaseAge).

#### SQL Stats Database Aggregation

How frequently we try and aggregate stats on the database.
If this job is enabled on a number of nodes only one will actually perform the aggregation on the database.  

#### Node Status

How frequently we try write stats about node status including JVM and memory usage.

#### Cluster Lock Keep Alive

How frequently we issue our keep alive for cluster locks.

#### Index Shard Retention

Logically delete index shards that are older than the retention period set on their associated index.
Physically deletes index shard data on disk and associated DB entry.
Refreshes index field data for indexing purposes.

#### Property Cache Reload

How frequently we invalidate the system property cache and reload from the database.

#### Volume Status Retention

How frequently we try and delete old volume status information.

#### Volume Status

Scans your volumes to ensure they are available and determines how much free space they have.
Records this status in the Volume Status table.

#### Disable Unused Accounts

How frequently we check the system property stroom.daysToUnusedAccountExpiry to check and disable
unused accounts.

#### Pipeline Destination Roll

How frequently we check pipeline destination's to roll (age off and start a new one).
This period is controlled in the pipeline.   

#### Benchmark System

Used to benchmark the performance of an Stroom cluster. To use this task you need to stop
receiving data so that the results are skewed by processing data other than benchmark data. 
We only run this task in our reference environment to ensure that each version of Stroom
maintains or improves upon the processing performance of previous versions.

#### Stream Processor

Distributes stream tasks to worker nodes for processing. Stream tasks are created based 
on stream filters added to the \u2018Processors\u2019 screen of each pipeline.
