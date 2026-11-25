---
title: "Breaking Changes"
linkTitle: "Breaking Changes"
weight: 30
date: 2026-11-25
tags:
description: >
  Changes in Stroom version 8.0 that may break existing processing or ways of working.
---

{{< warning >}}
Please read this section carefully in case any of the changes affect you.
{{< /warning >}}


## Stroom

### `countUnique()` is Deprecated

`countUnique()` is deprecated, though it works as it did before.
Use the new [`countDistinct()`]({{< relref "docs/reference-section/expressions/aggregate#count-distinct" >}}) or [`dcount()`]({{< relref "docs/reference-section/expressions/aggregate#dcount" >}}) instead.

{{< warning >}}
Don't change an existing Table Builder rule to use either.
The values that the rule has already stored for `countUnique()` can't be read by them, so its counts would be wrong or it would fail.
Make the change in a copy of the rule instead, see [Changing the Query]({{< relref "docs/user-guide/search/analytics/table-builder#changing-the-query" >}}).
The same applies to changing between `countDistinct()` and `dcount()`, or changing the accuracy of `dcount()`.
{{< /warning >}}


## Stroom-Proxy

{{% todo %}}
Complete this section.
{{% /todo %}}


## Stroom & Stroom-Proxy

Breaking changes that are common to both Stroom and Stroom Proxy.

{{% todo %}}
Complete this section.
{{% /todo %}}
