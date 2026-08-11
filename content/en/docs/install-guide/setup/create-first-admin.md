---
title: "Creating the First Administrator"
linkTitle: "First Administrator"
weight: 50
date: 2026-08-11
tags:
  - install
description: >
  How to give a newly installed Stroom its first administrator, using the command line.
---

A new Stroom installation normally has no administrator.
Until one exists, nobody can log in and set the system up, so this is a required step for most installations.

This page covers how to create that first administrator from the command line.
Once you have one, all further users, groups and permissions can be managed from within the Stroom user interface.


## Do you need to do this?

You do **not** need to do this if either of the following applies:

* You are running the `stroom_core_test` Docker stack, which is pre-configured with an `admin` account (password `admin`).
  See [Single Node (Docker)]({{< relref "docs/install-guide/single-node-docker" >}}).
* You have set `stroom.security.identity.autoCreateAdminAccountOnBoot` to `true` **before first boot**, in which case Stroom creates the `admin` account for you.
  This property defaults to `false`.
  See [Internal IDP]({{< relref "open-id/internal-idp" >}}).

Everyone else needs to create an administrator manually.

{{% note %}}
`autoCreateAdminAccountOnBoot` only has an effect on a fresh database.
Setting it on an installation that has already started will not retrospectively create the account, so use this page instead.
{{% /note %}}


## Which procedure do you need?

