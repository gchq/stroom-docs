---
title: "Upgrade Notes"
linkTitle: "Upgrade Notes"
weight: 40
date: 2023-10-20
tags: 
description: >
  Required actions and information relating to upgrading to Stroom version 7.2.
---

{{% warning %}}
Please read this section carefully in case any of it is relevant to your Stroom instance.
{{% /warning %}}


## Regex Performance Issue in XSLTs

v7.2 of Stroom uses a newer version of the Saxon XML processing library.
There is a bug in this and all newer Saxon versions that means that case insensitive regular expression matching performs very badly (can be orders of magnitude slower than a case sensitive regex).
The performance issue will show itself when multiple pipelines with effected XSLTs are being processed concurrently.
This impacts XSLT/Xpath functions like `matches()` that use the `i` flag for case insensitive matching.

Until this bug is fixed in Saxon you will have to change the XSLTs that use the `i` in one of the following ways:

* Re-write the regular expression to use case sensitive matching
  E.g. `matches('CATHODE', 'cat', 'i')` => `matches('CATHODE', '[cC][aA][tT])`.
* Add the flag `;j` to force Saxon to use the Java regular expression engine instead of the Saxon one.
  E.g. `matches('CATHODE', 'cat', 'i')` => `matches('CATHODE', 'cat', 'i;j')`.


## Tagging Entities

As described in [Document Tagging]({{< relref "new-features#document-tagging" >}}) Stroom now pre-populates the filter of some of the tree pickers with pre-configured tags to limit the entities returned.
If you do nothing then after upgrade these tree pickers will show no matching entities to the user.

You have two options:

1. Tag entities with the pre-configured tags so they are visible in the tree pickers.

   To do this you need to find and tag the following entities:

   * Tag all reference loader pipelines (those using the {{< pipe-elm "ReferenceDataFilter" >}} pipeline element) with `reference-loader` (or whatever value(s) is/are set in `stroom.ui.referencePipelineSelectorIncludedTags`).
   * Tag all extraction pipelines (those using the {{< pipe-elm "SearchResultOutputFilter" >}} pipeline element) with `extraction` (or whatever value(s) is/are set in `stroom.ui.query.dashboardPipelineSelectorIncludedTags`).

   Any new entities matching the above criteria also need to be tagged in this way to ensure users see the correct entities.
   The new [Find Content]({{< relref "new-features#find-content" >}}) is useful for tracking down _Pipelines_ that contain a certain element.

   The property `stroom.ui.query.viewPipelineSelectorIncludedTags` is not an issue for an upgrade to v7.2 as _Views_ did not exist prior to this version.
   All new dynamic extraction pipeline entities (those using the {{< pipe-elm "DynamicSearchResultOutputFilter" >}} pipeline element) need to be tagged with `dynamic` and `extraction` (or whatever value(s) is/are set in `stroom.ui.query.viewPipelineSelectorIncludedTags`)

1. Change the system properties to not pre-populate the filters.
   If you do not want to use this feature then you can just clear the values of the following properties:

   * `stroom.ui.query.dashboardPipelineSelectorIncludedTags`
   * `stroom.ui.query.viewPipelineSelectorIncludedTags`
   * `stroom.ui.referencePipelineSelectorIncludedTags`


## Reference Data Store

See [Partitioned Reference Data Stores]({{< relref "other-changes#partitioned-reference-data-stores" >}}) for details of the changes to reference data stores.

No intervention is required on upgrade for this change, this section is for information purposes only, however it is recommended that you take a backup copy of the existing reference data store files before booting the new version of Stroom.
To do this, make a copy of the files in the directory specified by `stroom.pipeline.referenceData.lmdb.localDir`.
If there is a problem then you can replace the store with the copy and try again.

