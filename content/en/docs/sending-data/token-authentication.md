---
title: "Token Authentication"
linkTitle: "Token Authentication"
weight: 70
date: 2022-12-30
tags:
  - authentication
  - token
description: >
  How to send data using token based authentication.
---

As an alternative to using SSL certificates for authentication when sending data to the `/datafeed` endpoint, you can use a {{< glossary "token" "JSON Web Token" >}}.
Using a token for authentication requires that Stroom or Stroom-Proxy have been configured with `identityProviderType` set to `EXTERNAL_IDP` (see [External IDP]({{< relref "docs/install-guide/setup/open-id/external-idp" >}}) for details on the configuration for an external IDP and how to generate a token).

To attach a token to the request you just need to set the [HTTP header]({{< relref "header-arguments" >}}) `Authorization` with a value of the form 

```text
Bearer YOUR_TOKEN_GOES_HERE
```
