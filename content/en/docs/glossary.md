---
title: "Glossary"
linkTitle: "Glossary"
weight: 80
date: 2022-02-16
tags: 
description: >
  Glossary of common words and terms used in Stroom.

---

## API

Application Programming Interface.
An interface that one system can present so other systems can use it to communicate.
Stroom has a number of APIs, e.g. its many REST APIs and its `/datafeed` interface for data receipt.


## API Key

A key or token for authenticating with the {{< glossary "API" >}}.
It is an encrypted string that contains details of the user and the expiration date of the token.
Possession of a valid API Key for a user account means that you can do anything that the user can do in the user interface via the API.
API Keys should therefore be protected carefully and treated like a password.


## Byte Order Mark

A special Unicode character at the start of a text stream that indicates the byte order (or endianness) of the stream.

See [Byte Order Mark]({{< relref "docs/sending-data/data-formats/character-encoding" >}}) for more detail.


## Condition

A Condition in an query expression term, e.g. `=`, `>`, `in`, etc.


## Content

Content in Stroom typically means the documents/entities created Stroom and as seen in the explorer tree.
Content can be created/modified by Stroom users and imported/exported for sharing between different Stroom instances.


## Dashboard

A Dashboard is a configurable entity for querying one or more {{< glossary "Data Source" "Data Sources">}} and displaying the results as a table, a visualisation or some other form.

See the [User Guide]({{< relref "docs/user-guide/dashboards" >}}) for more detail.


## Data Source

The source of data for a {{< glossary "Query" >}}, e.g. a Lucene based {{< glossary "Index" >}}, a SQL Statistics Data source, etc.
There are three types of Data source:

* {{< stroom-icon "document/Index.svg" "Index" >}} Lucene based search index data sources.
* {{< stroom-icon "document/StatisticStore.svg" "SQL Statistics" >}} Stroom's SQL Statistics data sources.
* {{< stroom-icon "document/searchable.svg" "Searchable" >}} Searchable data sources for searching the internals of Stroom.

A data source will have a {{< glossary "DocRef" >}} to identify it and will define the set of {{< glossary "Field" "Fields" >}} that it presents.
Each Field will have:
* A name
* A set of {{< glossary "Condition" "Conditions" >}} that it supports.
  E.g. a `Feed` field would likely support `is` but not `>`.
* A flag to indicate if it is queryable or not.
  I.e. a queryable field could be referenced in the query expression tree and in a {{< glossary "Dashboard" >}} table, but a non-queryable field could only be referenced in the Dashboard table.


## Data Splitter

Data Splitter is a {{< glossary "pipeline" >}} element for converting text data (e.g. CSV, fixed width, delimited, multi-line) into XML for onward processing.

See the [User Guide]({{< relref "docs/user-guide/data-splitter" >}}) or the [Pipeline Element Reference]({{< relref "user-guide/pipelines/element-reference/#dsparser" >}}) for more detail.


## Dictionary

A entity for storing static content, e.g. lists of terms for use in a query with the `in dictionary` condition.
They can also be used to hold arbitrary text for use in {{< glossary "XSLT" "XSLTs" >}} with the [dictionary()]({{< relref "user-guide/pipelines/xslt/xslt-functions#dictionary" >}})


## DocRef

A DocRef is an identifier used to identify most documents/entities in Stroom, e.g. An XSLT will have a DocRef.
It is comprised of the following parts:

* {{< glossary "UUID" >}} - A Universally Unique Identifier to uniquely identify the document/entity.
* Type - The type of the document/entity, e.g. `Index`, `XSLT`, `Dashboard`, etc.
* Name - The name given to the document/entity.

DocRefs are used heavily in the [REST API]({{< relref "user-guide/api" >}}) for identifying the document/entity to be acted on.


## Document

Typically refers to an item that can be created in the Explorer Tree, e.g. a Feed, a Pipeline, a Dashboard, etc. May also be known as an {{< glossary "Entity" >}}.


## Elasticsearch

