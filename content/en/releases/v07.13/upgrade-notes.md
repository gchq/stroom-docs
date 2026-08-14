---
title: "Upgrade Notes"
linkTitle: "Upgrade Notes"
weight: 40
date: 2026-03-18
tags: 
description: >
  Required actions and information relating to upgrading to Stroom version 7.13.
---

{{% warning %}}
Please read this section carefully in case any of it is relevant to your Stroom/Stroom-Proxy instance.
{{% /warning %}}


## Upgrade Path

You can upgrade to v7.13.x from any v7.x release that is older than the version being upgraded to.

If you want to upgrade to v7.13.x from v5.x or v6.x we recommend you do the following:

1. Upgrade v5.x to the latest patch release of v6.0.
1. Upgrade v6.x to the latest patch release of v7.0.
1. Upgrade v7.x to the latest patch release of v7.13.

{{% warning %}}
v7.13 **cannot** migrate content in legacy formats, i.e. content created in v5/v6.
You must therefore upgrade to v7.0.x first to migrate this content, before upgrading to v7.13.x.
{{% /warning %}}


## Java Version

Stroom v7.13 requires Java 25.

{{% warning %}}
This is different to the java version required for Stroom v7.9 (Java 21).
{{% /warning %}}

Ensure the Stroom and Stroom-Proxy hosts are running the latest patch release of Java v25.


## Before Upgrading

### Duplicate Account Email Addresses

This applies only if you use Stroom's internal identity provider.

Account email addresses must now be unique, so that the 'Forgot password' flow can identify an account from the email address it is given.
The database migration will stop with an error listing the addresses concerned if any are shared, and Stroom will not start.

Check for shared addresses before upgrading.

```sql
SELECT email, COUNT(1), GROUP_CONCAT(user_id)
FROM account
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(1) > 1;
```

If this returns any rows then give each of those accounts its own email address, or clear the address of all but one of them.
An account with no email address is fine, and any number of accounts may have none, but such an account cannot reset its password by email.


### External Identity Provider Redirect URI

This applies only if you use an external identity provider, e.g. Keycloak, AWS Cognito or Google.

The client registered at the provider must list Stroom's sign-in callback under its valid redirect URIs, substituting your Stroom public URL.

```text
https://<stroom-host>/api/auth/flow/v1/signin-oidc
```

This is the single `redirect_uri` that Stroom sends on the authorization request, so a provider that does not have this exact value registered will reject the login with an invalid redirect URI error.

If you also use provider-side logout, add the post logout landing page to the client's valid post logout redirect URIs.

```text
https://<stroom-host>/
```

The internal identity provider needs no configuration for this.

{{% see-also %}}
[External Identity Provider]({{< relref "docs/install-guide/setup/open-id/external-idp" >}})
{{% /see-also %}}


### Upgrading from a 7.13 Beta Release

This applies only if you have deployed a 7.13 beta release up to and including `v7.13-beta.10`.

The database migration scripts in those releases were named `V07_14...` rather than `V07_13...`, and have since been renamed to match the branch.
The migration will fail on the next release unless the recorded script names are updated first.

Run the following script against the Stroom database before starting the new version.

{{< external-link "v07_13_migration_script_rename.sql" "https://raw.githubusercontent.com/gchq/stroom/refs/heads/7.13/scripts/v07_13_migration_script_rename.sql" >}}


## After Upgrading

### Review Disabled Accounts

This applies only if you use Stroom's internal identity provider.

An administrator can no longer lock an account, so two kinds of account are converted to disabled by the migration and will appear in the accounts list as such.

* Any account that was locked at the point of upgrade.
  Locking was how an administrator barred an account, and disabling is now the control for that.
* An account flagged as a processing account, a setting that has been removed.

This fails closed, i.e. access stays barred until an administrator acts, so review the accounts list after upgrading and re-enable anything that was disabled in error.

{{% see-also %}}
[User Accounts]({{< relref "docs/user-guide/security/user-accounts" >}})
{{% /see-also %}}


## Configuration File Changes

<!--
Check changes using something like this (run from an up-to-date stroom repo):
old_ver=7.12
new_ver=7.13
git diff origin/${old_ver}..origin/${new_ver} stroom-config/stroom-config-app/src/test/resources/stroom/config/app/expected.yaml | cat
echo
echo
git diff origin/${old_ver}..origin/${new_ver} stroom-proxy/stroom-proxy-app/src/test/resources/stroom/dist/proxy-expected.yaml | cat
-->


### Stroom's `config.yml`

<!-- Comparison of the latest v7.12 release => v7.13 -->


#### New `ai` Branch

The following `ai` branch has been added for configuring the database connection details for the _ai_ module.
You should not need to configure any of this unless you want a dedicated database for this module.

```yaml
appConfig:
  ai:
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


#### Changes to `askStroomAi` Branch

This branch controls the Ask Stroom AI feature.

The following properties have been **removed**.

```yaml
appConfig:
  askStroomAi:
    chatMemory:
      timeToLive:
        time: 1
        timeUnit: "HOURS"
      tokenLimit: 30000
    tableSummary:
      maximumBatchSize: 16384
      maximumTableInputRows: 100
```

The following properties have been added.

```yaml
appConfig:
  askStroomAi:
    tableAnalysis:
      maxTotalRows: 10000
      maxRowsPerBatch: 1000
      maxParallelBatches: 4
      tableQuerySystemPrompt: "    You are a data analysis AI. You will answer user\
        \ questions     using ONLY the markdown-formatted DATA TABLE records provided.\
        \     If the records do not contain relevant details, say \"No relevant information.\"\
        \n"
      tableQueryUserPrompt: "    CONVERSATION CONTEXT:\n    {{context}}\n\n    USER\
        \ QUERY:\n    {{query}}\n\n    DATA TABLE:\n    {{table}}\n\n    Provide findings\
        \ relevant only to these records, in a concise structured format.     Use\
        \ the conversation context to understand what has been previously discussed.\n"
      multiSummaryMergePrompt: "    Merge the following summaries into a single unified,\
        \ concise summary.     Preserve important details, numerical findings, and\
        \ remove duplicates.\n\n    {{summaries}}\n"
    chatSystemPrompt: "You are a helpful data analysis assistant within the Stroom\
      \ data platform. When table data is attached to the conversation, it appears\
      \ as markdown tables prefixed with [Attached Table: ...] labels identifying\
      \ the source. Use data from all relevant attached tables to answer the user's\
      \ questions. If multiple tables are present, cite the source table name in your\
      \ answer. If you don't have enough information, say so."
    historySummaryPrompt: "Summarise the following conversation history in 2-3 concise\
      \ sentences. Preserve key facts, decisions, data findings, and any table names\
      \ or sources referenced. Do not include greetings or filler."
    maxHistorySafetyCapMessages: 200
    attachmentDownloadTimeoutMs: 60000
    enableDebugDetail: true
