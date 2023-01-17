---
title: "Query APIs"
linkTitle: "Query APIs"
weight: 10
date: 2022-02-16
tags:
  - api
description: >
  The APIs to allow other systems to query the data held in Stroom.

---

The Query APIs use common request/response models and end points for querying each type of data source held in _Stroom_.
The request/response models are defined in {{< external-link "stroom-query" "https://github.com/gchq/stroom-query" >}}.

Currently _Stroom_ exposes a set of query endpoints for the following data source types.
Each data source type will have its own endpoint due to differences in the way the data is queried and the restrictions imposed on the query terms.
However they all share the same API definition.

* {{< stroom-icon "document/Index.svg" "Index" >}}{{< external-link "stroom-index Queries" "https://gchq.github.io/stroom/v@@VERSION@@/#/Stroom-Index%20Queries" >}} -
  The Lucene based search indexes.
* {{< stroom-icon "document/StatisticStore.svg" "SQL Statistics" >}}{{< external-link "Sql Statistics Query" "https://gchq.github.io/stroom/v@@VERSION@@/#/Sql%20Statistics%20Query" >}} -
  Stroom's SQL Statistics store.
* {{< stroom-icon "document/searchable.svg" "Searchable" >}}{{< external-link "Searchable" "https://gchq.github.io/stroom/v@@VERSION@@/#/Searchable" >}} -
  Searchables are various data sources that allow you to search the internals of Stroom, e.g. local reference data store, annotations, processor tasks, etc.

The detailed documentation for the request/responses is contained in the _Swagger_ definition linked to above.


## Common endpoints

The standard query endpoints are

* /[datasource]({{< relref "#datasource" >}})
* /[destroy]({{< relref "#destroy" >}})
* /[keepAlive]({{< relref "#keepalive" >}})
* /[search]({{< relref "#search" >}})


### Datasource

The {{< glossary "Data Source" >}} endpoint is used to query _Stroom_ for the details of a data source with a given {{< glossary "DocRef" >}}.
The details will include such things as the fields available and any restrictions on querying the data.


### Search

The search endpoint is used to initiate a search against a data source or to request more data for an active search.
A search request can be made using iterative mode, where it will perform the search and then only return the data it has immediately available.
Subsequent requests for the same _queryKey_ will also return the data immediately available, expecting that more results will have been found by the query.
Requesting a search in non-iterative mode will result in the response being returned when the query has completed and all known results have been found.

The SearchRequest model is fairly complicated and contains not only the query terms but also a definition of how the data should be returned.
A single SearchRequest can include multiple ResultRequest sections to return the queried data in multiple ways, e.g. as flat data and in an alternative aggregated form.


#### _Stroom_ as a query builder

_Stroom_ is able to export the json form of a SearchRequest model from its dashboards.
This makes the dashboard a useful tool for building a query and the table settings to go with it.
You can use the dashboard to defined the data source, define the query terms tree and build a table definition (or definitions) to describe how the data should be returned.
The, clicking the download icon on the query pane of the dashboard will generate the SearchRequest json which can be immediately used with the /search API or modified to suit.


### Destroy

This endpoint is used to kill an active query by supplying the _queryKey_ for query in question.


### Keep alive

Stroom will only hold search results from completed queries for a certain lenght of time.
It will also terminate running queries that are too old.
In order to prevent queries being aged off you can hit this endpoint to indicate to Stroom that you still have an interest in a particular query by supplying the query key.

