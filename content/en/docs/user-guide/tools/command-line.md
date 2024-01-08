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


## Running commands

The basic structure of the shell command for starting one of stroom's commands depends on whether you are running the zip distribution of stroom or a docker stack.

In either case, `COMMAND` is the name of the stroom command to run, as specified by the various headings on this page.
Each command value is described in its own section and may take no arguments or a mixture of mandatory and optional arguments.

{{% note %}}
These commands are very powerful and potentially dangerous in the wrong hands, e.g. they allow the changing of user's passwords.
Access to these commands should be strictly limited.
Also, each command will run in its own JVM so are not really intended to be run when Stroom is running on the node.
{{% /note %}}


### Running commands with the zip distribution

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


### Running commands in a stroom Docker stack

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


## Command reference

{{% note %}}
All the examples below assume you are running stroom as part of the zip distribution.
If you are running a Docker stack then you will need to use the `command.sh` script (as described above) with the same arguments  but omitting the config file path.
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
--u USER \
--p PASSWORD \
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

This command will create an account in the internal identity provider within Stroom.
Stroom is able to use an external OpenID identity providers such as Google or AWS Cognito but by default will use its own.
When configured to use its own (the default) it will auto create an admin account when starting up a fresh instance.
There are times when you may wish to create this account manually which this command allows.


#### Authentication Accounts and Stroom Users

The user account used for authentication is distinct to the Stroom _user_ entity that is used for authorisation within Stroom.
If an external IDP is used then the mechanism for creating the authentication account will be specific to that IDP.
If using the default internal Stroom IDP then an account must be created in order to authenticate, either from within the UI if you are already authenticated as a privileged used or using this command.
In either case a Stroom user will need to exist with the same username as the authentication account.

The command will fail if the user already exists.
This command should NOT be run if you are using an external identity provider.

This command will also run any necessary database migrations to ensure it is working with the correct version of the database schema.


### `reset_password`

{{< command-line "stroomuser" "localhost" >}}
java -jar /absolute/path/to/stroom-app-all.jar \
reset_password \
--u USER \
--p PASSWORD \
path/to/config.yml
{{</ command-line >}}

Where the named arguments are:

* `-u` `--user` - The username for the user.
* `-p` `--password` - The password for the user.

This command is used for changing the password of an existing account in stroom's internal identity provider.
It will also reset all locked/inactive/disabled statuses to ensure the account can be logged into.
This command should NOT be run if you are using an external identity provider.
It will fail if the account does not exist.

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
* `--greateGroup` `GROUP_IDENTIFIER` - Creates a Stroom user group with the supplied group name.
* `--addToGroup` `USER_OR_GROUP_IDENTIFIER` `TARGET_GROUP` - Adds a user/group to an existing group.
* `--removeFromGroup` `USER_OR_GROUP_IDENTIFIER` `TARGET_GROUP` - Removes a user/group from an existing group.
* `--grantPermission` `USER_OR_GROUP_IDENTIFIER` `PERMISSION_IDENTIFIER` - Grants the named application permission to the user/group.
* `--revokePermission` `USER_OR_GROUP_IDENTIFIER` `PERMISSION_IDENTIFIER` - Revokes the named application permission from the user/group.
* `--listPermissions` - Lists all the valid permission names.

This command allows you to manage the account permissions within stroom regardless of whether the internal identity provider or an external party is used.
A typical use case for this is when using a external identity provider.
In this instance Stroom has no way of auto creating an admin account when first started so the association between the account on the 3rd party IDP and the stroom user account needs to be made manually.
To set up an admin account to enable you to login to stroom you can do:

This command is not intended for automation of user management tasks on a running Stroom instance that you can authenticate with.
It is only intended for cases where you cannot authenticate with Stroom, i.e. when setting up a new Stroom with a 3rd party IDP or when scripting the creation of a test environment.
If you want to automate actions that can be performed in the UI then you can make use of the REST API that is described at `/stroom/noauth/swagger-ui`.

{{% warning %}}
See the [section](#authentication-accounts-and-stroom-users) above about the distinction between authentication accounts and stroom users.
{{% /warning %}}

The following is an example command to create a new stroom user `jbloggs`, create a group called `Administrators` with the _Administrator_ application permission and then add `jbloggs` to the `Administrators` group.
This is a typical command to bootstrap a stroom instance with one admin user so they can login to stroom with full privileges to manage other users from within the application.

{{< command-line "stroomuser" "localhost" >}}
java -jar /absolute/path/to/stroom-app.jar \
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


#### External Identity Providers

The `manageUsers` command is particularly useful when using stroom with an external identity provider.
In order to use a new install of stroom that is configured with an external identity provider you must first set up a user with the _Administrator_ system permission.
If this is not done, users will be able to log in to stroom but will have no permissions to do anything.
You can optionally set up other groups/users with other permissions to bootstrap the stroom instance.

External OIDC identity providers have a unique identifier for each user (this may be called `sub` or `oid`) and this often takes the form of a {{< glossary "UUID" >}}.
Stroom stores this unique identifier (know as a _Subject ID_ in stroom) against a user so it is able to associate the stroom user with the identity provider user.
Identity providers may also have a more friendly _display name_ and _full name_ for the user, though these may not be unique.


##### `USER_IDENTIFIER`

The `USER_IDENTIFIER` is of the form `subject_id[,display_name[,full_name]]` e.g.:

* `eaddac6e-6762-404c-9778-4b74338d4a17`
* `eaddac6e-6762-404c-9778-4b74338d4a17,jbloggs`
* `eaddac6e-6762-404c-9778-4b74338d4a17,jbloggs,Joe Bloggs`

The optional parts are so that stroom can display more human friendly identifiers for a user.
They are only initial values and will always be over written with the values from the identity provider when the user logs in.

The following are examples of various uses of the `--createUser` argument group.

{{< command-line "stroomuser" "localhost" >}}
# Create a user using their unique IDP identifier and add them to group Administrators
java -jar /absolute/path/to/stroom-app.jar \
manage_users \
--createUser "45744aee-0b4c-414b-a82a-8b8b134cc201" \
--addToGroup "45744aee-0b4c-414b-a82a-8b8b134cc201"  Administrators \
path/to/config.yml

# Create a user using their unique IDP identifier, display name and full name
java -jar /absolute/path/to/stroom-app.jar \
manage_users \
--createUser "45744aee-0b4c-414b-a82a-8b8b134cc201,jbloggs,Joe Bloggs" \
--addToGroup "jbloggs"  Administrators \
path/to/config.yml

# Create multiple users at once, adding them to appropriate groups
java -jar /absolute/path/to/stroom-app.jar \
manage_users \
--createUser "45744aee-0b4c-414b-a82a-8b8b134cc201,jbloggs,Joe Bloggs" \
--createUser "37fb1eb4-f59c-4040-8e1d-57485e0f912f,jdoe,John Doe" \
--addToGroup "jbloggs"  Administrators \
--addToGroup "jdoe"  Analysts \
path/to/config.yml
{{</ command-line >}}


##### `GROUP_IDENTIFIER`

The `GROUP_IDENTIFIER` is the name of the group in stroom, e.g. `Administrators`, `Analysts`, etc.
Groups are created by an admin to help manage permissions for large number of similar users.
Groups relate only to stroom and have nothing to do with the identity provider.


##### `USER_OR_GROUP_IDENTIFIER`

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
