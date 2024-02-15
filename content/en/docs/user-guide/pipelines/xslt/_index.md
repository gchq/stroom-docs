---
title: "XSLT Conversion"
linkTitle: "XSLT Conversion"
weight: 30
date: 2021-07-27
tags:
  - xslt
description: >
  Using Extensible Stylesheet Language Transformations (XSLT) to transform data.
---

{{< glossary "XSLT" >}} is a language that is typically used for transforming XML documents into either a different XML document or plain text.
XSLT is key part of Stroom's pipeline processing as it is used to normalise bespoke events into a common XML audit event document conforming to the `event-logging` {{< glossary "XML Schema" >}}.

Once a text file has been converted into intermediary XML (or the feed is already XML), {{< glossary "XSLT" >}} is used to
translate the XML into the `event-logging` XML format.

The {{< pipe-elm "XSLTFilter" >}} pipeline element defines the XSLT document and is used to do the transformation of the input XML into XML or plain text.
You can have multiple XSLTFilter elements in a pipeline if you want to break the transformation into steps, or wish to have simpler XSLTs that can be reused.

_Raw Event_ Feeds are typically translated into the `event-logging:3` schema and _Raw Reference_ into the `reference-data:2` schema.

