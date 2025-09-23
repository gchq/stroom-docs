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

### Feed Status Check

If any proxy instances call into Stroom to make a feed status check using an API key or OAuth tokens, then the owner of those API keys or tokens will now need to be granted the `Check Receipt Status` application permission.


### AWS Open ID Connect Configuration

If you use AWS for OIDC authentication and you have configured the property `stroom.security.authentication.openId.publicKeyUriPattern` then you will need to change its value.
See [Upgrade Notes]({{< relref "upgrade-notes#open-id-connect-authentication" >}})


## Stroom-Proxy






