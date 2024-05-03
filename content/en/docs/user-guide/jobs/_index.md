---
title: "Background Jobs"
linkTitle: "Background Jobs"
weight: 20
date: 2024-04-25
tags: 
description: >
  Managing background jobs.
---

There are various jobs that run in the background within Stroom.
Among these are jobs that control pipeline processing, removing old files from the file system, checking the status of nodes and volumes etc.
Each job executes at a different time depending on the purpose of the job.
There are three ways that a job can be executed:

 1. [Cron]({{< relref "./scheduler#cron-schedules" >}}) scheduled jobs execute periodically according to a {{< glossary "cron" >}} schedule.
    These include jobs such as cleaning the file system where Stroom only needs to perform this action once a day and can do so overnight.
 1. [Frequency]({{< relref "./scheduler#frequency-schedules" >}}) controlled jobs are executed every X seconds, minutes, hours etc.
    Most of the jobs that execute with a given frequency are status checking jobs that perform a short lived action fairly frequently.
 1. Distributed jobs are only applicable to stream processing with a pipeline.
    Distributed jobs are executed by a worker node as soon as a worker has available threads to execute a jobs and the task distributor has work available.

A list of job types and their execution method can be seen by opening _Jobs_ from the main menu.

{{< stroom-menu "Monitoring" "Jobs" >}}

Each job can be enabled/disabled at the job level.
If you click on a job you will see an entry for each Stroom node in the lower pane.
The job can be enabled/disabled at the node level for fine grained control of which nodes are running which jobs.

For a full list of all the jobs and details of what each one does, see the [Job reference]({{< relref "/docs/reference-section/jobs" >}}).
