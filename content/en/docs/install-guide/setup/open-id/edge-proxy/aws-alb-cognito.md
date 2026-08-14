---
title: "AWS ALB and Cognito"
linkTitle: "AWS ALB and Cognito"
weight: 20
date: 2026-08-05
tags:
  - open-id
  - authentication
description: >
  Running Stroom behind an AWS Application Load Balancer that authenticates users against an Amazon Cognito user pool.
---

In this deployment the {{< external-link "Application Load Balancer" "https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html" >}} is the Open ID Connect Relying Party.
Its listener rule sends unauthenticated browsers to Cognito, completes the code flow, holds the session in `AWSELBAuthSessionCookie` cookies, and forwards each authenticated request to Stroom with three extra headers:

| Header | Contents |
| ------ | -------- |
| `x-amzn-oidc-data` | The user's claims as a JWT, **signed by the ALB** with a regional AWS key (ES256) |
| `x-amzn-oidc-accesstoken` | The access token from Cognito, in plain text |
| `x-amzn-oidc-identity` | The `sub` claim, in plain text |

Stroom authenticates the request by verifying the `x-amzn-oidc-data` signature against AWS's regional public key endpoint, checking the token's issuer against the configured one, and checking that the signing load balancer is one of yours.

{{% see-also %}}
Read [Edge Proxy RP]({{< relref "docs/install-guide/setup/open-id/edge-proxy" >}}) first for the model, the path scoping rules and the trust prerequisites.
The [Amazon Cognito]({{< relref "docs/install-guide/setup/open-id/external-idp/cognito" >}}) page covers creating the user pool; this page covers what is different when the ALB, not Stroom, is the client.
{{% /see-also %}}


## Cognito Setup

Create a user pool, hosted UI domain and app client as described on the [Cognito]({{< relref "docs/install-guide/setup/open-id/external-idp/cognito" >}}) page, with these differences:

* The app client belongs to the **ALB**, not to Stroom, so its allowed callback URL is the ALB's own:
  `https://STROOM_FQDN/oauth2/idpresponse`
  (this fixed path is handled by the load balancer itself and never reaches Stroom).
* The client must have a **client secret** and use the code grant; the ALB requires both.
* Register the post logout landing page as an allowed sign out URL for the client (see [Logout](#logout)).

No second app client for Stroom is needed.
The ALB is the only OIDC client in this topology.


## Load Balancer Setup

Order the listener rules so machine traffic is forwarded *without* authentication, then authenticate everything else:

1. Paths `/datafeed*`, `/stroom/datafeed*`, `/remoting/*`, `/status` → **forward** to the Stroom target group.
2. Default → **authenticate-cognito** (your user pool, app client and hosted UI domain) then **forward** to the Stroom target group.

Points worth knowing:

* `SessionCookieName` defaults to `AWSELBAuthSessionCookie`; if you change it, change `edgeAuthentication.logout.cookiesToExpire` to match.
* The session cookie is sharded at 4KB per shard (`-0`, `-1`, ...), which is why the [header size limit]({{< relref "docs/install-guide/setup/open-id/edge-proxy#request-header-sizes" >}}) matters.
* If the total claims and access token exceed 11KB the ALB itself returns HTTP 500 and increments its `ELBAuthUserClaimsSizeExceeded` metric — trim what the IDP puts in the token if you hit this.
* Restrict the Stroom target's security group to accept traffic only from the ALB's security group; this is [trust prerequisite one]({{< relref "docs/install-guide/setup/open-id/edge-proxy#trust-prerequisites" >}}).


## Stroom Configuration

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
          signOutUrl: "https://MY_DOMAIN.auth.REGION.amazoncognito.com/logout?\
client_id=ALB_CLIENT_ID&logout_uri=https://STROOM_FQDN/loggedOut"
      openId:
        identityProviderType: EXTERNAL_IDP
        # Cognito's discovery document; supplies the issuer that x-amzn-oidc-data is
        # checked against. Stroom runs no flow of its own, so no clientSecret is needed.
        openIdConfigurationEndpoint: "https://cognito-idp.REGION.amazonaws.com/\
POOL_ID/.well-known/openid-configuration"
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

### Identity Claims

The claims in `x-amzn-oidc-data` come from Cognito's **user info** endpoint, not from an ID token.
The default `uniqueIdentityClaim` of `sub` is correct and stable; set `userDisplayNameClaim` to taste (`username` and `email` are usually available).


## Logout

AWS documents ending an ALB session as the application's job: expire the session cookies and send the browser to the IDP's logout endpoint.
The configuration above does exactly that — `cookiesToExpire` removes the `AWSELBAuthSessionCookie` shards and `signOutUrl` sends the browser to Cognito's `/logout`.

Two registration details make it work:

* The `logout_uri` value must be registered in the Cognito app client as an **allowed sign out URL**.
* The page it points at must be matched by a **forward** rule, not the authenticate rule, or the sign in flow simply restarts and the user never appears to sign out.


## Verifying it Works

After deploying, load Stroom in a browser and check, in the developer tools network tab:

1. You are redirected to the Cognito hosted UI, sign in, and land back at Stroom.
2. The request to `/api/auth/flow/v1/status` returns `200` with `"authenticated": true` and the UI loads.
3. There is **no** navigation to `.../oauth2/authorize` on the Cognito domain after that first sign in — if there is, Stroom is running a second flow and `edgeAuthentication.enabled` is not set.

On the Stroom side, the log should not contain `Redirecting with an AuthenticationRequest to:` during normal browsing.
