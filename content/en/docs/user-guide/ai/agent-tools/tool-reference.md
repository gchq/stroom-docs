---
title: "MCP Tool Reference"
linkTitle: "MCP Tool Reference"
weight: 25
date: 2026-10-27
tags:
  - ai
  - mcp
description: >
  The tools Stroom's MCP endpoint offers, by tool policy category, and the resources it serves with them.
---

Stroom's MCP endpoint (`/mcp`) offers the tools below, as do the [Ask Stroom AI]({{< relref "../ask-stroom-ai" >}}) chat.
A user is offered only the tools of the categories their [MCP Tool Policies]({{< relref "tool-policies" >}}) grant them, and each call runs as them, with their permissions.
A client asks Stroom for the full description and arguments of each tool when it connects.


## What the Changes Column Means

Value | Meaning
-- | --
No | The tool only reads (or works things out), and is offered under a read-only policy.
Yes | A call changes something in Stroom. The user is asked to approve it first, in a form shown by the client.
Yes, confirms | A call changes something in Stroom. The tool asks the user in a form of its own, saying what it will do and letting them correct it, so it isn't approved a second time.
Build only | A call can only change the documents in its onboarding build's folder, so the user isn't asked: nothing outside the build changes until `promote_build`, which asks.
Workspace | A call only changes files in the session's workspace.

A tool marked _some calls_ has calls that only read (e.g. a dry run), which a read-only policy allows; only its calls that change something need read and write.
A call that changes something needs a client that can show forms (MCP elicitation), and is refused otherwise (see [Agent Tools]({{< relref "_index.md#how-the-tools-are-governed" >}})).


## Core

Documents, folders, the date and time, questions for the user, and the session's workspace files.

Tool | What it does | Changes
-- | -- | --
`ask_user` | Asks the user questions in a form and waits for the answers. | No
`describe_feed` | What a feed holds and, given a field, what the field means and how to search it. | No
`document_documentation` | Reads a document's Documentation tab. | No
`document_info` | A document's type, path, tags, history, version and dependencies. | No
`document_links` | Follows dependency links (dependants or dependencies) from documents. | No
`find_in_content` | Finds text in documents' content, such as XSLTs, text converters and dictionaries. | No
`find_reference_data` | The reference data maps the environment loads, for {{< xslt-func-link "lookup" >}} in a translation, and the pipelines and feeds that load them. | No
`folder_contents` | An Explorer folder's documents, streams, processor filters and task counts; finds documents by name. | No
`get_current_date` | Today's date in UTC. | No
`get_current_datetime` | The current date and time in UTC. | No
`get_current_time` | The current time of day in UTC. | No
`get_instructions` | The AGENTS documents that apply to folders or documents. | No
`get_utc_time_offset` | A time zone's offset from UTC. | No
`read_document` | A document's content, or what a processor filter selects; a pipeline as Stroom runs it, merged with its templates. | No
`delete_file` | Deletes a file in the workspace's `/outputs/`. | Workspace
`grep` | Finds lines of a workspace file that match some text. | No
`jq` | Runs a jq query on a workspace JSON file. | No
`ls` | Lists the workspace's files. | No
`pipeline` | Chains the data tools over workspace files. | No
`read_file` | Reads lines of a workspace file. | No
`str_replace` | Replaces text in a workspace file. | Workspace
`summarise_column` | Reduces a free-text column to patterns, and summarises them. | No
`table` | Queries a workspace table (CSV) with Stroom expressions. | No
`wc` | Counts a workspace file's lines and bytes. | No
`write_file` | Writes a file in the workspace's `/outputs/`. | Workspace
`xpath` | Runs XPath on a workspace XML file. | No


## Search

StroomQL queries, data sources and the events behind search results.

Tool | What it does | Changes
-- | -- | --
`describe_data_source` | A data source's fields, conditions and documentation, and the searches of an index that would mislead. | No
`fetch_events` | Fetches the events behind rows of StreamId and EventId into an XML file. | No
`list_data_sources` | Lists the data sources the user can query. | No
`run_stroomql` | Runs a StroomQL query into a workspace table, refusing one on an index whose answer would mislead. | No
`search_events` | XPath, text or jq search over fetched events, into a table; or, given an index, finds events in it as a dashboard would. | No
`validate_stroomql` | Checks a StroomQL query without running it. | No


## Content

