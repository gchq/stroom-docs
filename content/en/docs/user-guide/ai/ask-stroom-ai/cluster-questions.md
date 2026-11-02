---
title: "Questions about the cluster"
linkTitle: "Questions about the cluster"
weight: 25
date: 2026-10-31
tags:
  - ai
  - processing
  - configuration
description: >
  What the agent can tell an administrator about processing tasks, server tasks, system properties, volumes, data retention and Elasticsearch index templates, and the permissions each needs.
---

The agent can answer an administrator's questions about how the cluster is running, from the same state Stroom's own screens show.
Each of these tools only reads: none of them changes anything, and each needs the permission of the screen it reads.
For why a pipeline, feed or stream isn't processing, see [Finding why processing fails or stalls]({{< relref "../pipeline-admin/editing-pipelines#finding-why-processing-fails-or-stalls" >}}).


## Processing Tasks

> _"What's failing in processing today, and why?"_ or _"How many tasks are queued per node?"_

The agent can look at processor tasks across the cluster, filtered by pipelines (or analytic rules), feeds, nodes, processor filters, streams, statuses and a time window (e.g. `P7D`, `-7d` or `now()-1d`).

* **Failures** (the last 24 hours unless you give a window): the tasks by status, and by pipeline, feed and node with their failure rates, calling out a node with most of the failures; the failed tasks grouped, with their first and last times; tasks that look stuck (assigned or processing with no update for an hour, by default); and the kinds of error in the Error streams written in the window, from a sample of them (30 by default, at most 100), grouped by severity, element and message, with examples linked to their streams.
* **Lists** of tasks, newest first (50 by default, at most 500, or all of them to a CSV file in the chat's workspace).
* **Counts** of tasks by any of pipeline, feed, node, status and filter.

Stroom doesn't record why a task failed: the reason goes only to the application log of the node that ran it.
The agent doesn't read logs; it gives you the node and the times to look for in your log system.

It needs _Manage Processors_, as the **Processors** screen does.
Only tasks whose pipeline and feed you can view are counted, and Error streams are read only with _Data - View_.
Every limit the agent reaches is said in its answer.


## Server Tasks

> _"How many searches are users running, and who's running the longest?"_ or _"What is node-2 busy with?"_

The live view of **Monitoring** > **Server Tasks**: the tasks running on every enabled node now, counted by task name, user and node, listed, or one task shown with its sub-tasks.
Asked about searches, the agent counts each user's search once, by its top-level task, rather than by the sub-tasks it runs on every node, and says which searches have finished but are holding their results for a dashboard.

Every node is asked at once, waiting at most 15 seconds; the answer says which nodes answered and which didn't (their tasks are missing).
It needs _Manage Tasks_, and never stops a task.


## System Properties

> _"Why are my users' search results capped at 1,000,000, and how do I change that?"_

The agent can search the system properties by the words in their names and descriptions, get up to 10 in full (description, default, database value with who set it and when, each node's YAML value, the effective value and where it comes from, whether a change needs a restart), and list those under a path, e.g. `stroom.ui`.
It says how a value is changed: a database value on the **Properties** screen reaches every node within about a minute, while a YAML value applies to its node only and wins over the database value there.

It needs _Manage Properties_.
Secrets are masked: password properties, properties named like secrets, and credentials inside any other value (a URL's password, a token, an API key).


## Volumes

> _"Why has my data stopped being written?"_

Whether each data and index volume group can still be written to, and how Stroom treats volumes as they fill.
With _Manage Volumes_, each volume is given with its path, state and space; without it, only whether each group can be written to.

Stroom never deletes data to make room: when no volume of a group can be written to, data received for its feeds and the output of processing fail until space is freed, a limit is raised or a volume is added.
Streams are only deleted by data retention rules, or by a user, and index shards by their index's own retention.


## Data Retention

> _"How long is the ACME-EVENTS feed's data kept, and what would be deleted now?"_

The data retention rules in the order they apply, the rule that keeps a feed's or stream's data and until when, what the rules would delete now, and the jobs that do the deleting.
The rules and what they would delete need _Manage Policies_, as the **Data Retention** screen does, and the jobs _Manage Jobs_; without them, the rule that keeps each of your own streams is still given, as the **Data** screen gives it.


## Elasticsearch Index Templates

> _"Show me the index template behind the ACME index."_

Given an Elastic Index document, the agent reads, through the document's own cluster connection, the index template that applies to its index and each component template it is made of, and shows each one exactly as Elasticsearch returns it, under its name, for you to review or reproduce elsewhere.
It also names the newest index or data stream the index resolves to, and any lower-priority templates that match but don't apply.
A part Elasticsearch didn't give is shown with why: not found, forbidden (with Elasticsearch's message naming the missing privilege), or an error.

It needs View on the Elastic Index document, and the cluster's credentials need the Elasticsearch privileges to read templates.
It changes nothing in Elasticsearch.