```


#### New `contentIndex` Branch

This section is used for controlling the indexing of Stroom's content.

```yaml
appConfig:
  contentIndex:
    contentIndexDir: "content_index"
    minRebuildAge: "PT1M"
    storageType: "LOCAL"
```


#### New `docstore` Properties

```yaml
appConfig:
  docstore:
    docRefInfoCache:
      expireAfterAccess: "PT10M"
      expireAfterWrite: null
      maximumSize: 1000000
      refreshAfterWrite: null
      statisticsMode: "INTERNAL"
    docRefNameCache:
      expireAfterAccess: "PT10M"
      expireAfterWrite: null
      maximumSize: 1000000
      refreshAfterWrite: null
      statisticsMode: "INTERNAL"
    physicalDeleteAge: "P30D"
```


#### Changes to `explorer` Branch

The following properties have been removed.

```yaml
appConfig:
  explorer:
    docRefInfoCache:
      expireAfterAccess: "PT10M"
      expireAfterWrite: null
      maximumSize: 1000
      refreshAfterWrite: null
      statisticsMode: "INTERNAL"
```


#### Changes to `node` Branch

The following properties have been added.

```yaml
appConfig:
  node:
    nodeGroupCache:
      expireAfterAccess: null
      expireAfterWrite: "PT1H"
      maximumSize: 1000
      refreshAfterWrite: "PT10S"
      statisticsMode: "INTERNAL"
```


#### Changes to `pipeline` Branch

The following property has been added.

```yaml
appConfig:
  pipeline:
    parser:
      disableExternalEntities: true
```


#### Changes to `processor` Branch

The following properties have been added.

```yaml
appConfig:
  processor:
    processorProfileCache:
      expireAfterAccess: null
      expireAfterWrite: "PT1H"
      maximumSize: 1000
      refreshAfterWrite: "PT10S"
      statisticsMode: "INTERNAL"
```


#### Changes to the `security` Branch.

The following configuration properties have been removed.

```yaml
appConfig:
  security:
    authorisation:
      userCache:
        expireAfterAccess: "PT30M"
    identity:
      email:
        allowPasswordResets: false
        passwordResetUrl: "/s/resetPassword/?user=%s&token=%s"
      openid:
        refreshTokenCache:
          expireAfterAccess: "P1D"
          expireAfterWrite: null
          maximumSize: 10000
          refreshAfterWrite: null
          statisticsMode: "INTERNAL"
      passwordPolicy:
        passwordComplexityRegex: ".*"
```

The following new properties have been added.

```yaml
appConfig:
  security:
    authentication:
      csrf:
        protectBrowserOriginatedRequests: true
      edgeAuthentication:
        enabled: false
        logout:
          cookiesToExpire: []
          signOutUrl: null
      openId:
        authenticationRequestExtraParams: {}
        requiredAccessTokenType: null
        validateAudience: true
    identity:
      passwordResetRequestCooldown: "PT1M"
      reactivateInactiveAccountsOnLogin: false
      token:
        jwkRotationInterval: "P30D"
```

The default value of `passwordPolicyMessage` has changed from

```text
To conform with our Strong Password policy, you are 
required to use a sufficiently strong password. Password must be more
than 8 characters.
```

To

```text
To conform with our Strong Password policy, you are
required to use a sufficiently strong password. Password must be at least
8 characters.
```


The default value of `audienceClaimRequired` has changed from `false` to `true`.

```yaml
appConfig:
  security:
    authentication:
      openId:
        audienceClaimRequired: true
```

The default cache configuration for `userCache` has changed from `expireAfterAccess` to `expireAfterWrite`.

```yaml
appConfig:
  security:
    authorisation:
      userCache:
        expireAfterAccess: "PT30M"
```


#### Removed `state` Branch

The `state` config was used for a ScyllaDB backed sate store which has now been removed from Stroom.

```yaml
appConfig:
  state:
    scyllaDbDocCache:
      expireAfterAccess: null
      expireAfterWrite: "PT10M"
      maximumSize: 100
      refreshAfterWrite: null
      statisticsMode: "INTERNAL"
    sessionCache:
      expireAfterAccess: "PT1H"
      expireAfterWrite: null
      maximumSize: 10
      refreshAfterWrite: null
      statisticsMode: "INTERNAL"
    stateDocCache:
      expireAfterAccess: null
      expireAfterWrite: "PT10M"
      maximumSize: 100
      refreshAfterWrite: null
      statisticsMode: "INTERNAL"
```


#### Changes to the `statistics` Branch

The following properties for the HBase based statistics store have been removed along with this statistics store functionality.

```yaml
appConfig:
  statistics:
    hbase:
      docRefType: "StroomStatsStore"
      eventsPerMessage: 100
      kafkaConfigUuid: null
      kafkaTopics:
        count: "statisticEvents-Count"
        value: "statisticEvents-Value"
    internal:
      benchmarkCluster:
      - type: "StroomStatsStore"
        uuid: "2503f703-5ce0-4432-b9d4-e3272178f47e"
        name: "Benchmark-Cluster Test"
      cpu:
      - type: "StroomStatsStore"
        uuid: "1edfd582-5e60-413a-b91c-151bd544da47"
        name: "CPU"
      enabledStoreTypes:
      - "StatisticStore"
      eventsPerSecond:
      - type: "StroomStatsStore"
        uuid: "cde67df0-0f77-45d3-b2c0-ee8bb7b3c9c6"
        name: "EPS"
      heapHistogramBytes:
      - type: "StroomStatsStore"
        uuid: "b0110ab4-ac25-4b73-b4f6-96f2b50b456a"
        name: "Heap Histogram Bytes"
      heapHistogramInstances:
      - type: "StroomStatsStore"
        uuid: "bdd933a4-4309-47fd-98f6-1bc2eb555f20"
        name: "Heap Histogram Instances"
      memory:
      - type: "StroomStatsStore"
        uuid: "d8a7da4f-ef6d-47e0-b16a-af26367a2798"
        name: "Memory"
      metaDataStreamSize:
      - type: "StroomStatsStore"
        uuid: "3b25d63b-5472-44d0-80e8-8eea94f40f14"
        name: "Meta Data-Stream Size"
      metaDataStreamsReceived:
      - type: "StroomStatsStore"
        uuid: "5535f493-29ae-4ee6-bba6-735aa3104136"
        name: "Meta Data-Streams Received"
      pipelineStreamProcessor:
      - type: "StroomStatsStore"
        uuid: "efd9bad4-0bab-460f-ae98-79e9717deeaf"
        name: "PipelineStreamProcessor"
      refDataStoreEntryCount:
      - type: "StroomStatsStore"
        uuid: "TODO"
        name: "Reference Data Store Entry Count"
      refDataStoreSize:
      - type: "StroomStatsStore"
        uuid: "TODO"
        name: "Reference Data Store Size"
      refDataStoreStreamCount:
      - type: "StroomStatsStore"
        uuid: "TODO"
        name: "Reference Data Store Stream Count"
      searchResultsStoreCount:
      - type: "StroomStatsStore"
        uuid: "TODO"
        name: "Search Results Store Count"
      searchResultsStoreSize:
      - type: "StroomStatsStore"
        uuid: "TODO"
        name: "Search Results Store Size"
      streamTaskQueueSize:
      - type: "StroomStatsStore"
        uuid: "4ce8d6e7-94be-40e1-8294-bf29dd089962"
        name: "Stream Task Queue Size"
      volumes:
      - type: "StroomStatsStore"
        uuid: "60f4f5f0-4cc3-42d6-8fe7-21a7cec30f8e"
        name: "Volumes"
