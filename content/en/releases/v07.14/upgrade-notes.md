---
title: "Upgrade Notes"
linkTitle: "Upgrade Notes"
weight: 40
date: 2026-10-19
tags: 
description: >
  Required actions and information relating to upgrading to Stroom version 7.14.
---

{{< warning >}}
Please read this section carefully in case any of it is relevant to your Stroom/Stroom-Proxy instance.
{{< /warning >}}


## Upgrade Path

You can upgrade to v7.14.x from any v7.x release that is older than the version being upgraded to.

If you want to upgrade to v7.14.x from v5.x or v6.x we recommend you do the following:

1. Upgrade v5.x to the latest patch release of v6.0.
1. Upgrade v6.x to the latest patch release of v7.0.
1. Upgrade v7.x to the latest patch release of v7.14.

{{< warning >}}
v7.14 **cannot** migrate content in legacy formats, i.e. content created in v5/v6.
You must therefore upgrade to v7.0.x first to migrate this content, before upgrading to v7.14.x.
{{< /warning >}}


## Java Version

Stroom v7.14 requires Java 25.

{{< warning >}}
This is different to the java version required for Stroom v7.9 (Java 21).
{{< /warning >}}

Ensure the Stroom and Stroom-Proxy hosts are running the latest patch release of Java v25.


## Configuration File Changes

<!--
Check changes using something like this (run from an up-to-date stroom repo):
old_ver=7.13
new_ver=7.14
git diff origin/${old_ver}..origin/${new_ver} stroom-config/stroom-config-app/src/test/resources/stroom/config/app/expected.yaml | cat
echo
echo
git diff origin/${old_ver}..origin/${new_ver} stroom-proxy/stroom-proxy-app/src/test/resources/stroom/dist/proxy-expected.yaml | cat
-->


### Stroom's `config.yml`

<!-- Comparison of the latest v7.12 release => v7.13 -->

The following changes have been made to Stroom's configuration.
Most of the new properties have suitable defaults and do not need to be set unless you need to change the default behaviour.


#### New `ai.chatResponseCache` Property

The `ai()` XSLT and StroomQL functions now cache answers for identical combinations of model, system prompt and message.
This avoids repeated calls to the model for the same question.
Set `maximumSize` to `0` to disable the cache.

```yaml
appConfig:
  ai:
    chatResponseCache:
      expireAfterAccess: null
      expireAfterWrite: "PT10M"
      maximumSize: 1000
      refreshAfterWrite: null
      statisticsMode: "INTERNAL"
```


#### New `data.s3VolumeCache` Property

The data store now caches S3 volume details.
Cache entries expire 10 minutes after they are written and the cache holds up to 1,000 entries.

```yaml
appConfig:
  data:
    s3VolumeCache:
      expireAfterAccess: null
      expireAfterWrite: "PT10M"
      maximumSize: 1000
      refreshAfterWrite: null
      statisticsMode: "INTERNAL"
```


#### `visualisationAsset` Renamed to `documentAsset`

The `visualisationAsset` branch has been replaced by `documentAsset`, which provides asset management for documents as well as visualisations.
Rename existing `visualisationAsset` configuration to `documentAsset`, and `visualisationAssetDb` to `documentAssetDb`.

The new configuration supports AVIF and ICO MIME types, corrects the default MIME type for GIF files, and adds `maxUploadSize`.
This limits the size of an asset upload before it is streamed into the database; it is separate from the 512 KiB limit for editing asset content in the UI.

