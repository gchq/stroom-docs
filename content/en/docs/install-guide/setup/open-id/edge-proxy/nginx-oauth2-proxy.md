---
title: "NGINX, oauth2-proxy and KeyCloak"
linkTitle: "NGINX and oauth2-proxy"
weight: 30
date: 2026-09-22
tags:
  - open-id
  - authentication
description: >
  Running Stroom behind NGINX with oauth2-proxy authenticating users against KeyCloak (or any Open ID Connect provider).
---

In this deployment {{< external-link "oauth2-proxy" "https://oauth2-proxy.github.io/oauth2-proxy/" >}} is the Open ID Connect Relying Party.
NGINX asks it to authorise each request (`auth_request`); oauth2-proxy completes the code flow against the {{< glossary "idp" >}}, holds its session in `_oauth2_proxy` cookies, and hands back the IDP's token, which NGINX forwards to Stroom as an `Authorization: Bearer` header.

Unlike the ALB, nothing here mints its own token: Stroom receives the **IDP's own token** and verifies it against the IDP's published keys, exactly as it would verify a token presented by an API client.
That is why this pattern works unchanged with KeyCloak, Cognito or Entra ID behind the proxy; the page is written for KeyCloak, and [Entra ID](#entra-id-instead-of-keycloak) at the end lists what differs.

{{% see-also %}}
Read [Edge Proxy RP]({{< relref "docs/install-guide/setup/open-id/edge-proxy" >}}) first for the model, the path scoping rules and the trust prerequisites.
The [KeyCloak]({{< relref "docs/install-guide/setup/open-id/external-idp/keycloak" >}}) page covers setting up the realm and client; here the client belongs to oauth2-proxy rather than to Stroom.
{{% /see-also %}}


## KeyCloak Setup

Create a realm and a confidential client as described on the [KeyCloak]({{< relref "docs/install-guide/setup/open-id/external-idp/keycloak" >}}) page, with one difference: the client's redirect URI is **oauth2-proxy's** callback, `https://STROOM_FQDN/oauth2/callback`, not Stroom's.

No second client for Stroom is needed.


## Oauth2-proxy Setup

```ini
provider = "keycloak-oidc"
oidc_issuer_url = "https://IDP_HOST/realms/REALM"
client_id = "stroom-proxy-client"
client_secret = "THE_CLIENT_SECRET"
redirect_url = "https://STROOM_FQDN/oauth2/callback"
cookie_secret = "RANDOM_32_BYTES_BASE64"

# Hand the IDP's token to NGINX so it can be forwarded to Stroom.
set_authorization_header = true

# Refresh the session before the access token expires, so the forwarded
# token is always live.
cookie_refresh = "4m"
```

{{% note %}}
`set_authorization_header` forwards the **ID token**, not the access token.
Stroom verifies either happily, but this means the `requiredAccessTokenType` Stroom setting must be left unset — an ID token does not carry an access token's `typ` header and would be rejected.
{{% /note %}}


## NGINX Setup

The essential shape — authenticate the browser paths, forward the machine paths untouched, and **overwrite** the `Authorization` header on everything proxied:

```nginx
server {
    listen 443 ssl;
    server_name STROOM_FQDN;

    # oauth2-proxy's own endpoints (sign in, callback, sign out)
    location /oauth2/ {
        proxy_pass       http://oauth2-proxy:4180;
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Subrequest endpoint used by auth_request
    location = /oauth2/auth {
        internal;
        proxy_pass              http://oauth2-proxy:4180;
        proxy_set_header        Content-Length "";
        proxy_pass_request_body off;
    }

    # Browser facing paths - authenticated
    location / {
        auth_request /oauth2/auth;
        error_page 401 = /oauth2/sign_in;

        # Take the token oauth2-proxy returned and forward it to Stroom.
        # proxy_set_header OVERWRITES any client supplied Authorization header,
        # which is one of the trust prerequisites.
        auth_request_set $auth_token $upstream_http_authorization;
        proxy_set_header Authorization $auth_token;

        proxy_pass       https://stroom-backend:8080/;
        proxy_set_header Host              $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host  $host;
    }

    # Machine paths - no auth_request, Stroom authenticates these itself
    location /datafeed  { proxy_pass https://stroom-backend:8080/datafeed; }
    location /remoting/ { proxy_pass https://stroom-backend:8080/remoting/; }
    location /status    { proxy_pass https://stroom-backend:8080/status; }

    # Post logout landing page, served by NGINX itself so it needs no session
    location = /signed-out {
        default_type text/html;
        return 200 '<html><body><p>You have been signed out.</p><p><a href="/">Sign in again</a></p></body></html>';
    }
}
```


## Stroom Configuration

```yaml
server:
  applicationConnectors:
    - type: http
      port: 8080
      useForwardedHeaders: true
      maxRequestHeaderSize: 32KiB    # oauth2-proxy chunks its session cookie

appConfig:
  publicUri: "https://STROOM_FQDN"
  security:
    authentication:
      edgeAuthentication:
        enabled: true
        logout:
          cookiesToExpire: [ "_oauth2_proxy" ]
          signOutUrl: "https://STROOM_FQDN/oauth2/sign_out"
      openId:
        identityProviderType: EXTERNAL_IDP
        # The real IDP's discovery document - Stroom verifies the forwarded token
        # against the keys it advertises.
        openIdConfigurationEndpoint: "https://IDP_HOST/realms/REALM/\
.well-known/openid-configuration"
        # oauth2-proxy's client - the forwarded token's audience is this client.
        clientId: "stroom-proxy-client"
        # Leave requiredAccessTokenType unset: oauth2-proxy forwards the ID token.
```

No `clientSecret` is needed; Stroom runs no flow of its own.

{{% note %}}
oauth2-proxy can also run in a mode that forwards only plain headers such as `X-Forwarded-User` or `X-Auth-Request-Email` rather than a token.
Stroom does **not** support that: there is no signature to verify, so trusting those headers would mean trusting every hop unconditionally.
Always configure `set_authorization_header` so a verifiable token reaches Stroom.
{{% /note %}}


## Logout

The configuration above expires oauth2-proxy's (chunked) session cookies and sends the browser to `/oauth2/sign_out`, which ends the proxy session.
To also end the KeyCloak session, give oauth2-proxy's sign out a redirect to KeyCloak's end session endpoint:

```yaml
          signOutUrl: "https://STROOM_FQDN/oauth2/sign_out?rd=https%3A%2F%2FIDP_HOST%2Frealms%2FREALM%2Fprotocol%2Fopenid-connect%2Flogout"
```

(The `rd` value must be URL encoded and allowed by oauth2-proxy's `whitelist_domains`.)

With no return address, KeyCloak shows its own _You are logged out_ page, which is fine.
To land on the `/signed-out` page served by NGINX instead, add a `post_logout_redirect_uri` (and `client_id`) to KeyCloak's logout URL, URL encoded within the `rd` value, and add `https://STROOM_FQDN/signed-out` to the client's _Valid post logout redirect URIs_ in KeyCloak.
Either way the landing page must not be behind `auth_request`, or the sign in flow simply restarts.


## Verifying it Works

1. Loading Stroom redirects via oauth2-proxy to KeyCloak; after signing in, the UI loads.
1. The request to `/api/auth/flow/v1/status` returns `200` with `"authenticated": true`, and there is no subsequent navigation to KeyCloak's `/auth` endpoint.
1. `curl -H "Authorization: Bearer $TOKEN" https://stroom-backend:8080/api/...` from inside the network still works — machine access does not traverse the proxy.


## Entra ID Instead of KeyCloak

{{% see-also %}}
The [Microsoft Entra ID]({{< relref "docs/install-guide/setup/open-id/external-idp/azure-ad" >}}) page covers the app registration; here it belongs to oauth2-proxy rather than to Stroom.
{{% /see-also %}}

The NGINX configuration and the Stroom `edgeAuthentication` settings are unchanged.
What differs:

* **App registration** - create it as on the Entra ID page, but with a Web redirect URI of `https://STROOM_FQDN/oauth2/callback` (oauth2-proxy's callback), and `https://STROOM_FQDN/signed-out` as a second redirect URI for the post logout return.
  The client secret goes in oauth2-proxy's configuration and expires within 24 months; record the date.
  The _Expose an API_ step is not needed for browser sign in, because Stroom receives the ID token, not an access token.
* **oauth2-proxy** (7.8 or later, which added the `entra-id` provider and deprecated the old `azure` one):

  ```ini
  provider = "entra-id"
  oidc_issuer_url = "https://login.microsoftonline.com/TENANT_ID/v2.0"
  client_id = "PROXY_CLIENT_ID"
  client_secret = "PROXY_CLIENT_SECRET"
  # 'profile' for the name claims, 'offline_access' for a refresh token, without
  # which cookie_refresh cannot renew the session.
  scope = "openid email profile offline_access"
  ```

  The remaining settings (`redirect_url`, `cookie_secret`, `set_authorization_header`, `cookie_refresh`) are as above.
* **Stroom** - point `openIdConfigurationEndpoint` at `https://login.microsoftonline.com/TENANT_ID/v2.0/.well-known/openid-configuration` and set `clientId` to `PROXY_CLIENT_ID`.
  Because Stroom receives the **ID token**, the claims are the ones the Entra ID page describes: `oid`, `preferred_username` and `name` are all present, so `uniqueIdentityClaim: "oid"` is available here, unlike behind an [ALB]({{< relref "aws-alb#identity-claims" >}}) where only the user info claims arrive.
  Decide on `sub` or `oid` before the first user signs in.
  No `clientSecret`, `validIssuers`, `allowedAudiences` or `requestScopes` are needed: Stroom runs no flow, only v2.0 tokens are involved, the ID token's audience is the client id, and the scopes are set on oauth2-proxy.
* **Logout** - Entra ID's end session endpoint, with the return address registered as above:

  ```yaml
            signOutUrl: "https://STROOM_FQDN/oauth2/sign_out?rd=https%3A%2F%2Flogin.microsoftonline.com%2FTENANT_ID%2Foauth2%2Fv2.0%2Flogout%3Fpost_logout_redirect_uri%3Dhttps%3A%2F%2FSTROOM_FQDN%2Fsigned-out"
  ```

  `login.microsoftonline.com` must be in oauth2-proxy's `whitelist_domains` for the `rd` to be honoured.
  Without the `post_logout_redirect_uri`, Entra ID shows a generic signed out page of its own instead.
