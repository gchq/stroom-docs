---
title: "Sending Data to Stroom"
linkTitle: "Sending Data to Stroom"
weight: 50
date: 2021-07-27
tags: 
description: >
  How to send data (event logs) into Stroom or one of its proxies.
---

Stroom and Stroom Proxy have a simple HTTP POST interface that requires HTTP header arguments to be supplied as described [here]({{< relref "header-arguments.md" >}}).

Files are posted to Stroom and Stroom Proxy as described [here]({{< relref "payloads.md" >}}).

Stroom will return a response code indicating the success or failure status of the post as described [here]({{< relref "response-codes.md" >}})

Data can be sent from any operating systems or applications.
Some examples to aid in sending data can be found [here]({{< relref "example-clients.md" >}})

It is common practice for the developers/admins of a client system to write the translation to normalise their data as they're in the best position to understand their logging and to generate specific events as required.
See [here]({{< relref "../HOWTOs/EventFeeds/translation-how-to.md" >}}) for further details.
