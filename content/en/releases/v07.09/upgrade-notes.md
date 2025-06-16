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

#### Cache Config

A new property `statisticsMode` has been added to the standard cache config structure as used by all caches.
This controls whether and how cache statistics should be record.
Possible values are:
* `NONE` - Do not capture any statistics on cache usage.
    This means no statistics will be available for this cache in the Stroom UI.
    Capturing statistics has a minor performance penalty.
* `INTERNAL` - Uses the internal mechanism for capturing statistics. 
    This is only suitable for Stroom as these can be viewed through the UI.
* `DROPWIZARD_METRICS` - Uses Dropwizard Metrics for capturing statistics.
    This allows the cache stats to be accessed via tools such as Graphite/Collectd in addition to the Stroom UI.
    This adds a very slight performance overhead over `INTERNAL`.
    This is suitable for both Stroom and Stroom-Proxy.


#### Annotations

The following standard cache configuration blocks have been added for annotations, along with retention configuration.

```yaml
appConfig:
  annotation:
    annotationFeedCache:
      expireAfterAccess: "PT10M"
      expireAfterWrite: null
      maximumSize: 1000
      refreshAfterWrite: null
      statisticsMode: "INTERNAL"
    annotationTagCache:
      expireAfterAccess: "PT10M"
      expireAfterWrite: null
      maximumSize: 1000
      refreshAfterWrite: null
      statisticsMode: "INTERNAL"
    defaultRetentionPeriod: "5y"
    physicalDeleteAge: "P7D"
```


#### Content Auto-Generation

A new branch `autoContentCreation` has been added for content auto-generation, [see]({{< relref "./preview-features/#content-auto-generation" >}})

```yaml
appConfig:
  autoContentCreation:
    additionalGroupTemplate: "grp-${accountid}-sandbox"
    createAsSubjectId: "Administrators"
    createAsType: "GROUP"
    destinationExplorerPathTemplate: "/Feeds/${accountid}"
    enabled: false
    groupTemplate: "grp-${accountid}"
    templateMatchFields:
    - "accountid"
    - "accountname"
    - "component"
    - "feed"
    - "format"
    - "schema"
    - "schemaversion"
```

#### Data Formats

A new property has been added to control the list of data format names that can be assigned to a feed.
The property must include at least the values below.

```yaml
appConfig:
  data:
    meta:
      dataFormats:
      - "FIXED_WIDTH_NO_HEADER"
      - "INI"
      - "CSV"
      - "JSON"
      - "TEXT"
      - "XML_FRAGMENT"
      - "YAML"
      - "PSV_NO_HEADER"
      - "PSV"
      - "CSV_NO_HEADER"
      - "XML"
      - "TSV"
      - "SYSLOG"
      - "TSV_NO_HEADER"
      - "FIXED_WIDTH"
      - "TOML"
```


#### Data Receipt

The following properties have been added.

```yaml
appConfig:
  receive:
    allowedCertificateProviders: []
    authenticatedDataFeedKeyCache:
      expireAfterAccess: null
      expireAfterWrite: "PT5M"
      maximumSize: 1000
      refreshAfterWrite: null
      statisticsMode: "DROPWIZARD_METRICS"
    authenticationRequired: true
    dataFeedKeyOwnerMetaKey: "AccountId"
    dataFeedKeysDir: "data_feed_keys"
    enabledAuthenticationTypes:
    - "CERTIFICATE"
    - "TOKEN"
    - "DATA_FEED_KEY"
    feedNameGenerationEnabled: false
    feedNameGenerationMandatoryHeaders:
    - "AccountId"
    - "Component"
    - "Format"
    - "Schema"
    feedNameTemplate: "${accountid}-${component}-${format}-${schema}"
    x509CertificateDnHeader: "X-SSL-CLIENT-S-DN"
    x509CertificateHeader: "X-SSL-CERT"
```

The following properties have been removed.

```yaml
appConfig:
  receive:
    tokenAuthenticationEnabled: false
    certificateAuthenticationEnabled: true
```


#### Content Security Policy

The default value for the `contentSecurityPolicy` property has changed from this:

```yaml
appConfig:
  security:
    webContent:
      contentSecurityPolicy: "default-src 'self'; script-src 'self' 'unsafe-eval'\
        \ 'unsafe-inline'; img-src 'self' data:; style-src 'self' 'unsafe-inline';\
        \ connect-src 'self' wss:; frame-ancestors 'self';"
```

To this:

