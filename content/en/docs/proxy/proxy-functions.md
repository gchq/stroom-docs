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

## Receipt Filtering

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


## Instant Forwarding

This is a special type of forwarding that means data is streamed directly to a destination rather than being written to local disk first.
The instant forwarding is only possible if there is only one forwarding destination configured.
Data will still be subject to the configured receipt filtering.


## Directory Scanning

{{% note %}}
This feature was added in Stroom-Proxy 7.10.
{{% /note %}}

Stroom-Proxy can periodically scan one or more directories to look for ZIP files to ingest.
Any ZIP files found will be treated as if they were received via the `/datafeed` API.
The scanning will recurse into any directories found.

This feature is primarily aimed at re-processing data that Stroom-Proxy has been unable to forward due to an un-recoverable error or too many retries.


## Event Store API

Stroom-Proxy presents a HTTP POST API at `/api/event` to receive individual events.
If the Stroom-Proxy instances are sufficiently resilient then client systems can use this API to send events directly without needing to buffer them locally.

HTTP headers are used to provide the Feed and Stream Type, which are used as the key for aggregation.
The POSTed data is assumed to text data, UTF8 encoded.

Each event is converted into the following JSON object and aggregated by Feed and Stream Type in the Event Store.
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
* `detail` - The event payload.


## AWS Simple Queue Service Connector

Stroom-Proxy Supports receiving individual events from one or more AWS Simple Queue Service queues.
Each event received is treated in the same way as event received via the [Event Store API]({{< relref "#event-store-api" >}}).