```


#### New `visualisationAsset` Properties

```yaml
appConfig:
  visualisationAsset:
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
    mimetypes:
      apng: "image/apng"
      bmp: "image/bmp"
      css: "text/css"
      gif: "image/jpeg"
      htm: "text/html"
      html: "text/html"
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
  visualisationAssetDb:
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


#### Changes to the `ui` Branch

The values of the following properties have changed, so that the in-application help links point at the right pages of this documentation site.
These are only relevant if you have overridden them, e.g. to point at a locally published copy of the documentation.

| Property | Was | Now |
| --- | --- | --- |
| `stroom.ui.helpUrl` | `https://gchq.github.io/stroom-docs/7.5/docs` | `https://gchq.github.io/stroom-docs/7.13/docs` |
| `stroom.ui.helpSubPathExpressions` | `/user-guide/dashboards/expressions/` | `/reference-section/expressions/` |
| `stroom.ui.helpSubPathQuickFilter` | `/user-guide/finding-things/` | `/user-guide/content/finding-things/` |
| `stroom.ui.helpSubPathStroomQueryLanguage` | `/user-guide/dashboards/stroom-query-language/` | `/user-guide/search/queries/stroom-query-language/` |


### Stroom-Proxy's `config.yml`

#### Changes to the `security` Branch.

The following new properties have been added.

```yaml
appConfig:
  security:
    authentication:
      openId:
        authenticationRequestExtraParams: {}
        requiredAccessTokenType: null
        validateAudience: true
```

The default value of `audienceClaimRequired` has changed from `false` to `true`.

```yaml
appConfig:
  security:
    authentication:
      openId:
        audienceClaimRequired: true
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


<!-- Run on v7.13 -->


### Migration Scripts
 
<!--
#############################################################################################
#                                                                                           #
#  This section is auto-generated by TestListDbMigrations.listDbMigrationsForLatestVersion  #
#                                                                                           #
#############################################################################################
-->
 
For information purposes only, the following are the database migrations that will be run when upgrading to 7.13.0 from the previous minor version.
 
Note, the `legacy` module will run first (if present) then the other module will run in no particular order. 


#### Module `stroom-ai` 
 
##### Script `V07_13_00_001__ai.sql`
 
**Path**: `stroom-ai/stroom-ai-impl-db/src/main/resources/stroom/ai/impl/db/migration/V07_13_00_001__ai.sql`
 
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

--
-- Create the ai_chat table
--
CREATE TABLE IF NOT EXISTS ai_chat (
    id                    int NOT NULL AUTO_INCREMENT,
    version               int NOT NULL,
    create_time_ms        bigint NOT NULL,
    create_user           varchar(255) NOT NULL,
    update_time_ms        bigint NOT NULL,
    update_user           varchar(255) NOT NULL,
    user_uuid             varchar(255) NOT NULL,
    title                 varchar(255) NOT NULL,
    PRIMARY KEY           (id)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

--
-- Create the ai_chat_attachment table
--
CREATE TABLE IF NOT EXISTS ai_chat_attachment (
    id                    int NOT NULL AUTO_INCREMENT,
    fk_ai_chat_id         int NOT NULL,
    create_time_ms        bigint NOT NULL,
    update_time_ms        bigint NOT NULL,
    status                int NOT NULL,
    attachment_type       int NOT NULL,
    description           varchar(255),
    context_json          longtext,
    row_count             int,
    truncated             tinyint(1) NOT NULL DEFAULT 0,
    error_message         varchar(1024),
    PRIMARY KEY           (id),
    CONSTRAINT fk_ai_chat_attachment_chat
    FOREIGN KEY (fk_ai_chat_id) REFERENCES ai_chat (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

--
-- Create the ai_chat_message table
--
CREATE TABLE IF NOT EXISTS ai_chat_message (
    id                    int NOT NULL AUTO_INCREMENT,
    fk_ai_chat_id         int NOT NULL,
    create_time_ms        bigint NOT NULL,
    message_type          int NOT NULL,
    fk_attachment_id      int DEFAULT NULL,
    message               longtext NOT NULL,
    PRIMARY KEY           (id),
    CONSTRAINT fk_ai_chat_message_chat
    FOREIGN KEY (fk_ai_chat_id) REFERENCES ai_chat (id) ON DELETE CASCADE,
    CONSTRAINT fk_ai_chat_message_attachment
    FOREIGN KEY (fk_attachment_id) REFERENCES ai_chat_attachment (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

CREATE INDEX idx_ai_chat_user_uuid ON ai_chat (user_uuid);
CREATE INDEX idx_ai_chat_attachment_chat_id ON ai_chat_attachment (fk_ai_chat_id);
CREATE INDEX idx_ai_chat_message_chat_id ON ai_chat_message (fk_ai_chat_id);


SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set tabstop=4 shiftwidth=4 expandtab:

```
 
 
##### Script `V07_13_00_002__ai_remove_cascade.sql`
 
**Path**: `stroom-ai/stroom-ai-impl-db/src/main/resources/stroom/ai/impl/db/migration/V07_13_00_002__ai_remove_cascade.sql`
 
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

