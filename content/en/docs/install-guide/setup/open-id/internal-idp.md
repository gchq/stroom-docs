---
title: "Stroom's Internal IDP"
linkTitle: "Internal IDP"
weight: 20
date: 2022-11-25
tags: 
description: >
  Details about Stroom's own internal identity provider and authentication mechanisms.
  
---

By default a new Stroom instance/cluster will use its own internal {{< glossary "idp" >}} for authentication.

{{% note %}}
The `_test` variant of the Stroom Docker stack also uses the internal {{< glossary "idp" >}}, with the addition of an [Insecure Test Credential]({{< relref "test-credentials" >}}) so that Stroom-Proxy can authenticate without further setup.
{{% /note %}}

In this configuration, Stroom acts as its own Open ID Connect Identity Provider and manages both the user accounts for authentication and the user/group permissions, (see [Accounts and Users]({{< relref "accounts-users" >}})).

A fresh install can create a user account called `admin` with the password `admin`, which is a member of a {{< glossary "group users" "group">}} called `Administrators` holding the `Administrator` application permission.
This admin user can then be used to set up the other users on the system.

This bootstrap account is **only created when `stroom.security.identity.autoCreateAdminAccountOnBoot` is set to `true`**, which is not the default.
The password is deliberately weak, and by default Stroom requires it to be changed at the first login, governed by `stroom.security.identity.passwordPolicy.forcePasswordChangeOnFirstLogin`.

Without that property, no account is created and nobody will be able to log in to a new installation.
You must instead create the first administrator from the command line.

{{% see-also %}}
See [Creating the First Administrator]({{< relref "docs/install-guide/setup/create-first-admin" >}}).
{{% /see-also %}}

Additional user accounts are created and maintained using

{{< stroom-menu "Security" "Manage Accounts" >}}

See [User Accounts]({{< relref "docs/user-guide/security/user-accounts" >}}) for managing those accounts, and [Signing In]({{< relref "docs/user-guide/security/signing-in" >}}) for what users experience.

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
