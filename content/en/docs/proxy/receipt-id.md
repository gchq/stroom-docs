---
title: "Receipt ID"
linkTitle: "Receipt ID"
weight: 50
date: 2026-02-24
tags: 
description: >
  A unique identifier that is assigned to each item of data received by Stroom-Proxy.
---

On receipt of data, Stroom-Proxy will assign the data a unique Receipt ID.
This value will be set in the `ReceiptId` meta attribute.
It will also be appended to the `ReceiptIdPath` meta attribute, which is a comma delimited list of Receipt IDs.

The format of this attribute has been made to make it more useful to administrators, while still being unique across the environment that the Stroom and Stroom-Proxy instances are deployed in.

The format is as follows:

 `<timestamp>_<seq no>_<(P|S)>_<proxyId or stroom nodeName>`

* `<timestamp>` - The receipt timestamp in milliseconds since the {{< glossary "Unix Epoch" >}}, zero padded.

* `<seq no>` - This is zero padded four digit sequential number (starting at `0000`) that is used to distinguish between multiple receipt events happening during the same millisecond on the same instance.

* `<P|S>` - Indicates whether the item was received by Stroom (`S`) or Stroom-Proxy (`P`).

* `<proxyId or stroom nodeName>` - For Stroom-Proxy this will be the `proxyConfig.proxyId` that is either set in configuration to uniquely identify a proxy instance or is one of the {{< glossary "FQDN" >}}/{{< glossary "IP Address" >}}.
  For Stroom this is the node name of the Stroom instance.
  The `proxyId` set on each Stroom-Proxy instance must be unique across all Stroom-Proxy instances in the estate.
  The `nodeName` set on each Stroom instance must be unique across all Stroom instances in the estate.

An example Receipt ID is `0000001738332835967_0000_P_node1`

The new format is useful for tracing the flow of data through a chain of proxies as it will be included in receive and send logs as well as being written to the meta attributes.

To ensure uniqueness of these IDs across the estate, `proxyID` values should be unique within the environment that data will flow.
The same is true for Stroom `nodeName` values.
