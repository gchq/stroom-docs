---
title: "Internal Data Sources"
linkTitle: "Internal Data Sources"
weight: 40
date: 2024-05-03
tags: 
  - data-source
  - search
description: >
  A set of data sources for querying the inner workings of Stroom.
---

Stroom provides a number of built in data sources for querying the inner workings of stroom.
These data sources do not have a corresponding {{< glossary "Document" >}} so do not feature in the explorer tree.

These data sources appear as children of the root folder when selecting a data source in a Dashboard {{< stroom-icon "document/Dashboard.svg">}}, View {{< stroom-icon "document/View.svg" >}}.
They are also available in the list of data sources when editing a Query {{< stroom-icon "document/Query.svg" >}}.


## Analytics

{{% todo %}}
Complete
{{% /todo %}}


## Annotations

Annotations are a means of annotating search results with additional information and for assigning those annotations to users.
The _Annotations_ data source allows you to query the annotations that have been created.

Field                   | Type   | Description
------                  | ------ | ------------
`annotaion:Id`          | Long   | Annotation unique identifier.
`annotation:CreatedOn`  | Date   | Date created.
`annotation:CreatedBy`  | String | Username of the user that created the annotation.
`annotation:UpdatedOn`  | Date   | Date last updated.
`annotation:UpdatedBy`  | String | Username of the user that last updated the annotation.
`annotation:Title`      | String |
`annotation:Subject`    | String |
`annotation:AssignedTo` | String | Username the annotation is assigned to.
`annotation:Comment`    | String | Any comments on the annotation.
`annotation:History`    | String | History of changes to the annotation.


## Dual

The Dual data source is one with a single field that always returns one row with the same value.
This data source can be useful for testing expression functions.
It can also be useful when combined with an extraction pipeline that uses the `stroom:http-call()` XSLT function in order to make a single HTTP call using Dashboard parameter values.

Field   | Type   | Description
------  | ------ | ------------
`Dummy` | String | Always one row that has the value `X`


## Index Shards

Exposes the details of the index shards that make up Stroom's Lucene based index.
Each index is split up into one or more partitions and each partition is further divided into one or more shards.
Each row represents one index shard.

Field          | Type    | Description
------         | ------  | ------------
`Node`         | String  | The name of the node that the index belongs to.
`Index`        | String  | The name of the index document.
`Index Name`   | String  | The name of the index document.
`Volume Path`  | String  | The file path for the index shard.
`Volume Group` | String  | The name of the volume group the index is using.
`Partition`    | String  | The name of the partition that the shard is in.
`Doc Count`    | Integer | The number of documents in the shard.
`File Size`    | Long    | The size of the shard on disk in bytes.
`Status`       | String  | The status of the shard (`Closed`, `Open`, `Closing`, `Opening`, `New`, `Deleted`, `Corrupt`).
`Last Commit`  | Date    | The time and date of the last commit to the shard.


## Meta Store

Exposes details of the streams held in Stroom's {{< glossary "stream" >}} (aka meta) store.
Each row represents one stream.

Field                 | Type   | Description
------                | ------ | ------------
`Feed`                | String | The name of the feed the stream belongs to.
`Pipeline`            | String | The name of the pipeline that created the stream. [Optional]
`Pipeline Name`       | String | The name of the pipeline that created the stream. [Optional]
`Status`              | String | The status of the stream (`Unlocked`, `Locked`, `Deleted`).
`Type`                | String | The {{< glossary "Stream Type">}}, e.g. `Events`, `Raw Events`, etc.
`Id`                  | Long   | The unique ID (within this Stroom cluster) for the stream .
`Parent Id`           | Long   | The unique ID (within this Stroom cluster) for the parent stream, e.g. the Raw stream that spawned an Events stream. [Optional]
`Processor Id`        | Long   | The unique ID (within this Stroom cluster) for the processor that produced this stream. [Optional]
`Processor Filter Id` | Long   | The unique ID (within this Stroom cluster) for the processor filter that produced this stream. [Optional]
`Processor Task Id`   | Long   | The unique ID (within this Stroom cluster) for the processor task that produced this stream. [Optional]
`Create Time`         | Date   | The time the stream was created.
`Effective Time`      | Date   | The time that the data in this stream is effective for. This is only used for reference data stream and is the time that the snapshot of reference data was captured. [Optional]
`Status Time`         | Date   | The time that the status was last changed.
`Duration`            | Long   | The time it took to process the stream in milliseconds. [Optional]
`Read Count`          | Long   | The number of records read in segmented streams. [Optional]
`Write Count`         | Long   | The number of records written in segmented streams. [Optional]
`Info Count`          | Long   | The number of _INFO_ messages.
`Warning Count`       | Long   | The number of _WARNING_ messages.
`Error Count`         | Long   | The number of _ERROR_ messages.
`Fatal Error Count`   | Long   | The number of _FATAL_ERROR_ messages.
`File Size`           | Long   | The compressed size of the stream on disk in bytes.
`Raw Size`            | Long   | The un-compressed size of the stream on disk in bytes.


## Processor Tasks

Exposes details of the tasks spawned by the processor filters.
Each row represents one processor task.

Field                       | Type    | Description
------                      | ------  | ------------
`Create Time`               | Date    | The time the task was created.
`Create Time Ms`            | Long    | The time the task was created (milliseconds).
`Start Time`                | Date    | The time the task was executed.
`Start Time Ms`             | Long    | The time the task was executed (milliseconds).
`End Time`                  | Date    | The time the task finished.
`End Time Ms`               | Long    | The time the task finished (milliseconds).
`Status Time`               | Date    | The time the status of the task was last updated.
`Status Time Ms`            | Long    | The time the status of the task was last updated (milliseconds).
`Meta Id`                   | Long    | The unique ID (unique within this Stroom cluster) of the stream the task was for.
`Node`                      | String  | The name of the node that the task was executed on.
`Pipeline`                  | String  | The name of the pipeline that spawned the task.
`Pipeline Name`             | String  | The name of the pipeline that spawned the task.
`Processor Filter Id`       | Long    | The ID of the processor filter that spawned the task.
`Processor Filter Priority` | Integer | The priority of the processor filter when the task was executed.
`Processor Id`              | Long    | The unique ID (unique within this Stroom cluster) of the pipeline processor that spawned this task.
`Feed`                      | String  |
`Status`                    | String  | The status of the task (`Created`, `Queued`, `Processing`, `Complete`, `Failed`, `Deleted`).
`Task Id`                   | Long    | The unique ID (unique within this Stroom cluster) of this task.


## Reference Data Store

{{% warning %}}
This data source is for advanced users only and is primarily aimed at debugging issues with reference data.
{{% /warning %}}

Reference data is written to a persistent cache on storage local to the node.
This data source exposes the data held in the store on the local node only.
Given that most Stroom deployments are clustered and the UI nodes are typically not doing processing, this means the UI node will have no reference data.


## Task Manager

This data source exposed the back ground tasks currently running across the Stroom cluster.
Each row represents a single background server task.

Requires the `Manage Tasks` application permission.

Field         | Type     | Description
------        | ------   | ------------
`Node`        | String   | The name of the node that the task is running on.
`Name`        | String   | The name of the task.
`User`        | String   | The user name of the user that the task is running as.
`Submit Time` | Date     | The time the task was submitted.
`Age`         | Duration | The time the task has been running for.
`Info`        | String   | The latest information message from the task.