```yaml
appConfig:
  security:
    webContent:
      contentSecurityPolicy: "default-src 'self'; script-src 'self' 'unsafe-eval'\
        \ 'unsafe-inline'; img-src 'self' data:; style-src 'self' 'unsafe-inline';\
        \ frame-ancestors 'self';"
```


### Stroom-Proxy's `config.yml`

#### Cache Config

A new property `statisticsMode` has been added to the standard cache config structure as used by all caches.
This controls whether and how cache statistics should be record.
Possible values are:
* `NONE` - Do not capture any statistics on cache usage.
    This means no statistics will be available for this cache in the Stroom UI.
    Capturing statistics has a minor performance penalty.
* `DROPWIZARD_METRICS` - Uses Dropwizard Metrics for capturing statistics.
    This allows the cache stats to be accessed via tools such as Graphite/Collectd in addition to the Stroom UI.
    This adds a very slight performance overhead over `INTERNAL`.
    This is suitable for both Stroom and Stroom-Proxy.


#### Aggregation

The default aggregation frequency has changed from `PT1M` to `PT10M`.

```yaml
proxyConfig:
  aggregator:
    aggregationFrequency: "PT10M"
```

The property `maxOpenFiles` has been replaced with a standard cache configuration branch.

```yaml
proxyConfig:
  aggregator:
    openFilesCache:
      expireAfterAccess: null
      expireAfterWrite: null
      maximumSize: 100
      refreshAfterWrite: null
      statisticsMode: "DROPWIZARD_METRICS"
```


#### Data Receipt

Proxy uses the same data receipt config structure as Stroom, so see [above]({{< relref "#data-receipt" >}}) for details of the changes.





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

For information purposes only, the following are the database migrations that will be run when upgrading to 7.9.0 from the previous minor version.

Note, the `legacy` module will run first (if present) then the other module will run in no particular order.

#### Module `stroom-annotation`

##### Script `V07_09_00_001__annotation2.sql`

**Path**: `stroom-annotation/stroom-annotation-impl-db/src/main/resources/stroom/annotation/impl/db/migration/V07_09_00_001__annotation2.sql`

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