-- Remove CASCADE DELETE from ai_chat_attachment -> ai_chat
ALTER TABLE ai_chat_attachment
    DROP FOREIGN KEY fk_ai_chat_attachment_chat;
ALTER TABLE ai_chat_attachment
    ADD CONSTRAINT fk_ai_chat_attachment_chat
    FOREIGN KEY (fk_ai_chat_id) REFERENCES ai_chat (id);

-- Remove CASCADE DELETE from ai_chat_message -> ai_chat
ALTER TABLE ai_chat_message
    DROP FOREIGN KEY fk_ai_chat_message_chat;
ALTER TABLE ai_chat_message
    ADD CONSTRAINT fk_ai_chat_message_chat
    FOREIGN KEY (fk_ai_chat_id) REFERENCES ai_chat (id);

-- Remove SET NULL from ai_chat_message -> ai_chat_attachment
ALTER TABLE ai_chat_message
    DROP FOREIGN KEY fk_ai_chat_message_attachment;
ALTER TABLE ai_chat_message
    ADD CONSTRAINT fk_ai_chat_message_attachment
    FOREIGN KEY (fk_attachment_id) REFERENCES ai_chat_attachment (id);

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set tabstop=4 shiftwidth=4 expandtab:

```
 
 
#### Module `stroom-annotation` 
 
##### Script `V07_13_00_001__collation_fix.sql`
 
**Path**: `stroom-annotation/stroom-annotation-impl-db/src/main/resources/stroom/annotation/impl/db/migration/V07_13_00_001__collation_fix.sql`
 
```sql
-- ------------------------------------------------------------------------
-- Copyright 2016-2026 Crown Copyright
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

ALTER TABLE annotation_link CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
ALTER TABLE annotation_subscription CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
ALTER TABLE annotation_tag CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
ALTER TABLE annotation_tag_link CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
#### Module `stroom-app` 
 
##### Script `V07_13_00_005__populate_doc_dependency_processor_filters.java`
 
**Path**: `stroom-app/src/main/java/stroom/app/db/migration/V07_13_00_005__populate_doc_dependency_processor_filters.java`
 
It is not possible to display the content here.
The file can be viewed on : {{< external-link "GitHub" "https://github.com/gchq/stroom/tree/7.13/stroom-app/src/main/java/stroom/app/db/migration/V07_13_00_005__populate_doc_dependency_processor_filters.java" >}} 


#### Module `stroom-docstore` 
 
##### Script `V07_13_00_001__split_doc_table.sql`
 
**Path**: `stroom-docstore/stroom-docstore-impl-db/src/main/resources/stroom/docstore/impl/db/migration/V07_13_00_001__split_doc_table.sql`
 
