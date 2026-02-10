---
title: "Upgrade Notes"
linkTitle: "Upgrade Notes"
weight: 40
date: 2025-09-23
tags: 
description: >
  Required actions and information relating to upgrading to Stroom version 7.11.
---

{{% warning %}}
Please read this section carefully in case any of it is relevant to your Stroom/Stroom-Proxy instance.
{{% /warning %}}


## Upgrade Path

You can upgrade to v7.11.x from any v7.x release that is older than the version being upgraded to.

If you want to upgrade to v7.11.x from v5.x or v6.x we recommend you do the following:

1. Upgrade v5.x to the latest patch release of v6.0.
1. Upgrade v6.x to the latest patch release of v7.0.
1. Upgrade v7.x to the latest patch release of v7.11.

{{% warning %}}
v7.11 **cannot** migrate content in legacy formats, i.e. content created in v5/v6.
You must therefore upgrade to v7.0.x first to migrate this content, before upgrading to v7.11.x.
{{% /warning %}}


## Java Version

Stroom v7.10 requires Java 25.

{{% warning %}}
This is different to the java version required for Stroom v7.9 (Java 21).
{{% /warning %}}

Ensure the Stroom and Stroom-Proxy hosts are running the latest patch release of Java v25.


## Configuration File Changes

<!--
Check changes using something like this (run from an up-to-date stroom repo):
old_ver=7.10
new_ver=7.11
git diff origin/${old_ver}..origin/${new_ver} stroom-config/stroom-config-app/src/test/resources/stroom/config/app/expected.yaml
git diff origin/${old_ver}..origin/${new_ver} stroom-proxy/stroom-proxy-app/src/test/resources/stroom/dist/proxy-expected.yaml
-->

### Common Configuration Changes

These changes are common to both Stroom and Stroom Proxy.


#### New `receive` Branch Properties

```yaml
proxyConfig:
  receive:
    # The action to take if there is a problem with the data receipt rules, e.g.
    # Stroom Proxy has been unable to contact Stroom to fetch the rules.
    fallbackReceiveAction: "RECEIVE"
    # If defined then states the maximum size of a request (uncompressed for gzip requests).
    # Will return a 413 Content Too Long response code for any requests exceeding this
    # value. If undefined then there is no limit to the size of the request.
    # Defined as an IEC byte value, e.g. 10GiB, 10M, 23TB, 1024, etc.
    maxRequestSize: null
    # The data receipt checking mode, one of:
    # * FEED_STATUS - Use the legacy Feed Status Check method
    # * RECEIPT_POLICY - Use the new Data Receipt Rules
    # * RECEIVE_ALL - Receive ALL data with no checks
    # * DROP_ALL - Drop ALL data with no checks
    # * REJECT_ALL - Reject ALL data with no checks
    receiptCheckMode: "FEED_STATUS"
```


### Stroom's `config.yml`

#### New `askStroomAi` Branch

A new branch of configuration to configure [Ask Stroom AI]({{< relref "new-features#ask-stroom-ai" >}}).

```yaml
appCongfig:
  askStroomAi:
    chatMemory:
      # How long a chat memory entry should exist before being expired
      timeToLive:
        time: 1
        timeUnit: "HOURS"
      # Number of tokens to keep in each chat memory store
      tokenLimit: 30000
    # The DocRef of the OpenAIModel document to use for Ask Stroom AI. e.g.
    # modelRef:
    #  name: "My Model"
    #  type: "OpenAIModel"
    #  uuid: "8df699c0-2ce5-48bc-bb1a-e5d26bbd2175"
    modelRef:
    tableSummary:
      # Maximum number of tokens to pass the AI service at a time
      maximumBatchSize: 16384
      # Maximum number of table result rows to pass to the AI when making requests
      maximumTableInputRows: 100
```


#### New `contentStore` Branch

A new branch of configuration to configure one or more [Content Stores]({{< relref "new-features#content-store" >}}).

```yaml
appCongfig:
  contentStore:
    # A list of URLs to content store definition files
    urls:
    - "https://raw.githubusercontent.com/gchq/stroom-content/refs/heads/master/source/content-store.yml"
```


#### New `credentials` Branch

A new branch has been added for configuring the storage and caching of credentials for authenticating with other systems.

```yaml
  credentials:
    # A standard configuration branch for a database connection.
    # Only set this if you want the credentials tables to be located on a different database
    # to the rest of Stroom.
    db:
      connection:
        #...
      connectionPool:
        # ...
    # The path to stored cached key stores.
    keyStoreCachePath: "${stroom.home}/keystores"
```


#### Removed Elastic Property

The property `stroom.elastic.retention.scrollSize` has been removed.

```yaml
appCongfig:
  elastic:
    retention:           # <- REMOVED
      scrollSize: 10000  # <- REMOVED
```


#### `db` Branch added to `gitRepo`

A standard database configuration branch has been added to `GitRepo`.
You should not need to set this unless you want the Git Repo table data to be stored on a different database.

