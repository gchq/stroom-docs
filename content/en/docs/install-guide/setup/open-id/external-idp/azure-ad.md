---
title: "Microsoft Entra ID (Azure AD)"
linkTitle: "Microsoft Entra ID"
weight: 50
date: 2026-08-03
tags:
  - open-id
  - authentication
description: >
  How to set up Microsoft Entra ID, formerly Azure Active Directory, as an external identity provider for Stroom.
---

This page covers using {{< external-link "Microsoft Entra ID" "https://learn.microsoft.com/en-us/entra/identity-platform/v2-protocols-oidc" >}} as Stroom's {{< glossary "idp" >}}.
Entra ID is the current name for what was Azure Active Directory, and much of the tooling and documentation still says Azure AD.

{{% see-also %}}
Read [External IDP]({{< relref "docs/install-guide/setup/open-id/external-idp" >}}) first for what Stroom needs from any provider, and [Stroom Configuration]({{< relref "stroom-configuration" >}}) for what each setting does.
{{% /see-also %}}

Entra ID has two generations of endpoint, v1.0 and v2.0, which issue tokens with different issuers and different formats.
Two of the three things most likely to go wrong here come from mixing them up, so it is worth being deliberate: **use the v2.0 endpoints throughout**.


## Creating the App Registration

In the {{< external-link "Microsoft Entra admin centre" "https://entra.microsoft.com/" >}}, or the Azure portal under _Microsoft Entra ID_:

1. Go to _App registrations_ => _New registration_.
1. Give it a name, e.g. `Stroom`.
1. For _Supported account types_ choose **Accounts in this organizational directory only**, i.e. single tenant, unless you have a specific reason not to.
   This restricts sign in to your own tenant.
1. Under _Redirect URI_ select a platform of **Web** and enter `https://STROOM_FQDN/api/auth/flow/v1/signin-oidc`.
1. Click _Register_, then note the **Application (client) ID** and the **Directory (tenant) ID** from the overview page.

Where `STROOM_FQDN` is the public address of Stroom, i.e. what you have set as `appConfig.publicUri`.

{{% warning %}}
Entra ID matches redirect URIs exactly and does not accept wildcards.
It also requires `https`, other than for `http://localhost`.

Register the single exact URI above.
Earlier versions of Stroom sent the user's current page as the redirect URI; if you are upgrading, remove whatever was registered for that.
{{% /warning %}}

Then, still in the app registration:

1. Under _Authentication_, add a **Front-channel logout URL** of `https://STROOM_FQDN/`, and add the same value under _Redirect URIs_ if your tenant requires post logout redirect URIs to be registered.
1. Under _Certificates & secrets_ => _Client secrets_, create a new secret and copy its **Value** immediately, as it is only shown once.

{{% warning %}}
Entra ID client secrets **expire**, with a maximum lifetime of 24 months.
When the secret expires Stroom will stop being able to exchange authorization codes for tokens and nobody will be able to sign in.

Record the expiry date and plan the rotation, or use certificate credentials instead.
{{% /warning %}}

Entra ID supports PKCE, and Stroom always sends an `S256` challenge, so there is nothing to configure for it.


## Exposing an API for Access Tokens

This step is what makes API authentication work, and is the Entra ID equivalent of KeyCloak's audience mapper.

If Stroom only ever asks for the `openid`, `email` and `profile` scopes, Entra ID issues an access token for Microsoft Graph rather than for Stroom.
Those tokens are intended only for Graph, are not in a format a third party can validate, and will fail validation at Stroom.
Interactive sign in still works throughout, because it uses the `id_token`.

To get an access token that Stroom can validate, the app registration has to expose an API of its own:

1. Go to _Expose an API_ => _Add_ next to _Application ID URI_.
   Accept the default of `api://<client-id>`, or set your own.