Creating and changing Stroom documents: feeds, pipelines, translations, text converters, dictionaries, documentation and onboarding builds.

Tool | What it does | Changes
-- | -- | --
`start_onboarding` | Starts onboarding a source as events, a discovery index or reference data: makes its build and profiles the samples to tell their format and fields. | Build only
`start_build` | Creates (or finds) a build's workspace folder, for events, a discovery index or reference data, optionally from feeds already holding data. | Build only
`build_status` | Where an onboarding build stands: its next step, what is left before promotion, and each step's state. | No
`promote_build` | Moves a finished build's documents to their final folders, once the user has seen where everything goes and approved it. | Yes, confirms
`create_feed` | Creates a feed in the build folder, under a name the user confirms. | Yes, confirms
`find_pipeline_templates` | The pipeline templates a new pipeline can inherit from, best first, with what a child of each must supply. | No
`describe_template` | How the environment uses a pipeline template, before making a child of it. | No
`create_pipeline` | Creates a pipeline as a child of a template, setting only what the child supplies; or a new version of a source's pipeline. | Yes, confirms
`copy_pipeline` | Copies an existing source's pipeline into the build, with exactly the original's structure and settings. | Yes, confirms
`update_pipeline` | Changes a pipeline the build created: element properties, and the reference data its XSLT looks up. | Build only
`draft_translation_mapping` | Drafts a field mapping from the sample, for a translation into event-logging XML. | No
`build_translation_xslt` | Writes the translation XSLT from a field mapping, rather than by hand. | Build only (some calls)
`build_data_splitter` | Writes a Data Splitter from a description of a text format, runs it on the sample, and checks it with Stroom's own parser. | Build only (some calls)
`build_reference_xslt` | Writes the XSLT of a reference data pipeline from a mapping. | No
`rebuild_mapping` | Rebuilds the field mapping kept with a translation XSLT, from the XSLT itself. | Yes, confirms
`check_xslt` | Checks an XSLT before it is saved or stepped. | No
`check_events` | Checks event XML against the event-logging schema held in Stroom, and against quality rules beyond the schema. | No
`save_xslt` | Saves an XSLT written by hand, or an indexing XSLT from its plan, in the build. | Build only
`save_text_converter` | Saves a text converter in the build. | Build only
`save_dictionary` | Saves a Dictionary in the build. | Build only
`record_source_notes` | Keeps the user's vendor or event documentation, and notes condensed from it, as {{< stroom-doc "Documentation" >}} documents in the build. | Build only
`write_documentation` | Creates or updates the {{< stroom-doc "Documentation" >}} document for a pipeline in the build, or for an existing index. | Build only
`draft_cef_mapping` | Drafts a mapping of the source's Events to CEF (ArcSight Common Event Format) output. | Build only (some calls)
`review_coverage` | Whole-feed coverage of an events pipeline: the kinds of event the sample missed, from the records its translation couldn't match. | No
`list_visualisations` | The charting libraries installed, the kinds of chart each draws, and the Visualisations in Stroom. | No
`xslt_lookups` | The reference data lookups XSLTs make, and which loaders write each map. | No


## Indexing

Indexes, their fields, and Elasticsearch index templates.

Tool | What it does | Changes
-- | -- | --
`get_field_conventions` | The field naming conventions for indexes (e.g. ECS), and the user's choice of backend and naming. | No
`find_elastic_clusters` | The Elastic Cluster documents with their connection URLs (never credentials), and the Elastic Index documents that use each. | No
`draft_index_mapping` | Drafts the build's index: its fields, from the Events, following a field convention. | Yes, confirms
`propose_index_template` | Builds the Elasticsearch index template for the indexing pipeline's destination index, for the cluster admin to apply. | Yes, confirms
`check_index_template` | Checks a user's Elasticsearch index template, and its component templates, against the indexing pipeline. | Yes, confirms
`create_index_doc` | Creates the build's index document. | Yes, confirms
`create_indexing_pipeline` | Creates the build's indexing pipeline from a template, or, with no discovery template in Stroom, a discovery pipeline of its own. | Build only
`rename_index` | Uses another Elasticsearch index name wherever the build uses one. | Yes, confirms
`verify_index` | Verifies indexed events through Stroom (a workspace dashboard on the index, then test searches), rather than by querying the backend. | Yes, confirms
`elastic_index_templates` | Reads the index template and component templates that apply to an Elastic Index document's index, from its cluster. | No