```yaml
appCongfig:
  gitRepo:
    db:
      connection:
        #...
      connectionPool:
        # ...
```


#### New `receiptPolicy` Branch

A new configuration branch for [Data Receipt Rules]({{< relref "docs/user-guide/data-receipt/data-receipt-rules" >}}).

```yaml
  receiptPolicy:
    obfuscatedFields:
    - "AccountId"
    - "AccountName"
    # ...
    - "X-Forwarded-For"
    obfuscationHashAlgorithm: "SHA2_512"
    receiptRulesInitialFields:
      AccountId: "Text"
      Component: "Text"
    # ...
      user-agent: "Text"
      X-Forwarded-For: "Text"
```


### Stroom-Proxy's `config.yml`

#### Removed `contentSync`

The whole `contentSync` branch has been removed as it is no longer in use.

```yaml
proxyConfig:
  contentSync:
    apiKey: null
    contentSyncEnabled: false
    syncFrequency: "PT1M"
    upstreamUrl: null
```


#### Added `downstreamHost`

A new `downstreamHost` branch has been added to configure the default downstream host details and authentication.
In a typical deployment, Stroom Proxy will receive data and forward it on to a downstream Stroom or Stroom Proxy.
There are a number of parts of Stroom Proxy that need to communicate with the downstream host, e.g. feed status checking, forwarding or rule fetching.

This allows for the host's details and any authentication properties to be set in one place.
Typically you will only need to set the `hostname` and `apiKey` properties.

```yaml
proxyConfig:
  downstreamHost:
    # The API key to use for authentication (unless OpenID Connect is being used)
    apiKey: null
    # Only set this if you need to use a non-standard path
    apiKeyVerificationUrl: null
    enabled: true
    # The hostname of the downstream
    hostname: null
    # How long to cache verified keys for in memory
    maxCachedKeyAge: "PT10M"
    # How long keys will be persisted for on disk in case the downstream
    # can't be connected to
    maxPersistedKeyAge: "P30D"
    # The delay to use after there is an error connecting to the downstream
    noFetchIntervalAfterFailure: "PT30S"
    # Only requird if you need a common path prefix in front of the path
    # that Stroom / Stroom Proxy will use.
    pathPrefix: null
    # The hash algorithm used to hash persisted API keys.
    persistedKeysHashAlgorithm: "SHA2_512"
    # The port to connect to the downstream on
    # If not set, will default to 80/443 depending on scheme.
    port: null
    # The scheme to connect to the downstream on
    scheme: "https"
```


#### Remove various `feedStatus` properties

The following three properties have been removed from the `feedStatus` branch.

```yaml
proxyConfig:
  feedStatus:
    apiKey: null             # <- REMOVED
    defaultStatus: "Receive" # <- REMOVED
    enabled: true            # <- REMOVED
```


#### New `forwardHttpDestinations` property

A new property has been added to enable/disable the liveness checking for HTTP destinations.
Liveness checking will periodically check that the destination is live and if not, disable forwarding until the liveness check determines it to be live again.
Liveness checking is enabled by default.

```yaml
proxyConfig:
  forwardHttpDestinations:
  - .....
    livenessCheckEnabled: true
```


#### New `forwardFileDestinations` property

A new property has been added to enable/disable the liveness checking for file destinations.
Liveness checking will periodically check that the destination is live and if not, disable forwarding until the liveness check determines it to be live again.
Liveness checking is enabled by default.


```yaml
proxyConfig:
  forwardFileDestinations:
  - .....
    livenessCheckEnabled: true
```


#### Added `receiptPolicy` Branch

This configuration branch has been added to configure the [Data Receipt Rules]({{< relref "docs/user-guide/data-receipt/data-receipt-rules" >}}).

```yaml
proxyConfig:
  receiptPolicy:
    # Stroom Proxy will use downstreamHost to derive the URL to connect to.
    # Only set this if you need to use a non-standard URL.
    receiveDataRulesUrl: null
    # The frequency that Stroom Proxy will connect to the downstream host to obtain updated
    # receipt policy rules.
    syncFrequency: "PT1M"
```


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
 
<!--
#############################################################################################
#                                                                                           #
#  This section is auto-generated by TestListDbMigrations.listDbMigrationsForLatestVersion  #
#                                                                                           #
#############################################################################################
-->
 
For information purposes only, the following are the database migrations that will be run when upgrading to 7.11.0 from the previous minor version.
 
Note, the `legacy` module will run first (if present) then the other module will run in no particular order. 
 
#### Module `stroom-annotation` 
 
##### Script `V07_11_00_001__annotation3.sql`
 
**Path**: `stroom-annotation/stroom-annotation-impl-db/src/main/resources/stroom/annotation/impl/db/migration/V07_11_00_001__annotation3.sql`
 
