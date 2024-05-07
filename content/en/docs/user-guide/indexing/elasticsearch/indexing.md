---
title: "Indexing data"
linkTitle: "Indexing data"
weight: 3
date: 2022-12-15
tags:
  - elastic
  - indexing
description: >
  Indexing event data to Elasticsearch
---

A typical workflow is for a Stroom pipeline to convert XML `Event` elements into the XML equivalent of JSON, complying with the schema `http://www.w3.org/2005/xpath-functions`, using a format identical to the output of the XML function `xml-to-json()`.


## Understanding JSON XML representation

In an Elasticsearch indexing pipeline translation, you model JSON documents in a compatible XML representation.

Common JSON primitives and examples of their XML equivalents are outlined below.


### Arrays

Array of maps
```xml
<array key="users" xmlns="http://www.w3.org/2005/xpath-functions">
  <map>
    <string key="name">John Smith</string>
  </map>
</array>
```

Array of strings
```xml
<array key="userNames" xmlns="http://www.w3.org/2005/xpath-functions">
  <string>John Smith</string>
  <string>Jane Doe</string>
</array>
```


### Maps and properties

```xml
<map key="user" xmlns="http://www.w3.org/2005/xpath-functions">
  <string key="name">John Smith</string>
  <boolean key="active">true</boolean>
  <number key="daysSinceLastLogin">42</number>
  <string key="loginDate">2022-12-25T01:59:01.000Z</string>
  <null key="emailAddress" />
  <array key="phoneNumbers">
    <string>1234567890</string>
  </array>
</map>
```

{{% note %}}
It is recommended to insert a schema validation filter into your pipeline XML (with schema group `JSON`), to make it easier to diagnose JSON conversion errors.
{{% /note %}}

We will now explore how create an Elasticsearch *index template*, which specifies field mappings and settings for one or more indices.


## Create an Elasticsearch index template

For information on what index and component templates are, consult the Elastic {{< external-link "documentation" "https://www.elastic.co/guide/en/elasticsearch/reference/current/index-templates.html" >}}.

When Elasticsearch first receives a document from Stroom targeting an index, whose name matches any of the `index_patterns` entries in the index template, it will create a new index / data stream using the `settings` and `mappings` properties from the template.
In this way, the index does _not_ need to be manually created in advance.

{{% note %}}
If an index doesn't match a template when it is created, data will still be indexed - with default mappings and settings.
This may be appropriate for small indices, but with a default shard count of `5`, the indexing and search performance will likely be inadequate for large indices.
{{% /note %}}

The following example creates a basic index template `stroom-events-v1` in a local Elasticsearch cluster, with the following explicit field mappings:

1. `StreamId` -- mandatory, data type `long` or `keyword`.
1. `EventId` -- mandatory, data type `long` or `keyword`.
1. `@timestamp` -- required if the index is to be part of a {{< external-link "data stream" "https://www.elastic.co/guide/en/elasticsearch/reference/current/data-streams.html" >}} (recommended).
1. `User` -- An object containing properties `Id`, `Name` and `Active`, each with their own data type.
1. `Tags` -- An array of one or more strings.
1. `Message` -- Contains arbitrary content such as unstructured raw log data.
   Supports full-text search.
   Nested field `wildcard` {{< external-link "supports regexp queries" "https://www.elastic.co/guide/en/elasticsearch/reference/current/keyword.html#wildcard-field-type" >}}.

{{% note %}}
Elasticsearch does not have a dedicated `array` field mapping data type.
An Elasticsearch field may contain zero or more values by default.
See: {{< external-link "Arrays" "https://www.elastic.co/guide/en/elasticsearch/reference/current/array.html" >}} in the Elastic documentation.
{{% /note %}}

In Kibana Dev Tools, execute the following query:

`PUT _index_template/stroom-events-v1`

```json
{
  "index_patterns": [
    "stroom-events-v1*" // Apply this template to index names matching this pattern.
  ],
  "data_stream": {}, // For time-series data. Recommended for event data.
  "template": {
    "settings": {
      "number_of_replicas": 1, // Replicas impact indexing throughput. This setting can be changed at any time.
      "number_of_shards": 10, // Consider the shard sizing guide: https://www.elastic.co/guide/en/elasticsearch/reference/current/size-your-shards.html#shard-size-recommendation
      "refresh_interval": "10s", // How often to refresh the index. For high-throughput indices, it's recommended to increase this from the default of 1s
      "lifecycle": {
        "name": "stroom_30d_retention_policy" // (Optional) Apply an ILM policy https://www.elastic.co/guide/en/elasticsearch/reference/current/set-up-lifecycle-policy.html
      }
    },
    "mappings": {
      "dynamic_templates": [],
      "properties": {
        "StreamId": { // Required.
          "type": "long"
        },
        "EventId": { // Required.
          "type": "long"
        },
        "@timestamp": { // Required if the index is part of a data stream.
          "type": "date"
        },
        "User": {
          "properties": {
            "Id": {
              "type": "keyword"
            },
            "Name": {
              "type": "keyword"
            },
            "Active": {
              "type": "boolean"
            }
          }
        },
        "Tags": {
          "type": "keyword"
        },
        "Message": {
          "type": "text",
          "fields": {
            "wildcard": {
              "type": "wildcard"
            }
          }
        }
      }
    }
  },
  "composed_of": [
    // Optional array of component template names.
  ]
}
```


