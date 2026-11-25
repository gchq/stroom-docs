---
title: "New Features"
linkTitle: "New Features"
weight: 10
date: 2026-11-25
tags:
description: >
  New features in Stroom version 8.0.
---

## Counting Unique Values

There are two new functions for counting the unique values in each group of a query, dashboard, analytic rule or report:

* `dcount()` estimates the number of unique values.
  It takes up to 12 kilobytes for each group, however many unique values there are, and has a standard error of 0.8%.
  It has an optional accuracy, to trade space for accuracy.
* `countDistinct()` is exact for up to 10,000 unique values in each group, and is an estimate for more than that.
  The limit can be changed, see [Upgrade Notes]({{< relref "./upgrade-notes#new-maxcountdistinctvalues-properties" >}}).

```stroomql
from "File events"
group by UserId
select UserId, countDistinct(FileName) as Files, dcount(ClientAddress) as Addresses
```

Both are far quicker than `countUnique()` if there are many unique values, as it stores every value that it counts.
They also take less space, and `dcount()` takes far less.
`countUnique()` is now deprecated, see [Breaking Changes]({{< relref "./breaking-changes#countunique-is-deprecated" >}}).

{{< see-also >}}
* [Count Distinct]({{< relref "docs/reference-section/expressions/aggregate#count-distinct" >}})
* [Dcount]({{< relref "docs/reference-section/expressions/aggregate#dcount" >}})
{{< /see-also >}}
