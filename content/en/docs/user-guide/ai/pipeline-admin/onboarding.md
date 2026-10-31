---
title: "Onboarding a data source"
linkTitle: "Onboarding a data source"
weight: 10
date: 2026-10-22
tags:
  - ai
  - feed
  - pipeline
description: >
  Building a new source's feed, translation, pipelines and index with the agent, or a discovery index of raw data, or reference data.
---

The agent can onboard a new source of data with you: from samples of the data to a feed, a translation into Stroom's event-logging XML, the pipelines that process it, and an index of the events.
It can also index raw data as it is, to explore it, or load a table of reference data.
Its tools follow a plan, and every result says what the next step is, so the work keeps moving until it is done.

The same tools are available to MCP clients outside Stroom (see [Agent Tools]({{< relref "../agent-tools" >}})).


## What Kind of Work

Say what you have and what you want, and the agent picks the kind of work that fits, asking you when more than one would:

You have | You want | The work
-- | -- | --
Samples of a new source | Its events translated and indexed | Onboarding a source (below)
A feed already holding data | A translation for it | Onboarding, starting from the feed's streams, which the agent surveys for the kinds of event in them
Events already in Stroom | An index of them | Only the indexing stage
Raw data (JSON, delimited text or XML) | To see what it holds, before or instead of writing a translation | A [discovery index](#discovery-indexes)
A table to look values up in (users, assets, codes) | Reference data, on its own or for a translation's lookups | A [reference data build](#reference-data)
Events in Stroom | Sent on to ArcSight | CEF output
A pipeline in production | To fix or change it | A new version or working copy (see [Editing pipelines]({{< relref "editing-pipelines#changing-production-pipelines" >}}))

Each build is started as one kind (events, discovery or reference), and its plan then follows that kind of work from the start.


## How a Build Works

The work is done in a _build_: a folder of its own, under the build workspace folder (`System/MCP Workspace` by default), holding the documents the tools make for the source.
The tools change only the documents they made in a build, and refuse to write anywhere else.
When the build is finished and checked, _promotion_ moves its documents to their final folders.

{{< stroom-tree "System" >}}
  {{< stroom-tree "MCP Workspace" "The build workspace folder" >}}
    {{< stroom-tree "acme" "The build for the ACME firewall logs" />}}
  {{< /stroom-tree >}}
{{< /stroom-tree >}}

Ask for it in plain words, e.g. _"Onboard the ACME firewall logs, samples are in stream 123"_, or attach a feed or folder and choose the onboarding question the chat offers.
The agent then works through the plan with you, which you can follow in its task list:

1. **Start**: The build is made, and the samples are profiled to tell their format and fields.
   Samples can be text you give, streams already in Stroom, or files you upload; files are profiled once the feed is made and they have been uploaded to it.
1. **The events pipeline**: A feed, the samples uploaded to it, a pipeline from one of your pipeline templates, and a translation XSLT generated from a field mapping the agent drafts and you agree.
   Every record of the samples is stepped through it, its Events are checked against the event-logging schema, processing is started, and the source's notes and documentation are written, with its field mappings.
   The agent asks about indexing (the backend, cluster, index template and field naming) only once the build has Events.
1. **Indexing**: An index plan drafted from the Events (following a field convention such as ECS where you want one), the index document, and an indexing pipeline, verified with test searches, and documented.
1. **CEF output** (if you want it): A CEF mapping of the Events, a pipeline for it, stepped and documented.
1. **Promotion**: The build's layout is shown as a tree for you to confirm, then its new documents are moved into place, working copies of documents already in production are written back over them (after a backup), and the build's processor filters are handed over disabled, for you to enable.


### Pipeline Templates

The events pipeline inherits from one of your translation pipeline templates, never a copy of one.
If no template has the parser the samples need, the agent offers a template with its parser replaced by the right one (e.g. an XML fragment parser for XML fragments).
Only when Stroom has no translation template at all does the agent build an events pipeline of its own, made as Stroom's standard Event Data templates are, as a last resort.


### Text Formats

For text that isn't XML or JSON, the agent writes a {{< glossary "Data Splitter" >}} from a description of the format (delimited, regular expression, key=value, or syslog), never by hand first.
It is run on the samples, and through Stroom's own Data Splitter parser, which must read the samples as the agent expects before the Data Splitter is saved.
Its read buffer is sized for the samples' longest record, as a record longer than the buffer is lost.


## Discovery Indexes

A discovery index holds raw data (JSON, delimited text or XML) as it is, in Elasticsearch, with no translation, for exploring what a source holds, e.g. _"Index the raw ACME JSON so I can see what's in it"_.
The source can be a feed already holding raw data, or a sample.

1. The agent asks you, in one message: the cluster, the index's name (e.g. `stroom-discovery-acme-v1`), the discovery pipeline template, the field holding each record's time (and its format, unless ISO 8601 or epoch milliseconds), any stream meta to add, fields to leave out, and an example index template from a sibling index, if there is one.
   If records hold times in several fields, you choose which is the time stamp.
1. Delimited text first gets a Data Splitter naming its columns.
1. The agent drafts the index: only `StreamId`, `EventId` and `@timestamp` are mapped; Elasticsearch maps the other fields itself as documents arrive, and a JSON object held in a string is also indexed parsed, as `<field>_json`.
   The index template it proposes is permissive (strings as keywords, a limit on fields, malformed values ignored), and is a data stream when every sample record has a time stamp, a plain index otherwise.
1. You agree the template, and apply it to Elasticsearch (or have your cluster admin do so); the agent never writes to Elasticsearch.
1. The indexing pipeline is made from a discovery template, the samples are indexed, and the agent verifies them with test searches through Stroom, then documents the index.

The pipeline inherits from one of your discovery templates.
Only when Stroom has none does the agent offer to build a discovery pipeline of its own (a parser for the input, one record a split, the XSLT, a JSON schema filter and the Elasticsearch indexing filter), which you confirm in a form, as a last resort.


## Reference Data

A table to look values up in, such as users, assets or event codes, is a reference data build of its own, e.g. _"Load the asset list in stream 789 as reference data"_.
Its plan has a feed, the sample, a text converter, a reference data pipeline that is stepped and processed, and documentation, with no translation, Events or index.

The reference data pipeline's processor filter is created disabled: enable it on the pipeline's **Processors** tab, and the agent waits for the table to be processed.

An events pipeline whose translation looks values up in a table that hasn't been processed yet is stepped only once it has: Stroom remembers a lookup that found nothing for 10 minutes, so stepping sooner would show every lookup missing.


## What You are Asked

The agent asks you when something is yours to decide: the source's name and feed, which samples to use, how to map fields it can't place, which event-logging version to write, whether to keep a field you edited by hand.
Changes that create or move documents, or start processing (a new feed, pipeline or processor filter, reprocessing, promotion), ask you first in a short form.
Saving the build's own drafts (an XSLT, a text converter, documentation) doesn't, as those stay in the build folder until promotion, even once the chat has read data (see [Approvals]({{< relref "../ask-stroom-ai/using-the-chat#approvals" >}})).

Steps only you can take (enabling the processor filters promotion hands over, applying an index template to Elasticsearch) are given as buttons or requests for you to carry out: the tools never write to Elasticsearch.


## Sample Data

Give samples as text in the chat, as streams already in a feed, or as files on your machine.
For files, the agent gives you a command to run in your terminal, which posts each file to Stroom as you (with your API key, from the `STROOM_API_KEY` environment variable); your key is never put in the chat or the command.
The commands post to Stroom's MCP endpoint (`/mcp/upload`), so they need the endpoint turned on, the _Use MCP Tools_ permission and an API key; without those, upload the files on the feed's **Data** tab instead.
The commands must be run within 15 minutes (by default); any Stroom node can take them, even after a restart.


## What You Need

* A [tool policy]({{< relref "../agent-tools/tool-policies" >}}) granting you read and write tools in the Content, Processing and Indexing categories (the default policy grants read-only tools).
* Permission to create folders in `System/MCP Workspace` (or the configured build workspace folder).
* _Pipeline Stepping_, to step samples through the pipelines.
* _Data - Import_ and Edit on the feed, to upload samples.
* _Manage Processors_, and permission to create the destination folders, to promote the build.
