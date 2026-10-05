---
title: "API Key Authentication"
linkTitle: "API Key Authentication"
weight: 60
date: 2026-09-23
tags:
  - authentication
  - token
description: >
  How to send data using an API Key created in Stroom.
---

As an alternative to a [certificate]({{< relref "ssl" >}}) or an {{< glossary "idp" >}} [token]({{< relref "token-authentication" >}}), data can be sent to the `/datafeed` endpoint using an {{< glossary "API Key" >}} created within Stroom.

An API Key belongs to a Stroom user, and carries that user's permissions, so it should be protected as carefully as a password.
Create one as described in [Calling the API]({{< relref "docs/user-guide/api/calling-api#authentication" >}}), then attach it to the request with the [HTTP header]({{< relref "header-arguments" >}}) `Authorization`, exactly as a token would be:

```text
Bearer YOUR_API_KEY_GOES_HERE
```

API Keys have the form `sak_<hash>_<random>`, and it is that `sak_` prefix that lets Stroom-Proxy tell them apart from {{< glossary "idp" >}} tokens arriving in the same header.


## The Flow

Stroom can check an API Key against its own records.
Stroom-Proxy holds no user accounts, so it asks its downstream Stroom, or the next Stroom-Proxy in the chain, and caches the answer.

{{< image "sending-data/api-key-authentication.puml.svg" >}}Sending data with an API Key{{< /image >}}

Two consequences worth knowing when sending to a Stroom-Proxy:

* The **first** request with a given key is slower than the rest, because it waits on the downstream call.
  Afterwards the key is served from memory for `downstreamHost.maxCachedKeyAge`.
* A key that has been verified before goes on working through a downstream outage, because Stroom-Proxy falls back to its local file of verified keys, for as long as the entry there is younger than `downstreamHost.maxPersistedKeyAge`.
  That file survives a restart of the proxy.
  A key used for the **first** time during an outage cannot be verified and is refused, though it is not remembered as invalid and will be verified once the downstream returns.

{{% see-also %}}
See [Data Feed Identities]({{< relref "docs/user-guide/data-receipt/data-feed-identities" >}}) for _Data Feed Keys_, a similar credential that Stroom-Proxy can check locally with no downstream call, and which also sets meta data on the received data.
{{% /see-also %}}