## Create an Elasticsearch indexing pipeline template

An Elasticsearch indexing pipeline is similar in structure to the built-in packaged `Indexing` template pipeline.
It typically consists of the following pipeline elements:

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "RecordCountFilter" "recordCount (read)">}}
 {{< pipe-elm "SplitFilter" >}}
 {{< pipe-elm "IdEnrichmentFilter" >}}
 {{< pipe-elm "XSLTFilter" >}}
 {{< pipe-elm "SchemaFilter" >}}
 {{< pipe-elm "ElasticIndexingFilter" >}}
 {{< pipe-elm "RecordCountFilter" "recordCount (written)">}}
{{< /pipe >}}

* {{< pipe-elm "XSLTFilter" >}} contains the translation mapping `Events` to JSON `array`.
* {{< pipe-elm "SchemaFilter" >}} uses schema group `JSON`.

It is recommended to create a template Elasticsearch indexing pipeline, which can then be re-used.


### Procedure

1. Right-click on the {{< stroom-icon "folder.svg" >}}`Template Pipelines` folder in the Stroom Explorer pane ({{< stroom-icon "folder-tree.svg" "Explorer" >}}).
1. Select:  
   {{< stroom-menu "New" "Pipeline" >}}
1. Enter the name `Indexing (Elasticsearch)` and click {{< stroom-btn "OK" >}}.
1. Define the pipeline structure as above, and customise the following pipeline elements:
   1. Set the Split Filter `splitCount` property to a sensible default value, based on the expected source XML element count (e.g. `100`).
   1. Set the Schema Filter `schemaGroup` property to `JSON`.
   1. Set the Elastic Indexing Filter `cluster` property to point to the `Elastic Cluster` document you created [earlier]({{< relref "Getting-Started.md" >}}).
   1. Set the Write Record Count filter `countRead` property to `false`.

Now you have created a template indexing pipeline, it's time to create a feed-specific pipeline that inherits this template.


## Create an Elasticsearch indexing pipeline


### Procedure

1. Right-click on a folder {{< stroom-icon "folder.svg">}} in the Stroom Explorer pane {{< stroom-icon "folder-tree.svg" "Explorer" >}}.
1. {{< stroom-menu "New" "Pipeline" >}}
1. Enter a name for your pipeline and click {{< stroom-btn "OK" >}}.
1. Click the `Inherit From` {{< stroom-icon "ellipses-horizontal.svg" Ellipsis >}} button.
1. In the dialog that appears, select the template pipeline you created named `Indexing (Elasticsearch)` and click {{< stroom-btn "OK" >}}.
1. Select the Elastic Indexing Filter pipeline element.
1. Set the `indexName` property to the name of the destination index or data stream. `indexName` may be a simple string (static) or dynamic.
1. If using dynamic index names, configure the translation to output named element(s) that will be interpolated into `indexName` for each document indexed.


### Choosing between simple and dynamic index names

Indexing data to a single, named data stream or index, is a simple and convenient way to manage data.
There are cases however, where indices may contain significant volumes of data spanning long periods - and where a large portion of indexing will be performed up-front (such as when processing a feed with a lot of historical data).
As Elasticsearch data stream indices roll over based on the current time (not event time), it is helpful to be able to partition data streams by user-defined properties such as year.
This use case is met by Stroom's dynamic index naming.

{{% note %}}
An Elasticsearch {{< external-link "data stream" "https://www.elastic.co/guide/en/elasticsearch/reference/current/data-streams.html" >}} consists of one or more backing indices, which automatically roll over once a size or date threshold are met.
This abstraction assists with the lifecycle management of time-series log data, enabling users to define time and sized-based rules that can for instance, delete indices after they reach a certain age - or move older indices to different data tiers (e.g. cold storage).
{{% /note %}}


#### Single named index or data stream

This is the simplest use case and is suitable where you want to write all data for a particular pipeline, to a single data stream or index.
Whether data is written to an actual _index_ or _data stream_ depends on your index template, specifically whether you have declared `data_stream: {}`.
If this property exists in the index template matching `indexName`, a data stream is created when the first document is indexed.
Data streams, amongst many other features, provide the option to use Elasticsearch {{< external-link "Index Lifecycle Management (ILM) policies" "https://www.elastic.co/guide/en/elasticsearch/reference/current/index-lifecycle-management.html" >}} to manage their lifecycle.

