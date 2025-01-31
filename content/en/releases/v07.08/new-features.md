---
title: "New Features"
linkTitle: "New Features"
weight: 10
date: 2025-01-30
tags: 
description: >
  New features in Stroom version 7.8.
---

## New Stroom-Proxy implementation

Stroom-Proxy has been re-written to fundamentally change the way it works internally.
This is to improve performance over previous Stroom-Proxy implementations and to make it more robust.

{{% todo %}}
{{% /todo %}}


## Reporting

{{% todo %}}
{{% /todo %}}


## Apache HTTP Client

Previous versions of Stroom and Stroom-Proxy used a variety of HTTP clients for making HTTP requests, e.g. from the {{< pipe-elm "HTTPAppender" >}}.
These have been standardised to all use the Apache HTTP client which means a consistent set of configuration can be used.


## Receipt ID

A new meta attribute (`ReceiptId`) has been added to Stroom and Stroom-Proxy to provide a unique identifier for each request received.

The format of this attribute has been made to make it more useful to administrators, while still being unique across the environment that the Stroom and Stroom-Proxy instances are deployed in.

The format is as follows:

 `<timestamp>_<seq no>_<(P|S)>_<proxyId or stroom nodeName>`

* `<timestamp>` - The receipt timestamp in milliseconds since the {{< glossary "Unix Epoch" >}}, zero padded.
* `<seq no>` - This is zero padded four digit sequential number (starting at `0000`) that is used to distinguish between multiple receipt events happening during the same millisecond.
* `<P|S>` - Indicates whether the item was received by Stroom (`S`) or Stroom-Proxy (`P`).
* `<proxyId or stroom nodeName>` - For Stroom-Proxy this will be the `proxyId` that is either set in configuration to uniquely identify a proxy instance or is one of the FQDN/IP.
  For Stroom this is the node name of the Stroom instance.

An example Receipt ID is `0000001738332835967_0000_P_node1`

The new format is useful for tracing the flow of data through a chain of proxies as it will be included in receive and send logs as well as being written to the meta attributes.

In addition to `ReceiptId` we also have `ReceiptIdPath` which will have a `ReceiptId` appended to it on each receipt (comma delimited).

To ensure uniqueness of these IDs across the estate, ProxyIDs should be unique within the environment that data will flow.
The same is true for Stroom node names.


* Issue **{{< external-link "#4661" "https://github.com/gchq/stroom/issues/4661" >}}** : Use Apache HttpClient.

* Issue **{{< external-link "#4378" "https://github.com/gchq/stroom/issues/4378" >}}** : Add reporting.

* Issue **{{< external-link "#2201" "https://github.com/gchq/stroom/issues/2201" >}}** : New proxy implementation.
