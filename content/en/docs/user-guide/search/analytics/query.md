---
title: "Rule Queries"
linkTitle: "Query"
weight: 10
date: 2026-09-02
tags:
  - analytic
  - query
description: >
  The query that defines what an Analytic Rule detects, and how its columns become the content of a detection.
---

The _Query_ tab holds the {{< glossary "StroomQL" >}} query that defines the rule.
It is the same query editor used by the [Query]({{< relref "docs/user-guide/search/queries" >}}) {{< stroom-icon "document/Query.svg" >}} document, so you can write a query, run it and inspect the results while you are developing the rule.

**Every row the query returns becomes one detection.**
This is the single most important thing to understand about a rule.
A query that returns a million rows will raise a million detections, so it is worth running the query and looking at the row count before enabling the rule.

{{% see-also %}}
[Stroom Query Language]({{< relref "docs/user-guide/search/queries/stroom-query-language" >}})
{{% /see-also %}}


## Choosing a Data Source

A rule query can use any data source that a Query document can use, but the choice interacts with the [processing type]({{< relref "_index#processing-types" >}}).

* A _Scheduled Query_ rule can query anything, including {{< glossary "Searchable" "Searchables" >}} and Lucene indexes.
* A _Streaming_ rule must query a View {{< stroom-icon "document/View.svg" >}}, because the View's filter is what decides which streams are fed through the rule.

{{% see-also %}}
[Data Sources]({{< relref "docs/user-guide/search/data-sources" >}})
{{% /see-also %}}


## Time Ranges and Relative Times

A rule that is going to run repeatedly should express its time range relative to when it runs, not as absolute dates.

When a scheduled rule runs, Stroom sets the reference time for the query to the rule's _effective execution time_ rather than to the current clock time.
Every relative date expression in the query and in the time range is then resolved against that effective time.

This is what makes it possible for a rule to work through history.
A rule whose query says `where EventTime >= day() - 1d` will, when it runs for an effective time of last Tuesday, select last Monday's data.
The same query run for an effective time of today selects yesterday's data.

{{% note %}}
The effective execution time is not the same as the wall clock time at which the rule ran.
The difference matters whenever a rule is catching up, being replayed, or running over a historic period.
Both times are recorded on every detection, as `effectiveExecutionTime` and `executionTime`.
{{% /note %}}

{{% see-also %}}
[Date Expressions]({{< relref "docs/reference-section/dates#date-expressions" >}})
[Execution]({{< relref "execution" >}})
{{% /see-also %}}


## Columns

The columns your query selects become the content of each detection.

Every column is added to the detection as a name/value pair, using the column's name as the key, and is available to email templates through the `values` dictionary.
Two column names are treated specially.

Column     | Treatment
---------- | ----------
`StreamId` | Used as the `streamId` of the detection's linked event rather than added to `values`.
`EventId`  | Used as the `eventId` of the detection's linked event rather than added to `values`.

Including `StreamId` and `EventId` in the query is what allows a detection to link back to the {{< glossary "Event" >}} that caused it.
Without them the detection still carries all its other values, but there is nothing to click through to.

{{% warning %}}
Column names become keys in the email template context, so it pays to choose names that are easy to reference.
A column named `Source IP` has to be written as `values['Source IP']` in a template, whereas `SourceIp` can be written as `values.SourceIp`.
{{% /warning %}}

{{% see-also %}}
[Detections]({{< relref "detections" >}})
{{% /see-also %}}


## Table Preferences

Some things about a result table cannot be expressed in {{< glossary "StroomQL" >}}, such as which columns are hidden, how values are formatted and how rows are sorted.
These are set by interacting with the results table in the UI and are stored on the rule alongside the query.

For an Analytic Rule these preferences affect only what you see while developing the query.
For a [Report]({{< relref "docs/user-guide/search/reports" >}}) they also affect the file that is produced, because the report is written from the same table.


## Parameters

A rule can define parameters in the same way as a Query document, and refer to them in the query.
Parameters are stored on the rule, so a scheduled rule always runs with the values held against it.