The tools never write to Elasticsearch: an index template is given to the user (or their cluster admin) to apply.


## Processing

Streams, processor filters and tasks, sampling and stepping.

Tool | What it does | Changes
-- | -- | --
`stream_meta` | Finds streams and their meta, grouped and aggregated if asked. | No
`summarise_streams` | Summarises streams' errors (grouped and triaged) or events (counts per event type and action). | No
`locate_event` | Traces a stream, or one event in it, back to the raw stream, record, pipeline and code it came from. | No
`processing_status` | A pipeline's processor filters and their progress, and its processor tasks by status. | No
`processor_tasks` | Processing failures and why, backlogs, and task lists and counts across the cluster. | No
`explain_processing` | Why processing isn't happening (or is slow) for a pipeline, feed, stream or the whole cluster, checked link by link from the nodes and jobs to each processor filter, with a fix for each finding. | No
`profile_sample` | Profiles raw data, to tell its format, fields and time stamps (nothing is saved). | No
`survey_feed` | Samples a feed's streams over its lifetime and groups their records into kinds of event. | Build only (some calls)
`set_shape_handling` | Records in the build that some kinds of event are left untranslated on purpose (or no longer are). | Yes, confirms
`upload_sample` | Sends sample data to a feed, as the source's data is received; for files on the user's machine, gives commands to post them. | Build only
`step_pipeline` | Steps one record through a pipeline and shows what each element does to it. | No
`step_sample` | Steps every record of the sample streams and gives one verdict for the whole sample. | No
`step_records` | Steps chosen records of existing streams, where they are. | No
`compare_outputs` | Steps the same records through the current pipeline and a candidate, and compares each record's output field by field. | No
`summarise_fix` | Proves a fix by stepping the streams with it, and packages it for the user with the code's diff. | No
`evaluate_pipeline` | Gathers the facts for an evaluation of a pipeline, the same sections every time for its kind: its errors, a stepping verdict, and the checks for an events, indexing, CEF or reference data pipeline. | No
`create_processor_filter` | Creates a processor filter, for Stroom to process streams through a pipeline. | Yes, confirms
`set_processor_filter_enabled` | Disables a processor filter on a pipeline the build created (the user enables filters themselves). | Build only
`reprocess_streams` | Processes streams again through a pipeline under development, after a change. | Yes, confirms
`wait_for_processing` | Waits until each input stream's processing has ended, then reports the output and Error streams it wrote. | No


## Administration

Configuration and the cluster's work.

Tool | What it does | Changes
-- | -- | --
`config_properties` | Searches, gets and lists system properties, with where each value comes from; secrets masked. | No
`server_tasks` | The tasks running on every node now, as _Monitoring_ > _Server Tasks_ shows them. | No


## Tools Only in the Chat

These tools work on the chat itself, or offer buttons in it, so the MCP endpoint doesn't offer them:

* `current_results`: Snapshots the results of the attached query or dashboard.
* `memory`, `task_list`, `read_turn` and `search_history`: The chat's memory, task list and history.
* `propose_query`, `propose_query_change`, `propose_dashboard`, `propose_dashboard_change`, `propose_documentation_change`, `propose_code_change` and `propose_visualisation`: proposals the user applies with the chat's buttons.
* `preview_extraction` and `propose_extraction_pipeline`: Try a search extraction on the events of the attached dashboard's table, and offer a button to create it.
* `instruction_evidence` and `propose_instructions`: Gather the choices the user has made again and again in their own chats, and propose them as a folder's standing instructions (its `AGENTS` document), for the user to review and apply (see [Suggesting standing instructions]({{< relref "../pipeline-admin/configuration#suggesting-standing-instructions" >}})).


## Resources

With its tools, the endpoint serves MCP resources the tools refer to:

* **Guides** (`stroom://guide/<name>`, listed at `stroom://guides`): how to work with Stroom's content, e.g. `xslt`, `event-logging`, `data-splitter`, `json-input`, `reference-data`, `indexing`, `cef`, `documentation` and `visualisation`.
* **Field convention profiles** (`stroom://conventions/<name>`): the field naming conventions for indexes, `ecs` and `stroom-flat`.

When a client connects, Stroom also sends it instructions on how its tools work together, such as the order of an onboarding build.
