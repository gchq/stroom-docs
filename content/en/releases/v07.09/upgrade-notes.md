---
title: "Upgrade Notes"
linkTitle: "Upgrade Notes"
weight: 40
date: 2025-04-01
tags: 
description: >
  Required actions and information relating to upgrading to Stroom version 7.9.
---

{{% warning %}}
Please read this section carefully in case any of it is relevant to your Stroom instance.
{{% /warning %}}

## Java Version

Stroom v7.9 requires Java 21.
This is the same java version as Stroom v7.8.
Ensure the Stroom and Stroom-Proxy hosts are running the latest patch release of Java v21.


## Configuration File Changes

<!--
Check changes using something like this:
old_ver=7.6
new_ver=7.7
git diff origin/${old_ver}..origin/${new_ver} stroom-config/stroom-config-app/src/test/resources/stroom/config/app/expected.yaml
git diff origin/${old_ver}..origin/${new_ver} stroom-proxy/stroom-proxy-app/src/test/resources/stroom/dist/proxy-expected.yaml
-->

### Stroom's `config.yml`


### Stroom-Proxy's `config.yml`


## Database Migrations

When Stroom boots for the first time with a new version it will run any required database migrations to bring the database schema up to the correct version.

{{% warning %}}
It is highly recommended to ensure you have a database backup in place before booting stroom with a new version.
This is to mitigate against any problems with the migration.
It is also recommended to test the migration against a copy of your database to ensure that there are no problems when you do it for real.
{{% /warning %}}

On boot, Stroom will ensure that the migrations are only run by a single node in the cluster.
This will be the node that reaches that point in the boot process first.
All other nodes will wait until that is complete before proceeding with the boot process.

It is recommended however to use a single node to execute the migration.
To avoid Stroom starting up and beginning processing you can use the `migrage` command to just migrate the database and not fully boot Stroom.
See [`migrage` command]({{< relref "/docs/user-guide/tools/command-line#migrate" >}}) for more details.


<!-- 
Run stroom.db.migration.TestListDbMigrations.listDbMigrationsForLatestVersion() to generate the content for
this section
-->

### Migration Scripts

{{% todo %}}
TODO
{{% /todo %}}

