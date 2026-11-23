---
title: "New Features"
linkTitle: "New Features"
weight: 10
date: 2026-10-19
tags: 
description: >
  New features in Stroom version 7.14.
---

## Data Connections

A new {{< stroom-doc "DataConnection" >}} document type makes data held outside Stroom into one more kind of {{< glossary "Data Source" "data source" >}}.
{{< glossary "StroomQL" >}} queries, dashboards, scheduled analytic rules and reports can query it, and every part of StroomQL works on its rows as it does on Stroom's own data.

A Data Connection has one of five types:

* _JDBC_ - a database, queried with SQL given in each query.
  Stroom ships the MySQL and PostgreSQL drivers, and an administrator can add others.
* _Amazon Athena_ - Amazon Athena, queried with SQL through the AWS SDK, with a limit on the data a query may scan.
* _LDAP_ - an LDAP directory, such as OpenLDAP or Active Directory, searched with a filter given in each query.
* _CSV_ and _Excel_ - small lookup tables and reference lists held in the document itself, queried with StroomQL's own clauses.

The SQL or filter goes in a new `sql` clause, straight after `from`, as a triple-quoted string that can span lines and hold quotes without escaping:

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

Named placeholders such as `:team` take query parameters, and `:from` and `:to` take the query's time range, without ever changing the SQL or filter itself.

Data Connections connect with credentials held in the Credentials store, which gains an _AWS Access Key_ type for Amazon Athena.
A user needs _Use_ permission on both the Data Connection and its credential to query it.
No JDBC, Athena or LDAP connection is allowed until an administrator allows it with the new `dataConnection` properties, see [Upgrade Notes]({{< relref "./upgrade-notes#new-dataconnection-properties" >}}).

An example import pack, `stroom-data-connection/DataConnection-Examples.zip` in the Stroom repository, has JDBC, LDAP, CSV and Excel Data Connections with example queries.

{{< see-also >}}
* [Data Connections]({{< relref "docs/user-guide/search/data-sources/data-connections" >}})
* [StroomQL Sql clause]({{< relref "docs/user-guide/search/queries/stroom-query-language#sql" >}})
* [Credentials]({{< relref "docs/user-guide/security/credentials" >}})
{{< /see-also >}}


## StroomQL Joins

{{< glossary "StroomQL" >}} queries can now join the rows of one data source to those of another, matching them on keys.
Join lines go straight after `from`:

```stroomql
from "Windows events"
left join "HR Users" as hr on UserId = hr.Username
select UserId, hr.Department
```

The joined source is searched first and held, and the first source's rows are joined as they arrive, so results still appear as the search runs.
Any data source can be joined to any other, such as an index to a Data Connection, and either can be a bracketed query, such as a grouped summary.

There are six kinds of join:

* `join` (or `inner join`) - one row per match.
* `left join` (or `left outer join`) - also keeps the rows with no match.
* `right join` (or `right outer join`) - also keeps the joined source's rows with no match.
* `full join` (or `full outer join`) - also keeps the rows of either source with no match.
* `semi join` (or `left semi join`) - each row with a match, once, adding no fields.
* `anti join` (or `left anti join`) - each row with no match.

`where exists`, `where not exists`, `where ... in (from ...)` and `where ... not in (from ...)` are also accepted, as the SQL ways of writing semi and anti joins.

A join can also match events to events within a time window, e.g. a logon followed by a file export by the same user within 10 minutes:

```stroomql
from "Windows events" as logon
join "File events" as export
  on logon.UserId = export.UserId
  within 10m after logon.EventTime
select logon.UserId, logon.EventTime, export.FileName
```

Joins can be used in queries, in Embedded Query panels on dashboards, and in scheduled analytic rules and reports.
A joined source can hold up to 1,000,000 rows or 256 MB, which administrators can change, see [Upgrade Notes]({{< relref "./upgrade-notes#new-searchresultstore-join-properties" >}}).

The Data Connection example pack has ten example join queries.

{{< see-also >}}
* [Joins]({{< relref "docs/user-guide/search/queries/joins" >}})
* [StroomQL Grammar]({{< relref "docs/reference-section/stroomql-grammar#join-lines" >}})
* [StroomQL Join clause]({{< relref "docs/user-guide/search/queries/stroom-query-language#join" >}})
{{< /see-also >}}


## StroomQL Time Windows

The `window` clause of {{< glossary "StroomQL" >}} has been replaced.
It now puts rows into true windows of time and groups them by window, so a query can count events for each user for each day:

```stroomql
from "File events"
window EventTime by 1d
group by UserId
having count() > lag(count(), 1) * 2
select windowStart() as Day, UserId, count() as Events
```

* `advance` makes windows that overlap, e.g. `window EventTime by 1h advance 10m` is a window of an hour that starts every 10 minutes.
* `offset` moves where windows start, e.g. `window EventTime by 1d offset 6h` makes each day run from 06:00 to 06:00.
* Windows of days, weeks, months and years follow the calendar in the time zone of the query.
* The new functions `windowStart()` and `windowEnd()` give the times of a row's window.
* The new functions `lag()` and `lead()` give the value of an aggregate in an earlier or later window, so a window can be compared with another one.
* `having` now takes expressions, so the query above needs no `eval`.

Analytic rules judge a window only when it has all of its events.
A scheduled rule judges each window in the run whose time range holds the end of the window, and searches back before the range for the windows it reads with `lag()`.

The `periodN` columns and the `period()` function that the old clause used have been removed, see [Breaking Changes]({{< relref "./breaking-changes#stroomql-window-clause" >}}).

{{< see-also >}}
* [StroomQL Window clause]({{< relref "docs/user-guide/search/queries/stroom-query-language#window" >}})
* [StroomQL Grammar]({{< relref "docs/reference-section/stroomql-grammar#window" >}})
* [Time Windows in Analytic Rules]({{< relref "docs/user-guide/search/analytics/query#time-windows" >}})
{{< /see-also >}}
