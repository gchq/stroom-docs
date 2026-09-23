---
title: "Token Authentication"
linkTitle: "Token Authentication"
weight: 70
date: 2026-09-23
tags:
  - authentication
  - token
description: >
  How to send data using token based authentication.
---

As an alternative to using SSL certificates or an [API Key]({{< relref "api-key-authentication" >}}) for authentication when sending data to the `/datafeed` endpoint, you can use a {{< glossary "token" "JSON Web Token" >}}.
Using a token for authentication requires that Stroom or Stroom-Proxy have been configured with `identityProviderType` set to `EXTERNAL_IDP` (see [External IDP]({{< relref "docs/install-guide/setup/open-id/external-idp" >}}) for details on the configuration for an external IDP and how to generate a token).

To attach a token to the request you just need to set the [HTTP header]({{< relref "header-arguments" >}}) `Authorization` with a value of the form

```text
Bearer YOUR_TOKEN_GOES_HERE
```


## The Flow

The sending system obtains a token from the {{< glossary "idp" >}} for its own identity, then presents it with each request.
Stroom or Stroom-Proxy verifies that token against the IDP's published signing keys, exactly as it would verify any other bearer token.

{{< image "sending-data/token-authentication.puml.svg" >}}Obtaining a token and sending data with it{{< /image >}}

Tokens are short lived, typically around an hour, so a sender must obtain a fresh one when the old one expires rather than caching one indefinitely.

{{% see-also %}}
See [Tokens for API Use]({{< relref "docs/install-guide/setup/open-id/tokens-for-api" >}}) for creating the client credentials a sender uses, and [Microsoft Entra ID]({{< relref "docs/install-guide/setup/open-id/external-idp/azure-ad#obtaining-a-token-to-send-data" >}}) for a worked example with one provider.
{{% /see-also %}}
