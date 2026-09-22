---
title: "AWS Application Load Balancer"
linkTitle: "AWS ALB"
weight: 20
date: 2026-09-22
tags:
  - open-id
  - authentication
description: >
  Running Stroom behind an AWS Application Load Balancer that authenticates users against Amazon Cognito, Microsoft Entra ID or any other Open ID Connect provider.
---

In this deployment the {{< external-link "Application Load Balancer" "https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html" >}} is the Open ID Connect Relying Party.
Its listener rule sends unauthenticated browsers to the {{< glossary "idp" >}}, completes the code flow, holds the session in `AWSELBAuthSessionCookie` cookies, and forwards each authenticated request to Stroom with three extra headers:

| Header | Contents |
| ------ | -------- |
| `x-amzn-oidc-data` | The user's claims as a JWT, **signed by the ALB** with a regional AWS key (ES256) |
| `x-amzn-oidc-accesstoken` | The access token from the IDP, in plain text |
| `x-amzn-oidc-identity` | The `sub` claim, in plain text |

Stroom authenticates the request by verifying the `x-amzn-oidc-data` signature against AWS's regional public key endpoint, checking the token's issuer against the configured one, and checking that the signing load balancer is one of yours.

The ALB can authenticate against an Amazon Cognito user pool (an `authenticate-cognito` rule) or against any OIDC provider directly (an `authenticate-oidc` rule).
Stroom does not care which: the token it verifies is minted and signed by the ALB either way.
What the IDP changes is covered in [What Depends on the IDP](#what-depends-on-the-idp), with worked examples for [Cognito](#amazon-cognito) and [Entra ID](#microsoft-entra-id) below.

{{% see-also %}}
Read [Edge Proxy RP]({{< relref "docs/install-guide/setup/open-id/edge-proxy" >}}) first for the model, the path scoping rules and the trust prerequisites.
{{% /see-also %}}


## How the ALB Builds the Token

It matters where the claims in `x-amzn-oidc-data` come from, because it is not where the [External IDP]({{< relref "docs/install-guide/setup/open-id/external-idp" >}}) pages assume.

After exchanging the authorization code, the ALB sends the access token to the IDP's **user info endpoint** and signs the claims that come back.
The ID token is discarded; nothing from it reaches Stroom.
The payload therefore contains only what the IDP's user info endpoint returns, which is typically a small subset of the ID token's claims, plus an `iss` and `exp` that the ALB adds.

Two consequences for the Stroom configuration:

* `uniqueIdentityClaim` and `userDisplayNameClaim` must name claims that the **user info endpoint** returns.
  A claim that is only in the ID token, such as Entra ID's `oid`, cannot be used.
* Stroom checks the payload's `iss` against the issuer from `openIdConfigurationEndpoint`, so the issuer the ALB is configured with must be exactly the one the IDP's discovery document advertises.


## Load Balancer Setup

The `authenticate-cognito` and `authenticate-oidc` actions are only supported on an **HTTPS** listener.

Order the listener rules so machine traffic and the post logout page are served *without* authentication, then authenticate everything else:

1. Paths `/datafeed*`, `/stroom/datafeed*`, `/remoting/*`, `/status` → **forward** to the Stroom target group.
1. Path `/signed-out` → **fixed-response** with status `200`, content type `text/html` and body:

   ```html
   <html><body><p>You have been signed out.</p><p><a href="/">Sign in again</a></p></body></html>
   ```

1. Default → **authenticate-cognito** or **authenticate-oidc** (see the IDP sections below) then **forward** to the Stroom target group.

The `/signed-out` rule is the landing page for [logout](#logout).
Stroom does not serve one of its own, and it must be a page the authenticate rule does not cover, so the load balancer answers it directly.

Points worth knowing:

* `SessionCookieName` defaults to `AWSELBAuthSessionCookie`; if you change it, change `edgeAuthentication.logout.cookiesToExpire` to match.
* The session cookie is sharded at 4KB per shard (`-0`, `-1`, ...), which is why the [header size limit]({{< relref "docs/install-guide/setup/open-id/edge-proxy#request-header-sizes" >}}) matters.
* If the total claims and access token exceed 11KB the ALB itself returns HTTP 500 and increments its `ELBAuthUserClaimsSizeExceeded` metric — trim what the IDP puts in the token if you hit this.
* The ALB holds the IDP client secret, so the secret's rotation is now a listener rule change, not a Stroom one.
* Restrict the Stroom target's security group to accept traffic only from the ALB's security group; this is [trust prerequisite one]({{< relref "docs/install-guide/setup/open-id/edge-proxy#trust-prerequisites" >}}).


## Stroom Configuration

The parts that do not depend on the IDP:

```yaml
server:
  applicationConnectors:
    - type: http
      port: 8080
      useForwardedHeaders: true
      maxRequestHeaderSize: 32KiB

appConfig:
  publicUri: "https://STROOM_FQDN"    # the ALB's public address
  security:
    authentication:
      edgeAuthentication:
        enabled: true
        logout:
          cookiesToExpire: [ "AWSELBAuthSessionCookie" ]
          signOutUrl: "IDP_SIGN_OUT_URL"    # see the IDP sections below
      openId:
        identityProviderType: EXTERNAL_IDP
        # The IDP's discovery document; supplies the issuer that x-amzn-oidc-data is
        # checked against. Stroom runs no flow of its own, so no clientSecret is needed.
        openIdConfigurationEndpoint: "IDP_DISCOVERY_URL"
        # The ALB's client at the IDP.
        clientId: "ALB_CLIENT_ID"
        # MANDATORY - pins the JWT's 'signer' header to your load balancer(s).
        # Without it, every x-amzn-oidc-data token is rejected. Each value must reach at
        # least the account id; use the full ALB ARN where you know it.
        expectedSignerPrefixes:
          - "arn:aws:elasticloadbalancing:REGION:ACCOUNT_ID:"
```


### `expectedSignerPrefixes`

The regional AWS endpoint that Stroom fetches verification keys from serves the keys of **every** load balancer in that region, so the signature alone proves a token came from *an* ALB, not from *your* ALB.
This setting closes that gap: the `signer` field in the token's header, which is the signing load balancer's ARN, must start with one of the configured values.

It is required — with it unset, every ALB token is rejected, and the log message names this property.


### `publicKeyUriPattern`

The default value fetches keys from `https://public-keys.auth.elb.${awsRegion}.amazonaws.com/${keyId}`, which is correct for the commercial AWS regions.
AWS GovCloud serves the keys from different, S3 hosted endpoints, so GovCloud deployments must override it, e.g.:

```yaml
        publicKeyUriPattern: "https://s3-us-gov-west-1.amazonaws.com/\
aws-elb-public-keys-prod-us-gov-west-1/${keyId}"
```


## What Depends on the IDP

| | Amazon Cognito | Microsoft Entra ID | Other OIDC provider |
| --- | -------------- | ------------------ | ------------------- |
| ALB action | `authenticate-cognito` | `authenticate-oidc` | `authenticate-oidc` |
| Client registration | User pool app client | App registration | Per provider |
| Claims in `x-amzn-oidc-data` | `sub`, `username`, `email` | `sub`, `name`, `given_name`, `family_name`, `email` | Whatever the user info endpoint returns |
| `uniqueIdentityClaim` | `sub` (default) | `sub` (default) | `sub` (default) |
| `userDisplayNameClaim` | `username` or `email` | `email` or `name` | Check the user info claims |
| `signOutUrl` | Hosted UI `/logout` | `oauth2/v2.0/logout` | The end session endpoint |

The default `userDisplayNameClaim` of `preferred_username` is not returned by either Cognito's or Entra ID's user info endpoint, so set it explicitly, or users will sign in with no display name.


## Logout

AWS documents ending an ALB session as the application's job: expire the session cookies and send the browser to the IDP's logout endpoint.
The Stroom configuration above does exactly that — `cookiesToExpire` removes the `AWSELBAuthSessionCookie` shards and `signOutUrl` sends the browser to the IDP.

The IDP then returns the browser to a landing page, which is the `/signed-out` fixed response in the [listener rules](#load-balancer-setup).
Two things must be true of it:

* It must be served by a rule that comes **before** the authenticate rule, or the sign in flow simply restarts and the user never appears to sign out.
* Its full URL, `https://STROOM_FQDN/signed-out`, must be registered with the IDP as an allowed post logout destination; the sections below say where.


## Amazon Cognito

{{% see-also %}}
The [Amazon Cognito]({{< relref "docs/install-guide/setup/open-id/external-idp/cognito" >}}) page covers creating the user pool; this section covers what is different when the ALB, not Stroom, is the client.
{{% /see-also %}}


### Cognito Setup

Create a user pool, hosted UI domain and app client as described on the [Cognito]({{< relref "docs/install-guide/setup/open-id/external-idp/cognito" >}}) page, with these differences:

* The app client belongs to the **ALB**, not to Stroom, so its allowed callback URL is the ALB's own:
  `https://STROOM_FQDN/oauth2/idpresponse`
  (this fixed path is handled by the load balancer itself and never reaches Stroom).
* The client must have a **client secret** and use the code grant; the ALB requires both.
* Register `https://STROOM_FQDN/signed-out` as an allowed **sign out URL** for the client.

No second app client for Stroom is needed.
The ALB is the only OIDC client in this topology.


### Listener Rule

The default rule is an **authenticate-cognito** action naming your user pool, app client and hosted UI domain, followed by a forward to the Stroom target group.
Cognito's default `openid` scope returns an ID token, which the ALB needs to complete the flow; `email` and `profile` add the claims of the same name.


### Stroom Configuration for Cognito

```yaml
      edgeAuthentication:
        enabled: true
        logout:
          cookiesToExpire: [ "AWSELBAuthSessionCookie" ]
          signOutUrl: "https://MY_DOMAIN.auth.REGION.amazoncognito.com/logout?\
client_id=ALB_CLIENT_ID&logout_uri=https://STROOM_FQDN/signed-out"
      openId:
        identityProviderType: EXTERNAL_IDP
        openIdConfigurationEndpoint: "https://cognito-idp.REGION.amazonaws.com/\
POOL_ID/.well-known/openid-configuration"
        clientId: "ALB_CLIENT_ID"
        expectedSignerPrefixes:
          - "arn:aws:elasticloadbalancing:REGION:ACCOUNT_ID:"
        # Cognito's user info endpoint returns 'username' and 'email', not 'preferred_username'.
        userDisplayNameClaim: "username"
```

The default `uniqueIdentityClaim` of `sub` is correct and stable.


## Microsoft Entra ID

{{% see-also %}}
The [Microsoft Entra ID]({{< relref "docs/install-guide/setup/open-id/external-idp/azure-ad" >}}) page covers Entra ID generally; this section covers what is different when the ALB, not Stroom, is the client.
Much of that page does not apply here, as explained below.
{{% /see-also %}}


### App Registration

Create an app registration as described under [Creating the App Registration]({{< relref "docs/install-guide/setup/open-id/external-idp/azure-ad#creating-the-app-registration" >}}), with these differences:

* The registration belongs to the **ALB**, so the Web platform redirect URI is `https://STROOM_FQDN/oauth2/idpresponse`, not Stroom's `signin-oidc` callback.
* Add `https://STROOM_FQDN/signed-out` as a second Web redirect URI; Entra ID requires the `post_logout_redirect_uri` to be registered.
* A client secret is required, and it goes in the listener rule rather than Stroom's configuration.
  Entra ID secrets expire, with a maximum lifetime of 24 months; when this one does, the ALB can no longer complete sign in for anyone, so record the date.

The [Exposing an API for Access Tokens]({{< relref "docs/install-guide/setup/open-id/external-idp/azure-ad#exposing-an-api-for-access-tokens" >}}) step is **not** needed for browser sign in.
The access token Entra ID gives the ALB is a Microsoft Graph token, and the ALB only uses it to call Graph's user info endpoint, which is exactly what it is for.
It is still needed if Stroom-Proxies or other machine clients obtain Entra ID tokens to present to Stroom directly, as that traffic does not go through the ALB's authenticate rule.

Use a single tenant registration and the **v2.0** endpoints throughout, for the reasons given on the Entra ID page.


### Listener Rule

The default rule is an **authenticate-oidc** action, followed by a forward to the Stroom target group.
Entra ID's discovery document does not need to be, and cannot be, given to the ALB; the endpoints are entered individually:

```json
{
    "Type": "authenticate-oidc",
    "AuthenticateOidcConfig": {
        "Issuer": "https://login.microsoftonline.com/TENANT_ID/v2.0",
        "AuthorizationEndpoint": "https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize",
        "TokenEndpoint": "https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token",
        "UserInfoEndpoint": "https://graph.microsoft.com/oidc/userinfo",
        "ClientId": "ALB_CLIENT_ID",
        "ClientSecret": "ALB_CLIENT_SECRET",
        "Scope": "openid profile email offline_access",
        "OnUnauthenticatedRequest": "authenticate"
    },
    "Order": 1
}
```

* `Issuer` must be **exactly** `https://login.microsoftonline.com/TENANT_ID/v2.0`, with the `/v2.0` and no trailing slash.
  It becomes the `iss` claim of `x-amzn-oidc-data`, and Stroom checks it against the issuer from the v2.0 discovery document, so any difference rejects every request.
* `Scope` must include `profile` and `email`, otherwise the user info endpoint returns only `sub`.
  `offline_access` makes Entra ID issue a refresh token, which the ALB uses to renew the session silently; without it every user is bounced back through Entra ID when the access token expires, typically hourly.
* The user info endpoint is on `graph.microsoft.com`, not `login.microsoftonline.com`, so the ALB needs outbound access to both.


### Identity Claims

Entra ID's user info endpoint returns only `sub`, `name`, `given_name`, `family_name`, `picture` and `email`.
In particular it returns neither `oid` nor `preferred_username`, so the Entra ID page's advice does not carry over:

* `uniqueIdentityClaim` must be left at the default of `sub`.
  With `uniqueIdentityClaim: "oid"` copied from the Entra ID page, every request is rejected and the log says `Expecting claims to contain configured uniqueIdentityClaim 'oid' but it is not there`, followed by the claims that did arrive.
  In Entra ID `sub` is pairwise, i.e. specific to the app registration, and stable for as long as that registration exists.
  Deleting and recreating the ALB's app registration changes every user's `sub` and orphans their Stroom user, so treat the registration as permanent.
* `userDisplayNameClaim` must be set to `email` or `name`.
* The default `fullNameClaimTemplate` of `${name}` works, given the `profile` scope.

{{% warning %}}
Moving an existing Stroom from being Entra ID's client itself to sitting behind the ALB **changes every user's identity**: they were known by `oid` (or by the `sub` pairwise to Stroom's own app registration) and are now known by the `sub` pairwise to the ALB's.
None of the existing Stroom users will match, so their permissions and group memberships have to be reapplied to the new identities.
Plan this before switching, rather than discovering it when the administrator signs in to an empty UI.
{{% /warning %}}


### Stroom Configuration for Entra ID

```yaml
      edgeAuthentication:
        enabled: true
        logout:
          cookiesToExpire: [ "AWSELBAuthSessionCookie" ]
          signOutUrl: "https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/logout?\
post_logout_redirect_uri=https://STROOM_FQDN/signed-out"
      openId:
        identityProviderType: EXTERNAL_IDP
        # Note the '/v2.0' path part, which must agree with the listener rule's Issuer.
        openIdConfigurationEndpoint: "https://login.microsoftonline.com/TENANT_ID/v2.0/\
.well-known/openid-configuration"
        clientId: "ALB_CLIENT_ID"
        expectedSignerPrefixes:
          - "arn:aws:elasticloadbalancing:REGION:ACCOUNT_ID:"
        # Entra ID's user info endpoint does not return 'preferred_username'.
        userDisplayNameClaim: "email"
```

Compared with the [Entra ID]({{< relref "docs/install-guide/setup/open-id/external-idp/azure-ad#configuring-stroom" >}}) page's configuration, there is no `clientSecret`, `validIssuers`, `allowedAudiences`, `requestScopes` or `uniqueIdentityClaim: oid`.
Stroom runs no flow, only v2.0 tokens are ever involved, the ALB's token carries no audience, the scopes are set on the listener rule, and `oid` is not available.


### Setting up the Admin User

The administrator's `sub` is pairwise and is not shown anywhere in the Entra admin centre, and the `x-amzn-oidc-*` headers are only visible to Stroom, not in the browser.
The simplest way to obtain it is from Stroom's log:

1. Set the logger `stroom.security.common.impl.StandardJwtContextFactory` to `DEBUG` on one node; it then logs the claims of every token it verifies.
1. Have the administrator sign in once through the ALB.
1. Find the `jwtClaims:` entry for that sign in and take the `sub` value, then put the logger back to its normal level.

Stroom will already have created a user with that identity, with no permissions.
Grant them as described under [Setting up the Admin User in Stroom]({{< relref "docs/install-guide/setup/open-id/external-idp/azure-ad#setting-up-the-admin-user-in-stroom" >}}); the `manage_users` command is repeatable, so running it against the user that already exists is fine.
Once one administrator exists, further users can simply be found under _Users_ in the UI after their first sign in.


## Other OIDC Providers

Any provider the ALB can reach works the same way as Entra ID: an `authenticate-oidc` rule with the provider's issuer and endpoints, and the [generic Stroom configuration](#stroom-configuration) with the provider's discovery document.
Check three things against the provider's documentation:

1. The `Issuer` on the rule is exactly the issuer its discovery document advertises.
1. What its user info endpoint returns, and set `userDisplayNameClaim` accordingly.
1. What its end session endpoint is called, what parameter it takes for the return address, and whether that address must be registered.


## Verifying it Works

After deploying, load Stroom in a browser and check, in the developer tools network tab:

1. You are redirected to the IDP's sign in page, sign in, and land back at Stroom.
1. The request to `/api/auth/flow/v1/status` returns `200` with `"authenticated": true` and the UI loads.
1. There is **no** further navigation to the IDP's authorization endpoint (`.../oauth2/authorize` for Cognito, `.../oauth2/v2.0/authorize` for Entra ID) after that first sign in — if there is, Stroom is running a second flow and `edgeAuthentication.enabled` is not set.
1. Signing out lands on the _You have been signed out_ page, and following its link asks you to sign in again.

On the Stroom side, the log should not contain `Redirecting with an AuthenticationRequest to:` during normal browsing.

If every request is rejected with `Authenticated user is not permitted to use stroom`, set the logger `stroom.security.common.impl.StandardJwtContextFactory` to `DEBUG`: it logs the raw `x-amzn-oidc-data` token (`jws:`) and why verification failed.
Decode the token's header and payload (base64 JSON, the first and second dot separated segments) and compare the payload's `iss` with the issuer in the discovery document at `openIdConfigurationEndpoint`, and the header's `signer` with `expectedSignerPrefixes`.
