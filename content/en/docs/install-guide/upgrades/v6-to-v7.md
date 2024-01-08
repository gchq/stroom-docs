---
title: "Upgrade from v6 to v7"
linkTitle: "Upgrade from v6 to v7"
#weight:
date: 2022-02-04
tags: 
description: >
  This document describes the process for upgrading a Stroom single node docker stack from v6.x to v7.x.

---

{{% page-warning %}}
Before comencing an upgrade to v7 you should upgrade Stroom to the latest minor and patch version of v6.
{{% /page-warning %}}

## Differences between v6 and v7

Stroom v7 has significant differences to v6 which make the upgrade process a little more complicated.

* v6 handled authentication using a separate application, _stroom-auth-service_, with its own database.
  In v7 authentication is handled either internally in stroom (the default) or by an external identity provider such as google or AWS Cognito.
* v6 used a stroom.conf file or environment variables for configuration.
  In v7 stroom uses a config.yml file for its configuration (see [Properties]({{< relref "../../user-guide/properties.md" >}}))
* v6 used upper case and heavily abbreviated names for its tables.
  In v7 clearer and lower case table names are used.
  As a result ALL v6 tables get renamed with the prefix `OLD_`, the new tables created and any content copied over.
  As the database will be holding two copies of most data you need to ensure you have space to accomodate it.


## Pre-Upgrade tasks

The following steps are required to be performed before migrating from v6 to v7.


### Download migration scripts

Download the migration SQL scripts from https://github.com/gchq/stroom/blob/STROOM_VERSION/scripts 
e.g. https://github.com/gchq/stroom/blob/v7.0-beta.133/scripts 

These scripts will be used in the steps below.


### Pre-migration database checks

Run the pre-migration checks script on the running database.

{{< command-line "stroomuser" "localhost" >}}
docker exec \
-i \
stroom-all-dbs \
mysql --table -u"stroomuser" -p"stroompassword1" stroom \
< v7_db_pre_migration_checks.sql
{{</ command-line >}}

This will produce a report of items that will not be migrated or need attention before migration.


### Stop processing

Before shutting stroom down it is wise to turn off stream processing and let all outstanding server tasks complete.

*TODO* clairfy steps for this.


### Stop the stack

Stop the stack (stroom and the database) then start up the database.
Do this using the v6 stack.
This ensures that stroom is not trying to access the database.

{{< command-line "stroomuser" "localhost" >}}
./stop.sh
./start.sh stroom-all-dbs
{{</ command-line >}}


### Backup the databases

Backup all the databases for the different components.
Typically these will be `stroom`, `stats` and `auth`.

If you are running in a docker stack then you can run the `./backup_databases.sh` script.


### Stop the database

Stop the database using the v6 stack.

{{< command-line "stroomuser" "localhost" >}}
./stop.sh
{{</ command-line >}}


### Deploy and configure v7

Deploy the v7 stack.
*TODO* - more detail

Verify the database connection configuration for the stroom and stats databases.
Ensure that there is NOT any configuration for a separate auth database as this will now be in stroom.


### Running `mysql_upgrade`

Stroom v6 ran on mysql v5.6.
Stroom v7 runs on mysql v8.
The upgrade path for MySQL is 5.6 => 5.7.33 => 8.x

To ensure the database is up to date `mysql_upgrade` neeeds to be run using the 5.7.33 binaries, see the {{< external-link "MySQL documentation" "https://dev.mysql.com/doc/refman/8.0/en/mysql-upgrade.html" >}}.

This is the process for upgrading the database. All of these commands are using the v7 stack.

{{< command-line "stroomuser" "localhost" >}}
# Set the version of the MySQL docker image to use
export MYSQL_TAG=5.7.33
(out)
# Start MySQL at v5.7, this will recreate the container
./start.sh stroom-all-dbs
(out)
# Run the upgrade from 5.6 => 5.7.33
docker exec -it stroom-all-dbs mysql_upgrade -u"root" -p"my-secret-pw"
(out)
# Stop MySQL
./stop.sh
(out)
# Unset the tag variable so that it now uses the default from the stack (8.x)
unset MYSQL_TAG
(out)
# Start MySQL at v8.x, this will recreate the container and run the upgrade from 5.7.33=>8
./start.sh stroom-all-dbs
(out)
./stop.sh
{{</ command-line >}}


### Rename legacy stroom-auth tables

Run this command to connect to the `auth` database and run the pre-migration SQL script.

{{< command-line "stroomuser" "localhost" >}}
docker exec \
-i \
stroom-all-dbs \
mysql --table -u"authuser" -p"stroompassword1" auth \
< v7_auth_db_table_rename.sql
{{</ command-line >}}

This will rename all but one of the tables in the `auth` database.


### Copy the `auth` database content to `stroom`

Having run the table rename perform another backup of just the `auth` database.

{{< command-line "stroomuser" "localhost" >}}
./backup_databases.sh . auth

{{</ command-line >}}
Now restore this backup into the `stroom` database.
You can use the v7 stack scripts to do this.

{{< command-line "stroomuser" "localhost" >}}
./restore_database.sh stroom auth_20210312143513.sql.gz
{{</ command-line >}}

You should now see the following tables in the `stroom` database:

```text
OLD_AUTH_json_web_key
OLD_AUTH_schema_version
OLD_AUTH_token_types
OLD_AUTH_tokens
OLD_AUTH_users
```

This can be checked by running the following in the v7 stack.

{{< command-line "stroomuser" "localhost" >}}
echo 'select table_name from information_schema.tables where table_name like "OLD_AUTH%"' \
| ./database_shell.sh
{{</ command-line >}}


### Drop unused databases

There may be a number of databases that are no longer used that can be dropped prior to the upgrade.
Note the use of the `--force` argument so it copes with users that are not there.

{{< command-line "stroomuser" "localhost" >}}
docker exec \
-i \
stroom-all-dbs \
mysql --force -u"root" -p"my-secret-pw" \
< v7_drop_unused_databases.sql
{{</ command-line >}}

Verify it worked with:

{{< command-line "stroomuser" "localhost" >}}
echo 'show databases;' | docker exec -i stroom-all-dbs mysql -u"root" -p"my-secret-pw"
{{</ command-line >}}


## Performing the upgrade

To perform the stroom schema upgrade to v7 run the migrate command which will migrate the database then exit.
For a large upgrade like this is it is preferable to run the migrate command rather than just starting stroom as stroom will only migrate the parts of the schema as it needs to use them.
Running migrate ensures all parts of the migration are completed when the command is run and no other parts of stroom will be started.

{{< command-line "stroomuser" "localhost" >}}
./migrate.sh
{{</ command-line >}}


## Post-Upgrade tasks

*TODO* remove auth* containers,images,volumes
