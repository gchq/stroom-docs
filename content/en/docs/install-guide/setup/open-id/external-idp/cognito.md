---
title: "Amazon Cognito"
linkTitle: "Amazon Cognito"
weight: 30
date: 2026-08-03
tags:
  - open-id
  - authentication
description: >
  How to set up an Amazon Cognito user pool as an external identity provider for Stroom.
---

This page covers using an {{< external-link "Amazon Cognito" "https://docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html" >}} user pool as Stroom's {{< glossary "idp" >}}.

{{% see-also %}}
Read [External IDP]({{< relref "docs/install-guide/setup/open-id/external-idp" >}}) first for what Stroom needs from any provider, and [Stroom Configuration]({{< relref "stroom-configuration" >}}) for what each setting does.
{{% /see-also %}}

{{% note %}}
This page covers Stroom itself being the OIDC client of the user pool.
If Stroom sits behind an AWS Application Load Balancer whose listener rule does the authentication, the load balancer is the client instead - see [AWS ALB and Cognito]({{< relref "docs/install-guide/setup/open-id/edge-proxy/aws-alb-cognito" >}}).
{{% /note %}}

Cognito differs from a typical OIDC provider in two ways that directly affect the Stroom configuration, so they are worth knowing before you start.

* Its **access tokens carry no `aud` claim**, using `client_id` instead.
  Stroom requires an audience claim by default, so this has to be turned off.
* Its authorization, token and sign out endpoints belong to the **hosted UI domain**, which is separate from the user pool's issuer host.


## Creating the User Pool and App Client

In the AWS console, under Cognito:

1. Create a user pool, or use an existing one.
1. Configure a **domain** for the pool, either a Cognito prefix domain giving `https://YOUR_PREFIX.auth.REGION.amazoncognito.com`, or your own custom domain.
   This provides the hosted UI and the OAuth endpoints, and is required.
1. Create an **app client** of the confidential type, i.e. one with a client secret.
1. Enable the **Authorization code grant** for the client.
   Do not enable the implicit grant.
1. Set the OpenID Connect scopes to at least `openid` and `email`.
1. Set the **Allowed callback URL** to `https://STROOM_FQDN/api/auth/flow/v1/signin-oidc`.
1. Set the **Allowed sign out URL** to `https://STROOM_FQDN/`.
1. Note the app client id and app client secret, and the user pool id.

Where `STROOM_FQDN` is the public address of Stroom, i.e. what you have set as `appConfig.publicUri`.

{{% note %}}
Cognito requires callback URLs to use `https`, other than for `http://localhost`.
It matches them exactly and does not accept wildcards, so register the single URI above rather than anything broader.
{{% /note %}}

Cognito supports PKCE, and Stroom always sends an `S256` challenge, so there is nothing to configure for it.


## The Endpoints

Two different hosts are involved.

| Purpose | Host |
| ------- | ---- |
| Issuer, discovery document, JWKS | `https://cognito-idp.REGION.amazonaws.com/USER_POOL_ID` |
| Authorization, token, sign out | Your pool's domain, e.g. `https://YOUR_PREFIX.auth.REGION.amazoncognito.com` |

The discovery document is at:

```
https://cognito-idp.REGION.amazonaws.com/USER_POOL_ID/.well-known/openid-configuration
```

Set `openIdConfigurationEndpoint` to it, so that Stroom picks up the issuer and the JWKS URI.

Set `authEndpoint` and `tokenEndpoint` explicitly to your pool's domain, since those are the endpoints your users and Stroom actually need to reach:

* `https://YOUR_PREFIX.auth.REGION.amazoncognito.com/oauth2/authorize`
* `https://YOUR_PREFIX.auth.REGION.amazoncognito.com/oauth2/token`

{{% note %}}
Compare these against what your pool's discovery document advertises.
Where the two agree you can leave `authEndpoint` and `tokenEndpoint` unset and let the discovery document supply them; setting them explicitly is the reliable option.
{{% /note %}}


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
        openIdConfigurationEndpoint: "https://cognito-idp.eu-west-2.amazonaws.com/eu-west-2_ABC123456/.well-known/openid-configuration"
        # The hosted UI endpoints, which are on the pool's domain rather than the issuer host
        authEndpoint: "https://mydomain.auth.eu-west-2.amazoncognito.com/oauth2/authorize"
        tokenEndpoint: "https://mydomain.auth.eu-west-2.amazoncognito.com/oauth2/token"
        logoutEndpoint: "https://mydomain.auth.eu-west-2.amazoncognito.com/logout"
        # The app client id and secret
        clientId: "1h57kf5cpparlm9m52319hsnrf"
        clientSecret: "THE_APP_CLIENT_SECRET"
        # Cognito requires the token request to be sent as a form. This is the default.
        formTokenRequest: true
        # Cognito access tokens carry no 'aud' claim, so an absent one must not be a failure.
        # An 'aud' claim that IS present, as on an id_token, is still validated against clientId.
        audienceClaimRequired: false
        # Cognito does not issue 'preferred_username'
        userDisplayNameClaim: "cognito:username"
