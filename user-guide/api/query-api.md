# Query API

The Query API uses common request/response models and end points for querying each type of datasource held in _Stroom_. The request/response models are defined in [_stroom-query_](https://github.com/gchq/stroom-query).

Currently _Stroom_ exposes a set of query endpoints for 

* [_stroom-index_](https://gchq.github.io/stroom/#/stroom-index%20query%20-%20v2) (the Lucene based event index) 
* [_sqlstatistics_](https://gchq.github.io/stroom/#/sqlstatistics%20query%20-%20v2) (Stroom's own statistics store)

The detaield documentation for the requess/responses is contained in the _Swagger_ definition linked to above.

## Common endpoints

The standard query endpoints are

* /[datasource](#datasource)

* /[search](#search)

* /[destroy](#destroy)

### datasource

The datasource endpoint is used to query _Stroom_ for the details of a datasource with a given _docRef_. The details will inlcude such things as the fields available and any restricions on querying the data.

### search

The search endpoint is used to initiate a search against a datasource or to request more data for an active search. A search request can be made using iterative mode, where it will perform the search and then only return the data it has immediately available. Subsequent requests for the same _queryKey_ will also return the data immediately available, expecting that more results will have been found by the query. Requesting a search in non-iterative mode will result in the response being returned when the query has completed and all known results have been found.

### destroy

This endpoint is used to kill an active query by supplying the _queryKey_ for query in question.