```sql
--
-- Copyright 2016-2025 Crown Copyright
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
--

-- ============================================================================
-- Split doc table into doc (identity) + doc_data (typed content) +
-- doc_audit (operation trail) + doc_data_snapshot (deduplicated snapshots) +
-- doc_audit_data_snapshot (audit-to-snapshot links)
-- ============================================================================

-- stop note level warnings about objects (not)? existing
SET @old_sql_notes=@@sql_notes, sql_notes=0;

-- ---------------------------------------------------------------------------
-- Step 1: Create doc_data table with sparse typed columns
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS doc_data (
    id        bigint NOT NULL AUTO_INCREMENT,
    fk_doc_id bigint NOT NULL,
    ext       varchar(255) NOT NULL,
    data_type tinyint NOT NULL,
    json_data json,
    text_data longtext,
    bin_data  longblob,
    PRIMARY KEY (id),
    UNIQUE KEY doc_data_fk_doc_id_ext_idx (fk_doc_id, ext),
    CONSTRAINT doc_data_fk_doc_id FOREIGN KEY (fk_doc_id) REFERENCES doc (id)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------------------
-- Step 2a: Migrate VALID meta JSON -> doc_data.json_data
-- The meta row references itself (fk_doc_id = doc.id where ext = 'meta')
-- ---------------------------------------------------------------------------
INSERT INTO doc_data (fk_doc_id, ext, data_type, json_data)
SELECT id, ext, 1, CAST(CONVERT(data USING utf8mb4) AS JSON)
FROM doc
WHERE ext = 'meta'
  AND data IS NOT NULL
  AND CONVERT(data USING utf8mb4) IS NOT NULL
  AND JSON_VALID(CONVERT(data USING utf8mb4)) = 1;

-- ---------------------------------------------------------------------------
-- Step 2b: Migrate INVALID meta rows -> doc_data.text_data as fallback
-- These rows had data that could not be parsed as JSON.
-- Stored as text for manual inspection and correction.
-- ---------------------------------------------------------------------------
INSERT INTO doc_data (fk_doc_id, ext, data_type, text_data)
SELECT id, ext, 2, CONVERT(data USING utf8mb4)
FROM doc
WHERE ext = 'meta'
  AND data IS NOT NULL
  AND (CONVERT(data USING utf8mb4) IS NULL
       OR JSON_VALID(CONVERT(data USING utf8mb4)) = 0);

-- ---------------------------------------------------------------------------
-- Step 3a: Migrate VALID content JSON -> doc_data.json_data
-- These are non-meta rows with ext = 'json', joined to the meta row
-- ---------------------------------------------------------------------------
INSERT INTO doc_data (fk_doc_id, ext, data_type, json_data)
SELECT dm.id, d.ext, 1, CAST(CONVERT(d.data USING utf8mb4) AS JSON)
FROM doc d
JOIN doc dm ON dm.type = d.type AND dm.uuid = d.uuid AND dm.ext = 'meta'
WHERE d.ext = 'json'
  AND d.data IS NOT NULL
  AND CONVERT(d.data USING utf8mb4) IS NOT NULL
  AND JSON_VALID(CONVERT(d.data USING utf8mb4)) = 1;

-- ---------------------------------------------------------------------------
-- Step 3b: Migrate INVALID content JSON rows -> doc_data.text_data as fallback
-- ---------------------------------------------------------------------------
INSERT INTO doc_data (fk_doc_id, ext, data_type, text_data)
SELECT dm.id, d.ext, 2, CONVERT(d.data USING utf8mb4)
FROM doc d
JOIN doc dm ON dm.type = d.type AND dm.uuid = d.uuid AND dm.ext = 'meta'
WHERE d.ext = 'json'
  AND d.data IS NOT NULL
  AND (CONVERT(d.data USING utf8mb4) IS NULL
       OR JSON_VALID(CONVERT(d.data USING utf8mb4)) = 0);

-- ---------------------------------------------------------------------------
-- Step 4: Migrate text content -> doc_data.text_data
-- ---------------------------------------------------------------------------
INSERT INTO doc_data (fk_doc_id, ext, data_type, text_data)
SELECT dm.id, d.ext, 2, CONVERT(d.data USING utf8mb4)
FROM doc d
JOIN doc dm ON dm.type = d.type AND dm.uuid = d.uuid AND dm.ext = 'meta'
WHERE d.ext IN ('xsl', 'xsd', 'xml', 'js', 'txt');

-- ---------------------------------------------------------------------------
-- Step 5: Migrate remaining content -> doc_data.bin_data
-- ---------------------------------------------------------------------------
INSERT INTO doc_data (fk_doc_id, ext, data_type, bin_data)
SELECT dm.id, d.ext, 3, d.data
FROM doc d
JOIN doc dm ON dm.type = d.type AND dm.uuid = d.uuid AND dm.ext = 'meta'
WHERE d.ext NOT IN ('meta', 'json', 'xsl', 'xsd', 'xml', 'js', 'txt')
  AND d.ext IS NOT NULL;

-- ---------------------------------------------------------------------------
-- Step 6: Delete all non-meta rows from doc
-- ---------------------------------------------------------------------------
DELETE FROM doc WHERE ext != 'meta' OR ext IS NULL;

-- ---------------------------------------------------------------------------
-- Step 7: Restructure doc table - drop data/ext, add deleted, update indexes
-- ---------------------------------------------------------------------------
ALTER TABLE doc DROP KEY doc_type_uuid_ext_idx;
ALTER TABLE doc DROP KEY doc_type_uuid_idx;
ALTER TABLE doc DROP KEY doc_uuid_idx;
ALTER TABLE doc DROP KEY doc_type_name_uuid_idx;
ALTER TABLE doc DROP COLUMN data;
ALTER TABLE doc DROP COLUMN ext;
ALTER TABLE doc ADD COLUMN deleted bigint DEFAULT NULL;
ALTER TABLE doc ADD UNIQUE KEY doc_uuid_idx (uuid);
ALTER TABLE doc ADD KEY doc_type_name_uuid_idx (type, name, uuid);
ALTER TABLE doc ADD KEY doc_deleted_idx (deleted);

-- ---------------------------------------------------------------------------
-- Step 8: Create doc_audit table
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS doc_audit (
    id          bigint NOT NULL AUTO_INCREMENT,
    fk_doc_id   bigint NOT NULL,
    action      tinyint NOT NULL,
    action_time bigint NOT NULL,
    user_uuid   varchar(255) DEFAULT NULL,
    user_name   varchar(255) DEFAULT NULL,
    PRIMARY KEY (id),
    KEY doc_audit_fk_doc_id_idx (fk_doc_id),
    KEY doc_audit_action_time_idx (action_time),
    CONSTRAINT doc_audit_fk_doc_id FOREIGN KEY (fk_doc_id) REFERENCES doc (id)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------------------
-- Step 9: Create doc_data_snapshot table
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS doc_data_snapshot (
    id        bigint NOT NULL AUTO_INCREMENT,
    fk_doc_id bigint NOT NULL,
    ext       varchar(255) NOT NULL,
    data_type tinyint NOT NULL,
    data_hash bigint NOT NULL,
    json_data json,
    text_data longtext,
    bin_data  longblob,
    PRIMARY KEY (id),
    KEY doc_data_snapshot_dedup_idx (fk_doc_id, ext, data_hash),
    KEY doc_data_snapshot_fk_doc_id_idx (fk_doc_id),
    CONSTRAINT doc_data_snapshot_fk_doc_id FOREIGN KEY (fk_doc_id) REFERENCES doc (id)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------------------
-- Step 10: Create doc_audit_data_snapshot link table
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS doc_audit_data_snapshot (
    id                      bigint NOT NULL AUTO_INCREMENT,
    fk_doc_audit_id         bigint NOT NULL,
    fk_doc_data_snapshot_id bigint NOT NULL,
    PRIMARY KEY (id),
    KEY doc_audit_data_snapshot_fk_doc_audit_id_idx (fk_doc_audit_id),
    KEY doc_audit_data_snapshot_fk_doc_data_snapshot_id_idx (fk_doc_data_snapshot_id),
    CONSTRAINT doc_audit_data_snapshot_fk_doc_audit_id
        FOREIGN KEY (fk_doc_audit_id) REFERENCES doc_audit (id),
    CONSTRAINT doc_audit_data_snapshot_fk_doc_data_snapshot_id
        FOREIGN KEY (fk_doc_data_snapshot_id) REFERENCES doc_data_snapshot (id)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------------------
-- Step 11: Seed initial audit entries from existing meta JSON
-- The user_uuid is NULL because the current meta JSON only stores user
-- display names, not their UUIDs.
-- ---------------------------------------------------------------------------

-- CREATE entry from createTimeMs / createUser
INSERT INTO doc_audit (fk_doc_id, action, action_time, user_uuid, user_name)
SELECT d.id, 1,
       COALESCE(JSON_VALUE(dd.json_data, '$.createTimeMs' RETURNING SIGNED), 0),
       NULL,
       JSON_VALUE(dd.json_data, '$.createUser' RETURNING CHAR(255))
FROM doc d
JOIN doc_data dd ON dd.fk_doc_id = d.id AND dd.ext = 'meta'
WHERE dd.json_data IS NOT NULL;

-- UPDATE entry from updateTimeMs / updateUser (only if updateTimeMs is set)
INSERT INTO doc_audit (fk_doc_id, action, action_time, user_uuid, user_name)
SELECT d.id, 2,
       COALESCE(JSON_VALUE(dd.json_data, '$.updateTimeMs' RETURNING SIGNED), 0),
       NULL,
       JSON_VALUE(dd.json_data, '$.updateUser' RETURNING CHAR(255))
FROM doc d
JOIN doc_data dd ON dd.fk_doc_id = d.id AND dd.ext = 'meta'
WHERE dd.json_data IS NOT NULL
  AND JSON_VALUE(dd.json_data, '$.updateTimeMs' RETURNING SIGNED) IS NOT NULL;

-- Reset to the original value
SET SQL_NOTES=@OLD_SQL_NOTES;

```
 
 
##### Script `V07_13_00_002__add_version_column.sql`
 
**Path**: `stroom-docstore/stroom-docstore-impl-db/src/main/resources/stroom/docstore/impl/db/migration/V07_13_00_002__add_version_column.sql`
 
