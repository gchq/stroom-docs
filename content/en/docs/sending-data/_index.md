---
title: "Sending Data to Stroom"
linkTitle: "Sending Data to Stroom"
weight: 70
date: 2026-09-23
tags: 
description: >
  How to send data (event logs) into Stroom or one of its proxies.
---

Stroom and Stroom Proxy have a simple HTTP POST interface that requires HTTP header arguments to be supplied as described [here]({{< relref "header-arguments.md" >}}).

Files are posted to Stroom and Stroom Proxy as described [here]({{< relref "payloads.md" >}}).

Stroom will return a response code indicating the success or failure status of the post as described [here]({{< relref "response-codes.md" >}})

Data can be sent from any operating systems or applications.
Some examples to aid in sending data can be found [here]({{< relref "example-clients.md" >}})

Unless Stroom or Stroom-Proxy has been configured to receive data without it, the client must also authenticate.
There are four ways to do so, and which are available depends on how the receiving system has been configured.
The first three identify a Stroom user or an identity at the {{< glossary "idp" >}}; the fourth is specific to data receipt and also sets meta data on the data it receives.

| Credential | How it is sent | See |
| ---------- | -------------- | --- |
| A client certificate | The TLS handshake | [SSL Configuration]({{< relref "ssl" >}}) |
| An {{< glossary "API Key" >}} created in Stroom | `Authorization: Bearer ...` | [API Key Authentication]({{< relref "api-key-authentication" >}}) |
| An {{< glossary "idp" >}} token | `Authorization: Bearer ...` | [Token Authentication]({{< relref "token-authentication" >}}) |
| A _Data Feed Identity_ | `Authorization: Bearer ...` for a _Data Feed Key_, or the TLS handshake for a _Certificate Identity_ | [Data Feed Identities]({{< relref "docs/user-guide/data-receipt/data-feed-identities" >}}) |

It is common practice for the developers/admins of a client system to write the translation to normalise their data as they're in the best position to understand their logging and to generate specific events as required.
See [here]({{< relref "../HOWTOs/EventFeeds/translation-how-to.md" >}}) for further details.
