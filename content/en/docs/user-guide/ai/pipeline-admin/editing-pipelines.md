---
title: "Editing pipelines"
linkTitle: "Editing pipelines"
weight: 20
date: 2026-10-27
tags:
  - ai
  - pipeline
  - xslt
  - processing
description: >
  Looking into, stepping, fixing, changing, evaluating and documenting existing pipelines with the agent, and processing and reprocessing their streams.
---

Beyond [onboarding new sources]({{< relref "onboarding" >}}), the agent can work on the pipelines you already have.
Attach the pipeline (or its Stepping view) to the chat, or name it.


## Understanding a Pipeline

* **The pipeline as Stroom runs it**: The agent reads a pipeline merged with the templates it inherits from, so it sees every element, property and XSLT that applies, and which come from the template.
* **What it processes**: The feeds a pipeline's processor filters select (through dictionaries and stream ids too), and the filters' progress.
* **Its dependencies**: The documents it uses, and those that use it.
* **Its reference data**: The lookups its XSLTs make, which maps they read, and the pipelines and feeds that load each map.
* **Its translation**: What an XSLT does to an event, and, for a translation Stroom generated, the field mapping it was made from.

> _"Explain what the ACME-EVENTS pipeline does to a login event, and which parts come from its template."_


## Stepping and Fixing a Translation

With a pipeline's Stepping view attached, the agent sees the selected element's input, output and code, as you do.

* **Stepping**: It can step one record through a pipeline and show what each element does, step every record of a set of streams for one verdict, or step chosen records of existing streams where they are.
* **Proposing a change**: Asked to fix something (_"Make the time stamp UTC"_), the agent proposes a change to the XSLT or text converter being stepped.
  Before it is offered, the change is tried by stepping the record with it, and refused if it gives errors the current code doesn't, unless you tell the agent to offer it anyway.
  It is shown as a diff with _Review and apply_, which puts it in the editor, unsaved, for you to check and save.
* **Proving a fix**: For a fix to a production pipeline, the agent steps every record of the affected streams with the fixed code, compares the outputs with the current code's (only the expected parts should change), and gives you the code's diff and the outputs that change, to review before anything is saved.
* **Comparing outputs**: It can step the same records through the current pipeline and a candidate (draft code, or a new version), and compare each record's output field by field.

XSLT the agent writes is compiled with Stroom's own XSLT engine and functions, and checked against the event-logging schema and quality rules (a full UTC time stamp; the System's name and environment, Generator, Device and TypeId present; one action under EventDetail; no empty elements) before it is saved.
It may not call functions that reach outside Stroom.

> _"Step stream 4567 through this pipeline: why are records 12 to 15 producing errors?"_


## Changing Production Pipelines

The agent doesn't change production documents in place.
Instead, in a [build]({{< relref "onboarding#how-a-build-works" >}}):

* **New version**: A production pipeline's next version, with its translation written anew from a field mapping, keeping the reference data lookups you choose.
* **Working copy**: A copy of a source's pipeline (or XSLT) with exactly the original's structure and settings, to change and test.
* **New output**: A further pipeline for a source's Events, e.g. CEF (ArcSight Common Event Format) output, or forwarding.

When it is done and checked, promotion writes working copies back over the production documents (after a backup), and puts new versions where their type's destination is.
Promotion shows you the layout as a tree first, and asks before it changes anything.
A working copy keeps any edits you made by hand to the production XSLT (see [Hand edits]({{< relref "hand-edits" >}})).
If a production document is changed after its working copy is made, promotion shows you how the two differ and asks which to keep.

The agent can also change a pipeline it made: its elements' properties, and the reference data its XSLT looks up (a feed and its loader pipeline).

> _"Make a new version of the ACME-EVENTS translation that maps the new `src_zone` field."_


## Reference Data

* The agent lists the reference data maps the environment loads, with each map's key and value, and the loader pipeline and feeds behind it, so a translation can look values up with {{< xslt-func-link "lookup" >}}.
* It can write the XSLT of a reference data pipeline from a mapping, and load a new table as a [reference data build]({{< relref "onboarding#reference-data" >}}).
* It can attach reference data to a pipeline it made, so its lookups find their maps.


## Processing and Reprocessing

* **Processor filters**: The agent can create a processor filter for a pipeline (asking you first), and disable one on a pipeline it made.
  In a build, a filter for an events (or records) or indexing pipeline is created enabled once you approve it, and processing starts; any other (CEF output, reference data) is created disabled, for you to enable on the pipeline's **Processors** tab.
  Filters that promotion hands over are disabled, for you to enable (see [Builds and promotion]({{< relref "builds-and-promotion#after-promotion" >}})).
* **Reprocessing**: After changing a pipeline under development, it can process streams again through it (asking you first), at most 10 streams at a time.
  As for a new processor filter, the pipeline's current code must first have stepped clean: after a change to its XSLT or text converter, the agent steps the streams again until they are clean, then reprocesses.
  Stroom marks the earlier output of those streams deleted once the new output is written, but removes nothing from an index: before reprocessing into an Elasticsearch index that already holds those streams' documents, you are given the request to drop it (for your cluster admin); a build's own Lucene index is emptied once you approve.
  An Elasticsearch data stream keeps the mapping it was made with, so a changed index template only applies once it is dropped.
