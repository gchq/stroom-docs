---
title: "Test Credentials"
linkTitle: "Test Credentials"
weight: 50
date: 2022-12-29
tags: 
description: >
  Hard coded Open ID credentials for test or demonstration purposes.
---

Stroom and Stroom-Proxy come with a set of hard coded Open ID credentials that are intended for use in test/demo environments.
These credentials mean that the `_test` stroom docker stack can function out of the box with Stroom-Proxy able to authenticate with Stroom.

{{% warning %}}
These credentials are publicly available and therefore totally insecure.
If you are configuring a production instance of Stroom or Stroom-Proxy you must not use these credentials.

To correctly configure secure authentication in Stroom and Stroom-Proxy see [Internal IDP]({{< relref "internal-idp" >}}) or [External IDP]({{< relref "external-idp" >}}).
{{% /warning %}}


## Configuring the test credentials

To configure Stroom to use these hard-coded credentials you need to set the following property:

```yaml
  security:
    authentication:
      openId:
        identityProviderType: TEST_CREDENTIALS
```

When you start the Stroom instance you will see a large banner message in the logs that will include the {{< glossary "token" >}} that can be used in API calls or by Stroom-proxy for its feed status checks.

To configure Stroom-Proxy to use these credentials set the following:

```yaml
  feedStatus:
    apiKey: "THE_TOKEN_OBTAINED_FROM_STROOM'S_LOGS"
  security:
    authentication:
      openId:
        identityProviderType: NO_IDP
```


