---
title: "Feed Status Checking"
linkTitle: "Feed Status Checking"
#weight:
date: 2026-02-10
tags: 
description: >
  The process of checking a Feed's status on data receipt to determine what to do with that data.
---

Feed status checking is Stroom's legacy method for controlling data receipt.
For a richer method of controlling data receipt, see [Data Receipt Rules]({{< relref "data-receipt-rules" >}})

If the property `stroom.receive.receiptCheckMode` is set to `FEED_STATUS`, the _Feed Status_ value that has been set on the {{< stroom-icon "document/Feed.svg" >}} Feed is used to determine the action to perform on that data.


## Feed Status Values

A {{< stroom-icon "document/Feed.svg" >}} Feed can have the following _Feed Status_ values:

* **Receive** - All data for this Feed will be received into Stroom / Stroom Proxy.

* **Reject** - All data for this feed will be rejected.
               The client will get HTTP `406` error with the message `110 - Feed is not set to receive data`.

* **Drop** -  All data for this Feed will be silently dropped by Stroom / Stroom Proxy, i.e. discarded and not stored.
              The client will receive a HTTP `200` response as if the data had been successfully received.
              This is for use if you do not want the client to know their data is being discarded.


## Stroom Proxy

Stroom Proxy is also able to perform Feed status checking.
Stroom Proxy does not have direct access to the Feed settings so has to perform the Feed status check by making a request to a downstream Stroom Proxy or Stroom.
If a Stroom Proxy receives a Feed status check it will proxy that request to its own downstream Stroom / Stroom Proxy.

Stroom Proxy will cache the response it gets from the downstream, so that it doesn't need to make a call for every stream received.

To configure Stroom Proxy for Feed status checking you need to set the following properties:

```yaml
proxyConfig:

  receive:
    # The action to take if there is a problem with the data receipt rules, e.g.
    # Stroom Proxy has been unable to contact Stroom to fetch the rules.
    fallbackReceiveAction: "RECEIVE"
    receiptCheckMode: "FEED_STATUS"

  downstreamHost:
    # The API key to use for authentication (unless OpenID Connect is being used)
    apiKey: null
    # The hostname of the downstream
    hostname: null
    # The port to connect to the downstream on
    # If not set, will default to 80/443 depending on scheme.
    port: null
    # The scheme to connect to the downstream on
    scheme: "https"
```

