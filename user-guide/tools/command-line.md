# Command Line Tools

> * Version Information: Created with Stroom v7.0  
* Last Updated: 10 September 2020  

Stroom has a number of tools that are available from the command line in addition to starting the main application.

The basic structure of the command for starting one of stroom's commands is:

```bash
java -jar /absolute/path/to/stroom-app.jar COMMAND
```

`COMMAND` can be a number of values depending on what you want to do.
Each command value is described in its own section.

> **NOTE:** These commands are very powerful and potentially dangerous in the wrong hands, e.g. they allow the changing of user's passwords.
> Access to these commands should be strictly limited.

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

The command will fail if the user already exists.
This command should NOT be run if you are using a third party identity provider.

## `reset_password`

```bash
java -jar /absolute/path/to/stroom-app.jar reset_password --u USER --p PASSWORD path/to/config.yml
```
Where the named arguments are:

* `-u` `--user` - The username for the user.
* `-p` `--password` - The password for the user.

This command is used for changing the password of an existing account in stroom's internal identity provider.
This command should NOT be run if you are using a third party identity provider.
It will fail if the account does not exist.

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

```bash
java -jar /absolute/path/to/stroom-app.jar manage_users --createUser jbloggs --createGroup Administrators --addToGroup jbloggs Administrators --grantPermission Administrators "Administrator" path/to/config.yml
```

Where _jbloggs_ is the user name of the account on the 3rd party IDP.



