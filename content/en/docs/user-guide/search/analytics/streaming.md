---
title: "Streaming Rules"
linkTitle: "Streaming"
weight: 60
date: 2026-09-02
tags:
  - analytic
description: >
  Rules that run against streams as they are processed rather than on a schedule.
---

A _Streaming_ rule is run by a {{< glossary "Processor Filter" >}} rather than by a schedule.
Each {{< glossary "Stream" >}} that matches the filter is passed through the rule as it is processed, so a detection is raised without waiting for the next scheduled run.

Use this type where the delay imposed by a schedule is unacceptable.
For most rules a [Scheduled Query]({{< relref "_index#scheduled-query" >}}) is the better choice, because it can look across a window of data rather than at one stream at a time.


## Data Source

A streaming rule must query a View {{< stroom-icon "document/View.svg" >}}, and that View must specify an extraction pipeline.

The View is what makes streaming possible.
Its filter determines which streams are selected for processing, and its extraction pipeline determines the fields the rule's query can use.

A rule whose query names anything other than a View, or whose View has no pipeline, fails when it is processed rather than when it is saved.
The error is reported against the rule, so a streaming rule that raises nothing at all is worth checking here first.

{{% see-also %}}
[Views]({{< relref "docs/reference-section/documents#view" >}})
{{% /see-also %}}


## Processing

The _Execution_ tab of a streaming rule shows the rule's processors and filters, in the same form as the _Processors_ tab of a pipeline.

When a filter is created for the rule, its expression is defaulted from the filter on the View the query uses.
You can then narrow it further, for example to a subset of feeds or a range of stream creation times.

Because streaming rules use the normal stream processing machinery, they behave like any other processing task.

* They are picked up by the standard stream processor jobs, not by the _Analytic Executor_ jobs.
* Their progress can be tracked, and they can be reprocessed, from the _Processors_ screen.
* Their priority competes with other processing on the node.

{{% see-also %}}
[HOWTO - Enabling Processors]({{< relref "docs/HOWTOs/General/EnablingProcessorsHowTo" >}})
{{% /see-also %}}


## Differences from a Scheduled Rule

A streaming rule has no execution schedules, and consequently no execution history, no effective execution time and no catch up behaviour.
Relative date expressions in the query resolve against the time of processing.

It also has no [Duplicate Management]({{< relref "duplicate-management" >}}) tab, so repeated detections must be controlled by [limiting notifications]({{< relref "notifications#limiting-notifications" >}}) instead.

Streaming rules are the only type that can use _Use Source Feed If Possible_ on a stream notification, which writes each detection to the feed the source data came from rather than to the destination feed, see [Stream Destinations]({{< relref "notifications#stream-destinations" >}}).

{{% note %}}
A streaming rule sees one stream at a time.
A query that needs to compare data across streams, or count over a period, will not work as a streaming rule and should be a scheduled one.
{{% /note %}}
