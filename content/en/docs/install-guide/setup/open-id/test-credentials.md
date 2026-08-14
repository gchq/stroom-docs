---
title: "Insecure Test Credential"
linkTitle: "Insecure Test Credential"
weight: 50
date: 2026-07-29
tags: 
description: >
  An optional shared secret for wiring Stroom and Stroom-Proxy together in test or demonstration environments.
---

Stroom offers an optional shared secret that allows Stroom-Proxy, or a test script, to authenticate to Stroom as the internal processing user without an identity provider being involved.
It exists so that a test or demonstration stack can function without standing up a real {{< glossary "idp" >}}.

{{% warning %}}
This is totally insecure.
Anything holding the secret is treated as Stroom's own processing user, which is the most privileged identity in the system.

It must never be enabled in production.
To configure secure authentication see [Internal IDP]({{< relref "internal-idp" >}}) or [External IDP]({{< relref "external-idp" >}}).
{{% /warning %}}


## Enabling the Test Credential

This is not part of the identity provider configuration.
The identity provider, normally the internal one, handles all interactive sign in and token authentication as usual.
The secret is an addition to that, not a substitute for it.

It is disabled unless **both** of the following are supplied, as environment variables or as system properties:

| Setting | Purpose |
| ------- | ------- |
| `STROOM_ALLOW_INSECURE_TEST_CREDENTIALS=true` | An explicit acknowledgement that this is insecure. |
| `STROOM_INSECURE_TEST_CREDENTIAL` | The shared secret to be matched. |

Supplying only the first has no effect other than an error in the logs.

Both are supplied at runtime rather than in a configuration file.
This is deliberate.
A configuration file copied from a test environment into production cannot carry the secret with it, so a production deployment that never sets these variables cannot be tricked into enabling this.

You choose the secret yourself; Stroom publishes none.
A secret shared between systems for convenience is still not a credential to rely on outside test and demonstration use.

While it is enabled, Stroom logs a warning banner at startup, and logs again, at most every five minutes, whenever a request actually authenticates using it.


## Configuring Stroom-Proxy to Use the Credential

Set the secret as Stroom-Proxy's feed status API key, and give it the same value in Stroom's environment:

```yaml
  feedStatus:
    apiKey: "THE_VALUE_OF_STROOM_INSECURE_TEST_CREDENTIAL"
  security:
    authentication:
      openId:
        identityProviderType: NO_IDP
```

A request arriving at Stroom with this value as its bearer token is authenticated as the processing user.

For a secure equivalent, create an {{< glossary "API Key" >}} in Stroom and use that as the proxy's `feedStatus.apiKey` instead, leaving both settings above unset.
