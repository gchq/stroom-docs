---
title: "Upgrade Notes"
linkTitle: "Upgrade Notes"
weight: 40
date: 2025-09-23
tags: 
description: >
  Required actions and information relating to upgrading to Stroom version 7.10.
---

{{% warning %}}
Please read this section carefully in case any of it is relevant to your Stroom/Stroom-Proxy instance.
{{% /warning %}}


## Java Version

Stroom v7.10 requires Java 21.
This is the same java version as Stroom v7.9.
Ensure the Stroom and Stroom-Proxy hosts are running the latest patch release of Java v21.


## Configuration File Changes

<!--
Check changes using something like this (run from an up-to-date stroom repo):
old_ver=7.9
new_ver=7.10
git diff origin/${old_ver}..origin/${new_ver} stroom-config/stroom-config-app/src/test/resources/stroom/config/app/expected.yaml
git diff origin/${old_ver}..origin/${new_ver} stroom-proxy/stroom-proxy-app/src/test/resources/stroom/dist/proxy-expected.yaml
-->


### Stroom's `config.yml`

#### Git Repo

A new branch has been added to the config for configuring the directory used to store the local git repositories.

```yaml
appConfig:
  gitRepo:
    localDir: "git_repo"
```

#### X509 Certificate Extraction

A new property `x509CertificateDnFormat` has been added to define the format of the certificate Distinguished Name (DN).
Valid values are `LDAP` which is `,` delimited or `OPEN_SSL` which is `/` delimited.
The default is `LDAP`.

```yaml
appConfig:
  receive:
    x509CertificateDnFormat: "LDAP"
```

#### Open ID Connect Authentication

The property `stroom.security.authentication.openid.validateAudience` has been replaced by two new properties for controlling validation of the `aud` claim.
The `allowedAudiences` property allows you to supply a list of valid values for the `aud` claim.
If this list is not empty then if the `aud` claim is present, Stroom will ensure that it matches one of these values.

If `audienceClaimRequired` is set to `true` then Stroom will fail authentication if the `aud` claim is not present.

The new `fullNameClaimTemplate` lets you define a template for extracting the user's full name from the claims in a token.
For example, the template could be `${firstname} ${lastName}` if those two claims are available.
If the named claim is not present then the placeholder will be replaced by an empty string.

The template syntax for `publicKeyUriPattern` has changed from positional place holders (e.g. `https://public-keys.auth.elb.{}.amazonaws.com/{}`) to named place holders (e.g. `https://public-keys.auth.elb.${awsRegion}.amazonaws.com/${keyId}`).
This make it more flexible.

```yaml
appConfig:
  security:
    authentication:
      openId:
        allowedAudiences: []
        audienceClaimRequired: false
        fullNameClaimTemplate: "${name}"
        publicKeyUriPattern: "https://public-keys.auth.elb.${awsRegion}.amazonaws.com/${keyId}"
```


### Stroom-Proxy's `config.yml`

#### HTTP Forward Destinations

The property `forwardHeadersAdditionalAllowSet` has been added to the `forwardHttpDestinations` branch.
It is a set of case-insensitive HTTP header keys.

When forwarding data to a downstream Stroom/Stroom-Proxy, Stroom-Proxy will set the following headers using value from the Meta associated with the data `accountId, accountName, classification, component, contextEncoding, contextFormat, encoding, environment, feed, format, guid, schema, schemaVersion, system, type`.
If any additional HTTP headers need to be set then they should be added to this list.

```yaml
proxyConfig:
  forwardHttpDestinations:
  - forwardHeadersAdditionalAllowSet: []
```


#### X509 Certificate Extraction

The changes described above in [Stroom - X509 Certificate Extraction]({{< relref "#x509-certificate-extraction" >}}) also apply to stroom-proxy.


#### Open ID Connect Authentication

The changes described above in [Stroom - Open ID Connect Authentication]({{< relref "#open-id-connect-authentication" >}}) also apply to stroom-proxy.


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

For information purposes only, the following are the database migrations that will be run when upgrading to 7.10.0 from the previous minor version.

Note, the `legacy` module will run first (if present) then the other module will run in no particular order.

#### Module `stroom-index`

##### Script `V07_10_00_001__index_field.sql`

**Path**: `stroom-index/stroom-index-impl-db/src/main/resources/stroom/index/impl/db/migration/V07_10_00_001__index_field.sql`

```sql
-- Stop NOTE level warnings about objects (not)? existing
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0;

ALTER TABLE index_field              CHANGE COLUMN name                name                  varchar(512) NOT NULL;

SET SQL_NOTES=@OLD_SQL_NOTES;

```


#### Module `stroom-processor`

##### Script `V07_10_00_999__processor_filter_data.java`

**Path**: `stroom-processor/stroom-processor-impl-db/src/main/java/stroom/processor/impl/db/migration/V07_10_00_999__processor_filter_data.java`

It is not possible to display the content here.
The file can be viewed on : {{< external-link "GitHub" "https://github.com/gchq/stroom/tree/7.10/stroom-processor/stroom-processor-impl-db/src/main/java/stroom/processor/impl/db/migration/V07_10_00_999__processor_filter_data.java" >}}

#### Module `stroom-security`

##### Script `V07_10_00_005__trim_user_identities.sql`

**Path**: `stroom-security/stroom-security-impl-db/src/main/resources/stroom/security/impl/db/migration/V07_10_00_005__trim_user_identities.sql`

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

-- Trim existing user identity values so they are consistent with the app
-- that now trims these values.
-- Idempotent.

update stroom_user
set name = trim(name)
where name is not null
and name != trim(name);

update stroom_user
set display_name = trim(display_name)
where display_name is not null
and display_name != trim(display_name);

update stroom_user
set full_name = trim(full_name)
where full_name is not null
and full_name != trim(full_name);

-- --------------------------------------------------

SET SQL_NOTES=@OLD_SQL_NOTES;

-- vim: set tabstop=4 shiftwidth=4 expandtab:

```

