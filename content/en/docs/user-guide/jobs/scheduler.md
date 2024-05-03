---
title: "Scheduler"
linkTitle: "Scheduler"
#weight:
date: 2024-04-25
tags:
  - job
description: >
  How background jobs are scheduled.
---

Stroom has two main types of schedule, a simple frequency schedule that runs the job at a fixed time interval or a more complex {{< glossary "cron" >}} schedule.

{{% note %}}
This scheduler and its syntax are also used for Analytic Rules {{< stroom-icon "document/AnalyticRule.svg" >}}.
{{% /note %}}


## Frequency Schedules

A frequency schedule is expressed as a fixed time interval.
The frequency schedule expression syntax is stroom's standard duration syntax and takes the form of a value followed by an optional unit suffix, e.g. `10m` for ten minutes.

Prefix | Time Unit
-------|-------------
       | milliseconds
`ms`   | milliseconds
`s`    | seconds
`m`    | minutes
`h`    | hours
`d`    | days


## Cron Schedules

{{< glossary "cron" >}} is a syntax for expressing schedules.

For full details of cron expressions see [Cron Syntax]({{< relref "docs/reference-section/cron" >}})

Stroom uses a scheduler called Quartz which supports cron expressions for scheduling.




