---
title: "Stroom Configuration"
linkTitle: "Stroom Configuration"
weight: 10
date: 2026-08-03
tags:
  - open-id
  - authentication
description: >
  A reference for every Stroom and Stroom-Proxy setting involved in authenticating against an external identity provider.
---

This page is the provider agnostic reference for the Stroom side of the configuration.
The provider specific pages give the values to put in it for a given {{< glossary "idp" >}}.

All of these settings live under `security.authentication.openId` in the `config.yml` file, beneath `appConfig` for Stroom and `proxyConfig` for Stroom-Proxy.
The structure is identical for both.

{{% note %}}
`identityProviderType` cannot be changed at runtime; the application must be restarted for a change to take effect.
{{% /note %}}


## A Minimal Configuration

For most providers this is all that is needed:

```yaml
  security:
    authentication:
      authenticationRequired: true
      openId:
        identityProviderType: EXTERNAL_IDP
        openIdConfigurationEndpoint: "https://IDP_HOST/.well-known/openid-configuration"
        clientId: "StroomClient"
        clientSecret: "THE_CLIENT_SECRET"
        logoutEndpoint: "https://IDP_HOST/logout"
```

Stroom fetches the provider's configuration document from `openIdConfigurationEndpoint` at startup and takes the issuer, authorization endpoint, token endpoint and JWKS URI from it.
The logout endpoint is not part of that document, so it is set separately.

If you also want data receipt to be authenticated:

```yaml
  receive:
    # Require authentication for /datafeed requests
    authenticationRequired: true
    # Allow authentication using an Open ID token
    tokenAuthenticationEnabled: true
```


## Choosing the Identity Provider

### `identityProviderType`

```yaml
identityProviderType: EXTERNAL_IDP
```

| Value | Meaning |
| ----- | ------- |
| `INTERNAL_IDP` | Stroom's own built in IDP. The default for Stroom, and not valid for Stroom-Proxy. |
| `EXTERNAL_IDP` | A 3rd party IDP. Stroom's internal IDP can be the external IDP of a Stroom-Proxy. |
| `NO_IDP` | No IDP at all. Only for a Stroom-Proxy that forwards to a downstream proxy or Stroom and authenticates with an API key or certificate. |

Setting this to `EXTERNAL_IDP` makes `openIdConfigurationEndpoint` mandatory; Stroom will refuse to start without it.

{{% note %}}
A `TEST_CREDENTIALS` value existed in earlier versions and has been removed, along with the hard coded credentials behind it.
The replacement is described in [Insecure Test Credential]({{< relref "docs/install-guide/setup/open-id/test-credentials" >}}).
{{% /note %}}


## Endpoints

### `openIdConfigurationEndpoint`

The provider's OIDC discovery document, conventionally at `https://IDP_HOST/.well-known/openid-configuration`.
Setting this is much the easiest approach, as Stroom reads the other endpoints from it.


### `issuer`, `authEndpoint`, `tokenEndpoint`, `jwksUri`

Set these only if you are not using a configuration endpoint, or to override a value the provider advertises incorrectly.
Anything set here takes precedence over the discovery document.


### `logoutEndpoint`

Where Stroom sends the user to sign out at the provider.
This is not part of the discovery document, so it always has to be set by hand, and some providers do not offer one at all.

If it is not set, signing out ends the Stroom session but leaves the user signed in at the provider, so their next visit signs them straight back in without being asked for credentials.


### `logoutRedirectParamName`

```yaml
logoutRedirectParamName: "post_logout_redirect_uri"
```

The query parameter Stroom uses to tell the provider where to send the user after signing out.
The only permitted values are `post_logout_redirect_uri`, the default and what the current specification says, and `redirect_uri` for older providers.


## Client Credentials

### `clientId` and `clientSecret`

The client, sometimes called an application, registered at the provider.

`clientSecret` may be left unset when the provider authenticates Stroom by mutual TLS instead of a secret.

{{% warning %}}
The client secret is a credential.
Supply it through an environment variable or your secret management system rather than committing it to `config.yml`, and rotate it if it is ever exposed.
{{% /warning %}}


### `requestScopes`

```yaml
requestScopes:
  - "openid"
  - "email"
```

The scopes Stroom asks for during an interactive sign in.
Setting this replaces the defaults rather than adding to them, so include `openid` in whatever you set.
Add `profile` if you need the `name`, `given_name` or `family_name` claims for `fullNameClaimTemplate`.


### `clientCredentialsScopes`

```yaml
clientCredentialsScopes:
  - "openid"
```

The scopes used when Stroom or Stroom-Proxy requests a token for its own service user, rather than for a person.
Again, this replaces the default.
For Azure AD you will likely need `openid` and `<your-app-id-uri>/.default`.


### `formTokenRequest`

```yaml
formTokenRequest: true
```

Whether the token request is sent as an HTML form body.
Some providers, Cognito among them, require this.
It is on by default and rarely needs changing.


## Audience Validation

The `aud` claim of a token names the application the token was minted for.
Checking it is what stops a token issued to some other application at the same provider being replayed against Stroom.

Three settings control this.


### `validateAudience`