1. Click _Add a scope_, name it something like `user_impersonation`, and choose who can consent.
1. Under _Manifest_, set `accessTokenAcceptedVersion` to `2`.

{{% note %}}
`accessTokenAcceptedVersion` defaults to `null`, which means v1.0.
A v1.0 access token has an issuer of `https://sts.windows.net/TENANT_ID/`, which does not match the v2.0 issuer that Stroom obtains from the v2.0 discovery document, so such tokens are refused.

Setting it to `2` is the clean fix.
See [Issuers](#issuers) if you have a reason to stay on v1.0.
{{% /note %}}

Callers then request that scope, e.g. `api://<client-id>/user_impersonation`, and the resulting access token carries an `aud` claim that Stroom can be configured to accept.


## Configuring Stroom

```yaml
  receive:
    # Set to true to require authentication for /datafeed requests
    authenticationRequired: true
    # Set to true to allow authentication using an Open ID token
    tokenAuthenticationEnabled: true
  security:
    authentication:
      authenticationRequired: true
      openId:
        identityProviderType: EXTERNAL_IDP
        # Note the '/v2.0' path part. Without it you get the v1.0 endpoints and a different issuer.
        openIdConfigurationEndpoint: "https://login.microsoftonline.com/TENANT_ID/v2.0/.well-known/openid-configuration"
        # The Application (client) ID from the app registration overview
        clientId: "11111111-2222-3333-4444-555555555555"
        clientSecret: "THE_CLIENT_SECRET_VALUE"
        logoutEndpoint: "https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/logout"
        # Accept both the id_token audience (the client id) and the access token audience
        # (the Application ID URI). Adjust to match what your tokens actually carry.
        allowedAudiences:
          - "11111111-2222-3333-4444-555555555555"
          - "api://11111111-2222-3333-4444-555555555555"
```

Replace `TENANT_ID` with the Directory (tenant) ID.


### Issuers

The v2.0 discovery endpoint advertises an issuer of `https://login.microsoftonline.com/TENANT_ID/v2.0`, which is a parent path of the discovery endpoint itself, so Stroom's issuer check is satisfied with no extra configuration.

The v1.0 endpoints are not so tidy.
Their issuer is `https://sts.windows.net/TENANT_ID/`, which shares no base URI with the discovery endpoint, and Stroom will refuse to start with:

> Issuer 'X' obtained from configuration endpoint Y does not share the same base URI.

If you must use v1.0, or you have v1.0 access tokens in circulation from an app registration you cannot change, list the issuer explicitly:

```yaml
        validIssuers:
          - "https://sts.windows.net/TENANT_ID/"
```

Using the v2.0 endpoints and `accessTokenAcceptedVersion: 2` is much the better answer.

{{% note %}}
Do not use the `common` or `organizations` endpoints in place of a tenant id.
Their discovery documents report an issuer containing a literal `{tenantid}` placeholder rather than a real value, and they allow sign in from any tenant, which is unlikely to be what you want.
{{% /note %}}


### Audience Validation

An Entra ID **id_token** carries `aud` set to the Application (client) ID, so interactive sign in validates against `clientId` with no further configuration.

An **access token** for your exposed API carries `aud` set to either the Application ID URI or the client id, depending on `accessTokenAcceptedVersion` and how the scope was requested.
Listing both in `allowedAudiences`, as above, covers either.

{{% warning %}}
Do not simply set `audienceClaimRequired: false` to make a rejection go away.
Entra ID does populate the audience claim, so an absent one means the token is not the one you think it is, most likely a Microsoft Graph token, and loosening the check hides that rather than fixing it.
{{% /warning %}}

Leave `validateAudience` at its default of `true`.


### Claims

The Stroom defaults suit Entra ID v2.0.
It issues `preferred_username`, normally the user principal name, which Stroom uses as the display name, and `name`, which satisfies the default `fullNameClaimTemplate` of `${name}`.

For `uniqueIdentityClaim` you have a choice:

| Claim | Notes |
| ----- | ----- |
| `sub` | The Stroom default. In Entra ID this is pairwise, i.e. a different value per application, and stable for the life of that app registration. Delete and recreate the app registration and every user's `sub` changes, orphaning their Stroom user. |
| `oid` | The user's object id in the directory. Stable across applications and across app registrations, so it survives a re-registration. Unique within a tenant. |

`oid` is the more robust choice for a single tenant deployment, and is what Microsoft's own guidance points to as the durable identifier.
`sub` is fine if you are confident the app registration will not be recreated.

```yaml
        uniqueIdentityClaim: "oid"
```

{{% warning %}}
Whichever you choose, decide before the first user signs in.
Changing it later means every existing Stroom user is orphaned, and their permissions and group memberships have to be reapplied to the new identities.

Do not use `preferred_username`, `email` or `upn`; all can be reassigned to a different person, who would then inherit the Stroom user.
{{% /warning %}}


### Group and Role Claims

Entra ID can be configured to emit `groups` and `roles` claims.
Stroom does not consume them.
All authorisation is done with Stroom's own users, groups and permissions, so directory group membership has no effect on what a user can do in Stroom.


### Access Token Type

Leave `requiredAccessTokenType` unset until you have decoded the header of a real access token from your tenant and confirmed what it contains.
Setting it to a value your tokens do not use will refuse every API call.


## Setting up the Admin User in Stroom

Find the identifier of the account that is to be the administrator, matching whatever you set `uniqueIdentityClaim` to.

If you are using `oid`, it is shown as the **Object ID** on the user's page under _Users_ in the Entra admin centre.
If you are using `sub`, it is pairwise and not shown anywhere in the portal, so you will need to decode an `id_token` issued for that user, or have them sign in once and read it from the Stroom logs.

Then run the following, ideally **before** Stroom has been started for the first time:

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

The command is repeatable and will skip anything that already exists, so running it against a user who has already signed in is fine.
Restart Stroom afterwards if it was running, as permissions are cached.

{{% see-also %}}
See [KeyCloak]({{< relref "keycloak#setting-up-the-admin-user-in-stroom" >}}) for a fuller description of what this command does, and [Command Line Tools]({{< relref "docs/user-guide/tools/command-line" >}}) for its options.
{{% /see-also %}}


## Stroom-Proxy with Entra ID

A Stroom-Proxy obtains a token for its own service user using the client credentials grant.

Create a second app registration for the proxy, then grant it access to the API exposed by the Stroom app registration:

1. In the proxy's app registration, go to _API permissions_ => _Add a permission_ => _My APIs_ and select the Stroom app registration.
1. Choose _Application permissions_, which is the client credentials case, rather than delegated permissions.
1. Have a directory administrator **grant admin consent**, without which the grant will fail.

Entra ID's client credentials flow uses the `.default` scope of the target API:

```yaml
  security:
    authentication:
      openId:
        identityProviderType: EXTERNAL_IDP
        openIdConfigurationEndpoint: "https://login.microsoftonline.com/TENANT_ID/v2.0/.well-known/openid-configuration"
        clientId: "THE_PROXY_CLIENT_ID"
        clientSecret: "THE_PROXY_CLIENT_SECRET"
        clientCredentialsScopes:
          - "api://11111111-2222-3333-4444-555555555555/.default"
```

{{% note %}}
Stroom's default for `clientCredentialsScopes` is `openid`, and its configuration description suggests setting `openid` alongside the `.default` scope.
Entra ID's v2.0 client credentials flow generally accepts a `.default` scope on its own and rejects it being combined with others, so start with just the `.default` scope as above and add `openid` only if your tenant requires it.
{{% /note %}}

The destination the proxy forwards to must accept the audience these tokens carry, which will be the Application ID URI or client id of the Stroom app registration, so make sure it appears in that destination's `allowedAudiences`.
