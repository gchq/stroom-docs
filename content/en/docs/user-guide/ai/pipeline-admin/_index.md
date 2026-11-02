---
title: "Pipeline Administration"
linkTitle: "Pipeline Administration"
weight: 25
date: 2026-10-27
tags:
  - ai
  - pipeline
  - feed
description: >
  For pipeline administrators and content developers: onboarding data sources and editing pipelines with the agent, in Ask Stroom AI or an MCP client.
---

The agent can do much of the work of a pipeline administrator with you: onboard a new source of data from its samples to its indexed events, and look into, fix, change and reprocess the pipelines you already have.
It works in [Ask Stroom AI]({{< relref "../ask-stroom-ai" >}}), or in an MCP client such as VS Code or Claude Code through [Stroom's MCP endpoint]({{< relref "../agent-tools" >}}), with the same tools.


## How the Agent Works on Pipelines

* **Stroom writes the code.**
  For a translation, the agent drafts a field mapping (which source field goes where in the event-logging schema) that you agree, and Stroom generates the XSLT from it; for a text format, it describes the format and Stroom writes the Data Splitter.
  The agent can still edit code by hand where a mapping can't express something, and Stroom keeps track of hand edits.
* **Everything is tried before it is used.**
  XSLT is compiled and checked before it is saved, every record of the samples is stepped through the pipeline, the Events are validated against the event-logging schema, and a fix is proved by stepping the streams it is for.
* **New work goes in a build.**
  New documents, and working copies of production ones, are made in a folder of their own, and only promotion, which you approve, moves them into place.
* **Templates are inherited, never copied.**
  A new pipeline is a child of one of your pipeline templates, setting only what the child supplies (e.g. its XSLT), so it follows later changes to the template.
  The agent only finds templates where it is [configured to look]({{< relref "configuration#where-the-agent-looks-for-templates" >}}), which by default is Stroom's standard templates in `System/Template Pipelines`.
* **You make the decisions.**
  The agent asks you what is yours to decide (a feed's name, how to map a field it can't place, which convention to index with), and changes that create documents or start processing ask you first in a short form.
* **Some steps are yours alone.**
  Enabling the processor filters that promotion hands over, and applying an index template to Elasticsearch, are given to you as buttons or requests to carry out; the agent never writes to Elasticsearch.


## What You Need

Permission | For
-- | --
A [tool policy]({{< relref "../agent-tools/tool-policies" >}}) granting read and write in Content, Processing and Indexing | Tools that make and change documents and start processing. The default policy grants read-only tools only.
_Pipeline Stepping_ | Stepping samples and streams through pipelines.
_Data - View_ | Reading streams, and the events behind search results.
_Data - Import_, and Edit on the feed | Uploading samples to a feed.
_Manage Processors_ | Processor filters, reprocessing, processing status and promotion.
Permission to create documents in the build folder (`System/MCP Workspace` by default) and in the destination folders | Builds and promotion.

Each tool runs as you, so it can only read and change what you can in Stroom's own screens.