```sql
-- ------------------------------------------------------------------------
-- Copyright 2023 Crown Copyright
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

DROP PROCEDURE IF EXISTS V07_11_00_001_annotation;

DELIMITER $$

CREATE PROCEDURE V07_11_00_001_annotation ()
BEGIN
    DECLARE object_count integer;

    --
    -- Add entry parent id
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation_entry'
    AND column_name = 'parent_id';

    IF object_count = 0 THEN
        ALTER TABLE `annotation_entry` ADD COLUMN `parent_id` bigint DEFAULT NULL;
    END IF;

    --
    -- Add entry update time
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation_entry'
    AND column_name = 'update_time_ms';

    IF object_count = 0 THEN
        ALTER TABLE `annotation_entry` ADD COLUMN `update_time_ms` bigint(20) NOT NULL;

        -- Copy all entry times to update times.
        SET @sql_str = CONCAT(
            'UPDATE annotation_entry a ',
            'SET a.update_time_ms = a.entry_time_ms');
        PREPARE stmt FROM @sql_str;
        EXECUTE stmt;

    END IF;

    --
    -- Add entry update user
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation_entry'
    AND column_name = 'update_user_uuid';

    IF object_count = 0 THEN
        ALTER TABLE `annotation_entry` ADD COLUMN `update_user_uuid` varchar(255) NOT NULL;

        -- Copy all entry users to update users.
        SET @sql_str = CONCAT(
            'UPDATE annotation_entry a ',
            'SET a.update_user_uuid = a.entry_user_uuid');
        PREPARE stmt FROM @sql_str;
        EXECUTE stmt;

    END IF;

END $$

DELIMITER ;

CALL V07_11_00_001_annotation;

DROP PROCEDURE IF EXISTS V07_11_00_001_annotation;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
#### Module `stroom-credentials` 
 
##### Script `V07_11_00_001__credential.sql`
 
**Path**: `stroom-credentials/stroom-credentials-impl-db/src/main/resources/stroom/credentials/impl/db/migration/V07_11_00_001__credential.sql`
 
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

--
-- Create the credential tables
--
CREATE TABLE IF NOT EXISTS credential (
    uuid                  varchar(255) NOT NULL,
    create_time_ms        bigint(20) NOT NULL,
    create_user           varchar(255) NOT NULL,
    update_time_ms        bigint(20) NOT NULL,
    update_user           varchar(255) NOT NULL,
    name                  varchar(255) NOT NULL,
    crendential_type      varchar(255) NOT NULL,
    key_store_type        varchar(255) DEFAULT NULL,
    expiry_time_ms        bigint DEFAULT NULL,
    secret_json           json NOT NULL,
    key_store             longblob DEFAULT NULL,
    PRIMARY KEY  (uuid),
    UNIQUE KEY name (name)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
#### Module `stroom-index` 
 
##### Script `V07_11_00_001__index_field.sql`
 
**Path**: `stroom-index/stroom-index-impl-db/src/main/resources/stroom/index/impl/db/migration/V07_11_00_001__index_field.sql`
 
```sql
-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

ALTER TABLE index_field ADD COLUMN `dense_vector` json DEFAULT NULL;

SET SQL_NOTES=@OLD_SQL_NOTES;

```
 
 
#### Module `stroom-processor` 
 
##### Script `V07_11_00_001__processor_filter.sql`
 
**Path**: `stroom-processor/stroom-processor-impl-db/src/main/resources/stroom/processor/impl/db/migration/V07_11_00_001__processor_filter.sql`
 
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

-- --------------------------------------------------

DELIMITER $$

-- --------------------------------------------------

DROP PROCEDURE IF EXISTS processor_run_sql_v1 $$

-- DO NOT change this without reading the header!
CREATE PROCEDURE processor_run_sql_v1 (
    p_sql_stmt varchar(1000)
)
BEGIN

    SET @sqlstmt = p_sql_stmt;

    SELECT CONCAT('Running sql: ', @sqlstmt);

    PREPARE stmt FROM @sqlstmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

-- --------------------------------------------------

DROP PROCEDURE IF EXISTS processor_add_column_v1$$

-- DO NOT change this without reading the header!
CREATE PROCEDURE processor_add_column_v1 (
    p_table_name varchar(64),
    p_column_name varchar(64),
    p_column_type_info varchar(64) -- e.g. 'varchar(255) default NULL'
)
BEGIN
    DECLARE object_count integer;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = p_table_name
    AND column_name = p_column_name;

    IF object_count = 0 THEN
        CALL processor_run_sql_v1(CONCAT(
            'alter table ', database(), '.', p_table_name,
            ' add column ', p_column_name, ' ', p_column_type_info));
    ELSE
        SELECT CONCAT(
            'Column ',
            p_column_name,
            ' already exists on table ',
            database(),
            '.',
            p_table_name);
    END IF;
END $$

-- idempotent
CALL processor_add_column_v1(
        'processor_filter',
        'export',
        'TINYINT(1) NOT NULL DEFAULT 0')$$

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```