{{< external-link "Elasticsearch" "https://www.elastic.co/elasticsearch/" >}} is an Open Source and commercial search index product.
Stroom can be connected to one or more Elasticsearch clusters so that event indexing and search is handled by Elasticsearch rather than internally.


## Entity

Typically refers to an item that can be created in the Explorer Tree, e.g. a Feed, a Pipeline, a Dashboard, etc. May also be known as a {{< glossary "Document" >}}.


## Events

This is a {{< glossary "Stream Type" >}} in Stroom.
An _Events_ stream consists of processed/cooked data that has been demarcated into individual Events.
Typically in Stroom an _Events_ stream will contain data conforming to the {{< external-link "event-logging XML Schema" "https://github.com/gchq/event-logging-schema" >}} which provides a normalised form for all {{< glossary "Raw Events" >}} to be transformed into.


## Explorer Tree

The left hand navigation tree.
The Explorer Tree is used for finding, opening, creating, renaming, copying, moving and deleting {{< glossary "Entity" "Entities" >}}.
It can also be used to control the access permissions of entities and folders.
The tree can be filtered using the quick filter, see [Finging Things]({{< relref "finding-things.md" >}}) for more details.


## Expression Tree

A tree of expression terms that each evaluate to a boolean (True/False) value.
Terms can be grouped together within an expression operator (AND, OR, NOT).
For example:

```text
AND (
  Feed is CSV_FEED
  Type = Raw Events
)
```
Expression Trees are used in {{< glossary "Processor Filter" "Processor Filters" >}} and {{< glossary "Query" >}} expressions.

See also [Dashboard Expressions]({{< relref "docs/user-guide/dashboards/expressions" >}}).


## Feed

A Feed is means of organising and categorising data in Stroom.
A Feed contains multiple {{< glossary "stream" "Streams" >}} of data that have been ingested into Stroom or output by a {{< glossary "Pipeline" >}}.
Typically a Feed will contain {{< glossary "Stream" "Streams" >}} of data that are all from one system and have a common data format.


## Field

A named data Field within some form of record or entity, and where each Field can have an associated value.
In Stroom Fields can be the Fields in an {{< glossary "Index" >}} (or other queryable {{< glossary "Datasource" >}}) or the fields of {{< glossary "Meta Data" >}} associated with a {{< glossary "Stream" >}}, e.g. Stream ID, {{< glossary "Feed" >}}, creation time, etc.


## Filter (Processor)

See {{< glossary "Processor Filter" >}}.


## FQDN

The {{< external-link "Fully Qualified Domain Name" "https://en.wikipedia.org/wiki/Fully_qualified_domain_name" >}} of a device, i.e. `server57.some.domain.com`.


## IDP

An {{< external-link "Identiy Provider (IDP)" "https://en.wikipedia.org/wiki/Identity_provider" >}} is a system that manages the identity information of principles (typically users) and provides authentication services to systems (like Stroom).

Examples of IDPs are Amazon Cognito, Microsoft Azure/Entra AD and Keycloak.


## Markdown

*Markdown* is a markup language for creating formatted text using a simple text editor.
Stroom uses the {{< external-link "Showdown" "https://github.com/showdownjs/showdown/wiki/Showdown's-Markdown-syntax" >}} markdown converter to render users' markdown content into formatted text.

{{% note %}}
Markdown is a somewhat loose standard so different markdown processors support different amounts of markdown syntax.
For a definitive guide to the syntax supported in Stroom, see the above link.
{{% /note %}}


## Parser

A Parser is a {{< glossary "Pipeline" >}} element for parsing {{< glossary "Raw Events" >}} into a structured form.
For example the Data Splitter Parser that parses text data into {{< glossary "Records" >}} and {{< glossary "Field" "Fields">}}.

See the [Pipeline Element Reference]({{< relref "user-guide/pipelines/element-reference/#parser" >}}) for details.


## Pipeline

A Pipeline is an entity that is constructed to take a single input of stream data and process/transform it with one or more outputs.
A Pipeline can have many elements within it to read, process or transform the data flowing through it.

