---
title: "Stroom Proxy"
linkTitle: "Stroom Proxy"
weight: 80
date: 2021-08-20
description: >
  Stroom Proxy acts as a proxy when sending data to a Stroom instance. Stroom Proxy has various modes such as storing, aggregating and forwarding the received data. Stroom Proxies can be used to forward to other Stroom Proxy instances.
tags:
  - proxy
---

Stroom Proxy is a lightweight forwarding agent that sits between data sources and the main Stroom instance.
It receives incoming data, optionally stores and aggregates it, and forwards it upstream.
Proxy is typically deployed at network boundaries or remote sites.

* [Stroom Proxy Installation]({{< relref "stroom-7-proxy-installation" >}}) — installing Stroom Proxy in docker or application mode.


