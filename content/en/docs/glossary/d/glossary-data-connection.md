---
title: "Data Connection"
linkTitle: "Data Connection"
description: >
  A Document that makes data held outside Stroom's own stores into a _Data source_: a JDBC database, Amazon Athena or an LDAP directory, or CSV or Excel data held in the Document itself.
---

A Data Connection is queried like any other {{< glossary "Data Source" "data source" >}}.
For a JDBC database or Amazon Athena each query gives SQL to run, and for an LDAP directory a search filter, in a `sql` clause.
CSV and Excel data is queried with {{< glossary "StroomQL" >}}'s own clauses.

{{< see-also >}}
* [Data Connections]({{< relref "docs/user-guide/search/data-sources/data-connections" >}})
* {{< glossary "Data Source" >}}
{{< /see-also >}}
