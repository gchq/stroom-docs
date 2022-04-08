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
This page is currently work in progress and will evolve with further testing of v5 => v7 migrations.
{{% /note %}}

{{% page-warning %}}
Before commencing an upgrade to v7 you must upgrade Stroom to the latest minor and patch version of v5.  
At the time of writing the latest version of v5 is `v5.5.16`.
{{% /page-warning %}}

## Differences between v5 and v7

Stroom v7 has significant differences to v6 which make the upgrade process a little more complicated.

* v5 handled authentication within the application.
  In v7 authentication is handled either internally in stroom (the default) or by an external identity provider such as google or AWS Cognito.
* v5 used the `~setup.xml`, `~env.sh` and `stroom.properties` files for configuration.
  In v7 stroom uses a config.yml file for its configuration (see [Properties]({{< relref "../../user-guide/properties.md" >}}))
* v5 used upper case and heavily abbreviated names for its tables.
  In v7 clearer and lower case table names are used.
  As a result ALL v5 tables get renamed with the prefix `OLD_`, the new tables created and any content copied over.
  As the database will be holding two copies of most data you need to ensure you have space to accommodate it.


## Pre-Upgrade tasks

Stroom can be upgraded straight from v5 to v7 without going via v6.
There are however a few pre-migration steps that need to be followed.


### Upgrade Stroom to the latest v5 version

Follow your standard process for performing a minor upgrade to bring your v5 Stroom instance up to the latest v5 version.
This ensures all v5 migrations are applying all the v6 and v7 migrations.


### Download migration scripts

Download the migration SQL scripts from https://github.com/gchq/stroom/blob/STROOM_VERSION/scripts 
e.g. https://github.com/gchq/stroom/blob/v7.0-beta.198/scripts 

Some of these scripts will be used in the steps below.
The unused scripts are not applicable to a v5=>v7 upgrade.


### Pre-migration database checks

Run the pre-migration checks script on the running database.

{{< command-line "stroomuser" "localhost" >}}
mysql --force --table -u"stroomuser" -p"stroompassword1" stroom \
< v7_db_pre_migration_checks.sql \
> v7_db_pre_migration_checks.out \
2>&1
{{</ command-line >}}

This will produce a report of items that will not be migrated or need attention before migration.


### Capture non-default Stroom properties

Run the following script to capture the non-default system properties that are held in the database.
This is a precaution in case they are needed following migration.

{{< command-line "stroomuser" "localhost" >}}
mysql --force --table -u"stroomuser" -p"stroompassword1" stroom \
< v5_list_properties.sql \
> v5_list_properties.out \
2>&1
{{</ command-line >}}


### Stop processing

Before shutting stroom down it is wise to turn off stream processing and let all outstanding server tasks complete.

*TODO* clarify steps for this.


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


### Deploy v7

Deploy the latest version of Stroom but don't start it.

*TODO* - more detail


### Migrate the v5 configuration into v7

The configuration properties held in the database and accessed for the _Properties_ UI screen will be migrated automatically by Stroom where possible.

Stroom v5 and v7 however are configured differently when it comes to the configuration files used to bootstrap the application, such as the database connection details.
These properties will need to be manually migrated from the v5 instance to the v7 instance.
The configuration to bootstrap Stroom v5 can be found in `instance/lib/stroom.properties`.
The configuration for v7 can be found in the following places:

* Zip distribution - `config/config.yml`.
* Docker stack - `volumes/stroom/config/config.yml`.
  Note that this file uses variable substitution so values can be set in `config/<stack_name>.env` if suitably substituted.

The following table shows the key configuration properties that need to be set to start the application and how they map between v5 and v7.