```


### Audience Validation

This is the setting most likely to catch you out.

A Cognito **id_token**, used by interactive sign in, carries `aud` set to the app client id, so it validates against `clientId` with no further configuration.

A Cognito **access token**, used for API calls, carries no `aud` claim at all; the equivalent information is in a `client_id` claim, which is not something Stroom validates against.
With the default of `audienceClaimRequired: true` those tokens are refused, so set it to `false`.

{{% warning %}}
`audienceClaimRequired` defaults to `true`, having previously defaulted to `false`.
If you are upgrading an existing Cognito deployment, add `audienceClaimRequired: false` before you upgrade, otherwise API calls made with Cognito access tokens will start being refused.
Interactive sign in is unaffected.
{{% /warning %}}

Leave `validateAudience` at its default of `true`.
Setting it to `false` would switch off audience checking for the `id_token` as well, which Cognito populates perfectly well.


### Claims

Cognito does not issue a `preferred_username` claim unless the user pool has been set up with that attribute, so the Stroom default for `userDisplayNameClaim` will usually not resolve.
Use `cognito:username`, or `email` where every user has one.

`uniqueIdentityClaim` should be left as `sub`, which for Cognito is a UUID that is stable for the life of the user.

{{% warning %}}
Do not be tempted to use `email` or `cognito:username` as the `uniqueIdentityClaim`.
Both can be changed or reassigned to another person, who would then inherit the Stroom user and its permissions.
{{% /warning %}}

For `fullNameClaimTemplate` to resolve, the corresponding attributes must be populated on the user and included in the token.
Add `profile` to `requestScopes` if you need `name`, `given_name` or `family_name`.


### Signing Out

Cognito's sign out endpoint has historically expected the return address in a `logout_uri` parameter rather than the `post_logout_redirect_uri` that Stroom sends.

Check whether sign out returns your users to Stroom.
If it leaves them on an error page at Cognito, try:

```yaml
        logoutRedirectParamName: "redirect_uri"
```

Those two values are the only ones Stroom accepts.
If neither works with your pool, leave `logoutEndpoint` unset; signing out will then end the Stroom session without signing the user out of Cognito, which means their next visit will sign them straight back in without being asked for credentials.


### Access Token Type

Leave `requiredAccessTokenType` unset unless you have decoded the header of a real Cognito access token and confirmed what it contains.
It is a hardening measure, and setting it to a value your provider does not use will refuse every API call.


## Setting up the Admin User in Stroom

The bootstrap process is the same as for any provider.
Find the `sub` of the user who is to be the administrator, which for Cognito is the user's UUID as shown in the console, then run the `manage_users` command **before** starting Stroom for the first time.

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

{{% see-also %}}
See [KeyCloak]({{< relref "keycloak#setting-up-the-admin-user-in-stroom" >}}) for a fuller description of what this command does, and [Command Line Tools]({{< relref "docs/user-guide/tools/command-line" >}}) for its options.
{{% /see-also %}}


## Stroom-Proxy with Cognito

A Stroom-Proxy obtains a token for its own service user using the client credentials grant.

In Cognito that grant requires a resource server with custom scopes defined on it, and the resulting tokens carry those custom scopes rather than `openid`.
Set `clientCredentialsScopes` to the custom scopes you have defined:

```yaml
  security:
    authentication:
      openId:
        identityProviderType: EXTERNAL_IDP
        openIdConfigurationEndpoint: "https://cognito-idp.eu-west-2.amazonaws.com/eu-west-2_ABC123456/.well-known/openid-configuration"
        tokenEndpoint: "https://mydomain.auth.eu-west-2.amazoncognito.com/oauth2/token"
        clientId: "THE_PROXY_APP_CLIENT_ID"
        clientSecret: "THE_PROXY_APP_CLIENT_SECRET"
        formTokenRequest: true
        audienceClaimRequired: false
        clientCredentialsScopes:
          - "https://stroom.example.com/api.write"
```

The destination the proxy forwards to must be configured to accept the tokens this produces, which again means `audienceClaimRequired: false` at that end.
