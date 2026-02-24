---
title: "Stroom Proxy"
linkTitle: "Stroom Proxy"
weight: 80
date: 2026-02-24
tags:
  - proxy
description: >
  Stroom Proxy acts as a proxy for sending data to a Stroom instance/cluster.
  Stroom Proxy has various modes such as storing, aggregating and forwarding the received data.
  Stroom Proxies can be used to forward to other Stroom Proxy instances.
---

Stroom-Proxy's primary role is to act as a front door for data being sent to Stroom.
Data can be sent to Stroom-Proxy in small chunks and it will aggregate the data into larger chunks (grouped by {{< glossary "Feed" >}} and {{< glossary "Stream Type" >}}) so that Stroom doesn't have to process lots of small {{< glossary "Stream" "Streams" >}}.
It also provides a separation between the client and Stroom, so Stroom can be taken offline while data is still being accepted by Stroom-Proxy.

See [Architecture]({{< relref "docs/architecture#overview" >}}) for an example of how Stroom-Proxy is typically deployed.


## API

Stroom-Proxy presents an identical _HTTP POST_ `/datafeed` {{< glossary "API" >}} to Stroom, so clients can send the same data in the same way to either Stroom or Stroom-Proxy.

For more detail on sending data into Stroom-Proxy see [Sending Data]({{< relref "docs/sending-data" >}}).


## Functions

Stroom-Proxy has a number of key functions:

* _Receipt Filtering_ - The process of filtering the incoming data based on the HTTP headers.
  Data can either be _Received_, silently _Dropped_ or _Rejected_ with an error.
* _Splitting_ - Splitting received {{< glossary "ZIP" >}} files by {{< glossary "Feed" >}} and {{< glossary "Stream Type" >}}.
* _Aggregation_ - Storing received data locally and forwarding it when the aggregation limits have been reached.
* _Forwarding_ - Forwarding the received/aggregated data to one or more forward destinations.
* _Instant Forwarding_ - Data is streamed to a single _HTTP_ forward destination (i.e. Stroom or another Stroom-Proxy) as the data is received.
  This function does not support multiple forward destinations or aggregations.
* _Directory Scanning_ - Periodically scanning one or more directories for ZIP files in [Stroom ZIP Format]({{< relref "docs/sending-data/payloads#stroom-zip-format" >}}).
* _Event Store_ - Stroom-Proxy presents an {{< glossary "API" >}} for receiving individual events.
  This is to support applications that want to log events directly to Stroom-Proxy rather than writing them to rolled files locally.

For a more detailed explanation of each function, see [Proxy Functions]({{< relref "proxy-functions" >}}).









