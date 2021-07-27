---
title: "Command Line Tools"
linkTitle: "Command Line Tools"
#weight:
date: 2021-07-27
tags: 
description: >
  Command line actions for administering Stroom.
---

> **Version Information:** Created with Stroom v7.0  
> **Last Updated:** 10 September 2020  

Stroom has a number of tools that are available from the command line in addition to starting the main application.

The basic structure of the command for starting one of stroom's commands is:

```bash
java -jar /absolute/path/to/stroom-app.jar COMMAND
```

`COMMAND` can be a number of values depending on what you want to do.
Each command value is described in its own section.

> **NOTE:** These commands are very powerful and potentially dangerous in the wrong hands, e.g. they allow the changing of user's passwords.
> Access to these commands should be strictly limited.
> Also, each command will run in its own JVM so are not really intended to be run when Stroom is running on the node.

## `server`

```bash
java -jar /absolute/path/to/stroom-app.jar server path/to/config.yml
```

This is the normal command for starting the Stroom application using the supplied YAML configuration file.
The example above will start the application as a foreground process.
Stroom would typically be started using the `start.sh` shell script, but the command above is listed for completeness.

When stroom starts it will check the database to see if any migration is required.
If migration from an earlier version (including from an empty database) is required then this will happen as part of the application start process.


## `migrate`

```bash
java -jar /absolute/path/to/stroom-app.jar migrate path/to/config.yml
```

There may be occasions where you want to migrate an old version but not start the application, e.g. during migration testing or to initiate the migration before starting up a cluster.
This command will run the process that checks for any required migrations and then performs them.
On completion of the process it exits.
This runs as a foreground process.


## `create_account`

```bash
java -jar /absolute/path/to/stroom-app.jar create_account --u USER --p PASSWORD [OPTIONS] path/to/config.yml
```
Where the named arguments are:

* `-u` `--user` - The username for the user.
* `-p` `--password` - The password for the user.
* `-e` `--email` - The email address of the user.
* `-f` `--firstName` - The first name of the user.
* `-s` `--lastName` - The last name of the user.
* `--noPasswordChange` - If set do not require a password change on first login.
* `--neverExpires` - If set, the account will never expire.

This command will create an account in the internal identity provider within Stroom.
Stroom is able to use third party OpenID identity providers such as Google or AWS Cognito but by default will use its own.
When configured to use its own (the default) it will auto create an admin account when starting up a fresh instance.
There are times when you may wish to create this account manually which this command allows.

### Authentication Accounts and Stroom Users
The user account used for authentication is distinct to the Stroom _user_ entity that is used for authorisation within Stroom.
If an external IDP is used then the mechanism for creating the authentication account will be specific to that IDP.
If using the default internal Stroom IDP then an account must be created in order to authenticate, either from within the UI if you are already authenticated as a privileged used or using this command.
In either case a Stroom user will need to exist with the same username as the authentication account.

The command will fail if the user already exists.
This command should NOT be run if you are using a third party identity provider.

This command will also run any necessary database migrations to ensure it is working with the correct version of the database schema.


## `reset_password`

```bash
java -jar /absolute/path/to/stroom-app.jar reset_password --u USER --p PASSWORD path/to/config.yml
```
Where the named arguments are:

* `-u` `--user` - The username for the user.
* `-p` `--password` - The password for the user.

This command is used for changing the password of an existing account in stroom's internal identity provider.
It will also reset all locked/inactive/disabled statuses to ensure the account can be logged into.
This command should NOT be run if you are using a third party identity provider.
It will fail if the account does not exist.

This command will also run any necessary database migrations to ensure it is working with the correct version of the database schema.


## `manage_users`

```bash
java -jar /absolute/path/to/stroom-app.jar manage_users [OPTIONS] path/to/config.yml
```
Where the named arguments are:

* `--createUser USER_NAME` - Creates a Stroom user with the supplied username.
* `--greateGroup GROUP_NAME` - Creates a Stroom user group with the supplied group name.
* `--addToGroup USER_OR_GROUP_NAME TARGET_GROUP` - Adds a user/group to an existing group.
* `--removeFromGroup USER_OR_GROUP_NAME TARGET_GROUP` - Removes a user/group from an existing group.
* `--grantPermission USER_OR_GROUP_NAME PERMISSION_NAME` - Grants the named application permission to the user/group.
* `--revokePermission USER_OR_GROUP_NAME PERMISSION_NAME` - Revokes the named application permission from the user/group.
* `--listPermissions` - Lists all the valid permission names.

This command allows you to manage the account permissions within stroom regardless of whether the internal identity provider or a 3rd party one is used.
A typical use case for this is when using a third party identity provider.
In this instance Stroom has no way of auto creating an admin account when first started so the association between the account on the 3rd party IDP and the stroom user account needs to be made manually.
To set up an admin account to enable you to login to stroom you can do:

This command is not intended for automation of user management tasks on a running Stroom instance that you can authenticate with.
It is only intended for cases where you cannot authenticate with Stroom, i.e. when setting up a new Stroom with a 3rd party IDP or when scripting the creation of a test environment.
If you want to automate actions that can be performed in the UI then you can make use of the REST API that is described at `/stroom/noauth/swagger-ui`.

> See the [note](#authentication-accounts-and-stroom-users) above about the distinction between authentication accounts and stroom users.

```bash
java -jar /absolute/path/to/stroom-app.jar manage_users --createUser jbloggs --createGroup Administrators --addToGroup jbloggs Administrators --grantPermission Administrators "Administrator" path/to/config.yml
```

Where _jbloggs_ is the user name of the account on the 3rd party IDP.

This command will also run any necessary database migrations to ensure it is working with the correct version of the database schema.

The named arguments can be used as many times as you like so you can create multiple users/groups/grants/etc.
Regardless of the order of the arguments, the changes are executed in the following order:

1. Create users
1. Create groups
1. Add users/groups to a group
1. Remove users/groups from a group
1. Grant permissions to users/groups
1. Revoke permissions from users/groups

