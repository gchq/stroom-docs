---
title: "Signing Keys"
linkTitle: "Signing Keys"
weight: 36
date: 2026-07-29
tags:
  - authentication
  - token
  - administration
description: >
  The keys Stroom's internal identity provider uses to sign tokens, and how to withdraw one that may have been exposed.
---

When Stroom acts as its own {{< glossary "idp" >}} it signs the tokens it issues with a key that it creates and replaces by itself.
Nodes and Stroom-Proxy check that signature to satisfy themselves that a token really came from Stroom.

This screen exists so that a key believed to have been exposed can be withdrawn.
It is not needed for day to day running, because keys are replaced automatically.

{{% note %}}
This screen requires the `Administrator` {{< glossary "Application Permission" >}}, rather than `Manage Users` which is enough for most other security screens.
Withdrawing a signing key affects everybody using Stroom at once, so it is treated as an application wide action.
{{% /note %}}

Reach the screen by selecting

{{< stroom-menu "Security" "Signing Keys" >}}

from the main menu.


## What the Screen Shows

Each key is listed with its status and the date it was issued, and nothing else.
Nothing that identifies a key or describes its contents is shown, because the stored key includes the private half that produces signatures.

| Status | Meaning |
| ------ | ------- |
| _Active_ | New tokens are being signed with this key. |
| _Retired_ | No longer signing new tokens, but still trusted so that tokens already issued keep working. Shown with the date that trust ends. |
| _Expired_ | No longer trusted. Removed automatically shortly afterwards. |
| _Revoked_ | Withdrawn by an administrator. Anything signed with it is already refused. |

The active key has no end date.
Keys here do not expire on a schedule.
Rotation replaces the active key when it is old enough, and only at that point does the key it replaced gain a date on which it stops being trusted.


## Automatic Rotation

Stroom replaces the active signing key every `stroom.security.identity.token.jwkRotationInterval`, which is thirty days by default.

Rotation is invisible to users.
The key being replaced continues to be trusted for long enough that every token already signed with it expires naturally, so nobody is signed out and nothing needs to be restarted.


## Revoking a Key

Revoking withdraws a key immediately.
Any token signed with it stops being accepted, and a replacement signing key is created at the same moment so that Stroom can carry on issuing tokens.

There are two actions.

* _Revoke_ withdraws the selected key.
* _Revoke all_ withdraws every key that is still trusted, for when a key is believed to have been exposed but it is not known which.

Both actions ask for confirmation first, and the confirmation says what that particular key will cost, because the effect differs enormously between them.
Revoking a retired key usually affects a handful of people, while revoking the active key affects everyone.

{{% warning %}}
Revoking cannot be undone.
There is no way to restore trust in a key that has been withdrawn.

Revoke a key only if you believe it may have been exposed.
A key revoked by mistake costs everybody a fresh sign in, but no data is lost.
{{% /warning %}}


### What to Expect after Revoking the Active Key

Everybody using Stroom is signed out and must authenticate again.
For people at a browser this is quick, and they will be signed back in as soon as they do so.

Nodes and Stroom-Proxy hold their own tokens signed with the same key, and they replace those tokens as they expire rather than immediately.
Parts of the cluster may therefore be unable to talk to one another for up to ten minutes.
This resolves itself and needs no intervention, but it is worth expecting rather than being surprised by, and it is a good reason to reserve this action for a suspected compromise.

Revoking a retired or expired key has no such effect, as nothing is signing with it.

{{% see-also %}}
[Sessions and Tokens]({{< relref "sessions-and-tokens" >}})
[Internal IDP]({{< relref "docs/install-guide/setup/open-id/internal-idp" >}})
{{% /see-also %}}