| V5 property                                 | V7 property                                                 | Notes                                                                                                                                                                                                          |
| ------------------                          | ------------------                                          | ------                                                                                                                                                                                                         |
| _stroom.temp_                               | _appConfig.path.temp_                                       | Set this if different from `$TEMP` env var.                                                                                                                                                                    |
| -                                           | _appConfig.path.home_                                       | By default all local state (e.g. reference data stores, search results) will live under this directory. Typically it should be in a different location to the stroom instance as it has a different lifecycle. |
| _stroom.node_                               | _appConfig.node.name_                                       |                                                                                                                                                                                                                |
| -                                           | _appConfig.nodeUrl.hostname_                                | Set this to the FQDN of the node so other nodes can communicate with it.                                                                                                                                       |
| -                                           | _appConfig.publicUrl.hostname_                              | Set this to the public FQDN of Stroom, typically a load balancer or Nginx instance.                                                                                                                            |
| _stroom.jdbcDriverClassName_                | _appConfig.commonDbDetails.connection.jdbcDriverClassName_  | Do not set this. Will get defaulted to `com.mysql.cj.jdbc.Driver`                                                                                                                                              |
| _stroom.jdbcDriverUrl_                      | _appConfig.commonDbDetails.connection.jdbcDriverUrl_        |                                                                                                                                                                                                                |
| _stroom.jdbcDriverUsername_                 | _appConfig.commonDbDetails.connection.jdbcDriverUsername_   |                                                                                                                                                                                                                |
| _stroom.jdbcDriverPassword_                 | _appConfig.commonDbDetails.connection.jdbcDriverPassword_   |                                                                                                                                                                                                                |
| _stroom.jpaDialect_                         | -                                                           |                                                                                                                                                                                                                |
| _stroom.statistics.sql.jdbcDriverClassName_ | _appConfig.commonDbDetails.connection.jdbcDriverClassName_  | Do not set this. Will get defaulted to `com.mysql.cj.jdbc.Driver`                                                                                                                                              |
| _stroom.statistics.sql.jdbcDriverUrl_       | _appConfig.statistics.sql.db.connection.jdbcDriverUrl_      |                                                                                                                                                                                                                |
| _stroom.statistics.sql.jdbcDriverUsername_  | _appConfig.statistics.sql.db.connection.jdbcDriverUsername_ |                                                                                                                                                                                                                |
| _stroom.statistics.sql.jdbcDriverPassword_  | _appConfig.statistics.sql.db.connection.jdbcDriverPassword_ |                                                                                                                                                                                                                |
| _stroom.statistics.common.statisticEngines_ | _appConfig.statistics.internal.enabledStoreTypes_           | Do not set this. Will get defaulted to `StatisticStore`                                                                                                                                                        |
| -                                           | _appConfig.ui.helpUrl_                                      | Set this to the URL of your locally published stroom-docs site.                                                                                                                                                |
| _stroom.contentPackImportEnabled_           | _appConfig.contentPackImport.enabled_                       |

{{% note %}}
In the `config.yml` file, properties have a root of `appConfig.` which corresponds to a root of `stroom.` in the UI Properties screen.
{{% /note %}}

Some v5 properties, such as connection pool settings cannot be migrated to v7 equivalents.
It is recommended to review the default values for v7 `appConfig.commonDbDetails.connectionPool.*` and `appConfig.statistics.sql.db.connectionPool.*` properties to ensure they are suitable for your environment.
If they are not then set them in the `config.yml` file.
The defaults can be found in `config-defaults.yml`.


### Upgrading the MySQL instance and database

Stroom v5 ran on MySQL v5.6.
Stroom v7 runs on MySQL v8.
The upgrade path for MySQL is 5.6 => 5.7.33 => 8.x (see {{< external-link "Upgrade Paths" "https://dev.mysql.com/doc/refman/8.0/en/upgrade-paths.html" >}}).

To ensure the database is up to date `mysql_upgrade` needs to be run using the 5.7.33 binaries, see the {{< external-link "MySQL documentation" "https://dev.mysql.com/doc/refman/8.0/en/mysql-upgrade.html" >}}.

This is the process for upgrading the database.
The exact steps will depend on how you have installed MySQL.

1. Shutdown the database instance.
1. Remove the MySQL 5.6 binaries, e.g. using your package manager.
1. Install the MySQL 5.7.33 binaries.
1. Start the database instance using the 5.7.33 binaries.
1. Run `mysql_upgrade` to upgrade the database to 5.7 specification.
1. Shutdown the database instance.
1. Remove the MySQL 5.7.33 binaries.
1. Install the latest MySQL 8.0 binaries.
1. Start the database instance.
   On start up MySQL 8 will detect a v5.7 instance and upgrade it to 8.0 spec automatically without the need to run `mysql_upgrade`.


## Performing the Stroom upgrade

To perform the stroom schema upgrade to v7 run the _migrate_ command (on a single node) which will migrate the database then exit.
For a large upgrade like this is it is preferable to run the _migrate_ command rather than just starting Stroom as Stroom will only migrate the parts of the schema as it needs to use them so some parts of the database may not be migrated initially.
Running the migrate command ensures all parts of the migration are completed when the command is run and no other parts of stroom will be started.

{{< command-line "stroomuser" "localhost" >}}
./migrate.sh
{{</ command-line >}}


## Post-Upgrade tasks

*TODO*
