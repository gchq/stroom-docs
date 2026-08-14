---
title: "Command Line Tools"
linkTitle: "Command Line Tools"
#weight:
date: 2021-07-27
tags: 
description: >
  Command line actions for administering Stroom.
---

Stroom has a number of tools that are available from the command line in addition to starting the main application.

This page is the reference for those commands.
If you are setting up a new installation and need to give it an administrator, follow [Creating the First Administrator]({{< relref "docs/install-guide/setup/create-first-admin" >}}) instead, which walks through the whole task.


## Which Command Do I Need?

| Goal | Command |
| ---- | ------- |
| Start the application | [`server`](#server) |
| Migrate the database without starting the application | [`migrate`](#migrate) |
| Create an account so somebody can log in (internal {{< glossary "idp" >}} only) | [`create_account`](#create_account) |
| Change the password of an existing account (internal {{< glossary "idp" >}} only) | [`reset_password`](#reset_password) |
| Create Stroom users and groups, or grant/revoke permissions | [`manage_users`](#manage_users) |
| Create an {{< glossary "API Key" >}} for a user | [`create_api_key`](#create_api_key) |

Note that creating an administrator on a fresh installation using the internal {{< glossary "idp" >}} needs **both** `create_account` and `manage_users`.
See [Accounts and Stroom Users](#accounts-and-stroom-users) below for why.


## Running Commands

The basic structure of the shell command for starting one of stroom's commands depends on whether you are running the zip distribution of stroom or a docker stack.

In either case, `COMMAND` is the name of the stroom command to run, as specified by the various headings on this page.
Each command value is described in its own section and may take no arguments or a mixture of mandatory and optional arguments.

{{% note %}}
These commands are very powerful and potentially dangerous in the wrong hands, e.g. they allow the changing of user's passwords.
Access to these commands should be strictly limited.
Also, each command will run in its own JVM so are not really intended to be run when Stroom is running on the node.
{{% /note %}}


### Running Commands with the Zip Distribution

The commands are run by passing the command and any of its arguments to the `java` command.
The jar file is in the `bin` directory of the zip distribution.

{{< command-line "stroomuser" "localhost" >}}
java -jar /absolute/path/to/stroom-app-all.jar \
COMMAND \
[COMMAND_ARG...] \
path/to/config.yml
{{</ command-line >}}

For example:

{{< command-line "stroomuser" "localhost" >}}
java -jar /opt/stroom/bin/stroom-app-all.jar \
reset_password \
-u joe \
-p "correct horse battery staple" \
/opt/stroom/config/config.yml
{{</ command-line >}}


### Running Commands in a Stroom Docker Stack

Commands are run in a Docker stack using the `command.sh` script found in the root of the stack directory structure.

{{% note %}}
You do not specify the config file location as the script does this for you.
{{% /note %}}

{{< command-line "stroomuser" "localhost" >}}
./command.sh COMMAND [COMMAND_ARG...]
{{</ command-line >}}

For example:

{{< command-line "stroomuser" "localhost" >}}
./command.sh \
reset_password \
-u joe \
-p "correct horse battery staple"
{{</ command-line >}}


## Accounts and Stroom Users

Several of the commands below only make sense once you understand that Stroom keeps *authentication* and *authorisation* separate.

* An {{< glossary "Account" >}} is an identity used to log in.
  Accounts only exist within Stroom when the internal {{< glossary "idp" >}} is used.
  With an external IDP the accounts live in that provider and the mechanism for creating them is specific to it.
* A Stroom {{< glossary "user" >}} is the entity that holds group memberships and permissions.
  One is always needed, whichever IDP is in use.

So when using the internal IDP, a person needs **both** an account (to authenticate) and a Stroom user with the same identifier (to be authorised).
When using an external IDP they need only a Stroom user.

{{% see-also %}}
See [Accounts vs Users]({{< relref "docs/install-guide/setup/open-id/accounts-users" >}}) for a fuller description.
{{% /see-also %}}


## Command Reference

{{% note %}}
All the examples below assume you are running stroom as part of the zip distribution.
If you are running a Docker stack then you will need to use the `command.sh` script (as described above) with the same arguments but omitting the config file path.
{{% /note %}}


### `server`

{{< command-line "stroomuser" "localhost" >}}
java -jar /absolute/path/to/stroom-app-all.jar \
server \
path/to/config.yml
{{</ command-line >}}

This is the normal command for starting the Stroom application using the supplied YAML configuration file.
The example above will start the application as a foreground process.
Stroom would typically be started using the `start.sh` shell script, but the command above is listed for completeness.

When stroom starts it will check the database to see if any migration is required.
If migration from an earlier version (including from an empty database) is required then this will happen as part of the application start process.


### `migrate`

{{< command-line "stroomuser" "localhost" >}}
java -jar /absolute/path/to/stroom-app-all.jar migrate path/to/config.yml
{{</ command-line >}}

There may be occasions where you want to migrate an old version but not start the application, e.g. during migration testing or to initiate the migration before starting up a cluster.
This command will run the process that checks for any required migrations and then performs them.
On completion of the process it exits.
This runs as a foreground process.


### `create_account`

{{< command-line "stroomuser" "localhost" >}}
java -jar /absolute/path/to/stroom-app-all.jar \
create_account \
--user USER \
--password PASSWORD \
[OPTIONS] \
path/to/config.yml
{{</ command-line >}}

Where the named arguments are:

* `-u` `--user` - The username for the user.
* `-p` `--password` - The password for the user.
* `-e` `--email` - The email address of the user.
* `-f` `--firstName` - The first name of the user.
* `-s` `--lastName` - The last name of the user.
* `--noPasswordChange` - If set do not require a password change on first login.
* `--neverExpires` - If set, the account will never expire.

This command creates an {{< glossary "Account" >}} in the internal identity provider within Stroom.
Stroom is able to use an external OpenID identity provider such as Google or AWS Cognito but by default will use its own.

{{% warning %}}
A fresh installation using the internal IDP does **not** create an `admin` account unless `stroom.security.identity.autoCreateAdminAccountOnBoot` is set to `true` before first boot, and that property defaults to `false`.
Most new installations therefore need this command.

See [Creating the First Administrator]({{< relref "docs/install-guide/setup/create-first-admin" >}}).
{{% /warning %}}

This command creates an account for authentication only.
A Stroom user with the same username is also needed before that person has any permissions, see [Accounts and Stroom Users](#accounts-and-stroom-users) and [`manage_users`](#manage_users).

The command will fail if the account already exists.
This command should NOT be run if you are using an external identity provider.

This command will also run any necessary database migrations to ensure it is working with the correct version of the database schema.


### `reset_password`

{{< command-line "stroomuser" "localhost" >}}
java -jar /absolute/path/to/stroom-app-all.jar \
reset_password \
--user USER \
--password PASSWORD \
path/to/config.yml
{{</ command-line >}}

Where the named arguments are:

* `-u` `--user` - The username for the user.
* `-p` `--password` - The password for the user.

This command is used for changing the password of an existing account in Stroom's internal identity provider.
It will also reset all locked/inactive/disabled statuses to ensure the account can be logged into.

This command should NOT be run if you are using an external identity provider as the external identity provider is responsible for managing authentication accounts.

This command will fail if the account does not exist, i.e. `create_account` should have already been run or Stroom should be configured with `stroom.security.identity.allowCertificateAuthentication` set to true.

This command will also run any necessary database migrations to ensure it is working with the correct version of the database schema.


### `manage_users`

{{< command-line "stroomuser" "localhost" >}}
java -jar /absolute/path/to/stroom-app-all.jar \
manage_users \
[OPTIONS] \
path/to/config.yml
{{</ command-line >}}

Where the named arguments are:

* `--createUser` `USER_IDENTIFIER` - Creates a Stroom user with the supplied user identifier.
  See [below](#user_identifier) for the format of this argument.
* `--createGroup` `GROUP_IDENTIFIER` - Creates a Stroom user group with the supplied group name.
* `--addToGroup` `USER_OR_GROUP_IDENTIFIER` `TARGET_GROUP` - Adds a user/group to an existing group.
* `--removeFromGroup` `USER_OR_GROUP_IDENTIFIER` `TARGET_GROUP` - Removes a user/group from an existing group.
* `--grantPermission` `USER_OR_GROUP_IDENTIFIER` `PERMISSION_IDENTIFIER` - Grants the named application permission to the user/group.
* `--revokePermission` `USER_OR_GROUP_IDENTIFIER` `PERMISSION_IDENTIFIER` - Revokes the named application permission from the user/group.
* `--listPermissions` - Lists all the valid permission names.

This command creates Stroom users and groups and manages their permissions.
It works regardless of whether the internal identity provider or an external one is used, and is the only way to give a brand new installation an administrator.

{{% warning %}}
This command does **not** create an account for authentication.
When using the internal IDP you need [`create_account`]({{< relref "#create_account" >}}) as well, and the username must match exactly.
See [Accounts and Stroom Users](#accounts-and-stroom-users).
{{% /warning %}}

This command is not intended for automation of user management tasks on a running Stroom instance that you can authenticate with.
It is only intended for cases where you cannot authenticate with Stroom, i.e. when setting up a new Stroom or when scripting the creation of a test environment.
If you want to automate actions that can be performed in the UI then you can make use of the REST API that is described at `/stroom/noauth/swagger-ui`.

The following is an example command to create a new stroom user `jbloggs`, create a group called `Administrators` with the _Administrator_ application permission and then add `jbloggs` to the `Administrators` group.
This is a typical command to bootstrap a stroom instance with one admin user so they can login to stroom with full privileges to manage other users from within the application.

{{< command-line "stroomuser" "localhost" >}}
java -jar /absolute/path/to/stroom-app-all.jar \
manage_users \
--createUser jbloggs \
--createGroup Administrators \
--addToGroup jbloggs Administrators \
--grantPermission Administrators "Administrator" \
path/to/config.yml
{{</ command-line >}}

Where _jbloggs_ is the user name of the account on the identity provider.

This command will also run any necessary database migrations to ensure it is working with the correct version of the database schema.

The named arguments can be used as many times as you like so you can create multiple users/groups/grants/etc.
Regardless of the order of the arguments, the changes are executed in the following order:

1. Create users
1. Create groups
1. Add users/groups to a group
1. Remove users/groups from a group
1. Grant permissions to users/groups
1. Revoke permissions from users/groups

The command is idempotent.
It can be run multiple times with the same value with no error.

The `manage_users` command is particularly useful for provisioning a new Stroom installation.
It allows you to automate the setup of some or all Stroom users and their group membership and application permissions.

{{% see-also %}}
See [Creating the First Administrator]({{< relref "docs/install-guide/setup/create-first-admin" >}}) for worked examples of bootstrapping a new installation with both the internal and an external IDP.
{{% /see-also %}}


#### `USER_IDENTIFIER`

External OIDC identity providers have a unique identifier for each user (this may be called `sub` or `oid`) and this often takes the form of a {{< glossary "UUID" >}}.
Stroom stores this unique identifier (known as a _Subject ID_ in stroom) against a user so it is able to associate the stroom user with the identity provider user.
Which claim is used for this is governed by `stroom.security.authentication.openId.uniqueIdentityClaim`, which defaults to `sub`.

The `USER_IDENTIFIER` is of the form `subject_id[,display_name[,full_name]]` e.g.:

* `eaddac6e-6762-404c-9778-4b74338d4a17`
* `eaddac6e-6762-404c-9778-4b74338d4a17,jbloggs`
* `eaddac6e-6762-404c-9778-4b74338d4a17,jbloggs,Joe Bloggs`

The optional parts are so that stroom can display more human friendly identifiers for a user.
They are only initial values and will always be over written with the values from the identity provider when the user logs in.
The properties `stroom.security.authentication.openId.userDisplayNameClaim` (defaults to `preferred_username`) and `stroom.security.authentication.openId.fullNameClaimTemplate` (defaults to `${name}`) control which claims are used for the _Display Name_ and _Full Name_ fields once that happens.

The following are examples of various uses of the `--createUser` argument group.

{{< command-line "stroomuser" "localhost" >}}
# Create a user using their unique IDP identifier and add them to group Administrators
java -jar /absolute/path/to/stroom-app-all.jar \
manage_users \
--createUser "45744aee-0b4c-414b-a82a-8b8b134cc201" \
--addToGroup "45744aee-0b4c-414b-a82a-8b8b134cc201"  Administrators \
path/to/config.yml

# Create a user using their unique IDP identifier, display name and full name
java -jar /absolute/path/to/stroom-app-all.jar \
manage_users \
--createUser "45744aee-0b4c-414b-a82a-8b8b134cc201,jbloggs,Joe Bloggs" \
--addToGroup "jbloggs"  Administrators \
path/to/config.yml

# Create multiple users at once, adding them to appropriate groups
java -jar /absolute/path/to/stroom-app-all.jar \
manage_users \
--createUser "45744aee-0b4c-414b-a82a-8b8b134cc201,jbloggs,Joe Bloggs" \
--createUser "37fb1eb4-f59c-4040-8e1d-57485e0f912f,jdoe,John Doe" \
--addToGroup "jbloggs"  Administrators \
--addToGroup "jdoe"  Analysts \
path/to/config.yml
{{</ command-line >}}


#### `GROUP_IDENTIFIER`

The `GROUP_IDENTIFIER` is the name of the group in stroom, e.g. `Administrators`, `Analysts`, etc.
Groups are created by an admin to help manage permissions for large number of similar users.
Groups relate only to stroom and have nothing to do with the identity provider.


#### `USER_OR_GROUP_IDENTIFIER`

The `USER_OR_GROUP_IDENTIFIER` can either be the identifier for a user or a group, e.g. when granting a permission to a user/group.

It takes the following forms (with examples for each):

* `user_subject_id`
    * `eaddac6e-6762-404c-9778-4b74338d4a17`
* `user_display_name`
    * `jbloggs`
* `group_name`
    * `Administrators`

The value for the argument will first be treated as a unique identifier (i.e. the subject ID or group name).
If the user cannot be found it will fall back to using the display name to find the user.


### `create_api_key`

The `create_api_key` command can be used to create an API Key for a user.
This is useful if, when bootstrapping a cluster, you want to set up a user and associated API Key to allow an external process to monitor/manage that Stroom cluster, e.g. using an Operator in Kubernetes.

{{< command-line >}}
java -jar /absolute/path/to/stroom-app-all.jar \
create_api_key \
--user jbloggs \
--expiresDays 365 \
--keyName "Test key" \
--outFile /tmp/api_key.txt \
path/to/config.yml
{{</ command-line >}}

The arguments to the command are as follows:

* `-u` `--user` - The identity of the user to create the API Key for.
  This is the unique subject ID of the user.
* `-n` `--keyName` - The name of the key.
  This must be unique for the user.
* `-e` `--expiresDays` - Optional number of days after which the key should expire.
  This must not be greater than the configured property `stroom.security.authentication.maxApiKeyExpiryAge`.
  If not set, it will be defaulted to the maximum configured age.
* `-c` `--comments` - Optional string to set the comments for the API Key.
* `-o` `--outFile` - Optional path to use to output the API Key string to.
  If not set, the API Key string will be output to _stdout_.
* `-a` `--hashAlgorithm` - Optional name of the hash algorithm used to hash the API Key.
  If not set, Stroom's default is used.


## Typical Use Cases

The most common use of these commands is bootstrapping a brand new installation with an administrator, using `create_account` and/or `manage_users`.

That task is documented as a step by step procedure, covering both the internal and an external identity provider, and both the zip and Docker forms of each command:

{{% see-also %}}
See [Creating the First Administrator]({{< relref "docs/install-guide/setup/create-first-admin" >}}).
{{% /see-also %}}
