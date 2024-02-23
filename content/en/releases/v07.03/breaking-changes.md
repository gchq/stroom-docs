---
title: "Breaking Changes"
linkTitle: "Breaking Changes"
weight: 30
date: 2024-02-23
tags: 
description: >
  Changes in Stroom version 7.3 that may break existing processing or ways of working.
---

{{% warning %}}
Please read this section carefully in case any of the changes affect you.
{{% /warning %}}

* The Hessian based feed status RPC service `/remoting/remotefeedservice.rpc` has been removed as it is using the legacy `javax.servlet` dependency that is incompatible with `jakarta.servlet` that is now in use in stroom.
  This was used by Stroom-Proxy up to v5.