Stroom will automatically migrate reference data from the legacy single data store into multiple _Feed_ specific stores.
The legacy store exists in the directory configured by `stroom.pipeline.referenceData.lmdb.localDir`.
Each feed specific store will be in a sub-directory with a name like `USER-DETAILS-REFERENCE___309e1ca0-7a5f-4f05-847b-b706805d758c` (i.e. a file system safe version of the _Feed_ name and the _Feed's_ {{< glossary "UUID" >}}.

The migration happens on an as-needed basis.
When a [lookup]({{< relref "/docs/user-guide/pipelines/xslt/xslt-functions#lookup" >}}) is called from an XSLT, if the required reference stream is found to exist in the legacy store then it will be copied into the appropriate _Feed_ specific store (creating the store if required).
After being copied, the stream in the legacy store will be marked as available for purge so will get purged on the next run of the job _Ref Data Off-heap Store Purge_.

When Stroom boots it will delete a legacy store if it is found to be empty, so eventually the legacy store will cease to exist.

Depending on the speed of the local storage used for the reference data stores, the migration of streams and the subsequent purge from the legacy store may slow down processing until all the required migrations have happened.
The migration is a trade-off between the additional time it would take to re-load all the reference streams (rather than just copying them from the legacy store) and the dedicated lock on the legacy store that all migrations need to acquire.

If you experience performance problems with reference data migrations or would prefer not to migrate the date then you can simply delete the legacy stores prior to running Stroom v7.2 for the first time.
The legacy store can be found in the directory configured by `stroom.pipeline.referenceData.lmdb.localDir`.
Simply delete the files `data.mdb` and `lock.mdb` (if present).
With the store deleted, stroom will simply load all reference streams as required with no migration.


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


### Migration Scripts

For information purposes only, the following is a list of all the database migrations that will be run when upgrading from v7.0 to v7.2.0.
The migration script files can be viewed at {{< external-link "github.com/gchq/stroom" "https://github.com/gchq/stroom" >}}.

<!-- This list was produced by stroom.db.migration.TestListDbMigrations#listDbMigrationsByVersion -->
```text
7.1.0
  stroom-config
    V07_01_00_001__preferences.sql                                 - stroom-config/stroom-config-global-impl-db/src/main/resources/stroom/config/global/impl/db/migration/V07_01_00_001__preferences.sql
  stroom-explorer
    V07_01_00_005__explorer_favourite.sql                          - stroom-explorer/stroom-explorer-impl-db/src/main/resources/stroom/explorer/impl/db/migration/V07_01_00_005__explorer_favourite.sql
  stroom-security
    V07_01_00_001__add_stroom_user_cols.sql                        - stroom-security/stroom-security-impl-db/src/main/resources/stroom/security/impl/db/migration/V07_01_00_001__add_stroom_user_cols.sql
    V07_01_00_002__rename_preferred_username_col.sql               - stroom-security/stroom-security-impl-db/src/main/resources/stroom/security/impl/db/migration/V07_01_00_002__rename_preferred_username_col.sql
7.2.0
  stroom-analytics
    V07_02_00_001__analytics.sql                                   - stroom-analytics/stroom-analytics-impl-db/src/main/resources/stroom/analytics/impl/db/migration/V07_02_00_001__analytics.sql
  stroom-annotation
    V07_02_00_005__annotation_assigned_migration_to_uuid.sql       - stroom-annotation/stroom-annotation-impl-db/src/main/resources/stroom/annotation/impl/db/migration/V07_02_00_005__annotation_assigned_migration_to_uuid.sql
    V07_02_00_010__annotation_entry_assigned_migration_to_uuid.sql - stroom-annotation/stroom-annotation-impl-db/src/main/resources/stroom/annotation/impl/db/migration/V07_02_00_010__annotation_entry_assigned_migration_to_uuid.sql
  stroom-config
    V07_02_00_005__preferences_column_rename.sql                   - stroom-config/stroom-config-global-impl-db/src/main/resources/stroom/config/global/impl/db/migration/V07_02_00_005__preferences_column_rename.sql
  stroom-dashboard
    V07_02_00_005__query_add_owner_uuid.sql                        - stroom-dashboard/stroom-storedquery-impl-db/src/main/resources/stroom/storedquery/impl/db/migration/V07_02_00_005__query_add_owner_uuid.sql
    V07_02_00_006__query_add_uuid.sql                              - stroom-dashboard/stroom-storedquery-impl-db/src/main/resources/stroom/storedquery/impl/db/migration/V07_02_00_006__query_add_uuid.sql
  stroom-explorer
    V07_02_00_005__remove_datasource_tag.sql                       - stroom-explorer/stroom-explorer-impl-db/src/main/resources/stroom/explorer/impl/db/migration/V07_02_00_005__remove_datasource_tag.sql
  stroom-security
    V07_02_00_100__query_add_owners.sql                            - stroom-security/stroom-security-impl-db/src/main/resources/stroom/security/impl/db/migration/V07_02_00_100__query_add_owners.sql
    V07_02_00_101__processor_filter_add_owners.sql                 - stroom-security/stroom-security-impl-db/src/main/resources/stroom/security/impl/db/migration/V07_02_00_101__processor_filter_add_owners.sql
```


