---
title: "Data Connections"
linkTitle: "Data Connections"
weight: 35
date: 2026-11-12
tags:
  - data-source
  - search
  - data-connection
description: >
  Querying data held outside Stroom's own stores: a JDBC database, Amazon Athena or an LDAP directory, or CSV and Excel data held in the document itself.
---

A {{< stroom-doc "DataConnection" >}} is one more kind of {{< glossary "Data Source" "data source" >}}.
It lets {{< glossary "StroomQL" >}} queries, {{< glossary "Dashboard" "Dashboards" >}} and scheduled analytic rules query data that Stroom does not hold in its own indexes or stores, such as a reporting database or a staff directory.
Once its rows reach Stroom, every part of StroomQL works on them as it does on any other data source, e.g. `where`, `eval`, `group by`, `sort by` and `select`.

Data Connections are read-only.
Stroom never writes to the systems they connect to, and cannot join one data source to another.


## Types

Each Data Connection has a _Type_, which decides where its data comes from and how it is queried.

| Type | Data | Queried with | Fields |
|------|------|--------------|--------|
| [JDBC]({{< relref "jdbc" >}}) | A database reached through a JDBC driver, e.g. MySQL or PostgreSQL. | SQL in each query's `sql` clause. | The columns the SQL returns. |
| [Amazon Athena]({{< relref "athena" >}}) | Amazon Athena, reached through the AWS SDK. | SQL in each query's `sql` clause. | The columns the SQL returned when it last ran. |
| [LDAP]({{< relref "ldap" >}}) | An LDAP directory, e.g. OpenLDAP or Active Directory. | An LDAP search filter in each query's `sql` clause. | `dn` and the attributes listed in the document. |
| [CSV]({{< relref "csv-and-excel" >}}) | CSV text held in the document. | Stroom's own clauses only. | The columns listed in the document. |
| [Excel]({{< relref "csv-and-excel" >}}) | An Excel `.xlsx` workbook held in the document. | Stroom's own clauses only. | The columns listed in the document. |

The pages for each type describe its settings.
The rest of this page applies to them all.


## Creating a Data Connection

1. Right-click a folder in the Stroom Explorer pane ({{< stroom-icon "folder-tree.svg" "Explorer" >}}).
1. Select:  
   {{< stroom-menu "New" "Data Connection" >}}
1. Enter a name for the Data Connection and click {{< stroom-btn "OK" >}}.
   Queries name it after `from`, so a short name without spaces is easiest to type.
1. On the _Settings_ tab, choose the _Type_ and fill in the settings that appear below it.
1. Click {{< stroom-btn "Test Connection" >}}, or for CSV and Excel {{< stroom-btn "Check CSV" >}} or {{< stroom-btn "Check Workbook" >}}, to check the settings.
1. Click {{< stroom-icon "save.svg" "Save" >}}.

The settings of every type are kept when you change the _Type_, so you can switch back without losing them.
Only the settings of the chosen type are checked and used.

Settings an administrator controls, such as which JDBC URLs are allowed, are checked when you save, so a mistake is reported straight away.
They are checked again whenever the Data Connection connects, as an imported document is not checked on import.


### Settings for Every Type

_Time Column (optional)_
: A date column of the data, used to apply a query's time range.
  See [Time Range]({{< relref "#time-range" >}}).
  Not used by Amazon Athena.

_Query Timeout (seconds)_
: How long a query may run before it is stopped.
  An administrator may set a lower ceiling.
  Not used by CSV and Excel, which are read from the document.
  Default: `60`.

_Max Rows_
: The most rows a query may read.
  A query with more uses the first ones and warns that the limit was reached.
  An administrator may set a lower ceiling.
  Default: `100000`.


## Querying a Data Connection

Name the Data Connection after `from`, as for any other data source.
For CSV and Excel that is all that is needed, as the data is held in the document, e.g.

```stroomql
from "Teams"
where on_call = true
sort by members desc
select team, members
```