```yaml
appConfig:
  documentAsset:
    aceEditorModes:
      css: "CSS"
      htm: "HTML"
      html: "HTML"
      js: "JAVASCRIPT"
      svg: "XML"
      txt: "TEXT"
      xml: "XML"
    assetCacheDir: "asset_cache"
    clearAssetCacheOnStartup: false
    default: "application/octet-stream"
    defaultAceEditorMode: "TEXT"
    maxUploadSize: "50M"
    mimetypes:
      apng: "image/apng"
      avif: "image/avif"
      bmp: "image/bmp"
      css: "text/css"
      gif: "image/gif"
      ico: "image/vnd.microsoft.icon"
      jpeg: "image/jpeg"
      jpg: "image/jpeg"
      js: "text/javascript"
      png: "image/png"
      svg: "image/svg+xml"
      tif: "image/tiff"
      tiff: "image/tiff"
      txt: "text/plain"
      webp: "image/webp"
      xml: "application/xml"
  documentAssetDb:
    connection:
      jdbcDriverClassName: null
      jdbcDriverPassword: null
      jdbcDriverUrl: null
      jdbcDriverUsername: null
    connectionPool:
      cachePrepStmts: false
      connectionTimeout: "PT30S"
      idleTimeout: "PT10M"
      leakDetectionThreshold: "PT0S"
      maxLifetime: "PT30M"
      maxPoolSize: 30
      minimumIdle: 10
      prepStmtCacheSize: 25
      prepStmtCacheSqlLimit: 256
```


#### New `data.stepping` Properties

The `data.stepping` branch controls the persisted I/O used when stepping through streams.
The default `skeletonSweep` setting performs a cheaper initial capture and materialises data below the record boundary as it is visited.
The limits prevent a stepping session from consuming excessive disk space or processing too many records.

```yaml
appConfig:
  data:
    stepping:
      eagerMaterialisationRecords: 5000
      filteredScanWindow: 50
      maxBytesPerStream: 2147483648
      maxRecordSizeBytes: 104857600
      maxRecordsPerStream: 1000000
      maxRetainedFingerprintsPerElement: 3
      maxSessionIdleTime: "PT10M"
      maxSweptStreamsPerSession: 10
      orphanMaxAge: "PT1H"
      prefetchWindow: 10
      skeletonSweep: true
      storeSubDir: "stepping"
```

`maxBytesPerStream` and `maxRecordsPerStream` stop stepping with an error when the persisted I/O or captured records for a stream exceed the configured limit.
`maxSessionIdleTime` controls when an idle session and its persisted I/O are removed, while `orphanMaxAge` controls cleanup of abandoned session directories.


#### Changes to the `planb` Branch

The following properties have been added to control Plan B shard allocation, caching and merging.
`defaultShardCounts` defines the default number of shards for each state type.

```yaml
appConfig:
  planb:
    defaultShardCounts:
      STATE: 16
      TEMPORAL_STATE: 32
      RANGED_STATE: 16
      TEMPORAL_RANGED_STATE: 32
      SESSION: 32
      HISTOGRAM: 16
      METRIC: 16
      TRACE: 64
    mergedCheckpointCacheTtl: "PT10M"
    minTimeToKeepStoreShardEnv: "PT1H"
    shardMergeThreadCount: 4
```

`mergedCheckpointCacheTtl` controls how long an in-memory merged checkpoint index is retained.
`minTimeToKeepStoreShardEnv` controls how long an unused local copy of a shared store shard is retained before it is re-synchronised on next use.
`shardMergeThreadCount` limits concurrent shard merges.


#### Changes to the `processor` Branch

The processor has new controls for task assignment, polling and task leases.

* `claimTasksOnWorker` is experimental and defaults to `false`.
  When enabled, worker nodes claim their own tasks directly from the database.
  It must have the same value on every node, and changing it requires stopping the whole cluster before changing the value and restarting it.
* `skipEmptyFilterFetchDuration` sets how long an idle filter is left alone after no tasks are found for it.
* `skipNonProducingFiltersMaxDuration` caps the increasing delay before retrying filters that produce no tasks.
* `taskAvailabilityInterval` controls how often a node refreshes its summary of available work.
* `taskLeaseTimeout` controls when a task with no heartbeat is considered dead and returned to the `CREATED` state.
  It should be comfortably longer than the Processor Task Heartbeat job interval.
