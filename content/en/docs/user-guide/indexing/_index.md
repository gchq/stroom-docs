---
title: "Indexing data"
linkTitle: "Indexing data"
weight: 80
date: 2022-02-15
tags: 
description: >
  Indexing data for querying.
cascade:
  tags: 
    - index
---

Stroom supports multiple indexing technologies that allow event data to be indexed for fast searching.
An indexed field holds a pointer back to the original event, allowing full event details to be retrieved at query time via a [search extraction pipeline]({{< relref "/docs/user-guide/pipelines/recipies#search-extraction" >}}).

Stroom supports the following index types:

* [Lucene Index]({{< relref "lucene" >}}) — Stroom's built-in, managed index, stored on the Stroom nodes.
* [Elasticsearch]({{< relref "elasticsearch" >}}) — integration with an external Elasticsearch cluster for scalable, distributed indexing.
* [Solr]({{< relref "solr" >}}) — integration with an external Solr cluster.

For a pipeline-level view of how to configure each index type, see [Pipeline Recipes]({{< relref "/docs/user-guide/pipelines/recipies#indexing" >}}).

