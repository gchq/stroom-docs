---
title: "Upgrade from v5 to v7"
linkTitle: "Upgrade from v5 to v7"
#weight:
date: 2022-04-01
tags: 
description: >
  This document describes the process for upgrading Stroom from v5.x to v7.x.

---

{{% note %}}
This page is currently work in progress.
{{% /note %}}

{{% page-warning %}}
Before comencing an upgrade to v7 you must upgrade Stroom to the latest minor and patch version of v5.  
At the time of writing the latest version of v5 is `v5.5.16`.
{{% /page-warning %}}

## Differences between v5 and v7

Stroom v7 has significant differences to v6 which make the upgrade process a little more complicated.

* v5 handled authentication within the application.
  In v7 authentication is handled either internally in stroom (the default) or by an external identity provider such as google or AWS Cognito.
* v5 used `~setup.xml` and `~env.sh` files for configuration.
  In v7 stroom uses a config.yml file for its configuration (see [Properties]({{< relref "../../user-guide/properties.md" >}}))
* v5 used upper case and heavily abbreviated names for its tables.
  In v7 clearer and lower case table names are used.
  As a result ALL v5 tables get renamed with the prefix `OLD_`, the new tables created and any content copied over.
  As the database will be holding two copies of most data you need to ensure you have space to accomodate it.


## Pre-Upgrade tasks

Stroom can be upgraded straight from v5 to v7 without going via v6.
There are however a few pre-migration steps that need to be followed.


### Upgrade Stroom to the latest v5 version

Follow your standard process for performing a minor upgrade to bring your v5 Stroom instance up to the latest v5 version.
This ensures all v5 migratations are applying all the v6 and v7 migrations.


### Download migration scripts

Download the migration SQL scripts from https://github.com/gchq/stroom/blob/STROOM_VERSION/scripts 
e.g. https://github.com/gchq/stroom/blob/v7.0-beta.198/scripts 

Some of these scripts will be used in the steps below.
The unused scripts are not applicable to a v5=>v7 upgrade.


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


### Stop Stroom

Stop the stack (stroom and the database) then start up the database.
Do this using the v6 stack.
This ensures that stroom is not trying to access the database.

{{< command-line "stroomuser" "localhost" >}}
./stop.sh
{{</ command-line >}}


### Backup the databases

Backup all the databases for the different components.
Typically these will be `stroom` and `stats` (or `statistics`).


### Stop the database

Stop the database using the v6 stack.

{{< command-line "stroomuser" "localhost" >}}
./stop.sh
{{</ command-line >}}


### Deploy and configure v7

Deploy the latest version of Stroom but don't start it.

*TODO* - more detail

Verify the database connection configuration for the stroom and stats databases.


### Migrate the v5 configuration into v7

{{% todo %}}
Complete this section.
{{% /todo %}}


### Running `mysql_upgrade`

Stroom v5 ran on mysql v5.6.
Stroom v7 runs on mysql v8.
The upgrade path for MySQL is 5.6 => 5.7.33 => 8.x (see {{< external-link "Upgrade Paths" "https://dev.mysql.com/doc/refman/8.0/en/upgrade-paths.html" >}}

To ensure the database is up to date `mysql_upgrade` neeeds to be run using the 5.7.33 binaries, see the {{< external-link "MySQL documentation" "https://dev.mysql.com/doc/refman/8.0/en/mysql-upgrade.html" >}}.

This is the process for upgrading the database.
The exact steps will depend on how you have installed MySQL.

1. Shutdown the database instance.
1. Remove the MySQL 5.6 binaries.
1. Install the MySQl 5.7.33 binaries.
1. Start the database instance.
1. Run `mysql_upgrade` to upgrade the database to 5.7 spec.
1. Shutdown the database instance.
1. Install the MySQl 8.0 binaries.
1. Start the database instance.
   On start up MySQL 8 will detect a v5.7 instance and upgrade it to 8.0 spec automatically.


## Performing the upgrade

To perform the stroom schema upgrade to v7 run the migrate command (on a single node) which will migrate the database then exit.
For a large upgrade like this is it is preferable to run the migrate command rather than just starting Stroom as Stroom will only migrate the parts of the schema as it needs to use them.
Running the migrate command ensures all parts of the migration are completed when the command is run and no other parts of stroom will be started.

{{< command-line "stroomuser" "localhost" >}}
./migrate.sh
{{</ command-line >}}


## Post-Upgrade tasks

*TODO*
