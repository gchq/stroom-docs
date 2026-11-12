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
