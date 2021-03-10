> * Last Updated: 10 Mar 2021  

# Upgrading From v6 to v7

This document describes the process for upgrading a Stroom instance/cluster from v6.x to v7.x

*IMPORTANT* - Before comencing an upgrade to v7 you should upgrade Stroom to the latest minor and patch version of v6.

## Differences between v6 and v7

Stroom v7 has significant differences to v6 which make the upgrade process a little more complicated.

* v6 handled authentication using a separate application, _stroom-auth-service_, with its own database.
  In v7 authentication is handled either internally in stroom (the default) or by an external identity provider such as google or AWS Cognito.
* v6 used a stroom.conf file or environment variables for configuration.
  In v7 stroom uses a config.yml file for its configuration (see [Properties](../../user-guide/properties.md))
* v6 used upper case and heavily abbreviated names for its tables.
  In v7 clearer and lower case table names are used.
  As a result ALL v6 tables get renamed with the prefix `OLD_`, the new tables created and any content copied over.
  As the database will be holding two copies of most data you need to ensure you have space to accomodate it.

## Pre-Upgrade tasks

The following steps are required to be performed before migrating from v6 to v7.

### Backup the databases

Backup all the databases for the different components.
Typically these will be `stroom`, `stats` and `auth`.

If you are running in a docker stack then you can run the `./backup_databases.sh` script.


### Export database property values

Stroom stores global property values in the database.




## Performing the upgrade




## Post-Upgrade tasks