{{% note %}}
When indexing to a data stream, ensure to include a `string` field named `@timestamp` in the output JSON XML.
This is mandatory and indexing will fail if this field isn't a valid `date` value.
{{% /note %}}


#### Dynamic data stream names

With a dynamic stream name, `indexName` contains the names of elements, for example: `stroom-events-v1-{year}`.
For each document, the final index name is computed based on the values of the corresponding elements within the resulting JSON XML.
For example, if the JSON XML representation of an event consists of the following, the document will be indexed to the index or data stream named `stroom-events-v1-2022`:

```xml
<?xml version="1.1" encoding="UTF-8"?>
<array
        xmlns="http://www.w3.org/2005/xpath-functions"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.w3.org/2005/xpath-functions file://xpath-functions.xsd">
    <map>
        <number key="StreamId">3045516</number>
        <number key="EventId">1</number>
        <string key="@timestamp">2022-12-16T02:46:29.218Z</string>
        <number key="year">2022</number>
    </map>
</array>
```

This is due to the value of `/map/number[@key='year']` being `2022`.
This approach can be useful when you need to apply different ILM policies, such as maintaining older data on slower storage tiers.

{{% warning %}}
Any element names defined in `indexName` _must_ exist in the JSON XML (unless it is an empty document).
If a blank value is desired, output an empty `string` element.
{{% /warning %}}

{{% note %}}
If an element name begins with `_` (underscore), its value is _only_ used for `indexName` interpolation, and it is **not** included in the final JSON.
{{% /note %}}


##### Other applications for dynamic data stream names

Dynamic data stream names can also help in other scenarios, such as implementing fine-grained retention policies, such as deleting documents that aren't user-attributed after 12 months.
While Stroom `ElasticIndex` support data retention expressions, deleting documents in Elasticsearch by query is highly inefficient and doesn't cause disk space to be freed (this requires an index to be force-merged, an expensive operation).
A better solution therefore, is to use dynamic data stream names to partition data and assign certain partitions to specific ILM policies and/or data tiers.


##### Migrating older data streams to other data tiers

Say a feed is indexed, spanning data from 2020 through 2023.
Assuming most searches only need to query data from the current year, the data streams `stroom-events-v1-2020` and `stroom-events-v1-2021` can be moved to cold storage.
To achieve this, use {{< external-link "index-level shard allocation filtering" "https://www.elastic.co/guide/en/elasticsearch/reference/current/data-tier-shard-filtering.html" >}}.

In Kibana Dev Tools, execute the following command:

`PUT stroom-events-v1-2020,stroom-events-v1-2021/_settings`

```json
{
  "index.routing.allocation.include._tier_preference": "data_cold"
}
```

This example assumes a cold data tier has been defined for the cluster.
If the command executes successfully, shards from the specified data streams are gradually migrated to the nodes comprising the destination data tier.


## Create an indexing translation

In this example, let's assume you have event data that looks like the following:

```xml
<?xml version="1.1" encoding="UTF-8"?>
<Events
    xmlns="event-logging:3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="event-logging:3 file://event-logging-v3.5.2.xsd"
    Version="3.5.2">
  <Event>
    <EventTime>
      <TimeCreated>2022-12-16T02:46:29.218Z</TimeCreated>
    </EventTime>
    <EventSource>
      <System>
        <Name>Nginx</Name>
        <Environment>Development</Environment>
      </System>
      <Generator>Filebeat</Generator>
      <Device>
        <HostName>localhost</HostName>
      </Device>
      <User>
        <Id>john.smith1</Id>
        <Name>John Smith</Name>
        <State>active</State>
      </User>
    </EventSource>
    <EventDetail>
      <View>
        <Resource>
          <URL>http://localhost:8080/index.html</URL>
        </Resource>
        <Data Name="Tags" Value="dev,testing" />
        <Data 
          Name="Message" 
          Value="TLSv1.2 AES128-SHA 1.1.1.1 &quot;Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0&quot;" />
      </View>
    </EventDetail>
  </Event>
  <Event>
    ...
  </Event>
</Events>
```

We need to write an XSL transform (XSLT) to form a JSON document for each stream processed.
Each document must consist of an `array` element one or more `map` elements (each representing an `Event`), each with the necessary properties as per our index template.

See [XSLT Conversion]({{< relref "../../pipelines/xslt" >}}) for instructions on how to write an XSLT.

The output from your XSLT should match the following:

```xml
<?xml version="1.1" encoding="UTF-8"?>
<array
    xmlns="http://www.w3.org/2005/xpath-functions"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.w3.org/2005/xpath-functions file://xpath-functions.xsd">
  <map>
    <number key="StreamId">3045516</number>
    <number key="EventId">1</number>
    <string key="@timestamp">2022-12-16T02:46:29.218Z</string>
    <map key="User">
      <string key="Id">john.smith1</string>
      <string key="Name">John Smith</string>
      <boolean key="Active">true</boolean>
    </map>
    <array key="Tags">
      <string>dev</string>
      <string>testing</string>
    </array>
    <string key="Message">TLSv1.2 AES128-SHA 1.1.1.1 "Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0"</string>
  </map>
  <map>
    ...
  </map>
</array>
```


## Assign the translation to the indexing pipeline

Having created your translation, you need to reference it in your indexing pipeline.

1. Open the pipeline you created.
1. Select the `Structure` tab.
1. Select the {{< pipe-elm "XSLTFilter" >}} pipeline element.
1. Double-click the `xslt` property value cell.
1. Select the XSLT you created and click {{< stroom-btn "OK" >}}.
1. Click {{< stroom-icon "save.svg" "Save" >}}.


## Step the pipeline

At this point, you will want to [step the pipeline]({{< relref "../../../quick-start-guide/process/" >}}) to ensure there are no errors and that output looks as expected.


## Execute the pipeline

Create a pipeline processor and filter to run the pipeline against one or more feeds.
Stroom will distribute processing tasks to enabled nodes and send documents to Elasticsearch for indexing.

You can monitor indexing status via your Elasticsearch monitoring tool of choice.


### Detecting and handling errors

If any errors occur while a stream is being indexed, an `Error` stream is created, containing details of each failure.
`Error` streams can be found under the `Data` tab of either the indexing pipeline or receiving `Feed`.

{{% note %}}
You can filter the selected pipeline or feed to list only `Error` streams.
Click {{< stroom-icon "filter.svg" "Filter" >}} then add a condition `Type` `=` `Error`.
{{% /note %}}

Once you have addressed the underlying cause for a particular type of error (such as an incorrect field mapping), reprocess affected streams:

1. Select any `Error` streams relating for reprocessing, by clicking the relevant checkboxes in the stream list (top pane).
1. Click {{< stroom-icon "process.svg" "Process" >}}.
1. In the dialog that appears, check `Reprocess data` and click {{< stroom-btn "OK" >}}.
1. Click {{< stroom-btn "OK" >}} for any confirmation prompts that follow.

Stroom will re-send data from the selected `Event` streams to Elasticsearch for indexing.
Any existing documents matching the `StreamId` of the original `Event` stream are first deleted automatically to avoid duplication.


## Tips and tricks

### Use a common schema for your indices

An example is {{< external-link "Elastic Common Schema (ECS)" "https://www.elastic.co/guide/en/ecs/current/ecs-reference.html" >}}.
This helps users understand the purpose of each field and to build cross-index queries simpler by using a set of common fields (such as a user ID).

With this in mind, it is important that common fields also have the same data type in each index.
Component templates help make this easier and reduce the chance of error, by centralising the definition of common fields to a single *component*.


### Use a version control system (such as git) to track index and component templates

This helps keep track of changes over time and can be an important resource for both administrators and users.


### Rebuilding an index

Sometimes it is necessary to rebuild an index.
This could be due to a change in field mapping, shard count or responding to a user feature request.

To rebuild an index:

1. Drain the indexing pipeline by deactivating any processor filters and waiting for any running tasks to complete.
1. Delete the index or data stream via the Elasticsearch API or Kibana.
1. Make the required changes to the index template and/or XSL translation.
1. Create a new processor filter either from scratch or using the {{< stroom-icon "copy.svg" "Clone" >}} button.
1. Activate the new processor filter.


### Use a versioned index naming convention

As with the earlier example `stroom-events-v1`, a version number is appended to the name of the index or data stream.
If a new field is added, or some other change occurred requiring the index to be rebuilt, users would experience downtime.
This can be avoided by incrementing the version and performing the rebuild against a new index: `stroom-events-v2`.
Users could continue querying `stroom-events-v1` until it is deleted.
This approach involves the following steps:

1. Create a new Elasticsearch index template targeting the new index name (in this case, `stroom-events-v2`).
1. Create a copy of the indexing pipeline, targeting the new index in the Elastic Indexing Filter.
1. Create and activate a processing filter for the new pipeline.
1. Once indexing is complete, update the Elastic Index document to point to `stroom-events-v2`.
   Users will now be searching against the new index.
1. Drain any tasks for the original indexing pipeline and delete it.
1. Delete index `stroom-events-v1` using either the Elasticsearch API or Kibana.

If you created a data view in Kibana, you'll also want to update this to point to the new index / data stream.


{{% see-also %}}
1. [Searching an Elasticsearch index in a Dashboard]({{< relref "elastic-data-source.md" >}})
1. [Exploring data with Kibana]({{< relref "kibana.md" >}})
{{% /see-also %}}