```sql
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Copyright 2024-2026 Crown Copyright
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
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Add version column for optimistic concurrency control.
-- The version UUID is currently embedded inside the meta JSON blob ($.version).
-- Extract it to a dedicated column so the DB can enforce version matching atomically.

-- stop note level warnings about objects (not)? existing
SET @old_sql_notes=@@sql_notes, sql_notes=0;

-- Step 1: Add the column with a default that lets us identify unpopulated rows.
ALTER TABLE doc ADD COLUMN version varchar(36) NOT NULL DEFAULT '';

-- Step 2: Populate from existing meta JSON.
-- Populate from existing meta JSON stored in doc_data.json_data.
UPDATE doc d
JOIN doc_data dd ON dd.fk_doc_id = d.id AND dd.ext = 'meta'
SET d.version = JSON_UNQUOTE(JSON_EXTRACT(dd.json_data, '$.version'))
WHERE dd.json_data IS NOT NULL
  AND JSON_UNQUOTE(JSON_EXTRACT(dd.json_data, '$.version')) IS NOT NULL;

-- Step 3: Fallback — generate a UUID for rows with missing/invalid JSON
-- (e.g. those with meta stored in text_data rather than json_data).
UPDATE doc
SET version = UUID()
WHERE version = '';

-- Reset to the original value
SET SQL_NOTES=@OLD_SQL_NOTES;

```
 
 
##### Script `V07_13_00_003__doc_dependency.sql`
 
**Path**: `stroom-docstore/stroom-docstore-impl-db/src/main/resources/stroom/docstore/impl/db/migration/V07_13_00_003__doc_dependency.sql`
 
```sql
--
-- Copyright 2016-2025 Crown Copyright
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
--

-- ============================================================================
-- Tracks document-to-document dependency edges.
-- Each row means: the doc identified by (from_type, from_uuid) depends on
-- (to_type, to_uuid).
--
-- Uses bare UUIDs (no FK to doc table) because:
--   - Dependency targets may reference docs that don't exist yet (broken deps)
--   - Pseudo-refs (e.g. Annotations, SearchableIndex) are not in the doc table
--   - Non-doc entities (e.g. ProcessorFilter) are not in the doc table
-- ============================================================================

-- stop note level warnings about objects (not)? existing
SET @old_sql_notes=@@sql_notes, sql_notes=0;

CREATE TABLE IF NOT EXISTS doc_dependency (
    id          BIGINT NOT NULL AUTO_INCREMENT,
    from_type   VARCHAR(255) NOT NULL,
    from_uuid   VARCHAR(255) NOT NULL,
    from_name   VARCHAR(255) NOT NULL DEFAULT '',
    to_type     VARCHAR(255) NOT NULL,
    to_uuid     VARCHAR(255) NOT NULL,
    to_name     VARCHAR(255) NOT NULL DEFAULT '',
    PRIMARY KEY (id),
    -- A given (from, to) edge should be unique
    UNIQUE KEY  doc_dependency_from_to (from_uuid, to_uuid),
    -- Query pattern: "what does doc X depend on?"
    KEY         doc_dependency_from_uuid (from_uuid),
    -- Query pattern: "what depends on doc X?" (for safe-delete, dependants view)
    KEY         doc_dependency_to_uuid (to_uuid)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- Reset to the original value
SET sql_notes=@old_sql_notes;

```
 
 
##### Script `V07_13_00_004__populate_doc_dependency.java`
 
**Path**: `stroom-docstore/stroom-docstore-impl-db/src/main/java/stroom/docstore/impl/db/migration/V07_13_00_004__populate_doc_dependency.java`
 
It is not possible to display the content here.
The file can be viewed on : {{< external-link "GitHub" "https://github.com/gchq/stroom/tree/7.13/stroom-docstore/stroom-docstore-impl-db/src/main/java/stroom/docstore/impl/db/migration/V07_13_00_004__populate_doc_dependency.java" >}} 


#### Module `stroom-security` 
 
##### Script `V07_13_00_005__json_web_key.sql`
 
**Path**: `stroom-security/stroom-security-identity-db/src/main/resources/stroom/security/identity/db/migration/V07_13_00_005__json_web_key.sql`
 
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

-- Remove the old defunct test JSON web key inserted by V07_00_00_040__json_web_key_seed_data.sql.
DELETE FROM json_web_key
WHERE key_id = '1ec7a983-317d-46ce-ae93-ce42bc217e52';

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_13_00_010__account_self_service_unlock.sql`
 
**Path**: `stroom-security/stroom-security-identity-db/src/main/resources/stroom/security/identity/db/migration/V07_13_00_010__account_self_service_unlock.sql`
 
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

-- Supports self service account unlocking for the internal identity provider, see GH-5656.

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_13_00_010__account_self_service_unlock;

DELIMITER $$

CREATE PROCEDURE V07_13_00_010__account_self_service_unlock ()
BEGIN
    DECLARE object_count integer;
    DECLARE duplicate_count integer;

    -- The SHA-256 hash of the secret in the most recently issued password reset link for the account.
    -- The link is an opaque random string; only its hash is held here, so the link cannot be recovered
    -- from the database. Issuing a new link replaces this, so an earlier one stops working, and it is
    -- cleared whenever the password is set, so a link cannot be used twice or survive a password change.
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'account'
    AND column_name = 'reset_token_hash';

    IF object_count = 0 THEN
        ALTER TABLE account ADD COLUMN reset_token_hash varchar(64) DEFAULT NULL;
    END IF;

    -- When the current password reset link expires, as epoch millis. Held explicitly rather than derived
    -- so that changing the configured link lifetime does not retroactively change links already issued.
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'account'
    AND column_name = 'reset_token_expiry_ms';

    IF object_count = 0 THEN
        ALTER TABLE account ADD COLUMN reset_token_expiry_ms bigint DEFAULT NULL;
    END IF;

    -- When a password reset email was last requested for this account, used to stop the unauthenticated
    -- reset endpoint being used to send mail to someone's inbox over and over. Held against the account
    -- rather than in a table of its own so that it is bounded by the number of accounts, and against the
    -- database rather than in memory so that the limit holds across a cluster.
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'account'
    AND column_name = 'reset_email_requested_ms';

    IF object_count = 0 THEN
        ALTER TABLE account ADD COLUMN reset_email_requested_ms bigint DEFAULT NULL;
    END IF;

    -- A blank email address is no email address at all, and is held as NULL. Held as an empty string it
    -- would be a value like any other, so the second account left blank would clash with the first under
    -- the unique index below, where any number of accounts may have no address. Earlier versions wrote
    -- blanks through from the account screen, so normalise what is already stored before indexing it.
    UPDATE account SET email = NULL WHERE TRIM(email) = '';

    -- 'Forgot password' finds the account to reset by its email address, so an address must identify at
    -- most one account. An account may still have no email address at all, in which case it simply
    -- cannot be reset by email; a UNIQUE index permits any number of NULLs.
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.statistics
    WHERE table_schema = database()
    AND table_name = 'account'
    AND index_name = 'account_email_idx';

    IF object_count = 0 THEN
        -- Adding the index would fail with a bare duplicate key error, naming only the first clash, and
        -- only after the columns above had been added. Check first so that the operator is told what is
        -- wrong rather than being shown a key name.
        SELECT COUNT(1)
        INTO duplicate_count
        FROM (
            SELECT email
            FROM account
            WHERE email IS NOT NULL
            GROUP BY email
            HAVING COUNT(1) > 1
        ) duplicates;

        IF duplicate_count > 0 THEN
            SET @message_text = CONCAT(
                'Cannot make account.email unique: ', duplicate_count,
                ' email addresses are each used by more than one account');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @message_text;
        END IF;

        ALTER TABLE account ADD UNIQUE KEY account_email_idx (email);
    END IF;
END $$

DELIMITER ;

CALL V07_13_00_010__account_self_service_unlock;

DROP PROCEDURE IF EXISTS V07_13_00_010__account_self_service_unlock;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_13_00_015__drop_oauth_client_uri_pattern.sql`
 
