---
title: "Breaking Changes"
linkTitle: "Breaking Changes"
weight: 30
date: 2026-10-19
tags: 
description: >
  Changes in Stroom version 7.14 that may break existing processing or ways of working.
---

{{< warning >}}
Please read this section carefully in case any of the changes affect you.
{{< /warning >}}


## Stroom

### Migrating an Existing v7.14 Stroom

See [Migrating an Existing v7.14 Stroom]({{< relref "./upgrade-notes#migrating-an-existing-v714-stroom" >}})


### StroomQL Window Clause

The `window` clause of {{< glossary "StroomQL" >}} has been replaced, see [StroomQL Time Windows]({{< relref "./new-features#stroomql-time-windows" >}}).
Queries, dashboards, analytic rules and reports that use the old clause need to be changed.

* The `period0`, `period1`, etc. columns are no longer added to the table.
  Use `lag()` instead, e.g. `lag(count(), 1)` in place of `period1`.
* The `period()` function has been removed.
  Use `lag()` instead, e.g. `lag(count(), 1)` in place of `period(1, count())`.
* `using` has been removed from the clause.
  Give the aggregate to `lag()` instead.
* The time field is no longer added to the table as the start of the window.
  Select `windowStart()` instead.
* `advance` now sets how often a window starts, and no longer how many period columns there are.
* A row now holds the events of its own window, and a window with no events has no row unless another window reads it with `lag()` or `lead()`.

A query that uses `period()` or `using` is refused with a message that shows the new form.
A `periodN` name is not refused, as it is now treated as any other field name, so check for these by hand.


## Stroom-Proxy

{{% todo %}}
Complete this section.
{{% /todo %}}


## Stroom & Stroom-Proxy

Breaking changes that are common to both Stroom and Stroom Proxy.

{{% todo %}}
Complete this section.
{{% /todo %}}


