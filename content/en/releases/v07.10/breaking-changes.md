---
title: "Breaking Changes"
linkTitle: "Breaking Changes"
weight: 30
date: 2025-09-23
tags: 
description: >
  Changes in Stroom version 7.10 that may break existing processing or ways of working.
---

{{% warning %}}
Please read this section carefully in case any of the changes affect you.
{{% /warning %}}


## Stroom

No Stroom specific breaking changes in v7.10.


## Stroom-Proxy

No Stroom-Proxy specific breaking changes in v7.10.


## Stroom & Stroom-Proxy

### Open ID Connect Configuration

The property `stroom.security.authentication.openid.validateAudience` has been removed.
See [Upgrade Notes]({{< relref "upgrade-notes#open-id-connect-authentication" >}}) for details.


### AWS Open ID Connect Configuration

If you use AWS for OIDC authentication and you have configured the property `stroom.security.authentication.openId.publicKeyUriPattern` then you will need to change its value.
See [Upgrade Notes]({{< relref "upgrade-notes#open-id-connect-authentication" >}}) for details.