* `useMaxMetaIdFromPreviousPoll` avoids missing data that was inserted but not yet committed when the current maximum meta ID was read.

The obsolete `disownDeadTasksAfter` property has been removed.
Task leases are now controlled by `taskLeaseTimeout`.


#### New `receive.s3Event` Properties

S3 event processing can now be configured to poll an AWS SQS queue.
The queue URL, polling limits, visibility timeout and optional dead-letter queue are configured under `receive.s3Event.sqs`.

```yaml
appConfig:
  receive:
    s3Event:
      rePollDuration: "PT5M"
      sleepDurationPostFailure: "PT1M"
      sqs:
        assumeRole: null
        awsRegionName: null
        credentials: null
        deadLetterQueueUrl: null
        maxNumberOfMessages: 1000
        pollMaxWaitTime: "PT10S"
        queueUrl: null
        visibilityTimeout: "PT3M"
```

`rePollDuration` limits how long a scheduled execution polls before waiting for the next execution.
`sleepDurationPostFailure` sets the delay after a polling failure.
`visibilityTimeout` should be longer than the time needed to process a message; successfully processed messages are deleted from the queue.


#### New `sqlStore` Database Configuration

The SQL statistics store has a new database connection branch.
These values can be left unset when the connection is supplied through common database details.

```yaml
appConfig:
  sqlStore:
    db:
      connection:
        jdbcDriverClassName: null
        jdbcDriverPassword: null
        jdbcDriverUrl: null
        jdbcDriverUsername: null
      connectionPool:
        cachePrepStmts: false
        connectionTimeout: "PT30S"
        idleTimeout: "PT10M"
        leakDetectionThreshold: "PT0S"
        maxLifetime: "PT30M"
        maxPoolSize: 30
        minimumIdle: 10
        prepStmtCacheSize: 25
        prepStmtCacheSqlLimit: 256
```


### Stroom-Proxy's `config.yml`

#### New `forwardS3Destinations` Property

Stroom-Proxy can now forward proxy-format ZIP files to S3 destinations.

The `forwardS3Destinations` property is an empty list by default and should be configured with one or more S3 destinations if S3 forwarding is required.

```yaml
proxyConfig:
  forwardS3Destinations: []
```


#### New `receive.s3Event` Properties

Stroom-Proxy has a new configuration section for polling an AWS SQS queue for S3 event notifications.
This configuration section is shared with Stroom.

{{< note >}}
SQQ polling is not currently implemented in Stroom-Proxy.
{{< /note >}}


The queue URL, polling limits, visibility timeout, optional dead-letter queue and AWS HTTP client settings are configured under `proxyConfig.receive.s3Event.sqs`.

```yaml
proxyConfig:
  receive:
    s3Event:
      rePollDuration: "PT5M"
      sleepDurationPostFailure: "PT1M"
      sqs:
        assumeRole: null
        awsRegionName: null
        credentials: null
        deadLetterQueueUrl: null
        httpClient:
          connectionRequestTimeout: "PT3M"
          connectionTimeout: "PT3M"
          cookiesEnabled: false
          followRedirects: true
          keepAlive: "PT0S"
          maxConnections: 1024
          maxConnectionsPerRoute: 1024
          proxy: null
          retries: 0
          timeToLive: "PT1H"
          timeout: "PT3M"
          tls: null
          userAgent: null
          validateAfterInactivityPeriod: "PT0S"
        maxNumberOfMessages: 1000
        pollMaxWaitTime: "PT10S"
        queueUrl: null
        visibilityTimeout: "PT3M"
```

`rePollDuration` limits how long a scheduled execution polls before waiting for the next execution.

`sleepDurationPostFailure` sets the delay after a polling failure.

`visibilityTimeout` should be longer than the time needed to process a message because successfully processed messages are deleted from the queue.


## Database Migrations

When Stroom boots for the first time with a new version it will run any required database migrations to bring the database schema up to the correct version.

