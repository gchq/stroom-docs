---
title: "Builds and promotion"
linkTitle: "Builds and promotion"
weight: 15
date: 2026-10-31
tags:
  - ai
  - pipeline
  - feed
description: >
  What the agent changes in Stroom, what a build folder holds, how to review a build, and what promotion does.
---

Everything the agent's pipeline tools make is made in a _build_ (see [How a build works]({{< relref "onboarding#how-a-build-works" >}})).
This page is for whoever reviews and promotes builds: what the agent can and can't change, what a build holds, and what promotion does.


## What the Agent Changes

* **It acts as you.**
  Every tool runs as the user who asked, through Stroom's own services, so Stroom's permission checks apply (Create in a folder, Edit on a document, _Manage Processors_ for processor filters) and the agent can do nothing you couldn't.
* **It creates only in the build folder.**
  New documents are made in a folder of their own under the build workspace folder (`System/MCP Workspace` by default).
  It changes only documents it made there; a production document is changed through a working copy in the build, written back only when you approve promotion.
* **What it never does:**
  It never writes to Elasticsearch (index templates and index drops are given to you, or your cluster admin, as requests to run), and never deletes streams; the only indexed data it removes is a build's own Lucene index, emptied before its streams are reprocessed, once you approve.
  XSLT it saves may not call {{< xslt-func-link "http-call" >}}, {{< xslt-func-link "fetch-json" >}} or {{< xslt-func-link "ask-ai" >}}, and calls {{< xslt-func-link "host-name" >}} or {{< xslt-func-link "host-address" >}} only once you agree.
  Processor filters for anything other than a build's own events (or records) or indexing pipelines are created disabled, for you to enable.


## What a Build Holds

* **Its documents**, in subfolders by role (Events or Records, Indexing, CEF, Reference), with its feeds, notes and records at the top.
* **Tags**: everything the agent made carries the tags `mcp-generated` and `mcp-managed`, and an XSLT generated from a field mapping also `mcp-kept-mapping`.
  Promotion removes `mcp-managed`, so `mcp-generated` still finds everything the agent made after it is in production.
* **The build record**: a {{< stroom-doc "Documentation" >}} document named `Build record`, which holds what the build knows about its documents between calls: which are working copies of production documents, which code has stepped clean, been verified or validated, and which feeds' samples are files on your machine.

For example, a build onboarding the ACME firewall logs to an index:

{{< stroom-tree "System" >}}
  {{< stroom-tree "MCP Workspace" >}}
    {{< stroom-tree "acme" "The build folder" >}}
      {{< stroom-tree "Events" "The translation pipeline and its code" />}}
      {{< stroom-tree "Indexing" "The indexing pipeline and the index" />}}
      {{< stroom-tree-doc "Feed" "ACME-FIREWALL-EVENTS" "The build's feed" >}}
      {{< stroom-tree-doc "Documentation" "Build record" "What the build knows about its documents" >}}
    {{< /stroom-tree >}}
  {{< /stroom-tree >}}
{{< /stroom-tree >}}

A document's build is the folder it is in.
{{< warning >}}
Don't move or rename anything in a build folder, or edit the build record: the build loses track of it.
{{< /warning >}}

{{< note >}}
A build that works from a feed's existing streams processes them where they are, writing its Events to a test feed of its own (`<FEED>-MCP-TEST`, or the next free name), so production Events aren't touched.
The test feed stays in the workspace at promotion, and the promoted pipeline writes to the feed as before.
Error streams are written into the input's feed, so they appear in the production feed beside its raw streams.
{{< /note >}}


## Reviewing a Build

Ask the agent where a build stands (e.g. _"What's left to do on the acme build?"_): every step of its plan is shown as done or to do, read from what the build holds, with what is next.
Every change the agent makes in a build also says what comes next.

Before you approve promotion, check:

* the pipeline's latest code stepped clean on the samples, and its Events validated;
* for an index, that its test searches passed for the indexing pipeline's latest code;
* the documentation is current (the agent rewrites it after a change of its own);
* for Elasticsearch, that the index template you agreed is applied to the cluster.

Errors you have agreed are harmless (e.g. a lookup miss for accounts the reference data doesn't hold) are recorded, with your reason, in the pipeline's documentation, so they aren't raised as problems again.
Records the translation keeps as `EventDetail/Unknown` are not errors: they are agreed rule by rule when the XSLT is saved, after the agent has shown you in the chat which records they are and what they hold.


## Hand Edits

You can edit an XSLT the agent generated in Stroom's own editor.
The agent keeps your edit: a later change of its own that would undo it is refused, and the agent then, with your agreement, carries your edit into the field mapping it generates from (`rebuild_mapping`, proved on the sample) before making its change.
Where its change and your edit touch the same field, you are asked whether to keep your edit or use its change.
An edit no field mapping can hold (e.g. an `xsl:iterate` building a list of users) is yours to keep or drop.
See [Hand edits]({{< relref "hand-edits" >}}) for the details.

Each generated XSLT's Documentation tab holds its version history: who changed it, when, whether by the agent or by hand, and what changed.
A build's changes show there as _Unreleased_ rows until promotion turns them into one version.


## What Promotion Does

Promotion first shows you the build's layout as a tree of the destination folders (new folders marked, working copies to be written back, documents left in the workspace), for you to confirm in the chat; then it asks for your approval in a short form bound to that layout.
Documents with no destination are named all at once, for you to say where they go.

Once approved:

* **New documents** are moved to their destination folders, created if they don't exist.
  Documents keep their UUIDs, so processor filters and references keep working.
  The build's role subfolders are kept under each destination when the build spans more than one role, unless you say otherwise.
* **A new version** of a production pipeline goes in a version subfolder beside its predecessor, named after the new version, with its own index, documentation and dashboard.
* **Working copies** are written back over their originals, after each original is backed up to the workspace's `backups` folder; a working copy with no changes is discarded.
  If an original was changed in production since its working copy was made (by a hand edit, say), you are asked first, before the layout is shown: you are told who changed it and when, and shown what overwriting would lose from production and what the copy brings, and you choose to overwrite production with the working copy (the production change is then only in the backup) or keep production as it is (the copy and its pipeline stay in the build).
* **Processing** is handed over: each promoted pipeline gets a processor filter for its feed, created disabled, unless it already has an enabled filter selecting what arrives.
  A document you asked to keep in the workspace (a test feed, say) stays there.
* The build folder is removed if nothing is left in it.

The result repeats the layout, with a link to each destination folder and each production document updated in place.


## After Promotion

* Review each promoted pipeline and enable its processor filter on its **Processors** tab when ready.
  Enabled, a filter processes everything on its feed, existing data included.
  If an earlier version of the pipeline still processes the same feed, disable it (or limit the new filter) first, or the feed's history is processed twice.
* An index that must start fresh is named, with the request to drop it, before its filter is enabled; otherwise it holds the build's events twice.
  Where its events pipeline was promoted too, enable the indexing filter only once the events pipeline's filter has processed the build's streams again.
* Once promoted, documents change only through a new build: a working copy, written back by promoting again.
* In the chat, the agent may offer to write the choices you made during the build, and in earlier chats, into the feed's folder as standing instructions, so the next build follows them.
  It offers once, and only when it finds choices you have made the same way more than once; you review the proposal and apply it (see [Suggesting standing instructions]({{< relref "configuration#suggesting-standing-instructions" >}})).
