---
title: "Proxy Functions"
linkTitle: "Proxy Functions"
weight: 30
date: 2026-02-24
tags:
  - proxy
description: >
  The key functions and capabilities of Stroom-Proxy.
---

## Data Receipt

### Data Feed API

This is Stroom-Proxy's traditional API for receiving data and Stroom shares the same API.
See [`/datafeed`]({{< relref "proxy-api#datafeed" >}}) for more details.


### Event Store API

Stroom-Proxy presents an alternative HTTP `POST` API at [`/api/event`]({{< relref "proxy-functions#" >}}) to receive individual events.
If the Stroom-Proxy instances are sufficiently resilient then client systems can use this API to send events directly without needing to buffer them locally.
It must only be used for sending a single event, not a batch of events.

The HTTP headers `Feed` and `Type` are used to provide the Feed and Stream Type, which are used as the compound aggregation key.
The request content is assumed to be _UTF-8_ encoded text data but can be in any format, e.g. `XML`, `JSON`, `CSV`, etc.

Stroom-Proxy will convert each request into the following JSON object and aggregate them by `Feed` and Stream `Type` in the Event Store, with one file per key.
The JSON combines the receipt information, the HTTP headers and the event data into one structured object that can be processed and transformed by Stroom.

```json
{
  "version": 0,
  "event-id": "1771956627189_0001_P_test-proxy",
  "proxy-id": "test-proxy",
  "feed": "FEED_X",
  "type": "Raw Events",
  "receive-time": "2026-02-24T18:10:27.192Z",
  "headers": [
    { "name": "Feed", "value": "FEED_X" },
    { "name": "Type", "value": "Raw Events" }
  ],
  "detail": "this\nis some data \n with new \n\n lines"
}
```

* `version` - The version of the Event structure, currently `0`.
* `event-id` - A unique ID for the event.
  This uses the [Receipt ID]({{< relref "receipt-id" >}}) which is a unique identifier for the event.
* `proxy-id` - The unique identity for the Stroom-Proxy instance within the estate.
* `feed` - The Feed the event is destined for, taken from the `Feed` HTTP header.
* `type` - The Stream Type the event is destined for, taken from the `Type` HTTP header.
* `receive-time` - The ISO-8601 timestamp taken when the event was received.
* `headers` - A list of the meta attributes extracted from the HTTP headers.
* `detail` - The event payload, i.e. the HTTP request content.

Each event is written as one line in the aggregated file, delimited by a Line Feed (`\n`).
A file containing one JSON object per line is typically referred to as {{< external-link "JSON Lines Format" "https://jsonlines.org" >}}.
This format is mean easier to parse than a single JSON object containing many events.

If Stroom-Proxy is configured for [aggregation]({{< relref "#aggregation" >}}) then the Event Store essentially adds another layer of aggregation in front of Stroom-Proxy's standard aggregation.
The Event Store aggregation is configured separately to the standard aggregation.
See [Event Store Configuration]({{< relref "configuring-stroom-proxy#event-store-configuration" >}}) for details on how to configure the Event Store and the aggregation thresholds.

Once a file of one or more individual event objects has met its aggregation thresholds it will be processed in the same way as data arriving via `/datafeed`.


#### Authentication

`/api/event` differs from the other `/api/...` [REST endpoints]({{< relref "proxy-api#rest-api" >}}) in how requests are authenticated.
It does not use the same authentication as the other endpoints.

Its authentication is performed in the same way as `/datafeed` and is configured using [Event Store Configuration]({{< relref "common-configuration#receive-configuration" >}}).


### AWS Simple Queue Service Connector

Stroom-Proxy Supports receiving individual events from one or more AWS Simple Queue Service queues.
Each event received is treated in the same way as event received via the [Event Store API]({{< relref "#event-store-api" >}}).


### Receipt Filtering

Stroom-Proxy can be configured a number of different methods of data receipt filtering:

* `FEED_STATUS` - Data is filtered based on the _Status_ of the Feed in Stroom.
* `RECEIPT_POLICY` - Data is filtered based on a set of policy rules that have been created in Stroom.
* `RECEIVE_ALL` - All data is accepted, regardless.
* `DROP_ALL` - All data is silently dropped.
* `REJECT_ALL` - All data is rejected with an error.


## Splitting

When ZIP data is received in [Stroom ZIP Format]({{< relref "docs/sending-data/payloads#stroom-zip-format" >}}) it will be examined to determine if it contains multiple _groups_ (where a group is identified by Feed and Stream Type).
ZIP data with multiple groups will be split so that data for each group will be processed separately.


## Aggregation

