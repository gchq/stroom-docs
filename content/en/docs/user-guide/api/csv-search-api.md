---
title: "CSV Search API"
linkTitle: "CSV Search API"
weight: 35
date: 2026-08-11
tags:
  - api
description: >
  The API for running a Stroom Query Language query and getting the results back as CSV.
---


## CSV Search

This endpoint runs a [Stroom Query Language]({{< relref "docs/user-guide/search/queries/stroom-query-language" >}}) query and returns the results as CSV.

Unlike the [Query APIs]({{< relref "query-api" >}}), which need a JSON _SearchRequest_ describing both the query terms and how the results should be structured, this endpoint takes the query as a single string and always returns a table.
It is intended for the common case of pulling a modest set of rows out of _Stroom_ from a script.

The Swagger specification for the endpoint can be found {{< external-link "here" "https://gchq.github.io/stroom/v@@VERSION@@/#/Queries/queryCsv" >}}.

```
GET /api/query/v1/csv/search
```

The call is authenticated in the same way as any other _Stroom_ API, so you will need an [API Key]({{< relref "calling-api#authentication" >}}).
The examples below assume it is held in `${TOKEN}`.


### Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `query` | _(required)_ | The _Stroom Query Language_ query to run. |
| `offset` | `0` | The index of the first row to return. |
| `length` | `100` | The maximum number of rows to return. |
| `incremental` | `true` | Whether to return the results found so far rather than waiting for the query to finish. See [Incremental and non incremental searches]({{< relref "#incremental-and-non-incremental-searches" >}}). |
| `timeout` | _see below_ | How long, in milliseconds, the server will wait for the query to finish before responding. Defaults to 1,000 for an incremental search and 300,000 (five minutes) for a non incremental one. |


### Response

The response body is `text/plain` CSV.
The first line holds the column names and each subsequent line holds one row.
Only visible columns are included, so a column hidden in the query is also absent from the CSV, as are _Stroom_'s internal special columns.

A query that matches nothing returns an empty body, which is not an error.


### Incremental and Non Incremental Searches

Searches in _Stroom_ are asynchronous, so a response can be sent back before the query has finished.
This means an empty or short CSV body on its own is ambiguous, as it could mean either that the query matched little, or that it had not got very far by the time the server replied.

Every response therefore carries two headers to resolve that ambiguity.

| Header | Description |
| --- | --- |
| `X-Stroom-Search-Incremental` | Whether the search ran incrementally, i.e. the value of the `incremental` parameter. |
| `X-Stroom-Search-Complete` | Whether the search finished. `false` means the CSV holds only the rows found so far, so it is a subset of the matching data. |

{{% note %}}
Always check `X-Stroom-Search-Complete` before treating the CSV as the full result set.
A truncated result and a complete one are otherwise indistinguishable.
{{% /note %}}

An **incremental** search (the default) returns whatever rows have been found when the timeout expires.
This gets you a quick answer at the cost of it probably being partial, and is the right choice when you want to see something immediately.
If `X-Stroom-Search-Complete` is `false` you can request the data again, optionally with a longer `timeout`.

A **non incremental** search waits for the query to finish and so returns the whole result set, subject to `offset` and `length`.
This is the right choice for a script that needs complete data.
The trade off is that the request holds open for as long as the query takes, so allow for that in the client's own timeout.


### Errors

Omitting the `query` parameter returns a `400` with the body `query not supplied`.

A query that _Stroom_ rejects, for example one that will not parse or that names a data source that cannot be found, returns a `400` whose body is the reason.

{{< command-line >}}
curl --silent --get --include \
  --header "Authorization:Bearer ${TOKEN}" \
  --data-urlencode 'query=from "Example Index" take 3' \
  https://stroom-fqdn/api/query/v1/csv/search
{{</ command-line >}}

```text
HTTP/1.1 400 Bad Request
Content-Type: text/plain

Expected one of [select, where] but got 'take'
Error at line 1, column 22
```

The first line is the reason reported by the query parser, so its exact wording depends on the query.
The `Error at line ..., column ...` line is only present when the parser reports a location for the problem.

A non incremental search that hits its `timeout` also returns a `400`, with a body of the form `The search timed out after PT5M`.
Either raise `timeout` or switch to an incremental search, which returns the rows found so far instead of failing.

The bodies of the above are `text/plain`.
Any other failure is a fault in _Stroom_ rather than a problem with the request, and returns a `500` whose body is a JSON object with `code`, `message` and `details` fields.

{{% note %}}
The `X-Stroom-Search-Incremental` and `X-Stroom-Search-Complete` headers are only present on a successful response.
A client that reads them should check the status code first, as an error carries neither header.
{{% /note %}}


### Examples

Fetch the first 1,000 rows, waiting up to two minutes for the query to finish.

{{< command-line >}}
TOKEN="...API KEY GOES IN HERE..."
curl \
  --silent \
  --get \
  --header "Authorization:Bearer ${TOKEN}" \
  --data-urlencode 'query=from "Example Index" where EventTime > now() - 1d select EventTime, UserId' \
  --data-urlencode 'length=1000' \
  --data-urlencode 'incremental=false' \
  --data-urlencode 'timeout=120000' \
  --output results.csv \
  https://stroom-fqdn/api/query/v1/csv/search
{{</ command-line >}}

Using `--data-urlencode` with `--get` lets `curl` do the URL encoding, which matters because a query will usually contain spaces and quotes.

The next example takes the quick, possibly partial, answer and checks whether it was complete.
The headers are written to `headers.out` so they can be inspected separately from the CSV.

{{< command-line >}}
curl \
  --silent \
  --get \
  --header "Authorization:Bearer ${TOKEN}" \
  --data-urlencode 'query=from "Example Index" select EventTime, UserId' \
  --dump-header headers.out \
  --output results.csv \
  https://stroom-fqdn/api/query/v1/csv/search
grep --ignore-case 'X-Stroom-Search-Complete' headers.out
{{</ command-line >}}

```text
X-Stroom-Search-Complete: false
```
