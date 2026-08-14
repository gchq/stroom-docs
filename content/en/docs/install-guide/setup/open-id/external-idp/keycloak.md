---
title: "KeyCloak"
linkTitle: "KeyCloak"
weight: 20
date: 2026-08-03
tags:
  - open-id
  - authentication
description: >
  How to set up KeyCloak as an external identity provider for Stroom.
---

This is a guide to setting up a new Stroom instance or cluster with {{< external-link "KeyCloak" "https://www.keycloak.org/" >}} as the 3rd party {{< glossary "idp" >}}.
It assumes you have deployed a new instance or cluster of Stroom and have **not** yet started it.

{{% see-also %}}
Read [External IDP]({{< relref "docs/install-guide/setup/open-id/external-idp" >}}) first for what Stroom needs from any provider, and [Stroom Configuration]({{< relref "stroom-configuration" >}}) for what each setting does.
{{% /see-also %}}

{{% note %}}
This page covers Stroom itself being the OIDC client of the realm.
If an authenticating reverse proxy (e.g. NGINX with oauth2-proxy) in front of Stroom does the sign in against KeyCloak instead, see [NGINX, oauth2-proxy and KeyCloak]({{< relref "docs/install-guide/setup/open-id/edge-proxy/nginx-oauth2-proxy" >}}).
{{% /note %}}


## Running KeyCloak

> If you already have a KeyCloak instance running then move on to the next section.

This section is not a definitive guide to running or administering KeyCloak.
It describes how to run KeyCloak using non-production settings for simplicity and to demonstrate using a 3rd party IDP.
You should consult the KeyCloak documentation on how to set up a production ready instance.

The easiest way to run KeyCloak is using Docker.
To create a KeyCloak container do the following:

{{< command-line >}}
docker create \
  --name keycloak \
  -p 9999:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:20.0.1 \
  start-dev
{{</ command-line >}}

This example maps KeyCloak's port to port `9999` to avoid any clash with Stroom that also runs on `8080`.
This will create a docker container called `keycloak` that uses an embedded H2 database to hold its state.

To start the container in the foreground, do:

{{< command-line >}}
docker start -a keycloak
{{</ command-line >}}

KeyCloak should now be running on {{< external-link "http://localhost:9999/admin" >}}.
If you want to run KeyCloak on a different port then delete the container and create it with a different port for the `-p` argument.

Log into KeyCloak using the username `admin` and password `admin` as specified in the environment variables set in the container creation command above.
You should see the admin console.

{{% note %}}
The admin console layout and the names of some settings vary between KeyCloak versions.
The steps below were written against the version above.
On a newer version the same settings may sit under differently named tabs, and the bootstrap admin environment variables have been renamed.
{{% /note %}}


## Creating a Realm

First you need to create a Realm.

1. Click on the drop-down in the left pane that contains the word `master`.
1. Click _Create Realm_.
1. Set the _Realm name_ to `StroomRealm`.
1. Click _Create_.


## Creating a Client

In the new realm click on _Clients_ in the left pane, then _Create client_.

1. Set the _Client ID_ to `StroomClient`.
1. Click _Next_.
1. Set _Client authentication_ to on, which makes this a confidential client.
1. Ensure the following are ticked:
    * Standard flow
    * Direct access grants
1. Click _Save_.

Open the new _Client_ and on the _Settings_ tab set:

* _Valid redirect URIs_ to `https://STROOM_FQDN/api/auth/flow/v1/signin-oidc`
* _Valid post logout redirect URIs_ to `https://STROOM_FQDN/*`

Where `STROOM_FQDN` is the public address of Stroom, i.e. what you have set as `appConfig.publicUri`.

{{% warning %}}
The redirect URI is a single exact value.
Do not use a wildcard such as `https://STROOM_FQDN/*` for it.

Earlier versions of Stroom sent the user's current page as the redirect URI and so did need a wildcard here.
If you are upgrading, replace it with the exact URI above.
{{% /warning %}}

The post logout redirect URI does use a wildcard, because Stroom appends a `state` parameter to it.

On the _Advanced_ tab, under _Advanced settings_, set _Proof Key for Code Exchange Code Challenge Method_ to `S256`.
Stroom always sends a PKCE challenge, so KeyCloak can be told to insist on one.

