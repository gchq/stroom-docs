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


## Feed

A Feed is means of organising and categorising data in Stoom.
A Feed contains multiple {{< glossary "stream" "Streams" >}} of data that have been ingested into Stroom or output by a {{< glossary "Pipeline" >}}.
Typically a Feed will contain {{< glossary "Stream" "Streams" >}} of data that are all from one system and have a common data format.


## Pipeline

A Pipeline is an entity that is constructed to take a single input of stream data and process/transform it with one or more outputs.
A Pipeline can have many elements within it to read, process or transform the data flowing through it.

See [the user guide]({{< relref "docs/user-guide/pipelines" >}}) for more detail.


## Stream

A Stream is the unit of data that Stroom works with and will typically contain many {{< glossary "Event" "Events" >}}.

See [the user guide]({{< relref "docs/user-guide/concepts/streams" >}}) for more detail.


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
