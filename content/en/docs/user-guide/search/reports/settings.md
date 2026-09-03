---
title: "Report Settings"
linkTitle: "Settings"
weight: 10
date: 2026-09-02
tags:
  - report
description: >
  The file type a report produces, whether empty reports are sent, and AI summaries.
---

The _Settings_ tab controls what kind of file the report produces and what goes in it, and holds the feed that execution errors are written to.

An [Analytic Rule]({{< relref "docs/user-guide/search/analytics" >}}) {{< stroom-icon "document/AnalyticRule.svg" >}} has a _Settings_ tab of its own, holding what the rule declares about itself.
A report has none of those settings, because it delivers a file rather than detections.


## File Type

Field     | Description
--------- | ------------
File Type | The format of the file the report produces.

Four formats are available.

Format     | Notes
---------- | ------
{{< glossary "CSV" >}} | Comma delimited. For something else to read.
TSV        | Tab delimited. For something else to read.
Excel      | Includes an additional _Info_ sheet recording the report name, description, and execution times.
{{< glossary "Markdown" >}} | For a person to read.

Choose Excel or Markdown where a person will read the report, and CSV or TSV where something else will consume it.
The Excel _Info_ sheet is worth knowing about, because it is where the recipient can see which period the report actually covers.


## Send Empty Reports

Field              | Description
------------------ | ------------
Send Empty Reports | Whether a report whose query returned no rows is still delivered.

There is a real choice here.
Delivering empty reports means the recipient knows the report ran and there was nothing to say, rather than being left to wonder whether it failed.
Suppressing them avoids a stream of empty files for a report that is usually quiet.

Only emptiness suppresses delivery.
A report that returned rows is always delivered however this is set, and a report that is suppressed is still recorded in the [execution history]({{< relref "docs/user-guide/search/analytics/execution#execution-history" >}}) as having run.

{{% note %}}
The default is to deliver empty reports.
{{% /note %}}


## AI Summary

A report can ask a model to summarise the data it produced and deliver that summary with the report.

Field             | Description
----------------- | ------------
AI Summary        | Whether to ask a model to summarise the report's data.
AI Summary Model  | The model to ask. Where this is not set, the model configured for Ask Stroom AI is used.
AI Summary Prompt | What to ask about the data. Where this is not set, a default prompt asks for a short summary of what the data shows and anything worth attention.

Where the summary ends up depends on the file type, since CSV and TSV cannot carry prose without breaking them for whatever reads them.

File Type | Where the summary goes
--------- | -----------------------
Excel     | An _AI Summary_ sheet.
Markdown  | An _AI Summary_ section after the table.
CSV, TSV  | A separate Markdown file delivered alongside the report.

The summary is also available to email templates as `aiSummary` and is recorded as a `ReportAiSummary` entry in the stream meta where the report is delivered to a feed.

{{% note %}}
The report is what the recipient is waiting for, so a model that is unavailable, slow or misconfigured costs the summary and nothing else.
The failure is logged and the report is delivered without a summary.
{{% /note %}}

{{% warning %}}
AI summaries are a preview feature and are subject to breaking changes in future releases.
Using a model requires the `Use` permission on the model document rather than the ability to read it.
{{% /warning %}}

{{% see-also %}}
[AI Summaries on Reports]({{< relref "releases/v07.14/preview-features#ai-summaries-on-reports" >}})
{{% /see-also %}}


## Feed for Errors

Field           | Description
--------------- | ------------
Feed For Errors | The {{< glossary "Feed" >}} that errors occurring during execution are written to. Use _Set Default_ to use the feed configured for the system.

{{% see-also %}}
[Error Feed]({{< relref "docs/user-guide/search/analytics/execution#error-feed" >}})
{{% /see-also %}}