If enabled, the aggregation function will locally store the received data and aggregate data from multiple HTTP requests together until the aggregation threshold is reached.
Data will be aggregated by common group key (Feed and Stream Type).

Aggregation can be limited by one or more of:

* Item count - The number of items in the aggregate.
* Maximum uncompressed size - The total uncompressed size of the aggregate.
  Note, this is a target as Stroom-Proxy may received a single item of data that is larger than this limit.
* Frequency - How often data is assembled into a completed aggregate.


## Forwarding

Stroom-Proxy can forward data to one or more destinations and the following destination types are supported:

* File - The data (in ZIP format) is written to a configured directory.
* HTTP - The data (in ZIP format) is POSTed to a configured URL.

If multiple destinations are configured, the ZIP to be forwarded will be copied to each of the forward destination input queues.
This means the failure to send to one destination has no impact on sending to the other destinations.

Forwarding is configured using [Forward Configuration]({{< relref "configuring-stroom-proxy#forward-configuration" >}}).

For details of the directories used in forwarding, see [`/40_forwarding_input_queue/`]({{< relref "architecture#40_forwarding_input_queue" >}}) and [`/50_forwarding/`]({{< relref "architecture#50_forwarding" >}}).


### Instant Forwarding

This is a special type of forwarding that means data is streamed directly to a destination rather than being written to local disk first.
The instant forwarding is only possible if there is only **one** forwarding destination configured.
Data will still be subject to the configured receipt filtering.

Instant forwarding is enabled by setting `instant` to `true` on the forward destination configuration branch.


### Forward Failure Handling

When there is a failure to forward a ZIP, Stroom-Proxy will move it to one of two places:

Retry Queue
: If the reason for the failure is considered a recoverable one, e.g. the HTTP destination is down, it will move the ZIP onto the retry queue.

  The retry behaviour is configured using [Queue Configuration]({{< relref "configuring-stroom-proxy#queue-configuration" >}})

Failure Directory
: If the failure is deemed unrecoverable, the ZIP will be moved to the `03_failure` sub directory within the forward destination directory.
  At this point the ZIP file is no longer under the control of Stroom-Proxy and will have to be dealt with manually by the administrator.

  If the reason for the failure is addressed it is possible to re-process the failed data by moving it into a directory that is configured for [Directory Scanning]({{< relref "#directory-scanning" >}}).


## Directory Scanning

Stroom-Proxy can periodically scan one or more directories to look for ZIP files to ingest.
Any ZIP files found will be treated as if they were received via the `/datafeed` API.
The scanning will recurse into any directories found.

This feature is primarily aimed at re-processing data that Stroom-Proxy has been unable to forward due to an un-recoverable error or too many retries.
This mechanism can also be used as an additional means of passing data into Stroom-Proxy (instead of via `/datafeed`).


### Example

A typical case scenario is that some data has failed to send to Stroom and the retry age has been reached so the ZIP has been moved to the forward failure directory:

Contents of `data/50_forwarding/downstream/`

```text
./03_failure/20251014/BAD_FEED/0/001/proxy.zip
./03_failure/20251014/BAD_FEED/0/001/proxy.meta
./03_failure/20251014/BAD_FEED/0/001/error.log
```

If you wish to re-send this ZIP you can do the following:

{{< command-line >}}
mv data/50_forwarding/downstream/03_failure/20251014/BAD_FEED/0/001 "./zip_file_ingest/${uuidgen)"
{{</ command-line >}}

This will move the `001` directory into `zip_file_ingest/`, renaming it to a unique {{< glossary "UUID" >}} to ensure it doesn't clash with any existing files/directories.
The name of this directory in the ingest directory has no bearing on processing, other than the order in which directories are scanned.

On the next scan, Stroom-Proxy will discover the `proxy.zip` file.
It will check for the presence of any of the optional associated side-car files (i.e. `proxy.meta` and `error.log`).
The entries in the `.meta` file will be consumed.
The `error.log` file will be deleted following successful ingest.

Stroom-Proxy will scan into all sub-directories within the ingest directory, regardless of depth.

The `.meta` sidecar file is optional, but if provided will be used to provide meta values equivalent to HTTP headers when sending to `/datafeed`.
For a `.meta` file to be consumed, it must have the same base-name as the ZIP file, e.g. `data.zip` and `data.meta`, and be in the same directory as the ZIP file.

{{% warning %}}
Stroom-Proxy may be scanning at the same time as you are moving files in to the `zip_file_ingest` directory.

Therefore, it is important that if you are supplying sidecar files that you move a parent directory rather than the files themselves (as is shown in the above `mv` example).
This will ensure that the move happens atomically, so all files will be visible to the scanner.
{{% /warning %}}




