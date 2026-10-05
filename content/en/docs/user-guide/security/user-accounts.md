---
title: "User Accounts"
linkTitle: "User Accounts"
weight: 30
date: 2026-07-29
tags:
  - authentication
  - user
  - account
description: >
  User accounts for authentication when using Stroom's internal identity provider.
---

{{% note %}}
If Stroom is configured to use an external {{< glossary "idp" >}} (e.g. Azure Active Directory or AWS Cognito) then all user accounts are managed within that {{< glossary "idp" >}} and the Manage Accounts screen in Stroom will not be available.
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


## Account States

An account has three states and they are independent of one another.
An account can be locked and disabled at the same time, or inactive and disabled, and so on.
Each is shown as its own column in the Manage Accounts screen because each answers a different question.

The quickest way to keep them apart is to ask what creates each state, because that also tells you what can clear it.

| State | What it is | Set by | Cleared by |
| ----- | ---------- | ------ | ---------- |
| _Disabled_ | A decision. An administrator has said this account may not be used. | An administrator | An administrator |
| _Locked_ | A defence. Stroom has reacted to repeated wrong passwords. | Stroom | Time, a password reset, or an administrator |
| _Inactive_ | An observation. Nobody has used this account for some time. | Stroom | A successful sign in, or an administrator |

An account in any of these three states cannot sign in.


### Enabled and Disabled

This is the administrator's control over whether an account may be used at all.
It is the only one of the three states that an administrator sets directly.

Disabling an account prevents any further sign in, immediately.
A disabled account cannot be recovered by the user under any circumstances.
Waiting will not release it and a password reset will not release it.
This makes disabling the right action whenever someone must be prevented from signing in, whether temporarily, for example while they are on extended leave, or permanently.

{{% warning %}}
Disabling an account stops that person signing in again.
It does not end the sessions they already hold, nor revoke the tokens they are already using, so somebody who is signed in at the time may carry on working.

To end access that is already in progress, disable the corresponding Stroom {{< glossary "user" >}} rather than, or as well as, the account.
Disabling a user ends their sessions across the cluster and revokes their tokens.
See [Sessions and Tokens]({{< relref "sessions-and-tokens" >}}) for how the two differ and when each is appropriate.
{{% /warning %}}


### Locked

An account is locked automatically after a number of consecutive failed sign in attempts, controlled by `stroom.security.identity.failedLoginLockThreshold`.
It is a defence against password guessing and nothing more.

An administrator cannot lock an account.
To prevent someone using Stroom, disable their account instead.

While an account is locked, further sign in attempts are refused without the password being checked at all, and those attempts are not counted against the account.
Continued guessing therefore reveals nothing and does not extend the lock.

There are three ways an account becomes usable again.

* _Waiting_.
  The lock lapses on its own after `stroom.security.identity.failedLoginLockDuration`, which is thirty minutes by default.
  Nothing needs to happen when it lapses.
  The next sign in with the correct password simply succeeds.
  The message shown to the user says roughly how long remains, so in a default configuration a locked user does not need to contact anybody.

* _Resetting their password_.
  If `stroom.security.identity.allowLockedAccountPasswordReset` is enabled then the user can request a password reset email and set a new password, which unlocks the account at the same time.
  This is described in [Signing In]({{< relref "signing-in" >}}).

* _An administrator unlocking it_.
  A user holding the `Manage Users` or `Administrator` {{< glossary "Application Permission" >}} can use the _Unlock_ action in the Manage Accounts screen.

Setting `failedLoginLockDuration` to zero means locks never lapse, in which case one of the other two routes is the only way back.
The duration is applied when a sign in is attempted rather than when the lock is created, so changing this property also changes locks that are already in force.


### Inactive

The `Account Maintenance` job marks an account as inactive when it has not been used for some time.
This happens in one of two cases:

* A brand new account that has never been signed into was created longer ago than `stroom.security.identity.passwordPolicy.neverUsedAccountDeactivationThreshold`.
* An account has not been signed into for longer than `stroom.security.identity.passwordPolicy.unusedAccountDeactivationThreshold`.

Accounts flagged as _never expires_ are exempt, as are accounts that have been reactivated recently, so that reactivating an account does not simply see it deactivated again on the job's next run.

As with locking, an administrator cannot mark an account as inactive.
Disabling is the control for preventing access.

How an inactive account becomes usable again depends on `stroom.security.identity.reactivateInactiveAccountsOnLogin`.

* When it is disabled, which is the default, an administrator must use the _Reactivate_ action in the Manage Accounts screen.
* When it is enabled, presenting a valid credential reactivates the account and signs the user in, in one step.
  This applies equally to a correct password and to a valid certificate.

A disabled account is never reactivated automatically.
Reactivation only happens once a credential has been accepted, and a disabled account never gets that far.


## Administrator Actions

The Manage Accounts screen offers the following actions to a user holding the `Manage Users` or `Administrator` {{< glossary "Application Permission" >}}.

| Action | Effect |
| ------ | ------ |
| _Disable_ / _Enable_ | Prevents or restores the ability to sign in. Does not end sessions already in progress. |
| _Unlock_ | Clears a failed sign in lock. |
| _Reactivate_ | Clears the inactive state. |
| _Set password_ | Sets a new password, optionally requiring the user to change it at their next sign in. |

There is deliberately no action to lock an account or to mark one as inactive.
Those two states are applied by Stroom in response to something it has observed, and an administrator wanting to prevent access should disable the account.

Requiring a password change at the next sign in can safely be combined with setting a password in the same save.
The requirement is kept rather than being cleared by the password change.

{{% see-also %}}
[Signing In]({{< relref "signing-in" >}})
[Sessions and Tokens]({{< relref "sessions-and-tokens" >}})
{{% /see-also %}}
