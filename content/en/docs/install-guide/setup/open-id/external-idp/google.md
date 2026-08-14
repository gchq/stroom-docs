---
title: "Google"
linkTitle: "Google"
weight: 40
date: 2026-08-03
tags:
  - open-id
  - authentication
description: >
  How to set up Google as an external identity provider for Stroom.
---

This page covers using {{< external-link "Google Identity" "https://developers.google.com/identity/openid-connect/openid-connect" >}} as Stroom's {{< glossary "idp" >}}, whether for consumer Google accounts or for a Google Workspace domain.

{{% see-also %}}
Read [External IDP]({{< relref "docs/install-guide/setup/open-id/external-idp" >}}) first for what Stroom needs from any provider, and [Stroom Configuration]({{< relref "stroom-configuration" >}}) for what each setting does.
{{% /see-also %}}

{{% warning %}}
Google is a more limited choice than KeyCloak or Cognito, in three respects.

* **Its access tokens are opaque, not JWTs.**
  Stroom cannot validate them, so token authentication for the API and for data receipt does not work with Google.
  Use Stroom {{< glossary "API Key" "API Keys" >}} instead.
* **It has no OIDC sign out endpoint.**
  Signing out of Stroom cannot sign the user out of Google.
* **It has no OIDC client credentials grant.**
  A Stroom-Proxy cannot obtain a service user token from Google.

Interactive sign in to the Stroom UI works perfectly well.
It is the machine to machine paths that Google does not serve.
{{% /warning %}}


## Creating the OAuth Client

In the {{< external-link "Google Cloud Console" "https://console.cloud.google.com/" >}}:

1. Select or create a project.
1. Configure the **OAuth consent screen**.
   For a Workspace domain choose the _Internal_ user type, which restricts sign in to your own domain.
   For consumer accounts the only option is _External_.
1. Go to _APIs & Services_ => _Credentials_ => _Create Credentials_ => _OAuth client ID_.
1. Choose an application type of **Web application**.
1. Under _Authorised redirect URIs_, add `https://STROOM_FQDN/api/auth/flow/v1/signin-oidc`.
1. Create the client and note the **Client ID** and **Client secret**.

Where `STROOM_FQDN` is the public address of Stroom, i.e. what you have set as `appConfig.publicUri`.

{{% warning %}}
Google matches redirect URIs exactly and **does not accept wildcards** of any kind.
It also requires `https`, other than for `http://localhost`.

This means that older Stroom guidance to register something like `https://STROOM_FQDN/*` could never have worked with Google.
Stroom now uses the single fixed callback URI above, which Google accepts.
{{% /warning %}}

Google supports PKCE, and Stroom always sends an `S256` challenge, so there is nothing to configure for it.

There is no sign out URL to register, because Google has no OIDC sign out endpoint to register one with.


## Configuring Stroom

```yaml
  security:
    authentication:
      authenticationRequired: true
      openId:
        identityProviderType: EXTERNAL_IDP
        openIdConfigurationEndpoint: "https://accounts.google.com/.well-known/openid-configuration"
        clientId: "123456789012-abcdefghijklmnop.apps.googleusercontent.com"
        clientSecret: "THE_CLIENT_SECRET"
        # Google issues no 'preferred_username' claim
        userDisplayNameClaim: "email"
        # 'profile' is needed for the 'name' claim used by fullNameClaimTemplate
        requestScopes:
          - "openid"
          - "email"
          - "profile"
```

The discovery document supplies the issuer, `https://accounts.google.com`, along with the authorization, token and JWKS endpoints, so none of those need setting by hand.

