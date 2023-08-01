---
title: "External IDP"
linkTitle: "External IDP"
weight: 30
date: 2022-11-25
tags:
description: >
  How to setup KEyCloak as an external identity provider for Stroom.
  
---

You may be running Stroom in an environment with an existing {{< glossary "identity provider idp" "Identity Provider (IDP)" >}} (KeyCloak, Cognito, Google, Active Directory, etc.) and want to use that for authenticating users.
Stroom supports 3rd party IDPs that conform to the {{< external-link "Open ID Connect" "https://openid.net/connect/" >}} specification.

The following is a guide to setting up a new stroom instance/cluster with KeyCloak as the 3rd party IDP.
KeyCloak is an Open ID Connect IDP.
Configuration for other IDPs will be very similar so these instructions will have to be adapted accordingly.
It is assumed that you have deployed a new instance/cluster of stroom AND have not yet started it.


## Running KeyCloak

> If you already have a KeyCloak instance running then move on to the next section.

This section is not a definitive guide to running/administering KeyCloak.
It describes how to run KeyCloak using non-production settings for simplicity and to demonstrate using a 3rd party IDP.
You should consult the KeyCloak documentation on how to set up a production ready instance of KeyCloak.

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


## Creating a realm

First you need to create a Realm.

1. Click on the drop-down in the left pane that contains the word `master`.
1. Click _Create Realm_.
1. Set the _Realm name_ to `StroomRealm`.
1. Click _Create_.


## Creating a client

In the new realm click on _Clients_ in the left pane, then _Create client_.

1. Set the _Client ID_ to `StroomClient`.
1. Click _Next_.
1. Set _Client authentication_ to on.
1. Ensure the following are ticked:
    * Standard flow
    * Direct access grants
1. Click _Save_.

Open the new _Client_ and on the _Settings_ tab set:

* _Valid redirect URIs_ to `https://localhost/*`
* _Valid post logout redirect URIs_ to `https://localhost/*`

On the _Credentials_ tab copy the _Client secret_ for use later in Stroom config.


## Creating users

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

Edit the `config.yml` file and set the following values

```yaml
  receive:
    # Set to true to require authenticatin for /datafeed requests
    authenticationRequired: true
    # Set to true to allow authentication using an Open ID token
    tokenAuthenticationEnabled: true
  security:
    authentication:
      authenticationRequired: true
      openId:
        # The client ID created in KeyCloak
        clientId: "StroomClient"
        # The client secret copied from KeyCloak above
        clientSecret: "XwTPPudGZkDK2hu31MZkotzRUdBWfHO6"
        # Tells Stroom to use an external IDP for authentication
        identityProviderType: EXTERNAL_IDP
        # The URL on the IDP to redirect users to when logging out in Stroom
        logoutEndpoint: "http://localhost:9999/realms/StroomRealm/protocol/openid-connect/logout"
        # The endpoint to obtain the rest of the IDPs configuration. Specific to the realm/issuer.
        openIdConfigurationEndpoint: "http://localhost:9999/realms/StroomRealm/.well-known/openid-configuration"
```

These values are obtained from the IDP.
In the case of KeyCloak they can be found by clicking on _Realm settings_ => _Endpoints_ => _OpenID Endpoint Configuration_ and extracting the various values from the JSON response.
Alternatively they can typically be found at this address on any Open ID Connect IDP, _https://host/.well-known/openid-configuration_.
The values will reflect the host/port that the IDP is running on along with the name of the realm.

Setting the above values assumes _KeyCloak_ is running on `localhost:9999` and the _Realm_ name is `StroomRealm`.


## Setting up the admin user in Stroom

Now that the `admin` user exists in the IDP we need to grant it `Administrator` rights in Stroom.

In the _Users_ section of KeyCloak click on user `admin`.
On the _Details_ tab copy the value of the _ID_ field.
The ID is in the form of a {{< glossary "UUID" >}}
This ID will be used in Stroom to uniquely identify the user and associate it with the identity in KeyCloak.

To set up Stroom with this admin user run the following (**before** Stroom has been started for the first time):

