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
  How to set up Stroom to authenticate users: with its own internal identity provider, with a 3rd party one such as KeyCloak, Cognito or Google, or behind an authenticating proxy such as an AWS Application Load Balancer.
---

Stroom authenticates its users against an {{< glossary "idp" >}} using {{< external-link "Open ID Connect" "https://openid.net/connect/" >}}.
There are three deployment models, distinguished by *where the user accounts live* and *which component performs the sign in*.

* [Internal IDP]({{< relref "internal-idp" >}}) - Stroom acts as its own identity provider and manages the user accounts itself. This is the default.
* [External IDP]({{< relref "external-idp" >}}) - A 3rd party identity provider, such as KeyCloak, Cognito or Google, holds the accounts; **Stroom performs the sign in** by redirecting the browser to it.
* [Edge Proxy RP]({{< relref "edge-proxy" >}}) - A 3rd party identity provider holds the accounts, but **an authenticating reverse proxy in front of Stroom performs the sign in** (an AWS Application Load Balancer with Cognito, NGINX with oauth2-proxy, etc.) and passes Stroom a verified identity with each request.

Not sure which you have?

| Your situation | Model |
| -------------- | ----- |
| No existing identity provider, or Stroom should manage its own accounts | [Internal IDP]({{< relref "internal-idp" >}}) |
| An existing IDP (KeyCloak, Cognito, Google, Entra ID) and browsers reach Stroom directly, or through a proxy that only routes | [External IDP]({{< relref "external-idp" >}}) |
| A load balancer or proxy in front of Stroom signs users in before traffic reaches it, e.g. an ALB `authenticate-cognito` rule, oauth2-proxy, or a policy that unauthenticated traffic must not reach the application | [Edge Proxy RP]({{< relref "edge-proxy" >}}) |

Whichever you use, authorisation is always handled by Stroom.
The provider establishes who a user is; Stroom decides what they are allowed to do.

{{% see-also %}}
See [Accounts and Users]({{< relref "accounts-users" >}}) for how identities at the provider relate to Stroom users, and [Tokens for API use]({{< relref "tokens-for-api" >}}) for authenticating machine to machine.
{{% /see-also %}}
