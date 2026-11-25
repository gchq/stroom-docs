---
title: "Amazon Athena Data Connections"
linkTitle: "Amazon Athena"
weight: 20
date: 2026-11-12
tags:
  - data-source
  - search
  - data-connection
  - aws
description: >
  Querying Amazon Athena with SQL through the AWS SDK.
---

An Amazon Athena {{< stroom-doc "DataConnection" >}} runs SQL in {{< external-link "Amazon Athena" "https://aws.amazon.com/athena/" >}} through the AWS SDK.
Each query gives the SQL to run in a `sql` clause, and the columns of its result become the query's fields.

Athena bills by the data each query scans, so several settings and rules here exist to keep the cost in check.


## Settings

_AWS Region_
: The AWS region of the Athena workgroup, e.g. `eu-west-2`.

_Workgroup_
: The Athena workgroup queries run in.
  The region and workgroup, written `region/workgroup`, must match one of the patterns an administrator has allowed in the `stroom.dataConnection.allowedAthenaWorkGroups` property.
  The workgroup's per-query data scan limit is the control on cost.
  Default: `primary`.

_Data Catalog_
: The data catalog queries run in.
  Default: `AwsDataCatalog`.

_Database_
: The database queries run in.
  Default: `default`.

_Output Location (optional)_
: The S3 URI query results are written to, e.g. `s3://my-bucket/athena/`.
  Leave it empty to use the workgroup's.
  It must match one of the patterns an administrator has allowed in the `stroom.dataConnection.allowedAthenaOutputLocations` property; with none, it must be left empty.

_Credential_
: The _AWS Access Key_ [credential]({{< relref "docs/user-guide/security/credentials" >}}) to query with.
  You need _Use_ permission on it, as does anyone who queries this Data Connection.
  With none, Stroom's own AWS identity is used, but only if an administrator has turned on the `stroom.dataConnection.allowDefaultAwsCredentials` property.

_Result Reuse (minutes)_
: How old a result of the same query may be and still be reused instead of running the query again.
  Athena bills every run, so this saves cost when the same query is run again.
  `0` never reuses a result.
  Default: `0`.

_Minimum Refresh (minutes)_
: The shortest interval at which a dashboard may rerun a query of this Data Connection automatically.
  Result reuse rarely helps a dashboard, as its time range changes on every refresh, and many refreshes also use up the account's limit on Athena queries running at once.
  `0` sets no minimum beyond the dashboard's own 10 seconds.
  Default: `5`.

_Max Data Scanned (MB)_
: The most data, in MB, a query may scan before Stroom stops it.
  Stroom checks while the query runs, so a query may pass the limit by what it scans between two checks.
  The workgroup's own per-query data scan limit is the one Athena enforces exactly, so set that too.
  `0` sets no limit beyond the workgroup's.
  Default: `0`.

The _Query Timeout_ and _Max Rows_ settings are described in [Settings for Every Type]({{< relref "docs/user-guide/search/data-sources/data-connections#settings-for-every-type" >}}).
Athena takes the time range in its SQL, so it has no time column.

{{< stroom-btn "Test Connection" >}} runs no query, as every query is billed.
It looks up the workgroup and the database, which checks the credential, region, workgroup and database.
It reports the workgroup's data scan limit and result location, or that none is set, and whether the workgroup enforces its own settings.


## Writing the SQL

The SQL is a single statement that returns rows, given in a triple-quoted `sql` clause, e.g.

```stroomql
from "Events"
sql """
  select event_time, user_name, action
  from sign_ins
  where event_time >= :from and event_time < :to
    and outcome = 'FAILED'
"""
eval failures = count()
group by user_name
sort by failures desc
select user_name, failures
```

* Only SQL that starts with `SELECT`, `WITH`, `VALUES`, `SHOW` or `DESCRIBE` is run, as an Athena connection cannot be made read-only.
  That refuses `CREATE TABLE AS`, `INSERT` and `UNLOAD`.
* A `;` is only allowed at the end, so a query cannot run a second statement.
* A query with a time range must use `:from` or `:to` in its SQL, and is refused otherwise.
  Filtering in Stroom after Athena had scanned everything would cost money for nothing.
* Athena receives every parameter as text, written as a single SQL literal.
  To compare one with a number, cast it, e.g. `where id = cast(:id as bigint)`.

See [Parameters]({{< relref "docs/user-guide/search/data-sources/data-connections#parameters" >}}) and [Time Range]({{< relref "docs/user-guide/search/data-sources/data-connections#time-range" >}}).


### Fields

Athena cannot describe a query without running it, and every run is billed.
So the fields of a query are only known once its SQL has run; until then the field list is empty.
After a run, the fields are remembered for a while, so the query editor can list them.


### Cost

Each run reports the data Athena scanned with its results.

A query is stopped in Athena, not just in Stroom, when it is cancelled, when it reaches the query timeout or the _Max Data Scanned_ limit, or when Stroom fails after starting it.

{{% warning %}}
Set a per-query data scan limit on every workgroup Stroom may use.
It is the only limit Athena enforces exactly, whatever a Data Connection's settings.
{{% /warning %}}


## Security

* The region and workgroup must match one of the `stroom.dataConnection.allowedAthenaWorkGroups` patterns.
* An output location must match one of the `stroom.dataConnection.allowedAthenaOutputLocations` patterns.
  Every query writes its full result there, with the AWS identity of the user running it.
* A Data Connection must name an AWS access key credential, unless `stroom.dataConnection.allowDefaultAwsCredentials` is on.
  Otherwise any user who can create a document could query whatever Stroom's own AWS identity can read.
* Use AWS identities that can only read the tables Stroom should query.
  Federated queries pass SQL to connectors that Stroom cannot see into, so their accounts should only be able to read too.