CREATE TABLE IF NOT EXISTS annotation_tag (
  id                    int(11) NOT NULL AUTO_INCREMENT,
  uuid                  varchar(255) NOT NULL,
  type_id               tinyint NOT NULL,
  name                  varchar(255) NOT NULL,
  style_id              tinyint DEFAULT NULL,
  deleted               tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY           (id),
  UNIQUE KEY            `annotation_tag_type_id_name_idx` (`type_id`, `name`),
  UNIQUE KEY            `annotation_tag_uuid_idx` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS annotation_tag_link (
  id                    bigint(20) NOT NULL AUTO_INCREMENT,
  fk_annotation_id      bigint(20) NOT NULL,
  fk_annotation_tag_id  int(11) NOT NULL,
  PRIMARY KEY           (id),
  UNIQUE KEY            fk_annotation_id_fk_annotation_tag_id (fk_annotation_id, fk_annotation_tag_id),
  CONSTRAINT            annotation_tag_link_fk_annotation_id FOREIGN KEY (fk_annotation_id) REFERENCES annotation (id),
  CONSTRAINT            annotation_tag_link_fk_annotation_tag_id FOREIGN KEY (fk_annotation_tag_id) REFERENCES annotation_tag (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS annotation_link (
  id                    bigint(20) NOT NULL AUTO_INCREMENT,
  fk_annotation_src_id  bigint(20) NOT NULL,
  fk_annotation_dst_id  bigint(20) NOT NULL,
  PRIMARY KEY           (id),
  UNIQUE KEY            fk_annotation_src_id_fk_annotation_dst_id (fk_annotation_src_id, fk_annotation_dst_id),
  CONSTRAINT            annotation_link_fk_annotation_src_id FOREIGN KEY (fk_annotation_src_id) REFERENCES annotation (id),
  CONSTRAINT            annotation_link_fk_annotation_dst_id FOREIGN KEY (fk_annotation_dst_id) REFERENCES annotation (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS annotation_subscription (
  id                    bigint(20) NOT NULL AUTO_INCREMENT,
  fk_annotation_id      bigint(20) NOT NULL,
  user_uuid             varchar(255) NOT NULL,
  PRIMARY KEY           (id),
  UNIQUE KEY            fk_annotation_id_user_uuid (fk_annotation_id, user_uuid),
  CONSTRAINT            annotation_subscription_fk_annotation_id FOREIGN KEY (fk_annotation_id) REFERENCES annotation (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `annotation_feed` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `annotation_feed_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

DROP PROCEDURE IF EXISTS V07_09_00_001_annotation;

DELIMITER $$

CREATE PROCEDURE V07_09_00_001_annotation ()
BEGIN
    DECLARE object_count integer;

    --
    -- Add logical delete
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation'
    AND column_name = 'deleted';

    IF object_count = 0 THEN
        ALTER TABLE `annotation` ADD COLUMN `deleted` tinyint NOT NULL DEFAULT '0';
    END IF;

    --
    -- Add description
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation'
    AND column_name = 'description';

    IF object_count = 0 THEN
        ALTER TABLE `annotation`
        ADD COLUMN `description` longtext;
    END IF;

    --
    -- Add data retention time
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation'
    AND column_name = 'retention_time';

    IF object_count = 0 THEN
        ALTER TABLE `annotation` ADD COLUMN `retention_time` bigint(20) DEFAULT NULL;
    END IF;

    --
    -- Add data retention unit
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation'
    AND column_name = 'retention_unit';

    IF object_count = 0 THEN
        ALTER TABLE `annotation` ADD COLUMN `retention_unit` tinyint DEFAULT NULL;
    END IF;

    --
    -- Add data retention until
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation'
    AND column_name = 'retain_until_ms';

    IF object_count = 0 THEN
        ALTER TABLE `annotation`
        ADD COLUMN `retain_until_ms` bigint DEFAULT NULL;
    END IF;

    --
    -- Add parent id
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation'
    AND column_name = 'parent_id';

    IF object_count = 0 THEN
        ALTER TABLE `annotation`
        ADD COLUMN `parent_id` bigint(20) DEFAULT NULL;
    END IF;

    --
    -- Add entry type id
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation_entry'
    AND column_name = 'type_id';

    IF object_count = 0 THEN
        ALTER TABLE annotation_entry ADD COLUMN type_id tinyint NOT NULL;
        UPDATE annotation_entry SET type_id = 0 WHERE type = "Title";
        UPDATE annotation_entry SET type_id = 1 WHERE type = "Subject";
        UPDATE annotation_entry SET type_id = 2 WHERE type = "Status";
        UPDATE annotation_entry SET type_id = 3 WHERE type = "Assigned";
        UPDATE annotation_entry SET type_id = 4 WHERE type = "Comment";
        UPDATE annotation_entry SET type_id = 5 WHERE type = "Link";
        UPDATE annotation_entry SET type_id = 6 WHERE type = "Unlink";
        ALTER TABLE annotation_entry DROP COLUMN type;
    END IF;

    --
    -- Add entry logical delete
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation_entry'
    AND column_name = 'deleted';

    IF object_count = 0 THEN
        ALTER TABLE `annotation_entry` ADD COLUMN `deleted` tinyint NOT NULL DEFAULT '0';
    END IF;

    --
    -- Remove status
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation'
    AND column_name = 'status';

    IF object_count > 0 THEN
        INSERT INTO annotation_tag (uuid, type_id, name, style_id, deleted)
        SELECT uuid(), 0, status, null, 0
        FROM annotation
        WHERE status NOT IN (SELECT name FROM annotation_tag WHERE type_id = 0)
        GROUP BY status;

        INSERT INTO annotation_tag_link (fk_annotation_id, fk_annotation_tag_id)
        SELECT a.id, at.id
        FROM annotation a
        JOIN annotation_tag at ON (a.status = at.name AND at.type_id = 0)
        WHERE a.id NOT IN (SELECT fk_annotation_id FROM annotation_tag_link);

        ALTER TABLE `annotation` DROP COLUMN `status`;
    END IF;

    --
    -- Remove comment
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation'
    AND column_name = 'comment';

    IF object_count > 0 THEN
        ALTER TABLE `annotation` DROP COLUMN `comment`;
    END IF;

    --
    -- Remove history
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation'
    AND column_name = 'history';

    IF object_count > 0 THEN
        ALTER TABLE `annotation` DROP COLUMN `history`;
    END IF;

    --
    -- Add feed
    --
    SELECT COUNT(1)
    INTO object_count
    FROM information_schema.columns
    WHERE table_schema = database()
    AND table_name = 'annotation_data_link'
    AND column_name = 'feed_id';

    IF object_count = 0 THEN
        ALTER TABLE `annotation_data_link` ADD COLUMN `feed_id` int DEFAULT NULL;
    END IF;

END $$

DELIMITER ;

CALL V07_09_00_001_annotation;

DROP PROCEDURE IF EXISTS V07_09_00_001_annotation;

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set shiftwidth=4 tabstop=4 expandtab:

```

