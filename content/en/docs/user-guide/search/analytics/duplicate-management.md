---
title: "Duplicate Management"
linkTitle: "Duplicate Management"
weight: 50
date: 2026-09-02
tags:
  - analytic
description: >
  Suppressing detections that repeat something you have already been told.
---

Some rules will detect the same thing over and over.
A rule that runs hourly and looks for a misconfigured device will find that device every hour until someone fixes it, and nobody needs telling twenty four times a day.

_Duplicate Management_ suppresses detections that match ones the rule has already raised.
The tab is only shown for [Scheduled Query]({{< relref "_index#scheduled-query" >}}) rules.

This is different from [limiting notifications]({{< relref "notifications#limiting-notifications" >}}), which bounds how many notifications a rule may send regardless of what they say.
Duplicate management suppresses repeats while still delivering anything new.


## Settings

Field                            | Description
-------------------------------- | ------------
Remember Notifications           | Store the column values of de-duplicated detections so they can be viewed.
Suppress Duplicate Notifications | Suppress detections identical to ones already sent.
Choose Columns                   | Use a chosen set of columns to decide what counts as identical, rather than all of them.
Columns                          | A comma delimited list of column names, used when _Choose Columns_ is set.

The two switches are independent, and the store is used if either of them is set.

Remember | Suppress | Effect
-------- | -------- | -------
No       | No       | No store is used at all, and every detection is delivered.
No       | Yes      | Duplicates are suppressed.
Yes      | No       | Every detection is delivered, but what the rule has seen is recorded so it can be viewed.
Yes      | Yes      | Duplicates are suppressed, and what the rule has seen can be viewed.

Setting _Remember Notifications_ on its own is a useful way to see what a rule would suppress before committing to suppressing it.

The lower part of the tab lists what the rule has stored, which is how you check why something was or was not suppressed.
It also lets you clear the store.


## Choosing Columns

Where _Choose Columns_ is not set, the columns used depend on whether the query groups its results.

* A query with **grouped** columns uses those grouped columns, and ignores the rest.
* A query with **no grouping** uses every column.

Using every column is often too strict, because a column that changes on every run will make every detection unique.
A rule whose query selects a timestamp, or a count, or an event id, will never suppress anything unless the columns are narrowed down to the ones that identify the thing being detected.

_Choose Columns_ is how you narrow them.
For the misconfigured device example, choosing just the device name means the rule tells you about that device once rather than hourly, however much the other columns change.

Column names are case sensitive and must match the names in the query.

{{% warning %}}
Changing which columns are used for de-duplication requires the duplicate check store to be cleared.
The stored entries were built from the old set of columns and cannot be compared against the new one, so until the store is cleared the results will not be what you expect.
{{% /warning %}}


## The Duplicate Check Store

Each rule has its own store, held on the processing node and configured by the `stroom.analytics.duplicateCheckStore` property.

The store is keyed on the rule, so it survives the rule being edited.
It is deleted when the rule is deleted.

{{% note %}}
Because suppression is based on what the rule has already raised, replaying an execution will not re-deliver its detections while suppression is on.
Where you are deliberately re-running something and want the detections again, clear the store first.
{{% /note %}}
