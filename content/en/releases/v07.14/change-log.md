---
title: "Change Log"
linkTitle: "Change Log"
weight: 50
date: 2026-09-01
tags: 
description: >
  Full list of changes in this release.
---

<!--
To build this list run get_stroom_changelog_content.sh.
You need to provide it with the path to a stroom repo that has all the latest commits
for the two branches being compared. You can run it between tags (e.g. v7.11-beta.21 v7.11-beta.22) if
you need to add in the changes for a patch release.

E.g. ./get_stroom_changelog_content.sh ../stroom_v7_13 7.13 7.14

OR, if you use Vim use this command (changing the path to the stroom repo) to read it straight into this buffer
(Hash '#' needs to be escaped with '\' to stop vim replacing it with the current file path)
:r !./get_stroom_changelog_content.sh ../stroom_v7_13 7.13 7.14
-->


<!-- Changes between the latest v7.13 release and v7.14 -->


<!-- Changes between 'v7.13.0' and 'v7.14-beta.8' taken on Mon 19 Oct 08:25:47 BST 2026 -->


## New Features and Changes

* Feature : Add `random-integer(upperbound)` XSLT function.

* Feature **{{< external-link "#5833" "https://github.com/gchq/stroom/issues/5833" >}}** : Add XSLT function `send-email()` to send an email using the SMTP server configured in `stroom.analytics.emailConfig`.

* Feature **{{< external-link "#5834" "https://github.com/gchq/stroom/issues/5834" >}}** : Enterprise Floor Mapping

* Feature **{{< external-link "#5771" "https://github.com/gchq/stroom/issues/5771" >}}** : Traces: store, publish and browse as a first-class document type on a shared fs.

* Feature **{{< external-link "#5546" "https://github.com/gchq/stroom/issues/5546" >}}** : Add an S3 forwarder to proxy to forward proxy format ZIPs to S3. Add an SQS consumer to Stroom to consume S3 create events and create a meta record for the S3 based file. Add the volume type `S3 v1 (Read only)` for reading data from an S3 store that Stroom only has read access to.

* Feature **{{< external-link "#5279" "https://github.com/gchq/stroom/issues/5279" >}}** : Add experimental volume type `S3 v2 (Experimental)` that uses framed ZStandard compression. This is work in progress and not for production use.

* Feature **{{< external-link "#5662" "https://github.com/gchq/stroom/issues/5662" >}}** : Add stepping data store to cache stepping data and improve stepping performance.

* Feature **{{< external-link "#5690" "https://github.com/gchq/stroom/issues/5690" >}}** : Add task creation linear backoff to reduce futile attempts to create tasks for filters with less/no data to process.

* Feature **{{< external-link "#5691" "https://github.com/gchq/stroom/issues/5691" >}}** : Add task creation budgets per processor profile to ensure all profiles get tasks to process.

* Feature **{{< external-link "#5699" "https://github.com/gchq/stroom/issues/5699" >}}** : Add a per-task heartbeat job that renews the status time of tasks a node is processing, so live long-running tasks can be told apart from tasks owned by a dead node. Note that for processing tasks the Status Time now shows the time of the last heartbeat.

* Feature **{{< external-link "#5699" "https://github.com/gchq/stroom/issues/5699" >}}** : Replace the master-only Disown Dead Tasks job with a cluster-locked Processor Task Reaper driven by per-task heartbeats: stale processing tasks are returned to the task queue even when there is no master node, a node that cannot renew its heartbeats terminates its own in-flight tasks to prevent duplicate output, and a task status write that loses its optimistic lock is abandoned instead of forced. The stroom.processor.disownDeadTasksAfter property is replaced by stroom.processor.taskLeaseTimeout. This must not be deployed in the same release as the task heartbeat change - every node must already be heart-beating before the reaper replaces the node-contact check, or long-running tasks on not-yet-upgraded nodes will be falsely reaped.

* Feature **{{< external-link "#5699" "https://github.com/gchq/stroom/issues/5699" >}}** : Add the per node processor task availability summary and eligible filter computation that let a worker node work out for itself which processor filters it is allowed to process and which of them have tasks waiting, in a single query rather than one per filter. Not yet used to claim tasks. Adds the stroom.processor.taskAvailabilityInterval property.

* Feature **{{< external-link "#5699" "https://github.com/gchq/stroom/issues/5699" >}}** : Restoring a logically deleted processor filter, e.g. by importing a filter over one that was deleted, now replaces it with a new filter that takes over its UUID and records the deleted filter as its parent, instead of resetting the deleted filter's tracker and reusing it. This keeps a processor filter ID meaning one fixed body of work, so that the completed tasks of the old filter still refer to a tracker that reflects them, and adds the processor_filter.parent_filter_id column. Note that restoring a filter that still has active tasks no longer fails.

* Feature **{{< external-link "#5699" "https://github.com/gchq/stroom/issues/5699" >}}** : Add an experimental mode, stroom.processor.claimTasksOnWorker, **off by default**, in which each worker node finds and claims its own processor tasks directly from the database rather than being fed by the task queue held in memory on the master node. It is not yet proven in production, so leave it off unless you have been asked to trial it; with it off Stroom behaves as before, using the master's task queue. A worker knows which filters its own processing profiles allow it to run, so it no longer has to be guessed at on its behalf, and task assignment no longer depends on there being a master node. Tasks are claimed with SKIP LOCKED so that nodes claiming at the same time get different tasks, oldest first. A new ProcessorTaskClaiming system info entry gathers what every node is doing at the moment it is asked, replacing the master only view of the task queue. This must be set the same on every node and changing it is a hard cutover: stop the whole cluster, change the value everywhere, then start it again. Running a mixed cluster is not supported. Tasks left behind by either mode are returned to the created state and reprocessed, so switching either way loses no work, though tasks that were in flight when the cluster stopped wait for stroom.processor.taskLeaseTimeout before another node picks them up. The Processor Task Reaper also returns any tasks left behind by the master's queue to the created state once this mode is on.

* Feature **{{< external-link "#1890" "https://github.com/gchq/stroom/issues/1890" >}}** : Add an optional sixth argument to `bitmap-lookup` to set the delimiter placed between the values of the matched bit positions. Defaults to a single space.

* Feature **{{< external-link "#5751" "https://github.com/gchq/stroom/issues/5751" >}}** : Add `ask-ai()` XSLT and `askAi()` StroomQL functions to ask a named OpenAI model a question and return its answer.

* Feature **{{< external-link "#5761" "https://github.com/gchq/stroom/issues/5761" >}}** : Add AI summaries to reports.


## Bug Fixes

* Bug **{{< external-link "#5843" "https://github.com/gchq/stroom/issues/5843" >}}** : Fix NPE when fetching explorer tree nodes with debug logging enabled.

* Bug **{{< external-link "#5597" "https://github.com/gchq/stroom/issues/5597" >}}** : Fix `TypeError: Cannot read properties of null` error when an embedded query with a visualisation returns no rows.

* Bug **{{< external-link "#5853" "https://github.com/gchq/stroom/issues/5853" >}}** : Fix error saying SQS has not been configured when it has.

* Bug : Fix the OK and Cancel buttons being permanently disabled when OK is clicked on the Lucene index New Field dialog with a blank name.

* Bug : Fix pooled byte buffer resource closure.

* Bug : Fix more issues with failure handling during S3 event consumption.

* Bug **{{< external-link "#5835" "https://github.com/gchq/stroom/issues/5835" >}}** : Stop logging an ERROR on every run of the Table Builder analytic job for each rule with an empty or broken query. A WARN is now only logged if such a rule is preventing an existing store from being deleted.

* Bug **{{< external-link "#5819" "https://github.com/gchq/stroom/issues/5819" >}}** : Replace the Lucene 8.11.4 `lucene-analyzers-common` dependency with `lucene-analysis-common:10.3.2` so that it matches the version of Lucene core.

* Bug **{{< external-link "#5667" "https://github.com/gchq/stroom/issues/5667" >}}** : Fix scheduled analytic, report and data generation execution needlessly using single-threaded work queues. Executions now run sequentially on the calling thread.

* Bug **{{< external-link "#5844" "https://github.com/gchq/stroom/issues/5844" >}}** : Fix termination handling for S3 event notifications poll job. Also stop it spamming the logs when there is a problem. Added the property `sleepDurationPostFailure` to control sleep time after a failure.

* Bug **{{< external-link "#5809" "https://github.com/gchq/stroom/issues/5809" >}}** : Change the Admin account bootstrap process to use `tryLock` rather than `lock` to save holding up the other nodes.

* Bug **{{< external-link "#5793" "https://github.com/gchq/stroom/issues/5793" >}}** : Fix `No enabled forward destinations are configured` error when booting proxy with only an S3 forward destination enabled.

* Bug : Fix error handling in stream viewer when data does not exist in S3.

* Bug **{{< external-link "#5683" "https://github.com/gchq/stroom/issues/5683" >}}** : Fix processor filters silently skipping a stream that was still being committed when task creation read the max stream id, leaving it permanently unprocessed. Task creation is now bounded by the max stream id seen on the previous poll, which costs up to one poll interval of extra latency before a new stream gets a task and can be turned off with the property `stroom.processor.useMaxMetaIdFromPreviousPoll`.

* Bug **{{< external-link "#5713" "https://github.com/gchq/stroom/issues/5713" >}}** : Fix `bitmap-lookup` returning the values of the matched bit positions concatenated with no delimiter. The values are now space delimited as documented.

* Bug : DataGen Issues.


## Dependency Changes

* Dependency : Bumps poi from 5.4.1 to 5.5.1.

* Dependency : Bumps software.amazon.awssdk.crt:aws-crt from 0.47.0 to 0.48.5.

* Dependency : Bumps jakarta.xml.bind:jakarta.xml.bind-api from 4.0.2 to 4.0.5.

* Dependency : Uplift lucene from 10.3.2 to 10.5.1.

* Dependency : Uplift org.apache.commons:commons-fileupload2-jakarta-servlet6 from 2.0.0-M4 to 2.0.0-M5.

* Dependency : Uplift Jooq to v3.21.9.

* Dependency : Bumps com.openai:openai-java from 4.3.0 to 4.69.3.

* Dependency : Uplift docker image base to eclipse-temurin:25.0.4.1_1-jdk-alpine-3.24.

* Dependency : Add missing jackson annotation dependencies.


## Code Refactor

* Refactor : Refactor `meta-stream` and `meta-stream-for-id` into two classes. Refactor `manifest` and `manifest-for-id` into two classes.


## Build Changes

* Build : Bumps org.yaml:snakeyaml from 2.6 to 2.7 in the build script.

* Build : Bump com.gradle.develocity from 4.2.2 to 4.4.1.

* Build : Uplift gradle to 9.8.0.

* Build : Change ERD dockerfile to use debian:trixie-slim, uplift plant_erd to v0.4.12.

* Build : Uplift PlantUML to v1.2026.8 and fix SVG generation script.

* Build : Split up java CI build to reduce memory use and to make checkstyle fail fast.
