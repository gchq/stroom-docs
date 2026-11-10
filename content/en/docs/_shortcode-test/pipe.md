---
title: "pipe"
linkTitle: "pipe"
#weight:
date: 2026-10-21
tags: 
description: >
  
---

A pipeline with one element.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
{{< /pipe >}}

A pipeline with multiple elements.

{{< pipe >}}
 {{< pipe-elm "Source" >}}
 {{< pipe-elm "XMLParser" >}}
 {{< pipe-elm "RecordCountFilter" "recordCount (read)">}}
 {{< pipe-elm "SplitFilter" >}}
 {{< pipe-elm "IdEnrichmentFilter" >}}
{{< /pipe >}}