**Path**: `stroom-security/stroom-security-identity-db/src/main/resources/stroom/security/identity/db/migration/V07_13_00_015__drop_oauth_client_uri_pattern.sql`
 
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

-- Drop the unused oauth_client.uri_pattern column. redirect_uri validation is an exact match against
-- the application's public root and does not use this column.

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_13_00_015__drop_oauth_client_uri_pattern;

DELIMITER $$

CREATE PROCEDURE V07_13_00_015__drop_oauth_client_uri_pattern ()
BEGIN
    DECLARE object_count integer;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'oauth_client'
    AND column_name = 'uri_pattern';

    IF object_count = 1 THEN
        ALTER TABLE oauth_client DROP COLUMN uri_pattern;
    END IF;
END $$

DELIMITER ;

CALL V07_13_00_015__drop_oauth_client_uri_pattern;

DROP PROCEDURE IF EXISTS V07_13_00_015__drop_oauth_client_uri_pattern;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_13_00_020__account_lockout_expiry.sql`
 
**Path**: `stroom-security/stroom-security-identity-db/src/main/resources/stroom/security/identity/db/migration/V07_13_00_020__account_lockout_expiry.sql`
 
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

-- Supports time-limited (auto-expiring) account lockout for the internal identity provider.

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_13_00_020__account_lockout_expiry;

DELIMITER $$

CREATE PROCEDURE V07_13_00_020__account_lockout_expiry ()
BEGIN
    DECLARE object_count integer;

    -- When a failure-driven lock auto-expires, as epoch millis. A lock set by repeated failed logins
    -- carries an expiry so that it clears itself after a configured period, rather than needing an
    -- administrator. NULL means the lock (if any) never expires: this is the case for a lock set
    -- manually by an administrator, and is the default for a freshly created account.
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'account'
    AND column_name = 'locked_until_ms';

    IF object_count = 0 THEN
        ALTER TABLE account ADD COLUMN locked_until_ms bigint DEFAULT NULL;
    END IF;
END $$

DELIMITER ;

CALL V07_13_00_020__account_lockout_expiry;

DROP PROCEDURE IF EXISTS V07_13_00_020__account_lockout_expiry;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_13_00_025__oauth_token.sql`
 
**Path**: `stroom-security/stroom-security-identity-db/src/main/resources/stroom/security/identity/db/migration/V07_13_00_025__oauth_token.sql`
 
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