On the _Credentials_ tab copy the _Client secret_ for use later in Stroom config.


## Adding an Audience Mapper

This step matters, and is easy to miss.

By default KeyCloak does not put the client id in the `aud` claim of the access tokens it issues; typically it puts `account` there instead.
Stroom validates the audience of every token it is given, so without this step API calls made with a KeyCloak access token are refused.
Interactive sign in still works, because the `id_token` does carry the client id.

In the realm, click _Client scopes_ in the left pane, then the `StroomClient-dedicated` scope belonging to the client.

1. Click _Add mapper_ => _By configuration_ => _Audience_.
1. Set _Name_ to `stroom-audience`.
1. Set _Included Client Audience_ to `StroomClient`.
1. Ensure _Add to access token_ is on.
1. Click _Save_.

The alternative, if you would rather not change KeyCloak, is to tell Stroom what KeyCloak actually issues:

```yaml
        allowedAudiences:
          - "account"
```

That is weaker, since `account` is an audience every client in the realm can obtain, so a token minted for another application in the same realm would be accepted by Stroom.
Prefer the mapper.


## Creating Users

Click on _Users_ in the left pane then _Add user_.
Set the following:

* Username - `admin`
* First name - `Administrator`
* Last name - `Administrator`

Click _Create_.

Select the _Credentials_ tab and click _Set password_.

Set the password to `admin` and set _Temporary_ to off.

{{% note %}}
Standard practice would be for there to be a number of administrators where each has their own identity (in their own name) on the IDP.
Each would be granted the `Administrator` application permission (directly or via a group).
For this example we are calling our administrator `admin`.
{{% /note %}}

Repeat this process for the following user:

* Username - `jbloggs`
* First name - `Joe`
* Last name - `Bloggs`
* Password - `password`


## Configure Stroom for KeyCloak

Edit the `config.yml` file and set the following values:

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
        # Tells Stroom to use an external IDP for authentication
        identityProviderType: EXTERNAL_IDP
        # The endpoint to obtain the rest of the IDP's configuration. Specific to the realm/issuer.
        openIdConfigurationEndpoint: "http://localhost:9999/realms/StroomRealm/.well-known/openid-configuration"
        # The client ID created in KeyCloak
        clientId: "StroomClient"
        # The client secret copied from KeyCloak above
        clientSecret: "XwTPPudGZkDK2hu31MZkotzRUdBWfHO6"
        # The URL on the IDP to redirect users to when logging out of Stroom
        logoutEndpoint: "http://localhost:9999/realms/StroomRealm/protocol/openid-connect/logout"
        # KeyCloak stamps its access tokens with a 'typ' header of 'Bearer'. Requiring it stops an
        # id_token being replayed against the API as though it were an access token.
        requiredAccessTokenType: "Bearer"
