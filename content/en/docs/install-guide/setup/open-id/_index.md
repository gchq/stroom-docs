---
title: "Setting up Stroom with an Open ID Connect IDP"
linkTitle: "Open ID Connect"
#weight:
date: 2026-08-03
cascade:
  tags:
    - open-id
    - authentication
description: >
  How to set up Stroom to authenticate users, either with its own internal identity provider or with a 3rd party one such as KeyCloak, Cognito or Google.
---

Stroom authenticates its users against an {{< glossary "idp" >}} using {{< external-link "Open ID Connect" "https://openid.net/connect/" >}}.
You have two choices for which provider that is.

* [Internal IDP]({{< relref "internal-idp" >}}) - Stroom acts as its own identity provider and manages the user accounts itself. This is the default.
* [External IDP]({{< relref "external-idp" >}}) - A 3rd party identity provider, such as KeyCloak, Cognito or Google, handles authentication.

Whichever you use, authorisation is always handled by Stroom.
The provider establishes who a user is; Stroom decides what they are allowed to do.

{{% see-also %}}
See [Accounts and Users]({{< relref "accounts-users" >}}) for how identities at the provider relate to Stroom users, and [Tokens for API use]({{< relref "tokens-for-api" >}}) for authenticating machine to machine.
{{% /see-also %}}
