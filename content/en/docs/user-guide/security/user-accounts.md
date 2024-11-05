---
title: "User Accounts"
linkTitle: "User Accounts"
weight: 20
date: 2024-11-01
tags:
  - authentication
  - user
  - account
description: >
  User accounts for authentication when using Stroom's internal identity provider.
---

{{% todo %}}
The Users, Groups and Permissions screens are undergoing significant change in Stroom v7.6.
Therefore this section will be updated with more detail in v7.6.
{{% /todo %}}


{{% note %}}
If Stroom is configured to use an external {{< glossary "identity provider idp" "Identity Provider">}} (e.g. Azure Active Directory or AWS Cognito) then all user accounts are managed within that {{< glossary "identity provider idp" "Identity Provider">}} and the Manage Accounts screen in Stroom will not be available.
For more details about external Identity Providers, see [Open ID Connect]({{< relref "docs/install-guide/setup/open-id" >}}).
{{% /note %}}


## Accounts vs Stroom Users

See [Accounts vs Users]({{< relref "docs/install-guide/setup/open-id/accounts-users" >}}) for details on the difference between a Stroom User Account and a Stroom User.


## Creating User Accounts

User accounts can only be created by a user that holds the `Manage Users` or `Administrator` {{< glossary "Application Permission" >}}.

Create a new user account by selecting

{{< stroom-menu "Security" "Manage Accounts" >}}

from the main menu.

As a minimum a user account must have a unique identifier that will be used to identify them in Stroom.

If the user's email address is added then Stroom will be able to email the user to reset their password.
This functionality is configured using the properties starting with this prefix `stroom.security.identity.email.`.


### Account Flags

User accounts have a number of flags that can be set by an administrator or automatically by Stroom.

* _Enabled_ - Enables/disables the account.
  A disabled account cannot login.
  Useful for disabling a user that is temporarily on leave.

* _Locked_ - Set when a users has too many failed login attempts (controlled by the property `stroom.security.identity.failedLoginLockThreshold`).
  Can be un-set by a user with `Manage Users` {{< glossary "Application Permission" >}}.
  A locked account cannot login.

* _Inactive_ - Set automatically in one of these cases:
  * A brand new account has not been used for a duration greater than `stroom.security.identity.passwordPolicy.neverUsedAccountDeactivationThreshold`.
  * An account has not been used for a duration greater than `stroom.security.identity.passwordPolicy.unusedAccountDeactivationThreshold`.
  A inactive account cannot login.

