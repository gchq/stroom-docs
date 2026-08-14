---
title: "Sessions and Tokens"
linkTitle: "Sessions and Tokens"
weight: 34
date: 2026-07-29
tags:
  - authentication
  - user
  - session
  - token
description: >
  Viewing and ending user sessions, and revoking the tokens held by a user.
---

Signing in to Stroom creates a session, and Stroom issues tokens that are used to prove who a user is, both to Stroom itself and between the nodes of a cluster.
This page describes how sessions and tokens are ended, both by users for themselves and by administrators.


## Ending Your Own Sessions

Any user can end their own sessions other than the one they are currently using, by selecting

{{< stroom-menu "User" "Sign Out Other Sessions" >}}

from the main menu.

This is useful after signing in from a machine that is no longer under their control.
It applies across every browser and device, and across every node in the cluster.

Completing a password reset also ends all of that user's sessions, including the one being used at the time.
See [Signing In]({{< relref "signing-in" >}}).


## The User Access Screen

A user holding the `Manage Users` or `Administrator` {{< glossary "Application Permission" >}} can see and end the access held by other users by selecting

{{< stroom-menu "Security" "User Access" >}}

from the main menu.

The screen lists users along with how many sessions and tokens each currently holds, and shows the sessions held for the selected user across every node in the cluster.

Two actions are available.

* _End this user's sessions and revoke their tokens_ does exactly that, across the whole cluster rather than just the node serving the request.
  It does not withdraw their access: the account is untouched and they can sign in again.

* _Open this user_ opens the selected user, where they can be disabled.
  This is offered alongside revocation because the two are easily confused and do quite different things, as described below.


## Revoking, Disabling, and the Difference Between Them

Three actions are easy to confuse, and each does something different.
To stop someone using Stroom completely and immediately, you need the last two together.

| Action | Ends sessions and tokens | Prevents signing in again |
| ------ | ------------------------ | ------------------------- |
| _End sessions and revoke tokens_, on the User Access screen | Yes | No |
| Disable the Stroom {{< glossary "user" >}}, on the Users screen | Yes | Yes |
| Disable the account, on the Manage Accounts screen | No | Yes |

Ending sessions and revoking tokens does both of those things and no more.
It deliberately leaves the account alone, so the password still works and the user can sign in again.
Every token revoked this way is dead permanently, but their access as a whole is not withdrawn.
It forces re-authentication rather than shutting anybody out, which makes it the right action when you want to be certain that whoever is currently signed in has to prove who they are again.

Disabling the Stroom {{< glossary "user" >}} does everything the above does, and additionally refuses them at authentication, whether they are signing in interactively or presenting a token.
This is the action to take when someone must be stopped, and is what the _Open this user_ button on the User Access screen is for.

Disabling the account, which only applies when Stroom is its own {{< glossary "idp" >}}, stops them authenticating at all.
It does not disturb a session that is already running.
See [User Accounts]({{< relref "user-accounts" >}}).

{{% warning %}}
This matters most when Stroom is configured to use an external {{< glossary "idp" >}}.
Revoking a user's sessions and tokens does not touch the session they hold with that provider, so their next request is likely to sign them straight back in automatically, without their even being asked for a password.

To prevent access when using an external {{< glossary "idp" >}}, disable the account at that provider, in Stroom, or both.
{{% /warning %}}


## Token Lifetimes

These are the defaults, and are configurable under `stroom.security.identity.token.`.

| Token | Property | Default |
| ----- | -------- | ------- |
| Access token | `accessTokenExpiration` | 60 minutes |
| Refresh token | `refreshTokenExpiration` | 30 days |
| Password reset link | `emailResetTokenExpiration` | 10 minutes |
| API key | `defaultApiKeyExpiration` | 365 days |

Refresh tokens can be used only once, and each use issues a replacement.
If a refresh token is presented a second time, which suggests it has been copied, Stroom withdraws that token and every token descended from it.

{{% see-also %}}
[User Accounts]({{< relref "user-accounts" >}})
[Signing In]({{< relref "signing-in" >}})
[Signing Keys]({{< relref "signing-keys" >}})
{{% /see-also %}}
