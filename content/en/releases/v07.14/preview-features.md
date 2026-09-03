---
title: "Preview Features (experimental)"
linkTitle: "Preview Features"
weight: 20
date: 2026-09-01
tags: 
description: >
  Preview features in Stroom version 7.14.
  Preview features are somewhat experimental in nature and are therefore subject to breaking changes in future releases.
---

## Asking a Model about Your Data

The AI capability introduced by Ask Stroom AI in v7.11 can now be used from a translation, from a query, and from a report.
All three ask a model defined by an `OpenAIModel` document, and all three require the `Use` permission on that document rather than the ability to read it.

Like Ask Stroom AI itself, these remain preview features and are subject to breaking changes in future releases.


### The `ask-ai()` XSLT Function

A translation can now ask a model a question with `stroom:ask-ai()`, passing the model to use, the message to ask, and optionally a system prompt.

{{% warning %}}
The model is asked once per call, so a pipeline that calls this for every record will make one request per record.
Repeated identical questions are served from a cache, but a translation that asks something different of every record will be slow.
{{% /warning %}}

{{% see-also %}}
[`ask-ai()`]({{< relref "docs/user-guide/pipelines/xslt/xslt-functions/ai" >}})
{{% /see-also %}}


### The `askAi()` StroomQL Function

Queries and dashboards gain a matching `askAi()` expression function, under a new _AI_ function category.
As with the XSLT function the model is asked once per value, so it is best used on a grouped or otherwise small set of rows.

{{% see-also %}}
[AI Functions]({{< relref "docs/reference-section/expressions/ai" >}})
{{% /see-also %}}


### AI Summaries on Reports

A _Report_ can now ask a model to summarise the data it produced, and deliver that summary alongside the report.
This is turned on per report from the report's _Settings_ tab, where you can also choose the model and change the prompt.
If no model is chosen the one configured for Ask Stroom AI is used, and if no prompt is given a default one asks for a short summary of what the data shows and anything worth attention.

Where the summary goes depends on the report's file type.

* Excel reports gain an _AI Summary_ sheet alongside the existing _Info_ sheet.
* Markdown reports gain an _AI Summary_ section after the table.
* CSV and TSV reports cannot carry prose without breaking them for whatever reads them, so the summary is written to a separate Markdown file.

However the report is delivered, the summary is also available in two other places.

* Email notifications can use it in the subject or body template as `{{ aiSummary }}`, and where the report is a CSV or TSV the summary file is attached alongside the report.
* Stream notifications record it as a `ReportAiSummary` entry in the stream meta.
  The report data itself is unchanged, so anything already reading those streams is unaffected.

Large reports are summarised in batches which are then merged, so a report bigger than the model's context window still produces a summary.
Where only some batches succeed, the summary says how much of the data it covers.

{{% note %}}
The report is what the recipient is waiting for, so a model that is unavailable, slow or misconfigured costs the summary and nothing else.
The failure is logged and the report is sent without a summary.
{{% /note %}}

{{% see-also %}}
* [Report Settings]({{< relref "docs/user-guide/search/reports/settings#ai-summary" >}})
* [Report Delivery]({{< relref "docs/user-guide/search/reports/delivery" >}})
{{% /see-also %}}
