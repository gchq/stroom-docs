---
title: "NGINX, oauth2-proxy and KeyCloak"
linkTitle: "NGINX and oauth2-proxy"
weight: 30
date: 2026-08-05
tags:
  - open-id
  - authentication
description: >
  Running Stroom behind NGINX with oauth2-proxy authenticating users against KeyCloak (or any Open ID Connect provider).
---

In this deployment {{< external-link "oauth2-proxy" "https://oauth2-proxy.github.io/oauth2-proxy/" >}} is the Open ID Connect Relying Party.
NGINX asks it to authorise each request (`auth_request`); oauth2-proxy completes the code flow against the {{< glossary "idp" >}}, holds its session in `_oauth2_proxy` cookies, and hands back the IDP's token, which NGINX forwards to Stroom as an `Authorization: Bearer` header.

Unlike the ALB, nothing here mints its own token: Stroom receives the **IDP's own token** and verifies it against the IDP's published keys, exactly as it would verify a token presented by an API client.
That is why this pattern works unchanged with KeyCloak, Cognito or Entra ID behind the proxy.

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


## Verifying It Works

1. Loading Stroom redirects via oauth2-proxy to KeyCloak; after signing in, the UI loads.
2. The request to `/api/auth/flow/v1/status` returns `200` with `"authenticated": true`, and there is no subsequent navigation to KeyCloak's `/auth` endpoint.
3. `curl -H "Authorization: Bearer $TOKEN" https://stroom-backend:8080/api/...` from inside the network still works — machine access does not traverse the proxy.