--
-- Create the oauth_token table: an inventory of the tokens the INTERNAL IdP has minted, so that they can
-- be listed and revoked before they expire. Externally minted tokens never get a row here - their
-- revocation is the external IdP's business.
--
-- Deliberately NOT called `token`. A legacy `token` table (V07_00_00_025) is dropped by a migration in a
-- DIFFERENT module, stroom-security-impl-db/V07_02_00_115__drop_token_table.sql, which reaches across the
-- schema boundary because cross-module migration order is non-deterministic. That drop is guarded only by
-- an existence check, so it cannot tell a brand new table from the legacy one - reusing the name would
-- mean silent data loss on whichever install orderings ran identity's migrations first.
--
CREATE TABLE IF NOT EXISTS oauth_token (
    id              int NOT NULL AUTO_INCREMENT,
    version         int NOT NULL,
    create_time_ms  bigint NOT NULL,
    create_user     varchar(255) NOT NULL,
    update_time_ms  bigint NOT NULL,
    update_user     varchar(255) NOT NULL,
    -- ACCESS | ID | REFRESH. A plain discriminator, NOT an FK to the legacy token_type table.
    token_type      varchar(10) NOT NULL,
    -- The JWT id, for ACCESS/ID rows only. Refresh tokens are opaque random strings, not JWTs, and have
    -- no jti - which is why this table has a surrogate id PK rather than keying on jti.
    jti             varchar(255) DEFAULT NULL,
    -- SHA-256 of the opaque refresh token, for REFRESH rows only. The redeemable credential is looked up
    -- by presentation and must never be stored in the clear.
    token_hash      varchar(255) DEFAULT NULL,
    -- A subject string, NOT an FK to account.id: service and external subjects have no account row.
    subject_id      varchar(255) NOT NULL,
    client_id       varchar(255) DEFAULT NULL,
    -- Rotation lineage for refresh tokens (grant id for access/id), so reuse can revoke a whole family.
    family_id       varchar(255) DEFAULT NULL,
    -- The scope granted at authentication, carried forward onto every successor token in the family.
    -- Needed to mint the successor when a refresh token is redeemed.
    scope           longtext,
    -- When the end user actually authenticated. Carried forward so a refreshed id token reports the
    -- original login time rather than the time of the refresh.
    auth_time_ms    bigint DEFAULT NULL,
    issued_ms       bigint NOT NULL,
    expires_ms      bigint NOT NULL,
    -- Set when a refresh token is redeemed. The row is KEPT until it expires rather than being deleted,
    -- because a consumed-but-unexpired row is what makes a replay of that token detectable for the whole of
    -- its lifetime.
    consumed_ms     bigint DEFAULT NULL,
    revoked         tinyint NOT NULL DEFAULT '0',
    revoked_ms      bigint DEFAULT NULL,
    revoked_by      varchar(255) DEFAULT NULL,
    PRIMARY KEY (id),
    -- Two nullable natural keys, exactly one of which is populated per token_type.
    UNIQUE KEY oauth_token_jti_idx (jti),
    UNIQUE KEY oauth_token_token_hash_idx (token_hash),
    -- Admin grouping and revoke-by-user.
    KEY oauth_token_subject_id_idx (subject_id),
    -- Family revocation on refresh reuse.
    KEY oauth_token_family_id_idx (family_id),
    -- Drives both the read-time `expires_ms > now` predicate and the purge job.
    KEY oauth_token_expires_ms_idx (expires_ms),
    -- The revoked-and-still-live lookup that builds the verify path's denylist. `revoked` leads because it
    -- is the selective column - almost no rows are revoked - whereas `expires_ms > now` matches nearly
    -- every row and so cannot narrow anything on its own.
    KEY oauth_token_revoked_idx (revoked, expires_ms)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_13_00_030__drop_processing_account.sql`
 
**Path**: `stroom-security/stroom-security-identity-db/src/main/resources/stroom/security/identity/db/migration/V07_13_00_030__drop_processing_account.sql`
 
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

-- Removes account.processing_account, which nothing sets and which grants nothing.
--
-- The flag marked an account as a non-interactive identity: hidden from the account list and search,
-- and refused both interactive sign in and password reset. No code path ever set it. Every migration
-- that populates the table writes false, and the create request carries no field for it, so the only
-- writer was an account update accepting the whole account object from the caller - which no longer
-- happens now that an update carries only the fields being changed.
--
-- It is also not how either machine identity in Stroom works. The internal processing user holds a
-- short lived self issued token and has no account row at all, and a data sender authenticating with
-- a client certificate is identified by the certificate's common name, deliberately without an account.

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_13_00_030__drop_processing_account;

DELIMITER $$

CREATE PROCEDURE V07_13_00_030__drop_processing_account ()
BEGIN
    DECLARE object_count integer;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'account'
    AND column_name = 'processing_account';

    IF object_count = 1 THEN
        -- Fail closed before the column goes. Such an account is currently barred from signing in, so
        -- dropping the column without this would silently turn it into an ordinary, usable account.
        -- Disabling is the control that expresses "barred" now, and unlike the flag an administrator
        -- can see it. This is expected to match no rows on any database that has not been hand edited.
        UPDATE account
        SET enabled = 0
        WHERE processing_account = 1;

        ALTER TABLE account DROP COLUMN processing_account;
    END IF;
END $$

DELIMITER ;

CALL V07_13_00_030__drop_processing_account;

DROP PROCEDURE IF EXISTS V07_13_00_030__drop_processing_account;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```
 
 
##### Script `V07_13_00_035__account_lock_state.sql`
 
**Path**: `stroom-security/stroom-security-identity-db/src/main/resources/stroom/security/identity/db/migration/V07_13_00_035__account_lock_state.sql`
 
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

-- Reduces the account lockout to the one thing it is for: blunting repeated wrong passwords.
--
--   locked          )
--   locked_until_ms ) -> failure_locked_ms
--   login_failures    -> failure_count
--
-- Three changes, in one migration because they are one idea.
--
-- Naming. Locking is not an administrative act. An administrator prevents an account being used by
-- disabling it, and only ever unlocks - and then only when the lock will not clear itself and self service
-- unlock is unavailable. Naming these columns as a group makes it harder to read them as general state.
--
-- Meaning. The old column held when the lock was due to end, worked out when the lock was applied, so it
-- was the configured duration already spent. Changing that duration then had no effect on any lock already
-- in force. Holding the moment the lock was applied and adding the configured duration at the point of
-- asking makes the setting mean what an administrator expects, for existing locks as well as new ones. A
-- duration of zero now means the lock does not lapse - including for locks already held, so setting it
-- during an incident makes every one of them permanent until an administrator releases it.
--
-- Shape. Once the column holds when the lock was applied, the boolean says nothing the timestamp does not:
-- a lock exists exactly when there is a time it was applied. Two columns that must agree are two columns
-- that can disagree, and a writer that clears one without the other leaves a lock that no longer means what
-- it says. One column cannot disagree with itself.

-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

DROP PROCEDURE IF EXISTS V07_13_00_035__account_lock_state;

DELIMITER $$

CREATE PROCEDURE V07_13_00_035__account_lock_state ()
BEGIN
    DECLARE object_count integer;

    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'account'
    AND column_name = 'locked';

    IF object_count = 1 THEN

        -- Carry over locks an administrator applied by hand, while `locked` still means "locked for any
        -- reason". A lock with no end time is the best available reading of that: a failure lock normally
        -- carries one. Disabling is the control that expresses an administrator barring an account now, and
        -- unlike a permanent lock it is visible for what it is.
        --
        -- This cannot tell a hand applied lock from a failure lock in a deployment configured with a zero
        -- lock duration, where failure locks are also stored with no end time. Those accounts become
        -- disabled. That fails closed - access stays barred until an administrator acts - but it is visible,
        -- and such deployments should expect to re-enable deliberately after upgrading.
        UPDATE account
        SET enabled = 0,
            locked = 0
        WHERE locked = 1
        AND locked_until_ms IS NULL;

        ALTER TABLE account
            CHANGE COLUMN locked_until_ms failure_locked_ms bigint DEFAULT NULL,
            CHANGE COLUMN login_failures failure_count int NOT NULL DEFAULT '0';

        -- When each surviving lock was applied cannot be recovered: the old column held only when it was
        -- due to end, and the duration that produced it is configuration rather than data. Treat them as
        -- locked now, so each serves at most one further full duration. That errs towards keeping an
        -- account locked rather than releasing one early, and it is bounded.
        UPDATE account
        SET failure_locked_ms = UNIX_TIMESTAMP() * 1000
        WHERE locked = 1;

        -- No lock means no lock time. Any end time left on an unlocked account is stale and must go, or the
        -- single column would report a lock that is not there.
        UPDATE account
        SET failure_locked_ms = NULL
        WHERE locked = 0;

        ALTER TABLE account
            DROP COLUMN locked;
    END IF;
END $$

DELIMITER ;

CALL V07_13_00_035__account_lock_state;

DROP PROCEDURE IF EXISTS V07_13_00_035__account_lock_state;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```