{{< command-line >}}
subject_id="XXX"; \
java -jar /absolute/path/to/stroom-app-all.jar \
  manage_users \
  ../local.yml \
  --createUser "${subject_id}" \
  --createGroup Administrators \
  --addToGroup "${subject_id}" Administrators \
  --grantPermission Administrators "Administrator"
{{</ command-line >}}

Where `XXX` is the user ID copied from the IDP as described above.
This command is repeatable as it will skip any users/groups/memberships that already exist.

{{% see-also %}}
See [Command Line Tools]({{< relref "command-line" >}}) for more details on using the `manage_users` command.
{{% /see-also %}}

This command will do the following:

* Create the Stroom User by creating an entry in the `stroom_user` database table for the IDP's `admin` user.
* Ensure that an `Adminstrators` group exists (i.e. an entry in the `stroom_user` database table for the `Adminstrators` group).
* Add the `admin` user to the group `Administrators`.
* Grant the application permission `Administrator` to the group `Administrators`.

{{% note %}}
This process is only required to bootstrap the admin user to allow them to log in with administrator rights to be able to manage the permissions and group memberships of other users.
It does not need to be done for every user.
Whenever a user successfully logs in via the IDP, Stroom will automatically create an entry in the `stroom_user` table for that user.
The user will have no permissions or group memberships so this will need to be applied by the administrator.
This does mean that new users will need to login before the administrator can manage their permissions/memberships.
{{% /note %}}


## Logging into Stroom

### As the administrator

Now that the user and permissions have been set up in Stroom, the administrator can log in.

First start the Stroom instance/cluster.

{{% warning %}}
If the `manage_users` command is run while Stroom is running you will likely not see the effect when logging in as the user permissions are cached.
Without Administrator rights you will not be able to clear the caches so you will need to wait for the cache entries to expire or restart Stroom.
{{% /warning %}}

Navigate to _http://STROOM_FQDN_ and Stroom should re-direct you to the IDP (KeyCloak) to authenticate.
Enter the username of `admin` and password `admin`.
You should be authenticated by KeyCloak and re-directed back to stroom.
Your user ID is shown in the bottom right corner of the Welcome tab.

As an administrator, the _Tools_ => _User Permissions_ menu item will be available to manage the permissions of any users that have logged on at least once.

Now select _User_ => _Logout_ to be re-directed to the IDP to logout.
Once you logout of the IDP it should re-direct you back to the IDP login screen for Stroom to log back in again.


### As an ordinary user

On the IDP login screen, login as user `jbloggs` with the password `password`.
You will be re-directed to Stroom however the explorer tree will be empty and most of the menu items will be disabled.
In order to gain permissions to do anything in Stroom a Stroom administrator will need to grant application/document permissions and/or group memberships to the user via the _Tools_ => _User Permissions_ menu item.


## Configure Stroom-Proxy for KeyCloak

In order to user Stroom-Proxy with OIDC

Edit the `config.yml` file and set the following values

```yaml
  receive:
    # Set to true to require authenticatin for /datafeed requests
    authenticationRequired: true
    # Set to true to allow authentication using an Open ID token
    tokenAuthenticationEnabled: true
  security:
    authentication:
      openId:
        # The client ID created in KeyCloak
        clientId: "StroomClient"
        # The client secret copied from KeyCloak above
        clientSecret: "XwTPPudGZkDK2hu31MZkotzRUdBWfHO6"
        # Tells Stroom to use an external IDP for authentication
        identityProviderType: EXTERNAL_IDP
        # The URL on the IDP to redirect users to when logging out in Stroom
        logoutEndpoint: "http://localhost:9999/realms/StroomRealm/protocol/openid-connect/logout"
        # The endpoint to obtain the rest of the IDPs configuration. Specific to the realm/issuer.
        openIdConfigurationEndpoint: "http://localhost:9999/realms/StroomRealm/.well-known/openid-configuration"
```

If Stroom-Proxy is configured to forward data onto another Stroom-Proxy or Stroom instance then it can use tokens when forwarding the data.
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
