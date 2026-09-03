---
title: "Report Delivery"
linkTitle: "Delivery"
weight: 20
date: 2026-09-02
tags:
  - report
description: >
  Delivering a report by email or to a feed, and the template context available to report emails.
---

The _Notifications_ tab of a Report works in the same way as it does for an [Analytic Rule]({{< relref "docs/user-guide/search/analytics/notifications" >}}), with the same two destination types and the same limit settings.
The difference is what gets delivered.
A rule delivers a detection, whereas a report delivers the file it produced.

A report can have several notifications, so the same report can be emailed to a distribution list and written to a feed for retention at the same time.


## Email Delivery

The report is sent as an **attachment**, with the subject and body rendered from the notification's templates.

Where the report is a CSV or TSV and an [AI summary]({{< relref "settings#ai-summary" >}}) was produced, the summary is attached as a second file rather than being packed into an archive, so the recipient does not have to unpack anything.

The file name is derived from the report name and the effective execution time, so a recipient who keeps several editions can tell them apart.


### Template Context

Report email templates use the same _Jinja_ syntax as rule detection templates but have a completely different set of variables available, because a report is not a detection.

Variable                 | Description
------------------------ | ------------
`reportName`             | The name of the Report {{< stroom-icon "document/Report.svg" >}}.
`description`            | The content of the report's _Documentation_ tab.
`executionTime`          | The wall clock time at which the report ran.
`effectiveExecutionTime` | The point in time the report covers.
`rowCount`               | The number of rows in the report.
`fileType`               | The format of the attached file.
`fileName`               | The name of the attached file.
`aiSummary`              | The AI summary, or an empty string where there is none.

`aiSummary` is always present so that a template using it renders whether or not a summary was produced.

{{% note %}}
None of the detection variables, such as `detectTime`, `headline` or `values`, are available to a report template.
A template written for an Analytic Rule will not work on a Report.
{{% /note %}}

{{% see-also %}}
[Templating]({{< relref "docs/reference-section/templating" >}})
[Report Context]({{< relref "docs/reference-section/templating#report-context" >}})
{{% /see-also %}}


## Feed Delivery

A _Stream_ notification writes the report into a {{< glossary "Feed" >}} as a stream of type `Report`.

The stream carries the report file itself, unchanged, so anything already reading those streams is unaffected by settings such as the AI summary.
The following entries are written to the stream {{< glossary "Metadata" >}}.

Meta Key                 | Description
------------------------ | ------------
`ReportName`             | The name of the report.
`ReportDescription`      | The content of the report's _Documentation_ tab.
`ExecutionTime`          | The wall clock time at which the report ran.
`EffectiveExecutionTime` | The point in time the report covers.
`ReportAiSummary`        | The AI summary, where one was produced.

Writing reports to a feed is how you retain a record of what was reported and when, independently of whoever received the email.

{{% note %}}
_Use Source Feed If Possible_ has no effect on a Report, as it only applies to streaming Analytic Rules.
Reports are always written to the _Destination Feed_.
{{% /note %}}


## Limiting

The _Limit Notifications_, _Maximum Notifications_ and _Resume Notifications After_ settings behave exactly as they do for an Analytic Rule.

They are far less likely to matter for a report, because a report produces one file per run rather than one notification per matching row.

{{% see-also %}}
[Limiting Notifications]({{< relref "docs/user-guide/search/analytics/notifications#limiting-notifications" >}})
{{% /see-also %}}
