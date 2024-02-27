---
title: "Pipeline Recipies"
linkTitle: "Pipeline Recipies"
weight: 10
date: 2024-02-15
tags:
  - pipeline
description: >
  A set of basic pipeline structure recipies for common use cases.
---

The following are a basic set of pipeline recipes for doing typical tasks in Stroom.
Is it not an exhaustive list as the possibilities with Pipelines are vast.
They are intended as a rough guide to get you started with building Pipelines.

## Data Ingest and Transformation

### CSV to Normalised XML

1. {{< glossary "CSV" >}} data is ingested.
1. The [Data Splitter]({{< relref "../data-splitter" >}}) parser parses the records and fields into `records` format XML using an XML based TextConverter {{< stroom-icon "document/TextConverter.svg">}} document.
1. The first XSLTFilter is used to normalise the events in `records` XML into `event-logging` XML.
1. The second XSLTFilter is used to decorate the events with additional data, e.g. `<UserDetails>` using reference data lookups.
1. The SchemaFilter ensures that the XML output by the stages of XSLT transformation conforms to the `event-logging` XMLSchema.
1. The XML events are then written out as an `Event` Stream to the Stream store.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "DSParser" "Data Splitter">}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (read)">}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "IdEnrichmentFilter" "ID" >}}
 {{< pipe-elm "XSLTFilter" "Normalise">}}
 {{< pipe-elm "XSLTFilter" "Decorate">}}
 {{< pipe-elm "SchemaFilter" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (written)">}}
 {{< pipe-elm "XMLWriter" >}}
 {{< pipe-elm "StreamAppender" >}}
{{< /pipe >}}

**Configured Content**

* {{< pipe-elm "DSParser" "Data Splitter">}} - A TextConverter {{< stroom-icon "document/TextConverter.svg">}} containing XML conforming to `data-splitter:3`.
* {{< pipe-elm "XSLTFilter" "Normalise">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming `records:2` => `event-logging:3`.
* {{< pipe-elm "XSLTFilter" "Decorate">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming `event-logging:3` => `event-logging:3`.
* {{< pipe-elm "SchemaFilter" >}} - XMLSchema `event-logging:3`


### JSON to Normalised XML

The same as ingesting CSV data above, except the input JSON is converted into an XML representation of the JSON by the JSONParser.
The _Normalise_ XSLTFilter will be specific to the format of the JSON being ingested.
The _Decorate)_ XSLTFilter will likely be identical to that used for the CSV ingest above, demonstrating reuse of pipeline element content.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "JSONParser" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (read)">}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "IdEnrichmentFilter" "ID" >}}
 {{< pipe-elm "XSLTFilter" "Normalise">}}
 {{< pipe-elm "XSLTFilter" "Decorate">}}
 {{< pipe-elm "SchemaFilter" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (written)">}}
 {{< pipe-elm "XMLWriter" >}}
 {{< pipe-elm "StreamAppender" >}}
{{< /pipe >}}

**Configured Content**

* {{< pipe-elm "XSLTFilter" "Normalise">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming `http://www.w3.org/2013/XSL/json` => `event-logging:3`.
* {{< pipe-elm "XSLTFilter" "Decorate">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming `event-logging:3` => `event-logging:3`.
* {{< pipe-elm "SchemaFilter" >}} - XMLSchema `event-logging:3`


### XML (not event-logging) to Normalised XML

As above except that the input data is already XML, though not in `event-logging` format.
The XMLParser simply reads the XML character data and converts it to XML SAX events for processing.
The _Normalise_ XSLTFilter will be specific to the format of this XML and will transform it into `event-logging` format.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (read)">}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "IdEnrichmentFilter" "ID" >}}
 {{< pipe-elm "XSLTFilter" "Normalise">}}
 {{< pipe-elm "XSLTFilter" "Decorate">}}
 {{< pipe-elm "SchemaFilter" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (written)">}}
 {{< pipe-elm "XMLWriter" >}}
 {{< pipe-elm "StreamAppender" >}}
{{< /pipe >}}

**Configured Content**

* {{< pipe-elm "XSLTFilter" "Normalise">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming _a 3rd party schema_ => `event-logging:3`.
* {{< pipe-elm "XSLTFilter" "Decorate">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming `event-logging:3` => `event-logging:3`.
* {{< pipe-elm "SchemaFilter" >}} - XMLSchema `event-logging:3`


### XML (event-logging) to Normalised XML

As above except that the input data is already in `event-logging` XML format, so no normalisation is required.
Decoration is still needed though.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (read)">}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "IdEnrichmentFilter" "ID" >}}
 {{< pipe-elm "XSLTFilter" "Decorate">}}
 {{< pipe-elm "SchemaFilter" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (written)">}}
 {{< pipe-elm "XMLWriter" >}}
 {{< pipe-elm "StreamAppender" >}}
{{< /pipe >}}

**Configured Content**

* {{< pipe-elm "XSLTFilter" "Decorate">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming `event-logging:3` => `event-logging:3`.
* {{< pipe-elm "SchemaFilter" >}} - XMLSchema `event-logging:3`


### XML Fragments to Normalised XML

XML Fragments are where the input data looks like:

```xml
<Event>
  ...
</Event>
<Event>
  ...
</Event>
```

In other words, it is technically badly formed XML as it has no root element or declaration.
This format is however easier for client systems to send as they can send multiple `<Event>` blocks in one stream (e.g. just appending them together in a rolled log file) but don't need to wrap them with an outer `<Events>` element.

The XMLFragmentParser understands this format and will add the wrapping element to make well-formed XML.
If the XML fragments are already in `event-logging` format then no _Normalise_ XSLTFilter is required.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLFragmentParser" "XMLFragParser" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (read)">}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "IdEnrichmentFilter" "ID" >}}
 {{< pipe-elm "XSLTFilter" "Decorate">}}
 {{< pipe-elm "SchemaFilter" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (write)">}}
 {{< pipe-elm "XMLWriter" >}}
 {{< pipe-elm "StreamAppender" >}}
{{< /pipe >}}

**Configured Content**

* {{< pipe-elm "XMLFragmentParser" "XMLFragParser">}} - Content similar to:
  ```xml
  <?xml version="1.1" encoding="utf-8"?>
  <!DOCTYPE Records [
  <!ENTITY fragment SYSTEM "fragment">]>
  <Events
      xmlns="event-logging:3"
      xmlns:stroom="stroom"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="event-logging:3 file://event-logging-v3.4.2.xsd"
      Version="3.4.2">
  &fragment;
  </Events>
  ```
* {{< pipe-elm "XSLTFilter" "Decorate">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming `event-logging:3` => `event-logging:3`.
* {{< pipe-elm "SchemaFilter" >}} - XMLSchema `event-logging:3`


## Handling Malformed Data

### Cleaning Malformed XML data

In some cases client systems may send XML containing characters that are not supported by the XML standard.
These can be removed using the {{< pipe-elm "InvalidXMLCharFilterReader" >}}.

The input data may also be known to contain other sets of characters that will cause problems in processing.
The {{< pipe-elm "FindReplaceFilter" >}} can be used to remove/replace either a fixed string or a Regex pattern.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "InvalidXMLCharFilterReader" >}}
 {{< pipe-elm "FindReplaceFilter" >}}
 {{< pipe-elm "XMLParser" >}}
{{< /pipe >}}
[Pipeline truncated]


## Raw Streaming

In cases where you want to export the raw (or cooked) data from a feed you can have a very simply pipeline to pipe the source data directly to an appender.
This may be so that the raw data can be ingested into another system for analysis.
In this case the data is being written to disk using a file appender.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "FileAppender" >}}
{{< /pipe >}}

{{% note %}}
Be careful when specifying the directory structure for the _FileAppender_ so that you don’t end up with too many files in one folder, which can cause some OS issues.
{{% /note %}}


## Indexing

### XML to Stroom Lucene Index

This use case is for indexing XML event data that had already been normalised using one of the ingest pipelines above.
The {{< pipe-elm "XSLTFilter">}} is used to transform the event into `records` format, extracting the fields to be indexed from the event.
The {{< pipe-elm "IndexingFilter">}} reads the `records` XML and loads each one into Stroom's internal Lucene index {{< stroom-icon "document/Index.svg">}}.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (read)">}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "IdEnrichmentFilter" "ID" >}}
 {{< pipe-elm "XSLTFilter" >}}
 {{< pipe-elm "SchemaFilter" >}}
 {{< pipe-elm "IndexingFilter" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (written)">}}
{{< /pipe >}}

**Configured Content**

* {{< pipe-elm "XSLTFilter">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming  `event-logging:3` => `records:2`.
* {{< pipe-elm "SchemaFilter" >}} - XMLSchema `records:2`

The `records:2` XML looks something like this, with each `<data>` element representing an indexed field value.

```xml
<?xml version="1.1" encoding="UTF-8"?>
<records 
    xmlns="records:2"
    xmlns:stroom="stroom"
    xmlns:sm="stroom-meta"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="records:2 file://records-v2.0.xsd"
    version="2.0">
  <record>
    <data name="StreamId" value="1997" />
    <data name="EventId" value="1" />
    <data name="Feed" value="MY_FEED" />
    <data name="EventTime" value="2010-01-01T00:00:00.000Z" />
    <data name="System" value="MySystem" />
    <data name="Generator" value="CSV" />
    <data name="IPAddress" value="1.1.1.1" />
    <data name="UserId" analyzer="KEYWORD" value="user1" />
    <data name="Action" value="Authenticate" />
    <data name="Description" value="Some message 1" />
  </record>
</records>
```


### XML to Stroom Lucene Index (Dynamic)

Dynamic indexing in Stroom allows you to use the XSLT to define the fields that are being indexed and how each field should be indexed.
This avoids having to define all the fields up front in the Index {{< stroom-icon "document/Index.svg">}} and allows for the creation of fields based on the actual data received.
The only difference with normal indexing in Stroom is that is uses the {{< pipe-elm "DynamicIndexingFilter" >}} and rather than transforming the event into `records:2` XML, it is transformed into `index-documents:1` XML as shown in the example below.

```xml
<?xml version="1.1" encoding="UTF-8"?>
<index-documents
    xmlns="index-documents:1"
    xmlns:stroom="stroom"
    xmlns:sm="stroom-meta"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="index-documents:1 file://index-documents-v1.0.xsd"
    version="1.0">
  <document>
    <field><name>StreamId</name><type>Id</type><indexed>true</indexed><stored>true</stored><value>1997</value></field>
    <field><name>EventId</name><type>Id</type><indexed>true</indexed><stored>true</stored><value>1</value></field>
    <field><name>Feed</name><type>Text</type><analyser>Alpha numeric</analyser><indexed>true</indexed><value>MY_FEED</value></field>
    <field><name>EventTime</name><type>Date</type><indexed>true</indexed><value>2010-01-01T00:00:00.000Z</value></field>
    <field><name>System</name><type>Text</type><analyser>Alpha numeric</analyser><indexed>true</indexed><value>MySystem</value></field>
    <field><name>Generator</name><type>Text</type><analyser>Alpha numeric</analyser><indexed>true</indexed><value>CSV</value></field>
    <field><name>IPAddress</name><type>Text</type><indexed>true</indexed><value>1.1.1.1</value></field>
    <field><name>UserId</name><type>Text</type><indexed>true</indexed><value>user1</value></field>
    <field><name>Action</name><type>Text</type><analyser>Alpha numeric</analyser><indexed>true</indexed><value>Authenticate</value></field>
    <field><name>Description</name><type>Text</type><analyser>Alpha numeric</analyser><indexed>true</indexed><value>Some message 1</value></field>
  </document>
</index-documents>
```


{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (read)">}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "IdEnrichmentFilter" "ID" >}}
 {{< pipe-elm "XSLTFilter" >}}
 {{< pipe-elm "SchemaFilter" >}}
 {{< pipe-elm "DynamicIndexingFilter" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (written)">}}
{{< /pipe >}}

**Configured Content**

* {{< pipe-elm "XSLTFilter">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming `event-logging:3` => `index-documents:1`.
* {{< pipe-elm "SchemaFilter" >}} - XMLSchema `index-documents:1`


### XML to an Elastic Search Index

This use case is for indexing XML event data that had already been normalised using one of the ingest pipelines above.
The {{< pipe-elm "XSLTFilter">}} is used to transform the event into `records` format, extracting the fields to be indexed from the event.
The {{< pipe-elm "ElasticIndexingFilter">}} reads the `records` XML and loads each one into an external Elasticsearch index {{< stroom-icon "document/ElasticIndex.svg">}}.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (read)">}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "IdEnrichmentFilter" "ID" >}}
 {{< pipe-elm "XSLTFilter" >}}
 {{< pipe-elm "SchemaFilter" >}}
 {{< pipe-elm "ElasticIndexingFilter" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (written)">}}
{{< /pipe >}}

**Configured Content**

* {{< pipe-elm "XSLTFilter">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming  `event-logging:3` => `records:2`.
* {{< pipe-elm "SchemaFilter" >}} - XMLSchema `records:2`


## Search Extraction

Search extraction is the process of combining the data held in the index with data obtained from the original indexed document, i.e. the event.
Search extraction is useful when you do not want to store the whole of an event in the index (to reduce storage used) but still want to be able to access all the event data in a Dashboard/View.
An extraction pipeline is required to combine data in this way.
Search extraction pipelines are referenced in Dashboard and View settings.


### Standard Lucene Index Extraction

This is a non-dynamic search extraction pipeline for a Lucene index.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "IdEnrichmentFilter" "ID" >}}
 {{< pipe-elm "XSLTFilter" >}}
 {{< pipe-elm "SearchResultOutputFilter" >}}
{{< /pipe >}}

**Configured Content**

* {{< pipe-elm "XSLTFilter">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming  `event-logging:3` => `records:2`.


### Dynamic Lucene Index Extraction

This is a dynamic search extraction pipeline for a Lucene index.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "IdEnrichmentFilter" "ID" >}}
 {{< pipe-elm "XSLTFilter" >}}
 {{< pipe-elm "DynamicSearchResultOutputFilter" >}}
{{< /pipe >}}

**Configured Content**

* {{< pipe-elm "XSLTFilter">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming `event-logging:3` => `index-documents:1`.


## Data Egress

### XML to CSV File

An recipe of writing normalised XML events (as produced by an ingest pipeline above) to a file, but in a flat file format like CSV.
The {{< pipe-elm "XSLTFilter">}} transforms the events XML into CSV data with XSLT including this:

```xml
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
```

The {{< pipe-elm "TextWriter" >}} converts the XML character events into a stream of characters encoded using the desired output character encoding.
The data is appended to a file on a file system, with one file per Stream.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (read)">}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "IdEnrichmentFilter" "ID" >}}
 {{< pipe-elm "XSLTFilter" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (written)">}}
 {{< pipe-elm "TextWriter" >}}
 {{< pipe-elm "FileAppender" >}}
{{< /pipe >}}

**Configured Content**

* {{< pipe-elm "XSLTFilter">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming `event-logging:3` => _schemaless plain text_.
* {{< pipe-elm "SchemaFilter" >}} - XMLSchema `records:2`


### XML to JSON Rolling File

This is similar to the above recipe for writing out CSV, except that the {{< pipe-elm "XSLTFilter">}} converts the event XML into XML conforming to the {{< external-link "https://www.w3.org/2013/XSL/json/">}} XMLSchema.
The {{< pipe-elm "JSONWriter" >}} can read this format of XML and convert it into JSON using the desired character encoding.
The {{< pipe-elm "RollingFileAppender" >}} will append the encoded JSON character data to a file on the file system that is rolled based on a size/time threshold.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (read)">}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "IdEnrichmentFilter" "ID" >}}
 {{< pipe-elm "XSLTFilter" >}}
 {{< pipe-elm "SchemaFilter" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (written)">}}
 {{< pipe-elm "JSONWriter" >}}
 {{< pipe-elm "RollingFileAppender" >}}
{{< /pipe >}}

**Configured Content**

* {{< pipe-elm "XSLTFilter">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming `event-logging:3` => `http://www.w3.org/2013/XSL/json`.
* {{< pipe-elm "SchemaFilter" >}} - XMLSchema `http://www.w3.org/2013/XSL/json`.


### XML to HTTP Destination

This recipe is for sending normalised XML events to another system over HTTP.
The {{< pipe-elm "HTTPAppender" >}} is configured with the URL and any {{< glossary "transport-layer-security-tls" "TLS" >}} certificates/keys/credentials.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (read)">}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "RecordCountFilter" "Rec Count (written)">}}
 {{< pipe-elm "XMLWriter" >}}
 {{< pipe-elm "HTTPAppender" >}}
{{< /pipe >}}


## Reference Data

### Reference Loader

A typical pipeline for loading XML [reference data]({{< relref "reference-data" >}}) (conforming to the `reference-data:2` XMLSchema) into the reference data store.
The {{< pipe-elm "ReferenceDataFilter" >}} reads the `reference-data:2` format data and loads each entry into the appropriate map in the store.

As an example, the `reference-data:2` XML for mapping userIDs to staff numbers looks something like this:

```xml
<?xml version="1.1" encoding="UTF-8"?>
<referenceData
    xmlns="reference-data:2"
    xmlns:evt="event-logging:3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="reference-data:2 file://reference-data-v2.0.1.xsd"
    version="2.0.1">
  <reference>
    <map>USER_ID_TO_STAFF_NO_MAP</map>
    <key>user1</key>
    <value>staff1</value>
  </reference>
  <reference>
    <map>USER_ID_TO_STAFF_NO_MAP</map>
    <key>user2</key>
    <value>staff2</value>
  </reference>
  ...
</referenceData>
```

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "ReferenceDataFilter" >}}
{{< /pipe >}}


## Statistics

This recipe converts normalised XML data and converts it into statistic events (confirming to the `statistics:4` XMLSchema).
Stroom's Statistic Stores {{< stroom-icon "document/StatisticStore.svg">}} are a way to store aggregated counts or averaged values over time periods.
For example you may want counts of certain types of event, aggregated over fixed time buckets.
Each XML event is transformed using the {{< pipe-elm "XSLTFilter" >}} to either return no output or a statistic event.
An example of `statistics:4` data for two statistic events is:

```xml
<?xml version="1.1" encoding="UTF-8"?>
<statistics
    xmlns="statistics:2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="statistics:2 file://statistics-v2.0.xsd">
  <statistic>
    <time>2023-12-22T00:00:00.000Z</time>
    <count>1</count>
    <tags>
      <tag name="user" value="user1" />
    </tags>
  </statistic>
  <statistic>
    <time>2023-12-23T00:00:00.000Z</time>
    <count>5</count>
    <tags>
      <tag name="user" value="user6" />
    </tags>
  </statistic>
</statistics>
```

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "SplitFilter" "Split" >}}
 {{< pipe-elm "XSLTFilter" >}}
 {{< pipe-elm "SchemaFilter" >}}
 {{< pipe-elm "StatisticsFilter">}}
{{< /pipe >}}

**Configured Content**

* {{< pipe-elm "XSLTFilter">}} - An XSLT {{< stroom-icon "document/XSLT.svg">}} transforming `event-logging:3` => `statistics:2`.
* {{< pipe-elm "SchemaFilter" >}} - XMLSchema `statistics:2`.

