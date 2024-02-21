---
title: "Pipelines"
linkTitle: "Pipelines"
weight: 110
date: 2021-07-27
tags: 
  - pipeline
  - processing
description: >
  Pipelines are the mechanism for processing and transforming ingested data.
---

Stroom uses Pipelines to process its data.
A pipeline is a set of [pipeline elements]({{< relref "element-reference" >}}) connected together.
Pipelines are very powerful and flexible and allow the user to transform, index, store and forward data in a wide variety of ways.


## Example Pipeline

Pipelines can take many forms and be used for a wide variety of purposes, however a typical pipeline to convert CSV data into cooked events might look like this:

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "DSParser" >}}
 {{< pipe-elm "RecordCountFilter" "recordCount (read)">}}
 {{< pipe-elm "SplitFilter" >}}
 {{< pipe-elm "IdEnrichmentFilter" >}}
 {{< pipe-elm "XSLTFilter" >}}
 {{< pipe-elm "SchemaFilter" >}}
 {{< pipe-elm "RecordCountFilter" "recordCount (written)">}}
 {{< pipe-elm "XMLWriter" >}}
 {{< pipe-elm "StreamAppender" >}}
{{< /pipe >}}


## Input Data

Pipelines process data in batches.
This batch of data is referred to as a {{< glossary "Stream" >}}.
The input for the pipeline is a single Stream that exists within a Feed and this data is fed into the left-hand side of the pipeline at {{< pipe-elm "Source" >}}.
Pipelines can accept streams from multiple Feeds assuming those feeds contain similar data.

The data in the Stream is always text data (XML, JSON, CSV, fixed-width, etc.) in a known {{< glossary "character encoding" >}}.
Stroom does not currently support processing binary formats.


## XML

The working format for pipeline processing is {{< glossary "XML" >}} (with the exception of raw streaming).
Data can be input and output in other forms, e.g. JSON, CSV, fixed-width, etc. but the majority of pipelines do most of their processing in XML.
Input data is converted into XML {{< external-link "SAX" "https://en.wikipedia.org/wiki/Simple_API_for_XML" >}} events, processed using [XSLT]({{< relref "xslt" >}}) to transform it into different shapes of XML then either consumed as XML (e.g. an {{< pipe-elm "IndexingFilter" >}}) or converted into a desired output format for storage/forwarding.


## Forks

Pipelines can also be forked at any point in the pipeline.
This allows the same data to processed in different ways.

{{% note %}}
Rather than creating complicated pipelines with forks, it is sometimes better to create multiple pipelines as this makes it easer to handle errors in one fork of the processing.
It also makes it easier to re-use common simple pipelines.
For example if you have a pipeline to transform CSV events into normalised XML then index it and forward it to a remote server, it may be better to have a pipeline to cook the events, then a common one to index those XML events and one to forward XML events.
{{% /note %}}


## Pipeline Inheritance

It is possible for pipelines to inherit from other pipelines.
This allows for the creation of a standard abstract pipelines with a set structure, though not fully configured, to be inherited by many concrete pipelines.

For example you may have a standard pipeline for indexing XML events, i.e. read XML data and pass it to an {{< pipe-elm "IndexingFilter" >}}, but the IndexingFilter is not configured with the actual Index {{< stroom-icon "document/Index.svg">}} to send documents to.
A pipeline that inherits this one can then be simply configured with the Index {{< stroom-icon "document/Index.svg">}} to use.

Pipeline inheritance allows for changes to the inherited structure, e.g. adding additional elements in line.
Multi level inheritance is also supported.


## Pipeline Element Types

Stroom has a number of categories of pipeline element.


### Reader

Readers are responsible for reading the raw bytes of the input data and converting it to character data using the Feed's character encoding.
They also provide functionality to modify the data before or after it is decoded to characters, e.g. {{< glossary "Bye Order Mark" >}} removal, or doing find/replace on the character data.
You can chain multiple Readers.


### Parser

A parser is designed to convert the character data into XML for processing.
For example, the {{< pipe-elm "JSONParser" >}} will use a JSON parser to read the character data as JSON and convert it into XML elements and attributes that represent the JSON structure, so that it can be transformed downstream using XSLT.

Parsers have a built in reader so if they are not preceded by a Reader they will decode the raw bytes into character data before parsing.


### Filter

A filter is an element that handles XML SAX events (e.g. element, attribute, character data, etc.) and can either return those events unchanged or modify them.
An example of Filter is an {{< pipe-elm "XSLTFilter" >}} element.
Multiple filters can be chained, with each one consuming the events output by the one preceding it, therefore you can have lots of common reusable XSLTFilters that all do small incremental changes to a document.


### Writer

A writer is an element that handles XML SAX events (e.g. element, attribute, character data, etc.) and converts them into encoded character data (using a specified encoding) of some form.
The preceding filter may have been an {{< pipe-elm "XSLTFilter" >}} which transformed XML into plain text, in which case only character data events will be output and a {{< pipe-elm "TextWriter" >}} can just write these out as text data.
Other writers will handle the XML SAX events to convert them into another format, e.g. the {{< pipe-elm "JSONWriter" >}} before encoding them as character data.


### Destination

A destination element is a consumer of character data, as produced by a writer.
A typical destination is a {{< pipe-elm "StreamAppender" >}} that writes the character data (which may be XML, JSON, CSV, etc.) to a new Stream in Stroom's stream store.
Other destinations can be used for sending the encoded character data to Kafka, a file on a file system or forwarding to an HTTP URL.