* **Verifying an index**: The agent verifies indexed events through Stroom, as a dashboard searches, never by querying the backend: the sample's streams, an exact match on each key field, and a time range, each search kept to the sample's streams, with each hit traced back to the record it came from.
  Some searches give a wrong answer without an error, and the agent avoids them: on Lucene, STARTS_WITH, ENDS_WITH, CONTAINS on a keyword field, a range on a text field, and IN with a value holding a space find nothing; on Elasticsearch, a wildcard on an `ip` field (use a CIDR range), STARTS_WITH and CONTAINS find nothing, and IS_NULL and IS_NOT_NULL match every document.
* **Waiting for processing**: It waits until each input stream's processing has ended, then reports the Events (or Reference) and Error streams it wrote.


## Finding Why Processing Fails or Stalls

* **Why nothing is processing**: Asked why a pipeline, feed or stream isn't processing (or is slow), or whether processing is healthy, the agent checks each link of the chain in turn:
  * The cluster's nodes, and the jobs processing needs on them (Processor Task Creator, Data Processor, and the task reaper and heartbeat)
  * Each processor filter: Whether it is enabled, its tracker (_Complete_, or _Error_, which Stroom never retries), its stream create time window, its feed dependencies and polling
  * Its processor profile: The node group, the periods it applies in, and the threads each node gets now
  * Where its tasks wait (locked streams, limits), and the higher-priority filters ahead of it in its profile
  * Whether output can be written: a volume group with no volume to write to

  Each link is reported as ok, blocking, slowing, or not checked (where you lack the permission to see it), with a fix for each finding.
  It reads Stroom's state only, never its logs, and needs _Manage Processors_ (with _Manage Jobs_, _Manage Nodes_ and _View System Information_ for the jobs and nodes).
  When waiting for processing finds nothing processed, the agent turns to this check.
* **Across the cluster**: What is failing today and why, backlogs, queued and stuck tasks by node, and task lists, from processor tasks (this needs _Manage Processors_).
* **Errors**: The errors in Error streams, grouped by severity, element and message, each triaged as blocking, for review, or benign, and the pipeline's own elements told from inherited ones.
  Your own [error triage rules]({{< relref "configuration#error-triage-rules" >}}) are applied first.
  Errors that lose text, such as records a Data Splitter drops because they are longer than half its buffer, are listed first, as the errors after them may only be their consequences.
  A document Elasticsearch rejects is reported on its own, with Elasticsearch's reason, and traced back to its record by its `EventId`.
  Stroom lists only the first 100 documents a batch rejects, and the agent says how many more were rejected without being listed.
  The pipeline's own errors are looked at before those its templates cause; an error you tell the agent is harmless is recorded with your reason in the pipeline's documentation, and then reported as benign.
* **Events**: What a stream's Events hold: counts per event type and action, and how often each part of the event-logging schema is filled in.
* **Tracing**: A stream, or one event in it, traced back to its raw stream, the record within it, the pipeline, and the XSLTs and text converters it went through.
* **Coverage**: The kinds of event a feed holds that a generated translation doesn't match yet, from the records it logged as unmatched.

> _"Which tasks for the ACME pipeline failed today, on which nodes, and why?"_

> _"Why isn't the ACME-EVENTS pipeline processing anything?"_


## Evaluating a Pipeline

The agent can review how well an existing pipeline works, and tell you in the chat what it found.

> _"Evaluate the ACME-EVENTS pipeline: how well does it translate this feed, and what should be improved?"_

It gathers the facts with one tool, `evaluate_pipeline`, so every evaluation covers the same ground, in the same order:

Section | What it checks
-- | --
Pipeline | What the pipeline is made of as Stroom runs it, with what it inherits from its templates, and what kind of pipeline it is.
Processing | The errors in the pipeline's newest Error streams, triaged as blocking, for review, or benign.
Stepping | A verdict from stepping its input streams through it, which needs _Pipeline Stepping_. By default these are the streams behind its newest output (up to 50 records of each); you can name the streams to step instead.
Checks for its kind | See the table below.

Kind of pipeline | Its own checks
-- | --
Events (a translation) | The Events it wrote checked against the event-logging schema, how often each part of them is filled in, and records no rule matched or kept as Unknown.
Indexing, or a discovery index | The fields it writes against the index's fields: fields the index lacks, index fields nothing writes, and type mismatches (e.g. free text in a keyword field).
CEF output, to Kafka or a file | Its CEF lines against ArcSight's dictionary: header fields still to fill in, keys outside the dictionary, and Event values no key carries. Sending to Kafka, or what the file appender does, is not tested.
Reference data | The maps it loads, with their key and value shapes, its feeds, and the pipelines that look the maps up.
Anything else | None beyond the sections above.

