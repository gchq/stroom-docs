---
title: "Reports"
linkTitle: "Reports"
weight: 50
date: 2026-09-02
tags:
  - analytic
  - report
description: >
  Reports run a query on a schedule and deliver the results as a file, by email or to a feed.
---

A Report {{< stroom-icon "document/Report.svg" >}} runs a query on a schedule and turns the results into a file, which is then delivered to the people or the {{< glossary "Feed" >}} you nominate.

Where an [Analytic Rule]({{< relref "docs/user-guide/search/analytics" >}}) {{< stroom-icon "document/AnalyticRule.svg" >}} turns each row of its query into a separate detection, a Report turns the whole result table into a single document.
Use a Report when somebody wants a periodic summary of what the data shows, and an Analytic Rule when somebody needs telling about individual things as they are found.


## How a Report Relates to an Analytic Rule

Reports and Analytic Rules are built on the same machinery and share most of their configuration.
Anything documented for Analytic Rules applies to Reports unless stated otherwise here.

Tab            | Difference from an Analytic Rule
-------------- | ---------------------------------
Query          | The same, except that the table preferences you set also shape the file produced, see [Query]({{< relref "#the-query" >}}).
Settings       | Reports only, see [Report Settings]({{< relref "settings" >}}).
Notifications  | The same destinations, but they deliver a file rather than a detection, see [Delivery]({{< relref "delivery" >}}).
Execution      | Identical, see [Execution]({{< relref "docs/user-guide/search/analytics/execution" >}}).
Documentation  | Included in the report's Excel info sheet and available to email templates.

The _Processing Type_ on a Report's _Execution_ tab offers only _Scheduled Query_.
Reports are always run on a schedule, so there is no streaming or table builder equivalent.
They also have no _Duplicate Management_ tab, because a report is a periodic summary and is expected to repeat.


## The Query

The _Query_ tab works as it does on an Analytic Rule, with one important difference.

The table preferences you set by interacting with the results, such as hidden columns, value formats and sort order, are stored on the report and applied when the report is generated.
What you see in the results table while developing the query is therefore what the recipient will get.

Relative date expressions resolve against the report's effective execution time rather than the current clock time, which is what allows a report for last month to be produced correctly today.

{{% see-also %}}
[Rule Queries]({{< relref "docs/user-guide/search/analytics/query" >}})
{{% /see-also %}}


## Jobs

Reports are run by the _Reports_ job, which is **disabled by default**.
A report will not run until that job has been enabled in {{< stroom-menu "Monitoring" "Jobs" >}}.

The job controls how often Stroom looks for report schedules that are due, not how often a report is produced.

{{% see-also %}}
[Jobs]({{< relref "docs/user-guide/jobs" >}})
{{% /see-also %}}


## Configuration

Reports use the same `stroom.analytics` configuration as Analytic Rules, including the SMTP settings that email delivery depends on, see [Email Setup]({{< relref "docs/install-guide/setup/email-setup" >}}).

The defaults offered in the UI for the processing node, error feed and destination feed come from `stroom.ui.reportUiDefaultConfig` rather than from the equivalent analytics property.
