---
title: "Join"
linkTitle: "Join"
description: >
  A line in a _StroomQL_ query that adds the rows of another _Data source_ to the query's rows, matching them on keys.
---

A join can add the fields of the matching rows, as `join`, `left join`, `right join` and `full join` do, or only keep the rows that have a match, or that have none, as `semi join` and `anti join` do.
Any {{< glossary "Data Source" "data source" >}} can be joined to any other, and either can be a bracketed query.

{{< see-also >}}
* [Joins]({{< relref "docs/user-guide/search/queries/joins" >}})
* [StroomQL Grammar]({{< relref "docs/reference-section/stroomql-grammar#join-lines" >}})
* {{< glossary "StroomQL" >}}
{{< /see-also >}}
