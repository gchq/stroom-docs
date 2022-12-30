---
title: "Tokens for API use"
linkTitle: "Tokens for API use"
weight: 40
date: 2022-11-25
tags: 
  - token
description: >
  How to create and use tokens for making API calls.
---

{{% note %}}
We strongly recommend you install _jq_ if you are working with JSON responses from the IDP.
It allows you to parse and extract parts of the JSON response.
{{< external-link "https://stedolan.github.io/jq/" >}}
{{% /note %}}


## Creating a user access token

If a user wants to use the REST API they will need to create a token for authentication/authorisation in API calls.
Any calls to the REST API will have the same permissions that the user has within Stroom.

The following excerpt of shell commands shows how you can get an access/refresh token pair for a user and then later use the refresh token to obtain a new access token.
It also shows how you can extract the expiry date/time from a token using _jq_.

```bash
get_jwt_expiry() {
  jq \
    --raw-input \
    --raw-output \
    'split(".") | .[1] | @base64d | fromjson | .exp | todateiso8601' \
    <<< "${1}"
}

# Fetch a new set of tokens (id, access and refresh) for the user
response="$( \
  curl \
    --silent \
    --request POST \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'client_id=admin-cli' \
    --data-urlencode 'grant_type=password' \
    --data-urlencode 'scope=openid' \
    --data-urlencode 'username=jbloggs' \
    --data-urlencode 'password=password' \
    'http://localhost:9999/realms/StroomRealm/protocol/openid-connect/token' )"

# Extract the individual tokens from the response
access_token="$( jq -r '.access_token' <<< "${response}" )"
refresh_token="$( jq -r '.refresh_token' <<< "${response}" )"

# Output the tokens
echo -e "\nAccess token (expiry $( get_jwt_expiry "${access_token}")):\n${access_token}"
echo -e "\nRefresh token (expiry $( get_jwt_expiry "${refresh_token}")):\n${refresh_token}"

# Fetch a new access token using the stored refresh token
response="$( \
  curl \
    --silent \
    --request POST \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'client_id=admin-cli' \
    --data-urlencode 'grant_type=refresh_token' \
    --data-urlencode "refresh_token=${refresh_token}" \
    'http://localhost:9999/realms/StroomRealm/protocol/openid-connect/token' )"

access_token="$( jq -r '.access_token' <<< "${response}" )"
refresh_token="$( jq -r '.refresh_token' <<< "${response}" )"

echo -e "\nNew access token (expiry $( get_jwt_expiry "${access_token}")):\n${access_token}"
echo -e "\nNew refresh token (expiry $( get_jwt_expiry "${refresh_token}")):\n${refresh_token}"
```

The above example assumes that you have created a user called `jbloggs` and a client ID `admin-cli`.

Access tokens typically have a short life (of the order of minutes) while a refresh token will have a much longer life (maybe up to a year).
Refreshing the token does not require re-authentication.


## Creating a service account token

If want another system to call one of Stroom's APIs then it is likely that you will do that using a non-human service account (or processing user account).


### Creating a new Client ID

The client system needs to be represented by a Client ID in KeyCloak.
To create a new Client ID, assuming the client system is called _System X_, do the following in the KeyCloak admin UI.

1. Click _Clients_ in the left pane.
1. Click _Create client_.
1. Set the _Client ID_ to be `system-x`.
1. Set the _Name_ to be `System X`.
1. Click _Next_.
1. Enable _Client Authentication_.
1. Enable _Service accounts roles_.
1. Click _Save_.

{{% note %}}
By enabling _Service accounts role_, KeyCloak will create a service account user called `service-account-system-x`.
Tokens will be created under this non-human user identity.
{{% /note %}}

Open the _Credentials_ tab and copy the _Client secret_ for use later.
Open the _Credentials_ tab and copy the _Client secret_ for use later.

To create an access token run the following shell commands:

```bash
response="$( \
  curl \
    --silent \
    --request POST \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'client_secret=k0BhYyvt6PHQqwKnnQpbL3KXVFHG0Wa1' \
    --data-urlencode 'client_id=system-x' \
    --data-urlencode 'grant_type=client_credentials' \
    --data-urlencode 'scope=openid' \
    'http://localhost:9999/realms/StroomRealm/protocol/openid-connect/token' )"

access_token="$( jq -r '.access_token' <<< "${response}" )"
refresh_token="$( jq -r '.refresh_token' <<< "${response}" )"

echo -e "\nAccess token:\n${access_token}"
```

Where `client_secret` is the _Client secret_ that you copied from KeyCloak earlier.

This access token can be refreshed in the same way as for a user access token, as described above.


## Using access tokens

Access tokens can be used in calls the Stroom's REST API or its datafeed API.
The process of including the token in a HTTP request is described in [API Authentication]({{< relref "/docs/user-guide/api#authentication" >}})
