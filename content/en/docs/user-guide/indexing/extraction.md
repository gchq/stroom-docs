---
title: "Search Extraction"
linkTitle: "Search Extraction"
#weight:
date: 2022-02-15
tags:
  - TODO
  - extraction
description: >
  The process of extracting non-indexed data from the source event/record in search results.

  
---

Stroom has the concept of Search Extraction.
This is the process of extracting un-indexed {{< glossary "Field" >}} values from the source {{< glossary "Event" >}}/Record to be used in search results.
Search extraction has two main purposes:

* Reducing the index storage requirements - if only the fields that you need to filter on are included in the index then this reduces the size of the index.
* Providing an abstraction of the search results, e.g. decorated in HTML form.

{{% todo %}}
Complete this section.
{{% /todo %}}


