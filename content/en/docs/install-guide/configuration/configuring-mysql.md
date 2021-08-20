---
title: "MySQL Configuration"
linkTitle: "MySQL Configuration"
#weight:
date: 2021-06-07
tags:
  - mysql
description: >
  
---

> **Version Information:** Created with Stroom v7.0  
> **Last Updated:** 2021-06-07  
> **See Also:** [MySQL Server Setup](../setup/mysql-server-setup.md)  
> **See Also:** [MySQL Server Administration (external link)](https://dev.mysql.com/doc/refman/8.0/en/server-administration.html)

## General configuration

MySQL is configured via the `.cnf` file which is typically located in one of these locations:

* `/etc/my.cnf`
* `/etc/mysql/my.cnf`
* `$MYSQL_HOME/my.cnf`
* `<data dir>/my.cnf`
* `~/.my.cnf`

### Key configuration properties

* `lower_case_table_names` - This proerty controls how the tables are stored on the filesystem and the case-sensitivity of table names in SQL.
  A value of `0` means tables are stored on the filesystem in the case used in CREATE TABLE and sql is case sensitive.
  This is the default in linux and is the preferred value for deployments of stroom of v7+.
  A value of `1` means tables are stored on the filesystem in lowercase but sql is case insensitive.
  [See also (external link)](https://dev.mysql.com/doc/refman/8.0/en/identifier-case-sensitivity.html)

* `max_connections` - The maximum permitted number of simultaneous client connections.
  For a clustered deployment of stroom, the default value of 151 will typically be too low.
  Each stroom node will hold a pool of open database connections for its use, therefore with a large number of stroom nodes and a big connection pool the total number of connections can be very large.
  This property should be set taking into account the values of the stroom properties of the form `*.db.connectionPool.maxPoolSize`.
  [See also (external link)](https://dev.mysql.com/doc/refman/8.0/en/connection-interfaces.html)

* `innodb_buffer_pool_size`/`innodb_buffer_pool_instances` - Controls the amount of memory availble to MySQL for caching table/index data.
  Typically this will be set to 80% of available RAM, assuming MySQL is running on a dedicated host and the total amount of table/index data is greater than 80% of avaialable RAM.
  _Note_: `innodb_buffer_pool_size` must be set to a value that is equal to or a multiple of `innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances`.
  [See also (external link)](https://dev.mysql.com/doc/refman/8.0/en/innodb-buffer-pool-resize.html)

> **TODO** - Add additional key configuration items


## Deploying without Docker

When MySQL is deployed without a docker stack then MySQL should be installed and configured according to the MySQL documentation.
How MySQL is deployed and configured will depend on the requirements of the environment, e.g. clustered, primary/standby, etc.


## As part of a docker stack

Where a stroom docker stack includes stroom-all-dbs (MySQL) the MySQL instance is configured via the `.cnf` file.
The `.cnf` file is located in `volumes/stroom-all-dbs/conf/stroom-all-dbs.cnf`.
This file is read-only to the container and will be read on container start.

### Database initialisation

When the container is started for the first time the database be initialised with the root user account.
It will also then run any scripts found in `volumes/stroom-all-dbs/init/stroom`.
The scripts in here will be run in alpabetical order.
Scripts of the form `.sh`, `.sql`, `.sql.gz` and `.sql.template` are supported.

`.sql.template` files are proprietry to stroom stacks and are just templated `.sql` files.
They can contain tags of the form `<<<ENV_VAR_NAME>>>` which will be replaced with the value of the named environment variable that has been set in the container.

If you need to add additional database users then either add them to `volumes/stroom-all-dbs/init/stroom/001_create_databases.sql.template` or create additional scripts/templates in that directory.

The script that controls this templating is `volumes/stroom-all-dbs/init/000_stroom_init.sh`.
This script MUST not have its executable bit set else it will be executed rather than being sourced by the MySQL entry point scripts and will then not work.


