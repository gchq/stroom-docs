---
title: "Upgrade Notes"
linkTitle: "Upgrade Notes"
weight: 40
date: 2026-03-18
tags: 
description: >
  Required actions and information relating to upgrading to Stroom version 7.12.
---

{{% warning %}}
Please read this section carefully in case any of it is relevant to your Stroom/Stroom-Proxy instance.
{{% /warning %}}


## Upgrade Path

You can upgrade to v7.12.x from any v7.x release that is older than the version being upgraded to.

If you want to upgrade to v7.12.x from v5.x or v6.x we recommend you do the following:

1. Upgrade v5.x to the latest patch release of v6.0.
1. Upgrade v6.x to the latest patch release of v7.0.
1. Upgrade v7.x to the latest patch release of v7.12.

{{% warning %}}
v7.12 **cannot** migrate content in legacy formats, i.e. content created in v5/v6.
You must therefore upgrade to v7.0.x first to migrate this content, before upgrading to v7.12.x.
{{% /warning %}}


## Java Version

Stroom v7.12 requires Java 25.

{{% warning %}}
This is different to the java version required for Stroom v7.9 (Java 21).
{{% /warning %}}

Ensure the Stroom and Stroom-Proxy hosts are running the latest patch release of Java v25.


## Configuration File Changes

<!--
Check changes using something like this (run from an up-to-date stroom repo):
old_ver=7.11
new_ver=7.12
git diff origin/${old_ver}..origin/${new_ver} stroom-config/stroom-config-app/src/test/resources/stroom/config/app/expected.yaml
git diff origin/${old_ver}..origin/${new_ver} stroom-proxy/stroom-proxy-app/src/test/resources/stroom/dist/proxy-expected.yaml
-->


### Common Configuration Changes

These changes are common to both Stroom and Stroom Proxy.

#### Changes to `receive` Branch

```yaml
    dataFeedIdentitiesDir: "data_feed_identities" # Default value changed from "data_feed_keys"
```


### Stroom's `config.yml`

#### Changes to `autoContentCreation` Branch

```yaml
  autoContentCreation:

    # An optional group to add the group defined by groupTemplate to.
    # The value of this property is the name of a group. It can be the same 
    # as groupParentGroupName if required. 
    # It allows all the templated groups to belong to a common group for easier 
    # permission management.
    additionalGroupParentGroupName: "Data Feed Developer"  # New property

    # If set, when Stroom auto-creates a feed, it will create an additional user group with a 
    # name derived from this template. This is in addition to the user group defined by 'groupTemplate'.
    # If not set, only the latter user group will be created. Default value is 'grp-${accountid}-dev'. 
    # If this property is set in the YAML file, use single quotes to prevent the 
    # variables being expanded when the config file is loaded.
    additionalGroupTemplate: "grp-${accountid}-dev"        # Default value changed from "grp-${accountid}-sandbox"

    # An optional templated sub-path of 'destinationExplorerPathTemplate'. If set, copied dependencies (e.g.
    # XSLT filters, Test Converters, etc.) will be created in the sub-directory defined by this template. 
    # If not set, that content will be created in the directory 
    destinationExplorerSubPathTemplate: "dev"              # New property

    # An optional group to add the group defined by groupTemplate to.
    # The value of this property is the name of a group. 
    # It allows all the templated groups to belong to a common group for easier 
    # permission management.
    groupParentGroupName: "Data Feed Reader"               # New property
```


#### `stroom.data.meta.dataFormats`

An additional default value of `JSON_LINES` has been added for handling data in JSON Lines format, i.e. one complete JSON object per line.
This is a useful format for JSON log events.


### Stroom-Proxy's `config.yml`

No Stroom-Proxy specific configuration changes have been made.


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
 
There are no database migrations in v7.12.
