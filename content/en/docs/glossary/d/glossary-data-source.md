---
title: "Data source"
linkTitle: "Data source"
description: >
  The source of data for a _Query_, e.g. a _Lucene_ based _Index_, a SQL Statistics Data source, etc.
---

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

{{% see-also %}}
* {{< glossary "Query">}}
* {{< glossary "Dashboard">}}
* {{< glossary "Field">}}
{{% /see-also %}}

