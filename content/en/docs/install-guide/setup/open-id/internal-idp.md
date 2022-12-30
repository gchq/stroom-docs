---
title: "Stroom's Internal IDP"
linkTitle: "Internal IDP"
weight: 20
date: 2022-11-25
tags: 
description: >
  Details about Stroom's own internal identity provider and authentication mechanisms.
  
---

By default a new Stroom instance/cluster will use its own internal {{< glossary "identity provider idp" "Identity Provider (IDP)" >}} for authentication.

{{% note %}}
An exception to this is the `_test` variant of the Stroom Docker stack which will default to using [Test Credentials]({{< relref "test-credentials" >}})
{{% /note %}}

In this configuration, Stroom acts as its own Open ID Connect Identity Provider and manages both the user accounts for authentication and the user/group permissions, (see [Accounts and Users]({{< relref "accounts-users" >}})).

A fresh install will come pre-loaded with a user account called `admin` with the password `admin`.
This user is a member of a {{< glossary "group users" "group">}} called `Administrators` which has the `Administrator` application permission.
This admin user can be used to set up the other users on the system.

Additional user accounts are created and maintained using the _Tools_ => _Users_ menu item.

## Configuration for the internal IDP

While Stroom is pre-configured to use its internal IDP, this section describes the configuration required.

In Stroom:

```yaml
  security:
    authentication:
      authenticationRequired: true
      openId:
        identityProviderType: INTERNAL_IDP
```

In Stroom-Proxy:

```yaml
  feedStatus:
    apiKey: "AN_API_KEY_CREATED_IN_STROOM"
  security:
    authentication:
      openId:
        identityProviderType: NO_IDP
```