```yaml
validateAudience: true
```

On by default.
The audience is checked against `allowedAudiences`, or against `clientId` when `allowedAudiences` is empty.

{{% warning %}}
Setting this to `false` disables audience checking altogether and is not recommended.
Any token that any application at the same provider can obtain would then be accepted by Stroom.
{{% /warning %}}

With `identityProviderType: EXTERNAL_IDP` and `validateAudience` left on, at least one of `allowedAudiences` or `clientId` must be set.
Stroom refuses to start otherwise, rather than letting mandatory validation quietly become a no-op.


### `allowedAudiences`

```yaml
allowedAudiences: []
```

A set of acceptable audience values, of which a token must carry at least one.
When empty, Stroom validates against `clientId` instead.

Set this when the provider puts something other than the client id in the `aud` claim of its access tokens, which is common.


### `audienceClaimRequired`

```yaml
audienceClaimRequired: true
```

On by default: a token with no `aud` claim at all is refused.

Set it to `false` only for a provider that omits the claim from its access tokens, Cognito being the obvious example.
Doing so does not disable validation; an `aud` claim, where one is present, still has to match.

{{% warning %}}
The default changed from `false` to `true`, and an empty `allowedAudiences` used to mean no audience checking rather than checking against the client id.

On upgrade, a deployment whose provider does not put the Stroom client id in the `aud` claim of its access tokens will start rejecting API calls that previously worked.
Interactive sign in is unaffected, because `id_token`s always carry the client id.

The fix is either to make the provider issue the right audience, which is preferable, or to list what it does issue in `allowedAudiences`.
See the provider pages for which applies to you.
{{% /warning %}}


## Token Validation

### `requiredAccessTokenType`

```yaml
requiredAccessTokenType: null
```

The JOSE `typ` header value a token must carry to be accepted as a bearer access token on the API, for example `at+jwt` for a provider following {{< external-link "RFC 9068" "https://datatracker.ietf.org/doc/html/rfc9068" >}}, or `Bearer` for KeyCloak.

When set, a token of any other type, such as an `id_token`, is refused on the API even though its signature is perfectly valid.
That prevents an `id_token`, which is meant only to tell Stroom who signed in, being replayed as an access token.

Leave it unset, the default, to accept any type.
Set it once you have confirmed what your provider actually puts in that header; decoding the header of a real access token is the reliable way to find out.

This applies only to bearer tokens on the API.
It has no effect on the interactive sign in flow or on an AWS load balancer data token.


### `validIssuers`

```yaml
validIssuers: []
```

Additional issuers to accept beyond the one the provider advertises.

Stroom checks that the issuer in the provider's configuration response is consistent with `openIdConfigurationEndpoint`.
Where a provider legitimately reports an issuer that is not a parent path of that endpoint, list it here so the check passes.


### Signature Algorithms

Not configurable.
Stroom accepts RS256/384/512, PS256/384/512 and ES256/384/512, and refuses unsigned tokens and tokens signed with an HMAC algorithm.

There is no reason to expect a mainstream provider to fall foul of this.


## Claims

### `uniqueIdentityClaim`

```yaml
uniqueIdentityClaim: "sub"
```

The claim used to link an identity at the provider to a Stroom user.
It must be unique at the provider and must never change for a given person, which is why `sub` is the default and normally the right answer.


### `userDisplayNameClaim`

```yaml
userDisplayNameClaim: "preferred_username"
```

A friendlier name for the user in the Stroom UI.
Not used for identity, so it need not be unique and may change.

Change it if your provider does not issue `preferred_username`; `email` is the usual alternative.


### `fullNameClaimTemplate`

```yaml
fullNameClaimTemplate: '${name}'
```

Builds the user's full name from claim values, for example `'${given_name} ${family_name}'`.
Claim names are case sensitive.

{{% note %}}
Use single quotes in the YAML file, otherwise the `${...}` variables are expanded when the configuration file is loaded rather than when a user signs in.
{{% /note %}}


## AWS Load Balancer Authentication

These apply when an AWS Application Load Balancer in front of Stroom performs the authentication and passes the result on in an `x-amzn-oidc-data` header.


### `expectedSignerPrefixes`

```yaml
expectedSignerPrefixes: []
```

The Amazon Resource Names of the load balancer(s) fronting Stroom, used to verify the `signer` in the JWT header.
Each value is the first N characters of an ARN and must include at least everything up to the colon after the account id, i.e. `arn:aws:elasticloadbalancing:region-code:account-id:`.


### `publicKeyUriPattern`

```yaml
publicKeyUriPattern: 'https://public-keys.auth.elb.${awsRegion}.amazonaws.com/${keyId}'
```

The pattern used to build the URI the load balancer's public key is fetched from.
Supports the `${awsRegion}` and `${keyId}` variables, each of which may appear more than once.
Use single quotes, as with `fullNameClaimTemplate`.


## Stroom-Proxy

Stroom-Proxy takes the same `security.authentication.openId` block, under `proxyConfig`.
`identityProviderType: INTERNAL_IDP` is not valid for a proxy; use `EXTERNAL_IDP`, or `NO_IDP` where the proxy has no OIDC infrastructure available to it.

