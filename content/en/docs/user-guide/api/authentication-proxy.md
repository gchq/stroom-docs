---
title: "Authentication Proxy"
linkTitle: "Authentication Proxy"
#weight:
date: 2025-11-21
tags:
description: >
  An endpoint to use Stroom as a proxy for an external IDP to obtain access tokens.
---

During provisioning of a Stroom instance that is configured to use an external IDP, it is sometimes required to call Stroom's API to provision the system in an automated way.
In order to call the API, some form of authentication will be needed, e.g. an access token from IDP.

To make it easier to obtain an access token, Stroom has the `/api/authproxy/v1/noauth/fetchClientCredsToken` endpoint.
This endpoint is not authenticated and essentially calls out to the configured external IDP to obtain an access token for the provided client credentials (client ID and secret).

In order to use it you must obtain these credentials for the user identity you want a token for.
Typically these will be the credentials for Stroom's own IDP client, which can be obtained from Stroom's `config.yml` file.

The following is an example of a bash script that uses `jq` and `yq` to obtain a token that can be used to call Stroom's authenticated APIs.

```sh
if ! command -v jq 1>/dev/null; then
  echo "jq is not installed, please install it." >&2
  exit 1
fi

if ! command -v yq 1>/dev/null; then
  echo "yq is not installed, please install it." >&2
  exit 1
fi

local config_file="config/config.yml"
local client_id_path='.appConfig.security.authentication.openId.clientId'
local client_secret_path='.appConfig.security.authentication.openId.clientSecret'

local client_id
client_id="$(yq -r "${client_id_path}" < "${config_file}")"
local client_secret
client_secret="$(yq -r "${client_secret_path}" < "${config_file}")"

if [[ -z "${client_id}" || "${client_id}" = "null" ]]; then
  echo "'${client_id_path}' not found in ${config_file}" >&2
  exit 1
fi

if [[ -z "${client_secret}" || "${client_secret}" = "null" ]]; then
  echo "'${client_secret_path}' not found in ${config_file}" >&2
  exit 1
fi

local req_json
req_json="$( \
  jq \
    -n \
    --arg client_id "${client_id}" \
    --arg client_secret "${client_secret}" \
    '{clientId: $client_id, clientSecret: $client_secret}')"

curl \
  -s \
  -k \
  --header "Content-Type: application/json" \
  --request POST \
  --data "${req_json}" \
  "${SCHEME}://${HOST}:${PORT}/api/authproxy/v1/noauth/fetchClientCredsToken"
```