JDBC, Amazon Athena and LDAP Data Connections also need the query to run in the external system: SQL for JDBC and Athena, or a search filter for LDAP.
It goes in a `sql` clause straight after `from`, as a string in triple double quotes (`"""`).
A triple-quoted string is taken exactly as written, so it can span lines and hold `"` and `\` without escaping, e.g.

```stroomql
from "Stroom DB"
sql """
  select f.name as feed, t.name as type
  from meta m
  join meta_feed f on f.id = m.feed_id
  join meta_type t on t.id = m.type_id
"""
eval streams = count()
group by feed, type
sort by streams desc
select feed, type, streams
```

The SQL or filter runs first, in the external system.
Its rows then go through the rest of the query in Stroom, like the rows of any other data source.
So keep the SQL or filter to what narrows the data, and let Stroom's clauses do the rest, or do as much as the external system can do faster, as you prefer.

A `sql` clause is refused for a data source that does not take one, and a JDBC, Athena or LDAP Data Connection without one is refused with an example of the clause.

{{% see-also %}}[StroomQL Sql clause]({{< relref "docs/user-guide/search/queries/stroom-query-language#sql" >}}){{% /see-also %}}


### Fields

The fields of a query are the columns of the rows its data source gives:

* JDBC: the columns of the SQL.
  Stroom asks the database to describe the SQL without running it, so the fields are known as you type.
* Amazon Athena: the columns of the SQL when it last ran, as Athena cannot describe a query without running it and every run is billed.
  Until the SQL has run once, the field list is empty.
* LDAP: `dn`, then each attribute listed in the document.
* CSV and Excel: the columns listed in the document.

A field the query uses that the data does not have is empty, and the query warns about it.
A field used in `where` that is not a column is an error.


### Parameters

The SQL or filter can take values from the query's parameters, such as those of a dashboard, with a named placeholder: a colon followed by the parameter's name, e.g. `:feed`.

```stroomql
from "Stroom DB"
sql """
  select m.id, m.create_time
  from meta m
  join meta_feed f on f.id = m.feed_id
  where f.name = :feed
"""
select id, create_time
```

A value is never pasted into the SQL or filter as text, so it cannot change it:

* JDBC binds it as a parameter of a prepared statement.
* Amazon Athena passes it as an execution parameter, written as a single SQL literal.
  As Athena receives every value as text, compare it with a number by casting, e.g. `where id = cast(:id as bigint)`.
* LDAP escapes it as a filter value, so `*)(uid=*` is matched as text and finds nothing.

A placeholder with no parameter of its name is an error.
SQL must use named placeholders: a `?` outside quotes is refused.


### Time Range

A query's time range can be applied in two ways.

**In the SQL or filter**, with the placeholders `:from` and `:to`, which take the start and end of the time range, e.g.

```sql
select * from events where event_time >= :from and event_time < :to
```

By default they are timestamps.
A format in braces after the name changes them:

| Placeholder | Value |
|-------------|-------|
| `:from` | A timestamp for JDBC and Athena, or an LDAP time (GeneralizedTime) for LDAP. |
| `:from{epochMillis}` | Milliseconds since 1970, as Stroom's own tables hold times. |
| `:from{epochSeconds}` | Seconds since 1970. |
| `:from{yyyy-MM-dd}` | Text in the given date pattern, in UTC. |

**In Stroom**, on the document's _Time Column_, when the SQL or filter has no `:from` or `:to`.
The SQL must return the column, and for LDAP, CSV and Excel it must be a Date column or attribute.
This reads every row the SQL or filter returns, so filtering in the SQL is faster on large data.

If neither applies, the time range is ignored and the query warns that it was.

Amazon Athena bills by the data each query scans, so an Athena query with a time range must use `:from` or `:to` in its SQL, and is refused otherwise.


### Limits and Warnings

A query stops when it has read the document's _Max Rows_ or runs for its _Query Timeout_, whichever comes first.
An administrator's ceilings on both apply to every Data Connection.

Problems that do not stop a query are reported as warnings with its results, e.g.:

* The row limit was reached, so only the first rows were used.
* The time range was ignored.
* A field the query uses is not a column of the data.
* Values were not of their column's type, so they are empty.
  The warning counts them and gives an example.
* For LDAP, a referral was not followed, or the directory's own size or time limit ended the search.

Closing or stopping a query stops it in the external system too.


## Dashboards

A Data Connection can be the data source of a dashboard's _Query_ panel.
CSV and Excel need nothing more.

For JDBC, Amazon Athena and LDAP the query needs its `sql` clause, which the _Query_ panel's expression editor has no place for.
Write the query in a {{< stroom-doc "Query" >}} document instead, and show it on the dashboard with an _Embedded Query_ panel.

A dashboard that refreshes automatically reruns the query each time, against the external system.
The _Minimum Refresh (minutes)_ setting of JDBC, Amazon Athena and LDAP Data Connections sets the shortest interval at which a dashboard may do so, to protect the system and, for Athena, the cost.
A dashboard set to refresh more often is held to the minimum.


## Analytics

[Scheduled Query]({{< relref "docs/user-guide/search/analytics/query" >}}) rules and {{< stroom-doc "Report" >}} documents can query a Data Connection.
Each run applies the rule's time range to the time it runs for, using `:from` and `:to` or the _Time Column_ as above.

[Streaming]({{< relref "docs/user-guide/search/analytics/streaming" >}}) and table builder rules run over events as Stroom processes them, through a {{< stroom-doc "View" >}}.
A View cannot use a Data Connection, so these rules cannot either.


## Permissions

To query a Data Connection a user needs _Use_ permission on the document.

JDBC, LDAP and Amazon Athena Data Connections name a [credential]({{< relref "docs/user-guide/security/credentials" >}}) to connect with.
The credential is used as the user running the query, who needs _Use_ permission on the credential too.
A credential that does not exist and one the user may not use give the same error, so the names of credentials cannot be discovered this way.

Testing a connection, and detecting the columns or attributes of the data, use the settings being edited with the credential they name.
So they need permission to edit the document as well.

{{% warning %}}
Stroom runs whatever SQL or filter a query gives, as the account of its credential.
Use accounts that can only read the data Stroom should query: Stroom asks JDBC databases for read-only connections, but only the database, Athena workgroup or directory can enforce what an account may do.
{{% /warning %}}


## Administration

An administrator controls what Data Connections may connect to with these properties, under `stroom.dataConnection`.
See [Properties]({{< relref "docs/user-guide/properties" >}}).

| Property | Default | Purpose |
|----------|---------|---------|
| `allowedUrlPatterns` | None | Regular expressions a JDBC URL must match one of. With none, no JDBC connection is allowed. |
| `deniedConnectionProperties` | A list of MySQL and PostgreSQL properties | JDBC driver properties a Data Connection may not set, in its URL or its connection properties, because they can read local files, load classes or turn off read-only connections. |
| `driverDirectory` | None | A directory of extra JDBC driver jars, for databases other than MySQL and PostgreSQL, whose drivers Stroom ships. Needs a restart. |
| `allowedAthenaWorkGroups` | None | Regular expressions an Amazon Athena `region/workgroup` must match one of, e.g. `^eu-west-2/stroom-.*$`. With none, no Athena connection is allowed. |
| `allowedAthenaOutputLocations` | None | Regular expressions an Athena output location must match one of. With none, Data Connections may not set one and the workgroup's is used. |
| `allowDefaultAwsCredentials` | `false` | Whether an Athena Data Connection with no credential may use Stroom's own AWS identity. |
| `allowedLdapUrlPatterns` | None | Regular expressions an LDAP URL must match one of, e.g. `^ldaps://directory\.example\.org:636$`. With none, no LDAP connection is allowed. |
| `allowPlainLdap` | `false` | Whether an LDAP Data Connection may connect with plain `ldap://` and no StartTLS, sending its password and results unencrypted. |
| `maxStoredDataSize` | `5M` (5 MiB) | The most CSV or Excel data a Data Connection may hold. |
| `maxQueryTimeout` | `PT10M` | The longest query timeout a Data Connection may set. |
| `maxRowsLimit` | `1000000` | The highest row limit a Data Connection may set. |
| `maxPoolSizeLimit` | `20` | The largest JDBC connection pool a Data Connection may set. |
| `connectionPoolCache` | 100 pools, closed after 10 minutes unused | The JDBC connection pools, one per Data Connection. |
| `fieldCache` | 1000 entries for 10 minutes | The columns of each query's SQL, so editors can list fields without asking the database each time. |
| `tableCache` | 10 entries, for 10 minutes unused | The rows read from the CSV or Excel data of each Data Connection. |

With the defaults, no JDBC, Athena or LDAP connection is allowed until an administrator allows one.
CSV and Excel Data Connections need no setting.


## Example Pack

The Stroom repository holds an import pack of example Data Connections and queries, `stroom-data-connection/DataConnection-Examples.zip`, for trying them out in a development or test Stroom.
Import it with:

{{< stroom-menu "Tools" "Import" >}}

It imports a _Data Connection Examples_ folder holding:

* _Stroom DB_, a JDBC Data Connection pointed at Stroom's own MySQL database, with queries of its nodes, streams and processor tasks.
* _Teams_, a CSV Data Connection, and _Bank Holidays_, an Excel one, each with a query.
  They need no set-up.
* _Directory_, an LDAP Data Connection, with queries of the people in a directory.

The _Documentation_ tab of each JDBC and LDAP Data Connection gives its set-up steps.
Change its URL to your own database or directory first, as the queries will otherwise read a different one, or none.

{{% warning %}}
Reading Stroom's own `meta` table directly bypasses Stroom's feed permissions, so do not set up the _Stroom DB_ example on a production Stroom.
{{% /warning %}}
