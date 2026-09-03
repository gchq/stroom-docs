---
title: "Analytic Rules"
linkTitle: "Analytic Rules"
weight: 40
date: 2026-09-02
tags: 
 - analytic
description: >
  Analytic Rules are queries that can be run against the data either as it is ingested or on a scheduled basis.
---

An Analytic Rule {{< stroom-icon "document/AnalyticRule.svg" >}} runs a query over your data and turns each row the query returns into a _detection_.
Detections are then delivered to one or more destinations, either written to a {{< glossary "Feed" >}} as XML or sent to people by email.

A rule is the combination of four things, each of which has its own tab on the rule.

* The [query]({{< relref "query" >}}) that decides what counts as a detection.
* The [processing type]({{< relref "#processing-types" >}}), which decides when and how the query is run.
* The [execution]({{< relref "execution" >}}) settings, which for a scheduled rule decide when it runs and over what period.
* The [notifications]({{< relref "notifications" >}}), which decide where detections are delivered.

If you want to run a query on a schedule and send the results to someone as a file rather than as detections, use a [Report]({{< relref "docs/user-guide/search/reports" >}}) {{< stroom-icon "document/Report.svg" >}} instead.
Reports and Analytic Rules share most of their configuration, so much of this section applies to both.


## Processing Types

The _Processing Type_ is set on the rule's _Execution_ tab and decides how the query is run.
It is the most significant choice you make about a rule, because it determines what the rest of the rule's configuration means.

Processing Type   | When the query runs                                     | Typical use
----------------- | ------------------------------------------------------- | ------------
Scheduled Query   | On a schedule that you define, over a window of data.    | Most rules.
Streaming         | Against each {{< glossary "Stream" >}} as it is processed. | Rules that must alert as close to ingest as possible.
Table Builder     | Experimental, see below.                                 | Not for production use.

Changing the processing type changes which tabs the rule shows, because some settings only apply to one type.

{{% note %}}
Whichever processing type you choose, the rule does nothing until the corresponding background job is enabled.
These jobs are all disabled by default, see [Jobs]({{< relref "#jobs" >}}) below.
{{% /note %}}


### Scheduled Query

A _Scheduled Query_ rule runs its query on a schedule, for example every hour or at 03:00 each day.
Each run covers a window of data, and the rule keeps track of which windows it has already covered so that it can work through history without gaps or repeats.

This is the type to use for most rules.
It is also the only type available to Reports.

{{% see-also %}}
[Execution]({{< relref "execution" >}})
{{% /see-also %}}


### Streaming

A _Streaming_ rule is run by a {{< glossary "Processor Filter" >}}, in the same way as a translation pipeline.
Each stream that matches the filter is passed through the rule as it is processed, so detections are raised without waiting for a schedule to come round.

{{% see-also %}}
[Streaming Rules]({{< relref "streaming" >}})
{{% /see-also %}}


### Table Builder

_Table Builder_ is an experimental feature and should not be used.

{{% see-also %}}
[Table Builder Rules]({{< relref "table-builder" >}})
{{% /see-also %}}


## Anatomy of a Rule

The tabs shown on an Analytic Rule depend on its processing type.

Tab                  | Shown for                | Purpose
-------------------- | ------------------------ | -----------
Query                | All                      | The query that defines the rule, see [Query]({{< relref "query" >}}).
Settings             | All                      | What the rule declares about itself, and where its errors go, see [Settings]({{< relref "settings" >}}).
Notifications        | All                      | Where detections are delivered, see [Notifications]({{< relref "notifications" >}}).
Execution            | All                      | Processing type, and the schedules for a Scheduled Query rule, see [Execution]({{< relref "execution" >}}).
Shards               | Table Builder only       | The data held in the rule's table, see [Table Builder Rules]({{< relref "table-builder" >}}).
Duplicate Management | Scheduled Query only     | Suppression of repeated detections, see [Duplicate Management]({{< relref "duplicate-management" >}}).
Documentation        | All                      | {{< glossary "Markdown" >}} describing the rule.
Permissions          | All                      | Who can read and use the rule.

The content of the _Documentation_ tab is not just for readers.
It is also used as the `detailedDescription` of the detections the rule raises, so it is worth writing something that will make sense to whoever receives the detection.
This can be turned off per rule with _Include Rule Documentation_ on the _Settings_ tab.


## Jobs

Analytic Rules are run by background jobs, all of which are **disabled by default**.
A newly created rule will do nothing at all until the job for its processing type has been enabled in {{< stroom-menu "Monitoring" "Jobs" >}}.

Job                                  | Drives
------------------------------------ | ---------
Analytic Executor: Scheduled Query   | Scheduled Query rules.
Analytic Executor: Table Builder     | Table Builder rules.
Analytic Execution History Retention | Deletion of old execution history.

Streaming rules are run by the normal stream processing jobs rather than by a job of their own.

The job frequency controls how often Stroom looks for schedules that are due, not how often a rule runs.
A rule scheduled to run every ten minutes will not do so if the job that looks for due schedules only runs hourly.

{{% see-also %}}
[Jobs]({{< relref "docs/user-guide/jobs" >}})
{{% /see-also %}}


## Configuration

Some rule behaviour is set by system properties rather than on the rule itself.

Property                                     | Purpose
-------------------------------------------- | ---------
`stroom.analytics.timezone`                  | The time zone used when generating detections.
`stroom.analytics.executionHistoryRetention`  | How long execution history is kept.
`stroom.analytics.emailConfig`                | The SMTP server used for email notifications, see [Notifications]({{< relref "notifications#email-destinations" >}}).
`stroom.analytics.duplicateCheckStore`        | The store behind [Duplicate Management]({{< relref "duplicate-management" >}}).
`stroom.ui.analyticUiDefaultConfig`           | The defaults offered in the UI for processing node, error feed and destination feed.

{{% see-also %}}
[Properties]({{< relref "docs/user-guide/properties" >}})
{{% /see-also %}}