```

These values are obtained from the IDP.
In the case of KeyCloak they can be found by clicking on _Realm settings_ => _Endpoints_ => _OpenID Endpoint Configuration_ and extracting the various values from the JSON response.
Alternatively they can typically be found at _https://host/.well-known/openid-configuration_ on any Open ID Connect IDP.
The values will reflect the host and port that the IDP is running on along with the name of the realm.

Setting the above values assumes KeyCloak is running on `localhost:9999` and the realm name is `StroomRealm`.

The claim defaults suit KeyCloak, so there is nothing to set for them.
KeyCloak issues `preferred_username`, which Stroom uses as the display name, and issues `name` where the user has a first and last name, which satisfies the default `fullNameClaimTemplate` of `${name}`.

{{% note %}}
Before setting `requiredAccessTokenType`, confirm the value your KeyCloak version actually uses by decoding the header of a real access token.
Leave it unset if in doubt; it is a hardening measure rather than a requirement.
{{% /note %}}


## Setting up the Admin User in Stroom

Now that the `admin` user exists in the IDP we need to grant it `Administrator` rights in Stroom.

In the _Users_ section of KeyCloak click on user `admin`.
On the _Details_ tab copy the value of the _ID_ field.
The ID is in the form of a {{< glossary "UUID" >}}.
This ID is the `sub` claim, which is what Stroom uses to uniquely identify the user and associate it with the identity in KeyCloak.

To set up Stroom with this admin user run the following (**before** Stroom has been started for the first time):

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

Where `XXX` is the user ID copied from the IDP as described above.
This command is repeatable as it will skip any users/groups/memberships that already exist.

{{% see-also %}}
See [Command Line Tools]({{< relref "docs/user-guide/tools/command-line" >}}) for more details on using the `manage_users` command.
{{% /see-also %}}

This command will do the following:

* Create the Stroom User by creating an entry in the `stroom_user` database table for the IDP's `admin` user.
* Ensure that an `Administrators` group exists (i.e. an entry in the `stroom_user` database table for the `Administrators` group).
* Add the `admin` user to the group `Administrators`.
* Grant the application permission `Administrator` to the group `Administrators`.

{{% note %}}
This process is only required to bootstrap the admin user, to allow them to log in with administrator rights and manage the permissions and group memberships of everyone else.
It does not need to be done for every user.
Whenever a user successfully logs in via the IDP, Stroom will automatically create an entry in the `stroom_user` table for that user.
The user will have no permissions or group memberships, so these will need to be applied by the administrator.
This does mean that new users will need to log in before the administrator can manage their permissions and memberships.
{{% /note %}}


## Logging into Stroom

### As the Administrator

Now that the user and permissions have been set up in Stroom, the administrator can log in.

First start the Stroom instance or cluster.

{{% warning %}}
If the `manage_users` command is run while Stroom is running you will likely not see the effect when logging in, as the user permissions are cached.
Without Administrator rights you will not be able to clear the caches, so you will need to wait for the cache entries to expire or restart Stroom.
{{% /warning %}}

Navigate to _https://STROOM_FQDN_ and Stroom should re-direct you to the IDP (KeyCloak) to authenticate.
Enter the username `admin` and password `admin`.
You should be authenticated by KeyCloak and re-directed back to Stroom.
Your user ID is shown in the bottom right corner of the Welcome tab.

As an administrator, the {{< stroom-menu "Tools" "User Permissions" >}} menu item will be available to manage the permissions of any users that have logged on at least once.

Now select {{< stroom-menu "User" "Logout" >}} to be re-directed to the IDP to log out.
Once you log out of the IDP it should re-direct you back to Stroom, which will send you to the IDP login screen to log back in again.


### As an Ordinary User

On the IDP login screen, log in as user `jbloggs` with the password `password`.
You will be re-directed to Stroom, however the explorer tree will be empty and most of the menu items will be disabled.
In order to gain permissions to do anything in Stroom, a Stroom administrator will need to grant application and document permissions and/or group memberships to the user via the {{< stroom-menu "Tools" "User Permissions" >}} menu item.


## Configure Stroom-Proxy for KeyCloak

Create a second client in KeyCloak for the proxy, following the steps above but with _Service accounts roles_ enabled so that it can use the client credentials grant.
A proxy has no interactive users, so it needs no redirect URIs.

Edit the proxy's `config.yml` file and set the following values:

```yaml
  receive:
    # Set to true to require authentication for /datafeed requests
    authenticationRequired: true
    # Set to true to allow authentication using an Open ID token
    tokenAuthenticationEnabled: true
  security:
    authentication:
      openId:
        identityProviderType: EXTERNAL_IDP
        openIdConfigurationEndpoint: "http://localhost:9999/realms/StroomRealm/.well-known/openid-configuration"
        clientId: "StroomProxyClient"
        clientSecret: "THE_PROXY_CLIENT_SECRET"
        logoutEndpoint: "http://localhost:9999/realms/StroomRealm/protocol/openid-connect/logout"
```

If Stroom-Proxy is configured to forward data on to another Stroom-Proxy or Stroom instance then it can use tokens when forwarding that data.
This assumes the downstream Stroom or Stroom-Proxy is also configured to use the same external IDP.

```yaml
  forwardHttpDestinations:

      # If true, adds a token for the service user to the request
    - addOpenIdAccessToken: true
      enabled: true
      name: "downstream"
      forwardUrl: "http://somehost/stroom/datafeed"
```

The token used will be for the service user account of the identity provider client used by Stroom-Proxy.

That token's audience is validated at the destination just like any other, so the destination needs either an audience mapper on the proxy's client, or the audience the proxy's tokens actually carry listed in its `allowedAudiences`.
