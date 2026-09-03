---
title: "Detections"
linkTitle: "Detections"
weight: 40
date: 2026-09-02
tags:
  - analytic
description: >
  What a detection contains, how it is built from the rule's query, and the XML written to a feed.
---

A _detection_ is what an Analytic Rule produces.
One is raised for each row the rule's query returns, and it is the detection, rather than the row, that is delivered to the rule's [notifications]({{< relref "notifications" >}}).

Detections written to a {{< glossary "Feed" >}} are XML in the `detection:1` namespace, so they can be indexed and searched like any other data in Stroom.
Detections sent by email are rendered through a template that has access to the same fields.

{{% warning %}}
A rule's detections do not currently validate against the published `detection:1` {{< glossary "XML Schema" >}} in the core content pack.
Stroom writes `detectorUuid`, `executionSchedule`, `executionTime`, `effectiveExecutionTime`, `level`, `status` and `feedName`, none of which that schema declares, and the schema requires a `headline` element that a rule does not produce.
This affects validation only, for example an XML Schema filter in a pipeline.
Indexing, searching and delivery are unaffected.
{{% /warning %}}


## How a Detection is Built

Most of a detection is filled in for you from the rule and from the run that raised it.

Field                    | Where it comes from
------------------------ | --------------------
`detectTime`             | When the detection was raised.
`detectorName`           | The name of the Analytic Rule {{< stroom-icon "document/AnalyticRule.svg" >}}.
`detectorUuid`           | The {{< glossary "UUID" >}} of the rule document.
`detectorVersion`        | The version of the rule document at the time it ran.
`detailedDescription`    | The content of the rule's _Documentation_ tab, see below.
`detectionUniqueId`      | A generated {{< glossary "UUID" >}}, different for every detection.
`detectionRevision`      | Always `0` for detections raised by a rule.
`executionSchedule`      | The name of the [execution schedule]({{< relref "execution" >}}) that fired, for a scheduled rule.
`executionTime`          | The wall clock time at which the rule ran.
`effectiveExecutionTime` | The point in time the run represented.
`values`                 | One entry per column in the query, see below.
`linkedEvents`           | Built from the `StreamId` and `EventId` columns, see below.
`level`                  | The severity declared by the rule, where it declares one, see [Settings]({{< relref "settings#level-and-status" >}}).
`status`                 | How reliable the rule declares itself to be, where it declares it, see [Settings]({{< relref "settings#level-and-status" >}}).

Because `detailedDescription` comes from the rule's documentation, what you write there is delivered with the detections the rule raises.
It is worth writing it for whoever receives the detection rather than for whoever maintains the rule.

Whether it is included is controlled by _Include Rule Documentation_ on the [Settings]({{< relref "settings" >}}) tab, which applies to every processing type.
Where it is unticked, `detailedDescription` is left empty.

{{% note %}}
`detectorVersion` is the version of the rule document, which changes every time the rule is saved.
It is not a version you set yourself.
{{% /note %}}


## Values

Every column the query selects becomes an entry in `values`, keyed by the column name.
In a feed these appear as `<value name="...">` elements, and in an email template they are reachable through the `values` dictionary.

The two exceptions are `StreamId` and `EventId`.
Rather than appearing in `values`, they are used to build a linked event, which records the {{< glossary "Stream" >}} and {{< glossary "Event" >}} the detection relates to.
A detection whose query selects neither will have no linked events.

{{% see-also %}}
[Columns]({{< relref "query#columns" >}})
{{% /see-also %}}


## Fields a Rule Does Not Set

The `detection:1` schema has several fields that an Analytic Rule never populates, because they only make sense for a detector that revises its own findings over time.

Field               | Purpose
------------------- | --------
`headline`          | A short description of what was detected.
`fullDescription`   | A complete description of what was detected.
`detectorEnvironment` | Where the detector was deployed.
`defunct`           | Marks earlier revisions of a detection as invalid.

These exist because the same schema is used by detections produced outside Stroom, for example by an XSLT in a translation pipeline or by an external processing framework, which can set them.

{{% see-also %}}
[Rule Detections Context]({{< relref "docs/reference-section/templating#rule-detections-context" >}})
{{% /see-also %}}


## Detections as a Data Source

Writing detections to a feed means they can be treated as data in their own right.
Once indexed they can be searched from a [Dashboard]({{< relref "docs/user-guide/search/dashboards" >}}) or [Query]({{< relref "docs/user-guide/search/queries" >}}), reported on, and used as the input to further rules.

A rule whose query runs over a feed of detections is a common way of spotting a pattern across detections that no single detection shows on its own.