Errors you have agreed are harmless, recorded in the pipeline's documentation, are reported as benign rather than as problems.
A section you don't have the permission for (_Data - View_, _Pipeline Stepping_, or _Manage Processors_ for a reference data pipeline's feeds) says so, and the rest is still given.
The agent then writes its report in the chat, under the same headings each time: a summary, the pipeline, its processing errors, stepping, the checks for its kind, and recommendations.
The evaluation points to deeper checks it doesn't run itself, such as a whole-feed coverage review or checking an Elasticsearch index template, for you to ask for next.

If you want to keep the report, ask the agent to save it.
It is saved in a build as its own {{< stroom-doc "Documentation" >}} document, named after the pipeline with ` - Evaluation` added (e.g. `ACME-EVENTS - Evaluation`), and promotion puts it beside the pipeline.
The pipeline's own documentation is left as it is, and nothing in the report is generated: it is the agent's own text.
Evaluating the same pipeline again and saving the report updates the earlier one, through a working copy that promotion writes back.


## Documentation

The agent documents a pipeline in a {{< stroom-doc "Documentation" >}} document of the pipeline's own name, kept beside the pipeline, from what it knows of the source.
It writes one for every pipeline it builds or changes, and can write one for a pipeline you already have.

> _"Document the ACME-EVENTS pipeline, using streams 4567 and 4568 as the sample."_

The documentation has these sections:

Section | What it holds
-- | --
Purpose and data | The feeds, the source system and what it records, the record format and the samples used.
Processing | The pipeline's elements, the template it inherits from, and the reference data and dictionaries it uses.
Field mapping | Generated: each field the pipeline writes, what it means for this source, where it comes from, and the values the sample gave it.
Reference maps | Generated, for a reference data pipeline in place of the Field mapping: each map it loads, with its key and value shapes, an example of each, how many entries the sample gave, the feeds that load it and the pipelines that look it up.
Output | What the pipeline produces beyond the Field mapping, e.g. volumes, or an index's template and test searches.
Conformance | How well the sample's output validated.
Errors | Generated: each kind of error processing the sample produced, with a count and an example, and the errors you have agreed are harmless.
Open items | Suggestions, known limitations, and input fields not mapped.
Version control | Who changed the documentation, when, and what changed.

The agent describes each field by what it means for this source, from its name, its values and any vendor documentation you gave it, and says when a meaning is unconfirmed.
The descriptions are kept with the documentation, so an update only describes new fields.
The Field mapping is laid out by event type by default; an `AGENTS` document's `## Documentation` section (`- field mapping: compact`) can choose a single compact table instead (see [Standing instructions]({{< relref "configuration#standing-instructions-agents-documents" >}})).

The documentation is also how a feed is explained to the people who search it: asked what a feed holds or what a field means, the agent answers from it.

{{< note >}}
The Field mapping, Reference maps and Errors sections are generated from the pipeline's XSLT, what it writes from the sample and the errors its processing produced.
Each time the agent writes the documentation it generates them again, so any edits you make to them are lost.
{{< /note >}}


### Documenting an Existing Pipeline

A pipeline you already have is documented in a build, like any other change, so nothing outside the build changes until you approve promotion.
The agent steps the pipeline over sample streams to generate the Field mapping and Errors sections: give it the raw streams for a translation or discovery pipeline, the Events streams for an indexing or CEF pipeline, or the Raw Reference streams for a reference data pipeline.
This needs _Pipeline Stepping_, and the [tools and permissions for builds]({{< relref "onboarding#what-you-need" >}}).

* **A pipeline with no documentation**: the documentation is made in the build, and promotion puts it beside the pipeline, or in a folder you choose.
* **A pipeline that already has documentation**: the agent makes a working copy of the document in the build, and promotion writes it back over the original, after a backup.

The Field mapping section of a pipeline the agent didn't generate is made in one of these ways:

* **A translation XSLT**: the agent writes the section itself, from reading the XSLT, as no mapping is kept with it.
* **An indexing XSLT**: the section lists the fields of the documents it writes, how often each is set and its values, but not where each comes from.
* **A discovery pipeline**: the section lists the fields of the documents it writes from its raw streams, as for an indexing XSLT.
* **A CEF XSLT**: the section is the mapping that the CEF lines it writes imply, whether it sends them to Kafka or writes them to a file, and even when the CEF is written by an XSLT it imports.

A reference data pipeline gets a Reference maps section instead, from stepping its Raw Reference sample streams.

To change just the text of a document's Documentation tab, without a build, ask in the chat (e.g. _"Improve the description of the ACME-EVENTS feed"_).
The agent proposes the change as a diff, with a _Review and apply_ button that puts it in the tab's editor, unsaved, for you to check and save.
Nothing is generated this way.


### Documenting an Existing Index

The agent can also document an index you already have, rather than the pipeline that feeds it (e.g. _"Document the ACME index"_), once you confirm which index document it means.
Its Field mapping section comes from a survey of the index through Stroom: each field, with its type, how often a sample of up to 100 recent documents held it, and their values.
The agent adds what it knows of the source, and the documentation is named after the index document and put beside it at promotion.

Every field the index's feeding pipelines write must be in the index.
If one isn't, the agent tells you which, and asks you to reindex, or to check again in a minute, as Stroom can be slow to list a field only just indexed.
If you want the documentation now anyway, it lists the field as not in the index.