If you have not started Stroom yet, follow the section matching the {{< glossary "idp" >}} you have configured, either [Internal IDP](#internal-idp) or [External IDP](#external-idp).

If you have already started Stroom and hit a problem, use this table to find the right one.

| Symptom | Cause | What to do |
| ------- | ----- | ---------- |
| You reach the Stroom login page but have no credentials that work | Using the {{< glossary "idp" "internal IDP" >}} and no {{< glossary "Account" "account" >}} exists | [Internal IDP](#internal-idp) below |
| You can sign in via your identity provider, but Stroom shows no content and you cannot create anything | Using an external {{< glossary "idp" >}} and no {{< glossary "user" "Stroom user" >}} exists for your identity, or it has no permissions | [External IDP](#external-idp) below |

The two cases differ because Stroom separates *authentication* from *authorisation*:

* An **Account** is an identity used to log in.
  Accounts only exist in Stroom when the internal IDP is used; with an external IDP the accounts live in that provider.
* A **Stroom user** is the entity that holds group memberships and permissions.
  One is always needed, whichever IDP is in use.

{{% see-also %}}
See [Accounts vs Users]({{< relref "open-id/accounts-users" >}}) for a fuller description of this distinction.
{{% /see-also %}}


## Before you start

You will need:

* Shell access to a Stroom node as the [processing user]({{< relref "processing-user-setup" >}}), e.g. `stroomuser`.
* Stroom **not running** on that node.
  Each command runs in its own JVM and is not intended to be run against a live node.
* For an external IDP, the unique identifier of the person who will be the administrator, as held by that provider.
  See [Finding the user's identifier on an external IDP](#finding-the-users-identifier-on-an-external-idp).

The commands below are shown in two forms.
Use whichever matches your installation:

* **Zip distribution** - `java -jar /absolute/path/to/stroom-app-all.jar COMMAND [ARGS] path/to/config.yml`
* **Docker stack** - `./command.sh COMMAND [ARGS]` run from the root of the stack directory.
  The script supplies the config file path for you, so do **not** pass one.

{{% see-also %}}
See [Command Line Tools]({{< relref "docs/user-guide/tools/command-line" >}}) for the full reference for each command used here.
{{% /see-also %}}


## Internal IDP

This is the default configuration, where Stroom manages its own accounts.

Creating an administrator takes two commands, because an account and a Stroom user are two different things:

1. `create_account` creates the account used to log in.
1. `manage_users` creates the Stroom user, creates an `Administrators` group holding the `Administrator` application permission, and puts the user in that group.

Assuming you want to set up `johndoe` as an administrator:

### 1. Create the account

{{< command-line "stroomuser" "localhost" >}}
java -jar /absolute/path/to/stroom-app-all.jar \
create_account \
--user johndoe \
--firstName John \
--lastName Doe \
--password "correct horse battery staple" \
path/to/config.yml
{{</ command-line >}}

Or, in a Docker stack:

{{< command-line "stroomuser" "localhost" >}}
./command.sh \
create_account \
--user johndoe \
--firstName John \
--lastName Doe \
--password "correct horse battery staple"
{{</ command-line >}}

By default Stroom will require this password to be changed at first login, governed by `stroom.security.identity.passwordPolicy.forcePasswordChangeOnFirstLogin`.
Pass `--noPasswordChange` if you do not want that.

### 2. Create the Stroom user and grant permissions

{{< command-line "stroomuser" "localhost" >}}
java -jar /absolute/path/to/stroom-app-all.jar \
manage_users \
--createUser johndoe \
--createGroup Administrators \
--addToGroup johndoe Administrators \
--grantPermission Administrators "Administrator" \
path/to/config.yml
{{</ command-line >}}

Or, in a Docker stack:

{{< command-line "stroomuser" "localhost" >}}
./command.sh \
manage_users \
--createUser johndoe \
--createGroup Administrators \
--addToGroup johndoe Administrators \
--grantPermission Administrators "Administrator"
{{</ command-line >}}

{{% warning %}}
The username must match **exactly** between `--user` (in `create_account`), `--createUser` and `--addToGroup` (in `manage_users`).
A mismatch produces an account that can log in but has no permissions.
{{% /warning %}}

To set up more than one administrator, repeat the `create_account` command for each person and pass the extra `--createUser`/`--addToGroup` arguments in a single `manage_users` command:

{{< command-line "stroomuser" "localhost" >}}
java -jar /absolute/path/to/stroom-app-all.jar \
manage_users \
--createUser johndoe \
--createUser janedoe \
--createGroup Administrators \
--addToGroup johndoe Administrators \
--addToGroup janedoe Administrators \
--grantPermission Administrators "Administrator" \
path/to/config.yml
{{</ command-line >}}


## External IDP

Where a 3rd party identity provider holds the accounts, you only need to create the Stroom user, not an account.
The provider is responsible for the credentials.

{{% warning %}}
Do **not** run `create_account` or `reset_password` when using an external IDP.
{{% /warning %}}

### Finding the user's identifier on an external IDP

Stroom links a Stroom user to an identity on the provider using a single claim from the authentication token.
Which claim is used is set by `stroom.security.authentication.openId.uniqueIdentityClaim`, which defaults to `sub`.

Establish that claim first, then find its value for the person who will be the administrator.
Depending on the provider, the value may look like a {{< glossary "UUID" >}}, an email address, or something else.

The provider-specific pages describe where to find this value:

* [KeyCloak]({{< relref "open-id/external-idp/keycloak#setting-up-the-admin-user-in-stroom" >}})
* [AWS Cognito]({{< relref "open-id/external-idp/cognito" >}})
* [Google]({{< relref "open-id/external-idp/google" >}})
* [Azure AD / Entra ID]({{< relref "open-id/external-idp/azure-ad" >}})

### Create the Stroom user and grant permissions

Assuming the unique identifier for _John Doe_ is `b6e06181-9e10-44eb-a33a-537509ec3abd`:

{{< command-line "stroomuser" "localhost" >}}
subject_id="b6e06181-9e10-44eb-a33a-537509ec3abd"; \
java -jar /absolute/path/to/stroom-app-all.jar \
manage_users \
--createUser "${subject_id},johndoe,John Doe" \
--createGroup Administrators \
--addToGroup "${subject_id}" Administrators \
--grantPermission Administrators "Administrator" \
path/to/config.yml
{{</ command-line >}}

The `johndoe` and `John Doe` parts are the optional display name and full name.
They are there so the Stroom user interface shows something more human friendly than a UUID.
They are only initial values and are overwritten with the values from the provider when the user first logs in.
See [`USER_IDENTIFIER`]({{< relref "docs/user-guide/tools/command-line#user_identifier" >}}) for the format of this argument.

{{% note %}}
Ideally run this **before** the administrator first logs in.
If they have already logged in then Stroom will have created a user for them automatically, and `--createUser` will leave that user alone, other than re-enabling it if it had been disabled.
The `--addToGroup` and `--grantPermission` arguments are what actually give them access.
{{% /note %}}


## Verifying it worked

Start Stroom, then log in as the new administrator.

If the login succeeds and the main menu includes

{{< stroom-menu "Security" "Users" >}}

then the user has the `Administrator` application permission and the setup is complete.

If you can log in but see nothing and the _Security_ menu is missing or sparse, the account exists but the Stroom user has no permissions.
Re-check that the identifiers matched exactly, then re-run the `manage_users` command.
It is idempotent, so it is safe to run again.

{{% warning %}}
If `manage_users` was run while Stroom was running, the new permissions may not take effect immediately because user permissions are cached.
Without Administrator rights you cannot clear the caches from the user interface, so either wait for the cache entries to expire or restart Stroom.
{{% /warning %}}


## What to do next

Now that you have an administrator you can manage everything else from within Stroom:

* [User Accounts]({{< relref "docs/user-guide/security/user-accounts" >}}) - creating further accounts (internal IDP only).
* [Users and Groups]({{< relref "docs/user-guide/security/users-and-groups" >}}) - creating users and groups.
* [Application Permissions]({{< relref "docs/user-guide/security/app-permissions" >}}) - granting permissions.
