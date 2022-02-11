---
title: "Glossary"
linkTitle: "Glossary"
weight: 80
date: 2022-02-02
tags: 
description: >
  Glossary of common words and tems used in Stroom.

---

## API

Application Programming Interface.
An interface that one system can present so other systems can use it to communicate.
Stroom has a number of APIs, e.g. its many REST APIs and its `/datafeed` interface for data receipt.


## Field

A named data Field within some form of record, and within such a record, each Field can have a value.
In Stroom Fields can be the Fields in an {{< glossary "Index" >}} or other queryable {{< glossary "Datasource" >}} or the fields of {{< glossary "Meta Data" >}} associated with a {{< glossary "Stream" >}}, e.g. Stream ID, {{< glossary "Feed" >}}, creation time, etc.


## Dashboard

{{% todo %}}
text
{{% /todo %}}


## Data Source

The source of data for a {{< glossary "Query" >}}, e.g. a Lucene based {{< glossary "Index" >}}, a SQL Statistics Data source, etc.


## Data Splitter
Data Splitter is a {{< glossary "pipeline" >}} element for converting text data (e.g. CSV, fixed width, delimited, multi-line) into XML for onward processing.

See [Data the user guide]({{< relref "docs/user-guide/data-splitter" >}}) for more detail.


## Document

Typically refers to an item that can be created in the Explorer Tree, e.g. a Feed, a Pipeline, a Dashboard, etc. May also be known as an {{< glossary "Entity" >}}.


## Entity

Typically refers to an item that can be created in the Explorer Tree, e.g. a Feed, a Pipeline, a Dashboard, etc. May also be known as a {{< glossary "Document" >}}.


## Event

{{% todo %}}
Complete
{{% /todo %}}


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

See also [Dashboard Expressions]({{< relref "expressions" >}}).


## Feed

A Feed is means of organising and categorising data in Stoom.
A Feed contains multiple {{< glossary "stream" "Streams" >}} of data that have been ingested into Stroom or output by a {{< glossary "Pipeline" >}}.
Typically a Feed will contain {{< glossary "Stream" "Streams" >}} of data that are all from one system and have a common data format.


## Filter (Processor)

See {{< glossary "Processor Filter" >}}.


## Pipeline

A Pipeline is an entity that is constructed to take a single input of stream data and process/transform it with one or more outputs.
A Pipeline can have many elements within it to read, process or transform the data flowing through it.

See [the user guide]({{< relref "docs/user-guide/pipelines" >}}) for more detail.


## Pipeline Element

An element within a {{< glossary "Pipeline" >}} that performs some action on the data flowing through it.

See the [Pipeline Element Reference]({{< relref "user-guide/pipelines/element-reference" >}}) for more detail.


## Processor

A Processor belongs to a {{< glossary "Pipeline" >}}.
It controls the processing of data through its parent Pipeline.
The Processor can be enabled/disabled to enable/disable the processing of data through the Pipeline.
A processor will have one or more {{< glossary "Processor Filter" "Processor Filters" >}} associated with it.


## Processor Filter

A Processor Filter consists of an expression tree to select which {{< glossary "Stream" "Streams" >}} to process.
For example a typical Processor Filter would have an Expression Tree that selected all Streams of type _Raw Events_ in a particular {{< glossary "Feed" >}}.
A filter could also select a single Stream by its ID, e.g. when {{< glossary "Re-Processing" >}} a Stream.
The filter is used to find Streams to process through the {{< glossary "Pipeline" >}} associated with the Processor Filter.
A Pipeline can have multiple Processor Filters.
Filters can be enabled/disabled independantly of their parent Processor to controll processing.


## Property

A configuration Property for configuring Stroom.
Properties can be set via _Tools_ => _Properties_ in the user interface or via the `config.yml` configuration file.

See [Properties]({{< relref "Properties" >}}) for more detail.


## Query

The search Query in a {{< glossary "Dashboard" >}} that selects the data to display.
The Query is constructed using an {{< glossary "Expression Tree" >}} of terms.

See [the user guide]({{< relref "user-guide/dashboards/queries" >}}) for more detail.


## Re-Processing

The act of repeating the processing of a set of input data ({{< glossary "Stream" "Streams" >}}) that have already been processed at least once.
Re-Processing can be done for an individual Stream or multiple Streams using a {{< glossary "Processor Filter" >}}.


## Stream

A Stream is the unit of data that Stroom works with and will typically contain many {{< glossary "Event" "Events" >}}.

See [the user guide]({{< relref "docs/user-guide/concepts/streams" >}}) for more detail.


## Stream Type

All {{< glossary "Stream" "Streams" >}} must have an Stream Type.
The list of Stream Types is configured using the {{< glossary "Property" >}} `stroom.data.meta.metaTypes`.
Additional Stream Types can be added however the list of Stream Types must include the following built-in types: 

`Context`  
`Error`  
`Events`  
`Meta`  
`Raw Events`  
`Raw Reference`  
`Reference`

Some Stream Types, such as `Meta` and `Context` only exist as [child streams]({{< relref "user-guide/concepts/streams#child-stream-types" >}}) within another Stream.


## Tracker

A Tracker is associated with a {{< glossary "Processor Filter" >}} and keeps track of the {{< glossary "Stream" "Streams" >}} that the Processor Filter has already processed.


## XSLT
E**x**tensible **S**tylesheet **L**anguage **T**ransformations is a language for transforming XML documents into other XML documents.
XSLTs are the primary means of transforming data in Stroom.
All data is converted into a basic form of XML and then XSLTs are used to decorate and transform it into a commonform.
XSLTs are also used to transform XML {{< glossary "Event" >}} data into non-XML forms or XML with a different schema for indexing, statistics or for sending to other systems.

See [the user guide]({{< relref "/docs/user-guide/pipelines/xslt" >}}) for more detail.





{{% todo %}}
Event  
Pipeline  
Translation  
Headers  
Filter  
Writer  
Destination  
Index  
Task  
Property  
Processor Filter
{{% /todo %}}