Note that `logoutEndpoint` is deliberately absent; see [Signing out](#signing-out) below.


### Audience Validation

Nothing to do.
Google's `id_token` carries `aud` set to your client id, so it validates against `clientId` with the default settings.


### Claims

Google issues `sub`, `email`, `email_verified`, `name`, `given_name`, `family_name` and `picture`, and `hd` for a Workspace account.
It does **not** issue `preferred_username`, which is Stroom's default for `userDisplayNameClaim`, so that has to be changed.
`email` is the natural choice.

`name`, `given_name` and `family_name` require the `profile` scope, which is why it is added to `requestScopes` above.
Without it the default `fullNameClaimTemplate` of `${name}` will not resolve.

Leave `uniqueIdentityClaim` as `sub`.
Google's `sub` is stable for a given account, unlike the email address.

{{% warning %}}
Do not set `uniqueIdentityClaim` to `email`.
A Workspace administrator can reassign an address to a different person, who would then inherit the Stroom user and all of its permissions.
Google's own guidance is to key on `sub` for exactly this reason.
{{% /warning %}}


### Signing Out

Google offers no OIDC sign out endpoint, so leave `logoutEndpoint` unset.

Logging out of Stroom then ends the Stroom session but leaves the user signed in to Google.
Their next visit to Stroom will sign them straight back in without being asked for credentials, which is worth being aware of on a shared machine.

Do not point `logoutEndpoint` at a general Google sign out URL, as that would sign the user out of every Google service on that browser, which is unlikely to be what they expect from a Stroom logout.


### Access Token Type

Leave `requiredAccessTokenType` unset.
It applies to JWT bearer tokens on the API, and Google's access tokens are not JWTs.


## Restricting Who Can Sign In

Authentication and authorisation are separate.
Anyone Google will authenticate can complete a sign in and have a Stroom user created for them, but that user starts with no permissions and no group memberships, so they can see nothing.

Even so, you should restrict who can reach the sign in at all:

* For a Workspace domain, set the OAuth consent screen to _Internal_, so only accounts in your domain can authenticate.
* For consumer accounts there is no equivalent, so any Google account can reach the consent screen.
  Consider whether Google is the right provider in that case.

Stroom has no configuration to restrict sign in by `hd` or email domain, so this has to be done at Google.


## Setting up the Admin User in Stroom

Find the `sub` of the account that is to be the administrator.
Unlike KeyCloak and Cognito, Google does not show this in an admin console; the reliable way to obtain it is to decode an `id_token` issued for that account, or read it from Stroom's logs after the person has signed in once.

The simplest route is therefore:

1. Configure Stroom as above and start it.
1. Have the intended administrator sign in once.
   They will land in Stroom with no permissions.
1. Read their `sub` from the Stroom logs, or from the {{< stroom-menu "Tools" "Users" >}} screen if another administrator is available.
1. Run the `manage_users` command with that value, then restart Stroom so the permission caches are rebuilt.

{{< command-line >}}
subject_id="XXX"; \
java -jar /absolute/path/to/stroom-app-all.jar \
  manage_users \
  --createUser "${subject_id}" \
  --createGroup Administrators \
  --addToGroup "${subject_id}" Administrators \
  --grantPermission Administrators "Administrator" \
  ../local.yml
{{</ command-line >}}

The command is repeatable and will skip anything that already exists, so running it against a user that signed in earlier is fine.

{{% see-also %}}
See [KeyCloak]({{< relref "keycloak#setting-up-the-admin-user-in-stroom" >}}) for a fuller description of what this command does, and [Command Line Tools]({{< relref "docs/user-guide/tools/command-line" >}}) for its options.
{{% /see-also %}}


## Data Receipt and the API

Because Google's access tokens are opaque rather than JWTs, Stroom cannot validate them, so this will not work:

```yaml
  receive:
    authenticationRequired: true
    tokenAuthenticationEnabled: true
```

Use Stroom {{< glossary "API Key" "API Keys" >}} for API clients and for feed status checks, or client certificates for data receipt.

{{% see-also %}}
See [Tokens for API use]({{< relref "docs/install-guide/setup/open-id/tokens-for-api" >}}).
{{% /see-also %}}


## Stroom-Proxy with Google

Google has no OIDC client credentials grant, so a Stroom-Proxy cannot obtain a service user token from it, and `addOpenIdAccessToken` on a forward destination has nothing to add.

Configure the proxy with `identityProviderType: NO_IDP` and give it an API key created in Stroom:

```yaml
  feedStatus:
    apiKey: "AN_API_KEY_CREATED_IN_STROOM"
  security:
    authentication:
      openId:
        identityProviderType: NO_IDP
```
