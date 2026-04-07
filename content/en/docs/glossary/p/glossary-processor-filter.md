---
title: "Processor filter"
linkTitle: "Processor filter"
description: >
  A Processor Filter is used to used to find Streams to process through the _Pipeline_ associated with the Processor Filter.
  A Processor Filter consists of an expression tree to select which _Streams_ to process and a tracker to track the what _Streams_ have been processed.
---

For example a typical Processor Filter would have an Expression Tree that selected all Streams of type _Raw Events_ in a particular {{< glossary "Feed" >}}.
A filter could also select a single Stream by its ID, e.g. when {{< glossary "Re-Processing" >}} a Stream.

A Pipeline can have multiple Processor Filters.
Filters can be enabled/disabled independently of their parent Processor to control processing.

{{% see-also %}}
* {{< glossary "Expression Tree" >}}
* {{< glossary "Feed" >}}
* {{< glossary "Pipeline" >}}
* {{< glossary "Re-Processing" >}}
* {{< glossary "Stream" >}}
{{% /see-also %}}