{{< warning >}}
It is highly recommended to ensure you have a database backup in place before booting stroom with a new version.
This is to mitigate against any problems with the migration.
It is also recommended to test the migration against a copy of your database to ensure that there are no problems when you do it for real.
{{< /warning >}}

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


<!-- Run on v7.14 -->


### Migration Scripts
 
<!--
#############################################################################################
#                                                                                           #
#  This section is auto-generated by TestListDbMigrations.listDbMigrationsForLatestVersion  #
#                                                                                           #
#############################################################################################
-->

For information purposes only, the following are the database migrations that will be run when upgrading to 7.14.0 from the previous minor version.
 
Note, the `legacy` module will run first (if present) then the other module will run in no particular order.
 

#### Module `stroom-cluster` 
 
##### Script `V07_14_00_001__cluster_lock_time.sql`
 
**Path**: `stroom-cluster/stroom-cluster-lock-impl-db/src/main/resources/stroom/cluster/lock/impl/db/migration/V07_14_00_001__cluster_lock_time.sql`
 
```sql
-- ------------------------------------------------------------------------
-- Copyright 2026 Crown Copyright
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- ------------------------------------------------------------------------

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_14_00_001__cluster_lock_time;

DELIMITER $$

CREATE PROCEDURE V07_14_00_001__cluster_lock_time ()
BEGIN
    DECLARE object_count integer;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'cluster_lock'
    AND column_name = 'lock_time_ms';

    IF object_count = 0 THEN
        -- When the lock was taken, as epoch millis, refreshed each time the holder extends its lease
        -- and cleared when the lock is released. NULL means the lock is free.
        ALTER TABLE cluster_lock ADD COLUMN lock_time_ms bigint DEFAULT NULL;
    END IF;
END $$

DELIMITER ;

CALL V07_14_00_001__cluster_lock_time;

DROP PROCEDURE IF EXISTS V07_14_00_001__cluster_lock_time;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_14_00_002__cluster_lock_more_columns.sql`
 
**Path**: `stroom-cluster/stroom-cluster-lock-impl-db/src/main/resources/stroom/cluster/lock/impl/db/migration/V07_14_00_002__cluster_lock_more_columns.sql`
 
```sql
-- ------------------------------------------------------------------------
-- Copyright 2026 Crown Copyright
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- ------------------------------------------------------------------------

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_14_00_002__cluster_lock_more_columns;

DELIMITER $$

CREATE PROCEDURE V07_14_00_002__cluster_lock_more_columns ()
BEGIN
    DECLARE object_count integer;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'cluster_lock'
    AND column_name = 'node_name';

    IF object_count = 0 THEN
        -- The node holding the lock, written when the lock is taken. Reported to whoever is waiting
        -- on a contended lock. It does not decide who may extend or release the lock: lock_token does,
        -- because a node name is not unique to one acquisition.
        ALTER TABLE cluster_lock ADD COLUMN node_name varchar(255) DEFAULT NULL;
    END IF;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'cluster_lock'
    AND column_name = 'thread_name';

    IF object_count = 0 THEN
        -- The thread on that node holding the lock, reported alongside node_name when a lock is
        -- contended.
        ALTER TABLE cluster_lock ADD COLUMN thread_name varchar(255) DEFAULT NULL;
    END IF;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'cluster_lock'
    AND column_name = 'lease_ms';

    IF object_count = 0 THEN
        -- How long the lock may be held without the holder extending it. The lock becomes available to
        -- another node once lock_time_ms plus this has passed, so a node that dies does not hold it
        -- forever.
        ALTER TABLE cluster_lock ADD COLUMN lease_ms bigint DEFAULT NULL;
    END IF;
END $$

DELIMITER ;

CALL V07_14_00_002__cluster_lock_more_columns;

DROP PROCEDURE IF EXISTS V07_14_00_002__cluster_lock_more_columns;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_14_00_003__cluster_lock_token.sql`
 