A proxy has no interactive users, so the settings concerned with the sign in flow, i.e. the redirect URIs, `requestScopes` and the claim settings, do not come into play.
What it needs is the ability to obtain a token for its own service user via the client credentials grant, and to validate tokens on data it receives.

```yaml
  receive:
    # Require authentication for /datafeed requests
    authenticationRequired: true
    # Allow authentication using an Open ID token
    tokenAuthenticationEnabled: true
  security:
    authentication:
      openId:
        identityProviderType: EXTERNAL_IDP
        openIdConfigurationEndpoint: "https://IDP_HOST/.well-known/openid-configuration"
        clientId: "StroomProxyClient"
        clientSecret: "THE_CLIENT_SECRET"
```

Where the proxy forwards data to another proxy or to Stroom, it can attach a token for its service user, provided the destination is configured against the same provider:

```yaml
  forwardHttpDestinations:
      # Adds a token for the service user to the request
    - addOpenIdAccessToken: true
      enabled: true
      name: "downstream"
      forwardUrl: "http://somehost/stroom/datafeed"
```

The client used by the proxy needs the client credentials grant enabled at the provider, and the destination must be willing to accept the audience that grant produces.
Not every provider supports issuing an OIDC token for a client credentials grant, so check the provider page.

{{% see-also %}}
See [Common Configuration]({{< relref "docs/install-guide/configuration/stroom-and-proxy/common-configuration#open-id-configuration" >}}) for this configuration block in the context of the whole file.
{{% /see-also %}}


## Troubleshooting

<!--
The headings below describe a symptom rather than naming a thing, so they read
as sentences and are deliberately in sentence case. Each is opted out of the
style check individually so that the rest of the section is still checked.
-->


<!-- style-check: disable -->
### Stroom will not start
<!-- style-check: enable -->

> If `identityProviderType` is set to 'EXTERNAL', property `openIdConfigurationEndpoint` must be set.

`EXTERNAL_IDP` requires a discovery endpoint.
If your provider genuinely has none, you cannot use this validation route; set the individual endpoints instead and raise it as an issue.

> When `identityProviderType` is EXTERNAL_IDP and `validateAudience` is true (the default), you must configure either `allowedAudiences` or `clientId`...

Stroom will not start with audience validation switched on and nothing to validate against, rather than let the check quietly become a no-op.
Set `clientId`, which you almost certainly want anyway, or `allowedAudiences`.

> Issuer 'X' obtained from configuration endpoint Y does not share the same base URI.

The provider is advertising an issuer that is not a parent path of the endpoint the document was fetched from, which the OIDC discovery specification says it should be.
Some providers do not follow this.
Where the value is genuinely correct for your provider, add it to `validIssuers`.

> Issuer 'X' obtained from configuration endpoint Y does not match those in the 'issuer' or 'validIssuers' properties.

You have set `issuer` or `validIssuers`, and what the provider advertised is not among them.
Correct the configured value, or add the advertised one.


<!-- style-check: disable -->
### The provider refuses the sign in
<!-- style-check: enable -->

An error at the provider, before the user gets back to Stroom, is almost always the redirect URI.
Check that `https://STROOM_FQDN/api/auth/flow/v1/signin-oidc` is registered exactly, using the same scheme, host, port and path prefix as `appConfig.publicUri`.

This is the single most common problem when upgrading, because Stroom used to send a different redirect URI for every page.


<!-- style-check: disable -->
### Sign in works but API calls are refused
<!-- style-check: enable -->

Interactive sign in validates the `id_token`, whereas the API validates an access token, and providers treat the two differently.
So sign in working tells you the client id, secret and endpoints are all correct, and points at the token validation settings.

In order of likelihood:

1. **Audience.**
   The access token's `aud` claim does not match `clientId` or `allowedAudiences`, or the token has no `aud` claim and `audienceClaimRequired` is `true`.
   See [Audience validation](#audience-validation).
1. **Token type.**
   `requiredAccessTokenType` is set to something the provider does not put in the token's `typ` header.
   Unset it, or correct it to the value the provider actually uses.
1. **Token type, the other way round.**
   The caller is presenting an `id_token` rather than an access token.
   Setting `requiredAccessTokenType` is what catches this.

Enable debug logging for `stroom.security.common.impl.StandardJwtContextFactory` to see the issuers, audiences and settings actually in use when a token is validated.


<!-- style-check: disable -->
### Users sign in but can see nothing
<!-- style-check: enable -->

That is expected for a new user.
Authentication is all the provider does; permissions are granted in Stroom, and a new user has none.
See [Users and permissions]({{< relref "docs/install-guide/setup/open-id/external-idp#users-and-permissions" >}}).

If an administrator you set up with `manage_users` cannot see anything either, remember that permissions are cached, so a restart may be needed if Stroom was running when the command was issued.


<!-- style-check: disable -->
### Signing out does not sign the user out of the provider
<!-- style-check: enable -->

Either `logoutEndpoint` is unset, or the provider has no OIDC sign out endpoint, as is the case for Google.
The Stroom session ends either way, but the provider's session does not, so the user's next visit signs them straight back in.
