---
title: "Prompt guide"
linkTitle: "Prompt guide"
weight: 15
date: 2026-10-27
tags:
  - ai
description: >
  What you can ask Ask Stroom AI to do, with example prompts, and how to get good answers.
---

Ask in plain words, as you would ask a colleague who knows Stroom.
The agent finds what it needs with its tools (as you, with your permissions), so you don't need to say which tool to use, or give UUIDs or paths.
The examples below show what it can do; the tools behind each depend on your [tool policies]({{< relref "../agent-tools/tool-policies" >}}) and permissions.


## Getting Good Answers

* **Attach what you mean.**
  The chat only sees the tab you attach (the chip above the input box), and documents and tables you attach.
  _"Why is this pipeline failing?"_ with the pipeline attached is quicker and surer than naming it.
* **Name the thing and the time.**
  _"Errors in the ACME-EVENTS feed since Monday"_ beats _"any errors?"_.
* **Say what you want back.**
  A table, a count, a short explanation, a chart or a change to apply.
* **Use the modes.**
  _Ask_ for questions only, _Plan_ to have the agent work out a plan without doing anything, then _Agent_ to carry it out.
  `/plan <task>` does the first in one step.
* **Steer as it works.**
  A message sent while the agent works is read once its current step finishes, e.g. _"Only look at node-2"_.
* **Let it ask.**
  For a task with decisions in it, the agent asks you, with what it recommends first; answer, and it carries on.

The agent proposes changes rather than making them where it can: a change to a query, dashboard, XSLT or documentation comes as a button for you to apply and save.


## Documents and Content

* _"What's in the Security folder?"_
* _"Find the XSLTs that use the `userLookup` map."_
* The documents that depend on a pipeline, and those it depends on: _"What uses this pipeline?"_
* _"Explain what this XSLT does to a 4625 event."_
* _"Which reference data loaders write the maps this translation looks up?"_
* _"Show me this document's history: who changed it and when?"_
* _"Write documentation for this pipeline"_ (proposed as a change to its Documentation tab, or, with the build tools, written as a full Documentation document with its field mapping: see [Documenting an existing pipeline]({{< relref "../pipeline-admin/editing-pipelines#documenting-an-existing-pipeline" >}}))


## Feeds and Data Sources

* _"What does the ACME-EVENTS feed hold, and how much has it received this week?"_
* _"What is `User.DomainName` in this feed, and how do I find domains ending in example.com?"_
* _"Which data sources can I query for firewall events?"_
* _"Which fields does the Windows Events index have, and which searches on it would mislead?"_
* _"Onboard the ACME firewall logs; samples are in stream 123"_ (see [Onboarding a data source]({{< relref "../pipeline-admin/onboarding" >}}))
* _"Index the raw ACME JSON as it is, so I can see what's in it"_ (a discovery index)
* _"Load the asset list in stream 789 as reference data"_


## Pipelines and Translations

* _"Which pipelines process this feed?"_
* _"Show me this pipeline as Stroom runs it, with what it inherits from its template."_
* With a pipeline's Stepping view attached:
  * _"Why is this record producing an error?"_
  * _"Fix the time stamp so it is in UTC"_ (proposed as a change to the XSLT, tried by stepping first, with _Review and apply_)
* _"Step the records of stream 4567 through the new version, and compare the output with the current one."_
* _"Translate the new event type in this feed; it isn't covered yet."_
* _"Evaluate the ACME-EVENTS pipeline and tell me what to improve"_ (see [Evaluating a pipeline]({{< relref "../pipeline-admin/editing-pipelines#evaluating-a-pipeline" >}}))


## Streams and Processing

* _"What's failing in processing today, and why?"_
* _"Which tasks for the ACME pipeline failed, on which nodes, and for which streams?"_
* _"How many tasks are queued on each node?"_
* _"Summarise the errors in this feed's Error streams from the last 24 hours."_
* Tracing a stream back to its raw stream, record, pipeline and code: _"Where did stream 73145 come from?"_
* _"Find the Raw Events streams of ACME-EVENTS received yesterday, by size."_
* _"Is anything stuck?"_
* _"Is processing healthy?"_
* Checking processing link by link, from the nodes and jobs to each processor filter (see [Finding why processing fails or stalls]({{< relref "../pipeline-admin/editing-pipelines#finding-why-processing-fails-or-stalls" >}})): _"Why isn't the ACME-EVENTS pipeline processing anything?"_


## Searching

* _"How many failed logins were there per user in the last 7 days?"_
* _"Write a StroomQL query for DNS lookups of domains no one looked up last month"_ (offered as a button to create the query)
* _"Show me the events behind the top 5 rows."_
* _"Which of these events have a `Proxy` element, and what's in it?"_
* A new dashboard, classic or StroomQL, which the agent asks how to build and then offers as a button (see [Building dashboards]({{< relref "dashboards" >}})): _"Build me a dashboard of web traffic by host, with a data preview"_


## Dashboards, Tables and Charts

With a dashboard or query attached:

* _"Add a table of the top 10 source IPs, and refresh the dashboard every 10 minutes."_

* _"Add a column with the user's domain, and group by it."_
* _"Highlight rows where the status is FAILED in red."_
* _"Add a tab for each event category."_
* _"Chart events per hour as a line chart, with a trend line"_ (see [Creating charts]({{< relref "charts" >}}))
* _"Show who messages whom as a network, and find the groups."_
* _"What's this spike?"_ or _"Explain what I've selected"_ (on a chart)
* _"Add each user's department to this table; it's in the events"_ (see [Adding fields from events]({{< relref "search-extraction" >}}))
* _"Which users logged in from more than three countries?"_
* Figures worked out exactly, in code: _"What share of each host's requests failed this week?"_
* Patterns in free text: _"What kinds of error message are in this table?"_
* _"Which charts could I make from this table?"_ or _"What can I do with this network graph?"_
* _"Make a gauge for each numeric column, in a grid."_

See [Analysing tables and charts]({{< relref "analytics" >}}) for the analysis the agent can do, with more examples.


## Indexing and Elasticsearch

* _"Show me the index template behind this Elastic Index."_
* _"Index the ACME events, following ECS"_ (part of onboarding)
* _"Why are this index's searches on `host.name` returning nothing?"_


## Configuration and the Cluster

These need the permissions of the screens they read (_Manage Properties_ for properties, _Manage Tasks_ for server tasks, _Manage Processors_ for processing).

* _"Why are my search results capped at 1,000,000, and how do I change that?"_
* _"Which properties differ from their defaults?"_
* _"What does `stroom.search.resultStore.maxSortedItems` do, and is it set the same on every node?"_
* _"How many searches are users running, and who's running the longest?"_
* _"What is node-2 busy with?"_

The agent reads properties but never changes them: it says how to change a value, and whether it needs a restart.
Secrets are masked.


## Memory and the Chat

* `/remember The ACME feeds are owned by the network team.`: Adds a fact to your memory, loaded into every chat.
* _"Remember that our firewall events go to the FW-EVENTS index."_
* _"Suggest standing instructions for /Feeds/Acme from my recent chats."_: Proposes the choices you keep making as the folder's `AGENTS` document, for you to review and apply (see [Suggesting standing instructions]({{< relref "../pipeline-admin/configuration#suggesting-standing-instructions" >}})).
* `/compact` when a long chat is running out of context, or `/new` to start afresh.

See [Using the chat]({{< relref "using-the-chat#commands" >}}) for every command.