See the [User Guide]({{< relref "docs/user-guide/pipelines" >}}) for more detail.


## Pipeline Element

An element within a {{< glossary "Pipeline" >}} that performs some action on the data flowing through it.

See the [Pipeline Element Reference]({{< relref "user-guide/pipelines/element-reference" >}}) for more detail.


## Processor

A Processor belongs to a {{< glossary "Pipeline" >}}.
It controls the processing of data through its parent Pipeline.
The Processor can be enabled/disabled to enable/disable the processing of data through the Pipeline.
A processor will have one or more {{< glossary "Processor Filter" "Processor Filters" >}} associated with it.


## Processor Filter

A Processor Filter consists of an expression tree to select which {{< glossary "Stream" "Streams" >}} to process through its parent {{< glossary "Pipeline" >}}.
For example a typical Processor Filter would have an Expression Tree that selected all Streams of type _Raw Events_ in a particular {{< glossary "Feed" >}}.
A filter could also select a single Stream by its ID, e.g. when {{< glossary "Re-Processing" >}} a Stream.
The filter is used to find Streams to process through the {{< glossary "Pipeline" >}} associated with the Processor Filter.
A Pipeline can have multiple Processor Filters.
Filters can be enabled/disabled independently of their parent Processor to control processing.


## Property

A configuration Property for configuring Stroom.
Properties can be set via in the user interface or via the `config.yml` configuration file.

See [Properties]({{< relref "Properties" >}}) for more detail.


## Query

The search Query in a {{< glossary "Dashboard" >}} that selects the data to display.
The Query is constructed using an {{< glossary "Expression Tree" >}} of terms.

See the [User Guide]({{< relref "user-guide/dashboards/queries" >}}) for more detail.


## Raw Events

This is a {{< glossary "Stream Type" >}} used for {{< glossary "Stream" "Streams" >}} received by Stroom.
Streams received by Stroom will be in a variety of text formats (CSV, delimited, fixed width, XML, JSON, etc.).
Until they have been processed by a pipeline they are essentially just unstructured character data with no concept of what is a record/event.
A {{< glossary "Parser" >}} in a pipeline is required to provide the demarcation between records/events.


## Re-Processing

The act of repeating the processing of a set of input data ({{< glossary "Stream" "Streams" >}}) that have already been processed at least once.
Re-Processing can be done for an individual Stream or multiple Streams using a {{< glossary "Processor Filter" >}}.


## Records

This is a {{< glossary "Stream Type" >}} for {{< glossary "Stream" "Streams" >}} containing data conforming to the {{< external-link "records:2 XML Schema" "https://github.com/gchq/stroom-content/blob/master/source/core-xml-schemas/stroomContent/XML%20Schemas/records/records%20v2.0.XMLSchema.data.xsd" >}}.
It also refers more generally to XML conforming to the `records:2` XML Schema which is used in a number of places in Stroom, including as the output format for the {{< element "DSParser" >}} and input for the {{< element "IndexingFilter" >}}.


## Searchable

A _Searchable_ is the term given the special searchable data sources that appear at the root of the explorer tree picker when selecting a data source.
These data sources are special internal data sources that are not user managed content, unlike an {{< glossary "Index" >}}.
They provide the means to search various aspects of Stroom's internals, such as the _Meta Store_ or _Processor Tasks_.


## Search Extraction

The process of extracting un-indexed {{< glossary "Field" >}} values from the source {{< glossary "Event" >}}/Record to be used in search results.

See the [User Guide]({{< relref "docs/user-guide/dashboards/search-extraction" >}}) for more detail.


## Stream

A Stream is the unit of data that Stroom works with and will typically contain many {{< glossary "Event" "Events" >}}.

See the [User Guide]({{< relref "docs/user-guide/concepts/streams" >}}) for more detail.


## Stream Type

All {{< glossary "Stream" "Streams" >}} must have an Stream Type.
The list of Stream Types is configured using the {{< glossary "Property" >}} `stroom.data.meta.metaTypes`.
Additional Stream Types can be added however the list of Stream Types must include the following built-in types: 

