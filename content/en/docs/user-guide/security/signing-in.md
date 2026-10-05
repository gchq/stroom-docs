---
title: "Signing In"
linkTitle: "Signing In"
weight: 32
date: 2026-07-29
tags:
  - authentication
  - user
  - account
  - password
description: >
  What happens when a user signs in to Stroom, how passwords are reset and how a locked account is recovered.
---

This page describes what a user experiences when signing in to Stroom using its internal {{< glossary "idp" >}}.

{{% note %}}
None of this applies when Stroom is configured to use an external {{< glossary "idp" >}}.
In that case sign in, password policy and account recovery are all handled by that provider.
See [Open ID Connect]({{< relref "docs/install-guide/setup/open-id" >}}).
{{% /note %}}


## Signing in with a Password

The outcome of a sign in attempt depends on the state of the account as well as the password.

| Situation | What the user is told |
| --------- | --------------------- |
| Correct password, account in good order | Signed in. Any earlier failed attempts are forgotten. |
| Wrong password | Invalid credentials. The failure is counted towards locking the account. |
| Account disabled | The account is disabled and they should contact an administrator. |
| Account locked | The account is locked, together with the quickest way to recover it. |
| Account inactive, correct password | Either signed in, or told the account has been deactivated. See [User Accounts]({{< relref "user-accounts" >}}). |

A wrong password and a user id that does not exist produce exactly the same answer, so the sign in screen cannot be used to discover which accounts exist.

For a disabled or locked account the password is not checked at all.
Neither state can be talked out of with a correct password, so there is nothing to be gained by checking one, and refusing without checking means the sign in screen cannot be used to test whether a password is correct.

Failed attempts against a disabled or locked account are not counted, because the account is already refused.


### Being Asked to Change Your Password

A user may be signed in successfully and then be required to set a new password before they can do anything else.
This happens in three cases:

* It is their first ever sign in and `stroom.security.identity.passwordPolicy.forcePasswordChangeOnFirstLogin` is enabled, which it is by default.
* An administrator has set a new password for them and asked that it be changed.
* Their password is older than `stroom.security.identity.passwordPolicy.mandatoryPasswordChangeDuration`.

The new password must satisfy the password policy, which is applied by the server on every route that sets a password.
The previous password cannot be reused.


## Getting Locked Out

After a number of consecutive wrong passwords, controlled by `stroom.security.identity.failedLoginLockThreshold`, the account is locked.

The message shown to a locked user depends on how the system is configured, and always gives them the cheapest way back in.

| Configuration | What the user is told |
| ------------- | --------------------- |
| Locks lapse on their own, which is the default | To try again in approximately so many minutes. |
| Locks lapse and self service reset is enabled | The same, plus a pointer to _Forgot password?_ |
| Locks never lapse (`failedLoginLockDuration` is zero) | To contact an administrator. |
| Locks never lapse and self service reset is enabled | To use _Forgot password?_ or contact an administrator. |

An administrator is only named where an administrator really is the only way back.
In a default configuration a locked user is told to wait, which avoids a support request for something that resolves itself.

See [User Accounts]({{< relref "user-accounts" >}}) for the three ways an account becomes usable again.


## Resetting a Forgotten Password

If the user has an email address recorded against their account, and `stroom.security.identity.passwordPolicy.allowPasswordResets` is enabled, they can use _Forgot password?_ on the sign in screen to be emailed a link for setting a new password.

The response shown on screen is the same whether or not the address belongs to an account, so this screen cannot be used to discover which email addresses have accounts.

The link is valid for `stroom.security.identity.token.emailResetTokenExpiration`, ten minutes by default, and can be used only once.
Requesting another link invalidates any earlier one.
Repeated requests are rate limited by `stroom.security.identity.passwordResetRequestCooldown`.

Completing a reset ends all of that user's existing sessions everywhere in the cluster.
They then sign in with their new password.


### When a Reset Cannot be Completed

Some accounts cannot be recovered this way.
Rather than sending a link that would not work, Stroom emails the account holder to say that the reset cannot currently be completed and that they should contact an administrator if it continues.

This happens when:

* The account is disabled.
  Only an administrator can enable it again.
* The account is locked and `stroom.security.identity.allowLockedAccountPasswordReset` is not enabled.
  Note that a lock which has already lapsed does not prevent a reset.
* The account is inactive and `stroom.security.identity.reactivateInactiveAccountsOnLogin` is not enabled.
  Without it, setting a new password would not be enough to sign in, so an administrator has to reactivate the account first.

The email is deliberately the same in all three cases and does not say which one applies.
It goes to the address held against the account, so it tells the account holder something is wrong without telling whoever made the request anything at all.

No email of any kind is sent when there is nobody to send it to, that is when the address matches no account, the account has no email address recorded, password resets are turned off, or an email was already sent within the cool-down period.


## Signing in with a Certificate

If `stroom.security.identity.allowCertificateAuthentication` is enabled, a user presenting a valid certificate can be signed in without typing a password.
The user id is taken from the certificate's common name using `stroom.security.identity.certificateCnPattern` and `stroom.security.identity.certificateCnCaptureGroupIndex`.

A valid certificate is treated in exactly the same way as a correct password.
The same account states apply in the same order, so a disabled or locked account is still refused, and an inactive account is either reactivated or refused depending on `stroom.security.identity.reactivateInactiveAccountsOnLogin`.

{{% see-also %}}
[User Accounts]({{< relref "user-accounts" >}})
[Sessions and Tokens]({{< relref "sessions-and-tokens" >}})
{{% /see-also %}}