**Path**: `stroom-cluster/stroom-cluster-lock-impl-db/src/main/resources/stroom/cluster/lock/impl/db/migration/V07_14_00_003__cluster_lock_token.sql`
 
```sql
-- ------------------------------------------------------------------------
-- Copyright 2026 Crown Copyright
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- ------------------------------------------------------------------------

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_14_00_003__cluster_lock_token;

DELIMITER $$

CREATE PROCEDURE V07_14_00_003__cluster_lock_token ()
BEGIN
    DECLARE object_count integer;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'cluster_lock'
    AND column_name = 'lock_token';

    IF object_count = 0 THEN
        -- Identifies one acquisition of the lock. Written when the lock is taken and matched when it is
        -- extended or released, so a holder whose lease has expired cannot extend or release the lock a
        -- later holder now owns. node_name and thread_name are not unique enough to do this: they are
        -- kept for reporting who holds a contended lock.
        ALTER TABLE cluster_lock ADD COLUMN lock_token varchar(36) DEFAULT NULL;
    END IF;
END $$

DELIMITER ;

CALL V07_14_00_003__cluster_lock_token;

DROP PROCEDURE IF EXISTS V07_14_00_003__cluster_lock_token;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
#### Module `stroom-data` 
 
##### Script `V07_14_00_005__zstd_dictionary.sql`
 
**Path**: `stroom-data/stroom-data-store-impl-fs-db/src/main/resources/stroom/data/store/impl/fs/db/migration/V07_14_00_005__zstd_dictionary.sql`
 
```sql
/*
 * Copyright 2016-2026 Crown Copyright
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

-- One dictionary (i.e one dict uuid) can be associated with multiple
-- feed|stream_type_name|child_stream_type_name combinations

CREATE TABLE IF NOT EXISTS zstd_dictionary (
    id                        int NOT NULL AUTO_INCREMENT,
    version                   int NOT NULL, -- OCC version
    create_time_ms            bigint NOT NULL,
    create_user               varchar(255) NOT NULL,
    update_time_ms            bigint NOT NULL,
    update_user               varchar(255) NOT NULL,
    -- The feed this dict is for
    feed_name                 varchar(255) NOT NULL,
    -- The stream type this dict is for.
    -- Nullable to allow for a dict specific to a child stream type and feed only
    -- Max 100 chars to stop key too long errors
    stream_type_name          varchar(100),
    -- The child stream type this dict is for.
    -- Nullable for the main stream type
    -- Max 100 chars to stop key too long errors
    child_stream_type_name    varchar(100),
    -- The unique identifier of the dictionary that the combination of
    -- feed|stream_type_name|child_stream_type_name is associated with.
    uuid                      varchar(36) NOT NULL,
    -- The status of this dict, e.g. if it is still in training
    status                    tinyint NOT NULL,
    PRIMARY KEY (id),
    KEY `zstd_dict_feed_type_child_type_uuid_idx` (
        feed_name,
        stream_type_name,
        child_stream_type_name,
        uuid),
    KEY `zstd_dict_feed_type_uuid_idx` (
        feed_name,
        stream_type_name,
        uuid),
    KEY `zstd_dict_uuid_idx` (uuid)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_14_00_010__zstd_dictionary_task.sql`
 
**Path**: `stroom-data/stroom-data-store-impl-fs-db/src/main/resources/stroom/data/store/impl/fs/db/migration/V07_14_00_010__zstd_dictionary_task.sql`
 
```sql
/*
 * Copyright 2016-2026 Crown Copyright
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

CREATE TABLE IF NOT EXISTS zstd_dictionary_task (
    id                        bigint NOT NULL AUTO_INCREMENT,
    create_time_ms            bigint NOT NULL,
    -- The meta_id of the file that needs re-compressing
    feed_name                 varchar(255) NOT NULL,
    -- The stream type this dict is for.
    -- Nullable to allow for a dict specific to a child stream type and feed only
    -- Max 100 chars to stop key too long errors
    stream_type_name          varchar(100) NOT NULL,
    -- The child stream type this dict is for.
    -- Nullable for the main stream type
    -- Max 100 chars to stop key too long errors
    child_stream_type_name    varchar(100),
    -- The status of this dict, e.g. if it is still in training
    meta_id                   bigint NOT NULL,
    PRIMARY KEY (id),
    -- No point having >1 task for the same file key
    UNIQUE KEY `zstd_dict_task_feed_stream_type_child_type_meta_id_idx` (
        feed_name,
        stream_type_name,
        child_stream_type_name,
        meta_id),
    KEY `zstd_dict_task_feed_stream_type_child_type_create_time_idx` (
        feed_name,
        stream_type_name,
        child_stream_type_name,
        create_time_ms)
--     CONSTRAINT `zstd_dict_task_fk_meta_id` FOREIGN KEY (`meta_id`)
--         REFERENCES `fs_meta_volume` (meta_id)
    ) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_14_00_015__fs_meta_s3_location.sql`
 
**Path**: `stroom-data/stroom-data-store-impl-fs-db/src/main/resources/stroom/data/store/impl/fs/db/migration/V07_14_00_015__fs_meta_s3_location.sql`
 
```sql
/*
 * Copyright 2016-2026 Crown Copyright
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

-- Links one or more files stored on S3 to a meta record.
-- In theory, we could just hold a FK to fs_meta_vol and the s3_key, but the volume
-- client config is editable, so if someone changes that then we no longer know
-- where the files are on s3. Having it in here seems safer, despite the duplication.
CREATE TABLE IF NOT EXISTS fs_meta_s3_location (
    id                        bigint NOT NULL AUTO_INCREMENT,
    meta_id                   bigint NOT NULL,
    -- Region/Bucket are strictly ascii and case-sensitive so use ascii and ascii_bin collation.
    s3_region                 VARCHAR(50) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    s3_bucket                 VARCHAR(63) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,

    -- Use a case-sensitive binary collation as we are not always in control of the keys.
    s3_key                    VARCHAR(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_bin NOT NULL,

    -- A deterministic hash of location for the unique key, except in the slim chance of a hash clash.
    s3_hash                   binary(32) GENERATED ALWAYS AS (
        unhex(sha2(
            concat(meta_id, '|', s3_region, '|', s3_bucket, '|', s3_key),
            256))
    ) STORED NOT NULL,

    PRIMARY KEY (id),

    -- Indexing the region+bucket+key results in an index key that is too big as it has to assume
    -- the s3_key is 4 bytes/char. Thus, we index the hash instead, which is much smaller and almost
    -- unique.
    UNIQUE KEY `fs_meta_s3_location_meta_s3_hash_idx` (meta_id, s3_hash)
    ) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_14_00_020__fs_volume_path.sql`
 
**Path**: `stroom-data/stroom-data-store-impl-fs-db/src/main/resources/stroom/data/store/impl/fs/db/migration/V07_14_00_020__fs_volume_path.sql`
 
```sql
/*
 * Copyright 2026 Crown Copyright
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_14_00_020;

DELIMITER $$

CREATE PROCEDURE V07_14_00_020 ()
BEGIN
    DECLARE object_count integer;

    -- Relax the 'not null' constraint on the path column
    ALTER TABLE fs_volume MODIFY path varchar(255);

    -- Check for existing unique constraint on 'path' and drop it
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.statistics
    WHERE table_schema = database()
    AND table_name = 'fs_volume'
    AND index_name = 'path'
    AND non_unique = 0;

    IF object_count > 0 THEN
        ALTER TABLE fs_volume DROP INDEX path;
    END IF;

    -- Check for the new composite unique constraint and add it if missing
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.statistics
    WHERE table_schema = database()
    AND table_name = 'fs_volume'
    AND index_name = 'fs_volume_type_path_idx'
    AND non_unique = 0;

    IF object_count = 0 THEN
        -- Paths should only be unique within a volume type
        ALTER TABLE fs_volume ADD CONSTRAINT fs_volume_type_path_idx UNIQUE (volume_type, path);
    END IF;

END $$

DELIMITER ;

CALL V07_14_00_020;

DROP PROCEDURE IF EXISTS V07_14_00_020;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
#### Module `stroom-meta` 
 
##### Script `V07_14_00_005__meta_add_read_only_col.sql`
 
**Path**: `stroom-meta/stroom-meta-impl-db/src/main/resources/stroom/meta/impl/db/migration/V07_14_00_005__meta_add_read_only_col.sql`
 
```sql
-- ------------------------------------------------------------------------
-- Copyright 2020 Crown Copyright
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- ------------------------------------------------------------------------

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_14_00_005__meta_add_read_only_col;

DELIMITER $$

CREATE PROCEDURE V07_14_00_005__meta_add_read_only_col ()
BEGIN
    DECLARE object_count integer;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
      AND table_name = 'meta'
      AND column_name = 'is_read_only';

    IF object_count = 0 THEN
        -- Column to indicate that the data associated with this meta record is outside the control
        -- of stroom and is thus read-only as far as stroom is concerned.
        ALTER TABLE meta
            ADD COLUMN is_read_only TINYINT(1) NOT NULL DEFAULT 0;
    END IF;
END $$

DELIMITER ;

CALL V07_14_00_005__meta_add_read_only_col;

DROP PROCEDURE IF EXISTS V07_14_00_005__meta_add_read_only_col;


SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set tabstop=4 shiftwidth=4 expandtab:

```
 
 
#### Module `stroom-processor` 
 
##### Script `V07_14_00_001__processor_filter_tracker_prev_max_meta_id.sql`
 
**Path**: `stroom-processor/stroom-processor-impl-db/src/main/resources/stroom/processor/impl/db/migration/V07_14_00_001__processor_filter_tracker_prev_max_meta_id.sql`
 
```sql
-- ------------------------------------------------------------------------
-- Copyright 2025 Crown Copyright
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- ------------------------------------------------------------------------

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_14_00_001__processor_filter_tracker_prev_max_meta_id;

DELIMITER $$

CREATE PROCEDURE V07_14_00_001__processor_filter_tracker_prev_max_meta_id ()
BEGIN
    DECLARE object_count integer;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'processor_filter_tracker'
    AND column_name = 'prev_max_meta_id';

    IF object_count = 0 THEN
        -- The max meta id seen on the previous task creation poll. Task creation is bounded
        -- by this rather than the live max meta id so that a meta row that was inserted but
        -- not yet committed when the max was read has a full poll interval to become visible
        -- before the tracker moves past it. Null means no poll has established a value yet.
        ALTER TABLE processor_filter_tracker ADD COLUMN prev_max_meta_id bigint DEFAULT NULL;
    END IF;
END $$

DELIMITER ;

CALL V07_14_00_001__processor_filter_tracker_prev_max_meta_id;

DROP PROCEDURE IF EXISTS V07_14_00_001__processor_filter_tracker_prev_max_meta_id;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_14_00_002__processor_filter_tracker_next_poll_ms.sql`
 
**Path**: `stroom-processor/stroom-processor-impl-db/src/main/resources/stroom/processor/impl/db/migration/V07_14_00_002__processor_filter_tracker_next_poll_ms.sql`
 
```sql
-- ------------------------------------------------------------------------
-- Copyright 2025 Crown Copyright
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- ------------------------------------------------------------------------

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_14_00_002__processor_filter_tracker_next_poll_ms;

DELIMITER $$

CREATE PROCEDURE V07_14_00_002__processor_filter_tracker_next_poll_ms ()
BEGIN
    DECLARE object_count integer;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'processor_filter_tracker'
    AND column_name = 'next_poll_ms';

    IF object_count = 0 THEN
        -- The earliest time that task creation should poll this filter again. It is only set
        -- when a poll creates no tasks, and each successive non producing poll pushes it
        -- further out, up to a maximum, so that filters with nothing to do are polled less
        -- often. Null means poll on the next task creation run.
        ALTER TABLE processor_filter_tracker ADD COLUMN next_poll_ms bigint DEFAULT NULL;
    END IF;
END $$

DELIMITER ;

CALL V07_14_00_002__processor_filter_tracker_next_poll_ms;

DROP PROCEDURE IF EXISTS V07_14_00_002__processor_filter_tracker_next_poll_ms;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_14_00_003__processor_filter_max_task_creation_delay.sql`
 
**Path**: `stroom-processor/stroom-processor-impl-db/src/main/resources/stroom/processor/impl/db/migration/V07_14_00_003__processor_filter_max_task_creation_delay.sql`
 
```sql
-- ------------------------------------------------------------------------
-- Copyright 2025 Crown Copyright
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- ------------------------------------------------------------------------

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_14_00_003__processor_filter_max_task_creation_delay;

DELIMITER $$

CREATE PROCEDURE V07_14_00_003__processor_filter_max_task_creation_delay ()
BEGIN
    DECLARE object_count integer;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'processor_filter'
    AND column_name = 'max_task_creation_delay';

    IF object_count = 0 THEN
        -- How long this filter will wait, at most, before task creation polls it again after
        -- polls that created no tasks, e.g. '30s'. Overrides the cluster wide
        -- skipNonProducingFiltersMaxDuration property so that latency sensitive filters, such
        -- as those raising alerts from infrequent data, can be polled more eagerly than the
        -- rest. Null means use the cluster wide property.
        ALTER TABLE processor_filter ADD COLUMN max_task_creation_delay varchar(255) DEFAULT NULL;
    END IF;
END $$

DELIMITER ;

CALL V07_14_00_003__processor_filter_max_task_creation_delay;

DROP PROCEDURE IF EXISTS V07_14_00_003__processor_filter_max_task_creation_delay;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_14_00_004__processor_filter_parent_filter_id.sql`
 
**Path**: `stroom-processor/stroom-processor-impl-db/src/main/resources/stroom/processor/impl/db/migration/V07_14_00_004__processor_filter_parent_filter_id.sql`
 
```sql
-- ------------------------------------------------------------------------
-- Copyright 2026 Crown Copyright
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- ------------------------------------------------------------------------

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_14_00_004__processor_filter_parent_filter_id;

DELIMITER $$

CREATE PROCEDURE V07_14_00_004__processor_filter_parent_filter_id ()
BEGIN
    DECLARE object_count integer;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'processor_filter'
    AND column_name = 'parent_filter_id';

    IF object_count = 0 THEN
        -- gh-5699. The filter this one was made from, where it was made by replacing an existing
        -- filter rather than being created outright, e.g. restoring a deleted filter so that its
        -- range is processed again. Reprocessing a range makes a new filter rather than resetting
        -- an existing filter's tracker, so that a filter id always means the same body of work;
        -- this column is what keeps the history visible once it does.
        --
        -- Deliberately not a foreign key. Old filters are physically deleted once their tasks have
        -- gone (see ProcessorFilterDaoImpl.physicalDeleteOldProcessorFilters), and a constraint
        -- here would keep every superseded ancestor alive for as long as any descendant existed.
        -- This is provenance, not referential integrity, so it is allowed to dangle.
        ALTER TABLE processor_filter ADD COLUMN parent_filter_id int DEFAULT NULL;
    END IF;
END $$

DELIMITER ;

CALL V07_14_00_004__processor_filter_parent_filter_id;

DROP PROCEDURE IF EXISTS V07_14_00_004__processor_filter_parent_filter_id;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