* Context
* Error
* {{< glossary "Events" >}}
* Meta
* {{< glossary "Raw Events" >}}
* Raw Reference
* Reference

Some Stream Types, such as `Meta` and `Context` only exist as [child streams]({{< relref "user-guide/concepts/streams#child-stream-types" >}}) within another Stream.


## Stepper

The Stepper is a tool in Stroom for developing and debugging a {{< glossary "Pipeline" >}}.
It allows the user to simulate passing a {{< glossary "Stream" >}} through a pipeline with the ability to _step_ from one record/event to the next or to jump to records/events based on filter criteria.
The parsers and translations can be edited while in the Stepper with the element output updating to show the effect of the change.
The stepper will not write data to the file system or stream stores.


## Transport Layer Security (TLS)

TLS is the evolution of Secure Sockets Layer (SSL) and refers to the encryption of traffic between client and server.


## Tracker

A Tracker is associated with a {{< glossary "Processor Filter" >}} and keeps track of the {{< glossary "Stream" "Streams" >}} that the Processor Filter has already processed.


## UTC

{{< external-link "UTC (Coordinated Universal Time)" "https://en.wikipedia.org/wiki/Coordinated_Universal_Time" >}}, also known as Zulu time, is the international standard by which the world regulates clocks and time.
It is essentially a successor to Greenwich Mean Time (GMT).
UTC has the timezone offset of `+00:00`.
All international time zones are relative to UTC.

Stroom currently works internally in UTC, though it is possible to change the display time zone via User Preferences to display times in another timezone.


## UUID 

A Universally Unique Identifier for uniquely identifying something.
UUIDs are used as the identifier in {{< glossary "DocRef" "DocRefs" >}}.
An example of a UUID is `4ffeb895-53c9-40d6-bf33-3ef025401ad3`.

See the [User Guide]({{< relref "user-guide/dashboards" >}}) for more detail.


## Visualisation

A document comprising some Javascript code for visualising data, e.g. pie charts, heat maps, line graphs etc.
Visualisations are not baked into Stroom, they are content, so can be created/modified/shared by Stroom users.


## Volume

In Stroom a Volume is a logical storage area that Stroom can write data to.
Volumes are associated with a path on a file system that can either be local to the Stroom node or on a shared file system.
Stroom has two types of Volume; Index Volumes and Data Volumes.

* _Index Volume_ - Where the Lucene Index Shards are written to.
  An Index Volume must belong to a {{< glossary "Volume Group" >}}.
* _Data Volume_ - Where streams are written to.
  When writing {{< glossary "Stream" >}} data Stroom will pick a data volume to using a volume selector as configured by the {{< glossary "Property" >}} `stroom.data.filesystemVolume.volumeSelector`.

See the [User Guide]({{< relref "user-guide/volumes" >}}) for more detail.


## Volume Group

A Volume Group is a collection of one or more Index Volumes.
Index volumes must belong to a volume group and Indexes are configured to write to a particular Volume Group.
When Stroom is write data to a Volume Group it will choose which if the Volumes in the group to write to using a volume selector as configured by the {{< glossary "Property" >}} `stroom.volumes.volumeSelector`.

See the [User Guide]({{< relref "user-guide/volumes" >}}) for more detail.


## XSLT
E**x**tensible **S**tylesheet **L**anguage **T**ransformations is a language for transforming XML documents into other XML documents.
XSLTs are the primary means of transforming data in Stroom.
All data is converted into a basic form of XML and then XSLTs are used to decorate and transform it into a common form.
XSLTs are also used to transform XML {{< glossary "Events" >}} data into non-XML forms or XML with a different schema for indexing, statistics or for sending to other systems.

See the [User Guide]({{< relref "user-guide/pipelines/xslt" >}}) for more detail.


<!-- TODO
Event  
Pipeline  
Translation  
Headers  
Filter  
Writer  
Destination  
Index  
Task  
-->
