---
title: "JDBC Data Connections"
linkTitle: "JDBC"
weight: 10
date: 2026-11-12
tags:
  - data-source
  - search
  - data-connection
description: >
  Querying a database with SQL through a JDBC driver.
---

A JDBC {{< stroom-doc "DataConnection" >}} connects to a database through a JDBC driver.
Each query gives the SQL to run in a `sql` clause, and the columns of its result become the query's fields.

Stroom ships the MySQL and PostgreSQL drivers.
An administrator can add drivers for other databases by putting their jars in the directory named by the `stroom.dataConnection.driverDirectory` property.


## Settings

_JDBC URL_
: The JDBC URL of the database, e.g. `jdbc:mysql://reporting-db:3306/reports`.
  It must match one of the patterns an administrator has allowed in the `stroom.dataConnection.allowedUrlPatterns` property.
  Do not put a user name or password in it; choose a credential instead.

_Credential_
: The _Username / Password_ [credential]({{< relref "docs/user-guide/security/credentials" >}}) to connect with.
  You need _Use_ permission on it, as does anyone who queries this Data Connection.

_Connection Properties_
: Extra JDBC driver properties, one `name=value` per line.
  For MySQL, add `useCursorFetch=true` so large results are read in batches of the fetch size rather than all at once.

_Max Pool Size_
: The most connections Stroom keeps open to this database at once.
  An administrator may set a lower ceiling.
  Default: `5`.

_Fetch Size_
: How many rows are fetched from the database in each round trip.
  `0` uses the driver's own default.
  Default: `1000`.

_Minimum Refresh (minutes)_
: The shortest interval at which a dashboard may rerun a query of this Data Connection automatically, to limit the load on the database.
  `0` sets no minimum beyond the dashboard's own 10 seconds.
  Default: `0`.

The _Time Column_, _Query Timeout_ and _Max Rows_ settings are described in [Settings for Every Type]({{< relref "docs/user-guide/search/data-sources/data-connections#settings-for-every-type" >}}).

{{< stroom-btn "Test Connection" >}} connects with the settings as they stand and reports the database and driver it reached, and the user it connected as.


## Writing the SQL

The SQL is a single statement that returns rows, given in a triple-quoted `sql` clause, e.g.

```stroomql
from "Reports DB"
sql """
  select name, team, joined
  from staff
  where joined >= :from and joined < :to
"""
where team = "Platform"
select name, joined
```

* A `;` is only allowed at the end, so a query cannot run a second statement.
* Use named placeholders such as `:team` for values, not `?`, which is refused outside quotes.
  See [Parameters]({{< relref "docs/user-guide/search/data-sources/data-connections#parameters" >}}) and [Time Range]({{< relref "docs/user-guide/search/data-sources/data-connections#time-range" >}}).
* Give each column the name you want as its field, with `as` if needed, e.g. `count(*) as streams`.
  A field matches a column of the same name, or failing that a column whose name differs only in case, as some databases change the case of names that are not quoted.

Stroom asks the database to describe the SQL without running it, so the fields are listed in the query editor as you write the SQL.


### Column Types

Each column is read as a Stroom field type, from the type the driver reports:

| Database type | Field type |
|---------------|------------|
| `TINYINT`, `SMALLINT`, `INTEGER` | Integer |
| `BIGINT` | Long |
| `DECIMAL` and `NUMERIC` with no fraction and up to 18 digits | Long |
| `REAL`, `FLOAT` | Float |
| `DOUBLE`, and other `DECIMAL` and `NUMERIC` | Double |
| `BOOLEAN`, `BIT` | Boolean |
| `DATE`, `TIMESTAMP`, `TIMESTAMP WITH TIME ZONE` | Date |
| Anything else | Text |

A date or timestamp with no time zone is taken as UTC.
An unsigned `BIGINT` too large for a Long is read as a Double.

Stroom's own tables hold times as milliseconds since 1970 in `BIGINT` columns.
To read them as dates, convert them in the SQL, e.g. `from_unixtime(create_time / 1000)` in MySQL, and compare them with the time range using `:from{epochMillis}` and `:to{epochMillis}`.


## Security

Stroom asks for read-only connections, turning off auto-commit so that PostgreSQL connections are read-only too.
Only the database can enforce what an account may do, so the credential should be for an account that can only read the tables Stroom should query.

An administrator's controls are checked when the Data Connection is saved and again whenever it connects:

* The URL must match one of the `stroom.dataConnection.allowedUrlPatterns` patterns.
* Embedded databases (`jdbc:h2:`, `jdbc:hsqldb:`, `jdbc:derby:` and `jdbc:sqlite:`) are refused, as they read files on the Stroom server.
* Driver properties that can read local files, load classes or turn off read-only connections are refused, whether in the URL or the connection properties.
  The list is the `stroom.dataConnection.deniedConnectionProperties` property.
  For MySQL and PostgreSQL the URL is read by the driver's own parser, so a property cannot be hidden in it.
  The URLs of other databases cannot contain `%` or `(`; set their properties as connection properties instead.
* A user name or password in the URL or connection properties is refused, so a secret is never stored in the document.
