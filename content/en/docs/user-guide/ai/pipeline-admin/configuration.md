---
title: "Configuring for your environment"
linkTitle: "Configuring for your environment"
weight: 30
date: 2026-10-27
tags:
  - ai
  - pipeline
  - configuration
description: >
  Pointing the agent at your pipeline templates, and setting its build folder, error triage rules, field conventions and sample uploads.
---

The agent's onboarding and pipeline tools follow Stroom's own conventions by default.
These settings, all under `stroom.ai`, fit them to your environment.


## The Build Folder

`builds.workspaceFolder` (default `MCP Workspace`) is the folder below `System` in which each build gets a folder of its own.

{{< stroom-tree "System" >}}
  {{< stroom-tree "MCP Workspace" "The build workspace folder" >}}
    {{< stroom-tree "acme" "A build's folder" />}}
    {{< stroom-tree "firewall" "Another build's folder" />}}
  {{< /stroom-tree >}}
{{< /stroom-tree >}}

Users who onboard sources need permission to create folders in it.

{{< warning >}}
Renaming the setting leaves builds already in the old folder behind: rename the folder in the explorer tree to match.
{{< /warning >}}


## Pipeline Stages and Templates

The agent recognises each pipeline's _stage_, and looks for templates for a new pipeline of that stage, by `pipelineStages`.
The stages are:

Stage | What it does
-- | --
`translation` | Raw Events to Events.
`indexing` | Events to an index.
`discovery` | Raw structured data straight to an index, with no Events.
`reference` | A Raw Reference feed to the reference data maps that {{< xslt-func-link "lookup" >}} reads.
`records` | A source to a Records stream.
`forwarding` | Events sent on, e.g. as CEF to Kafka, or as CEF written to a file. A pipeline writing text is taken as CEF output when its XSLT, or an XSLT it imports, writes CEF lines.

Each stage has:

Property | Description
-- | --
`templateFolders` | The Explorer folders (paths from System, e.g. `System/Template Pipelines`) where the agent looks for templates for a new pipeline of this stage.
`templateNames` | Glob patterns (e.g. `Event Data (*)`) that the names of the templates in those folders must match. Empty for any name.
`schemaGroups` | The SchemaFilter `schemaGroup` values that mark a pipeline as this stage, when its elements don't say.
`streamTypes` | The StreamAppender `streamType` values that mark a pipeline as this stage, when its elements don't say.

Templates are looked for in the configured folders first, then among pipelines that working pipelines already inherit from, then in Stroom's standard templates.
If no template has the parser the samples need, the agent offers a template with its parser replaced; only if there is no translation template at all does it build an events pipeline of its own.
Likewise, only if there is no discovery template does it build a discovery pipeline of its own.
So that new pipelines inherit from your templates, make sure each stage you use (including `discovery` and `reference`) can find them.

Set the folders and names to your own templates, so that new pipelines inherit from them, and the schema groups and stream types if your templates validate against other schema groups or write other stream types.


## Error Triage Rules

The agent triages pipeline errors as **blocking** (must be fixed), **review** (may be caused by the pipeline's own content) or **benign** (report only), using Stroom's own rules.
`errorTriage.rules` adds your environment's rules, checked in order before Stroom's; the first to match decides.

Each rule may give:

Field | Matches
-- | --
`severity` | A list of `FATAL`, `ERROR`, `WARNING` and `INFO`.
`element` | A glob on the element's id.
`own` | `true` for an element the pipeline sets itself, `false` for one it inherits.
`message` | A regular expression on the error message.

and must give its `class` (`blocking`, `review` or `benign`) and `reason`.
For example, so that lookup misses for accounts not in reference data are reported but not fixed:

```yaml
appConfig:
  ai:
    errorTriage:
      rules:
        - element: decorationFilter
          severity: [WARNING, INFO]
          message: 'lookup'
          class: benign
          reason: 'User decoration miss for accounts not in reference data'
```

Errors a user tells the agent are benign during onboarding are also recorded in the source's documentation.


## Field Conventions

When indexing, the agent names fields following a convention that the user chooses: Elastic Common Schema (`ecs`) or Stroom's flat naming (`stroom-flat`).
It can also follow the fields of an index you point it at.
The conventions are served to MCP clients as resources (`stroom://conventions/<name>`).


## Sample Uploads

Samples on a user's machine are uploaded through Stroom's MCP endpoint, which needs to be turned on, with the commands the agent gives (see [Sample Data]({{< relref "onboarding#sample-data" >}})).
`sampleUploads.maxUploadMb` (100), `sampleUploads.commandsLast` (15 minutes) and `sampleUploads.maxPendingPerUser` (20) limit them (see [Deploying the MCP endpoint]({{< relref "../agent-tools/deployment" >}})).


## Standing Instructions (AGENTS Documents)

Give the agent your environment's own rules in {{< stroom-doc "Documentation" >}} documents named `AGENTS`, the equivalent of an `AGENTS.md` file.
An `AGENTS` document in a folder applies to everything in that folder and below it, e.g. `/Feeds/AGENTS` for every feed.

{{< stroom-tree "System" >}}
  {{< stroom-tree-doc "Documentation" "AGENTS" "Applies to everything" >}}
  {{< stroom-tree "Feeds" >}}
    {{< stroom-tree-doc "Documentation" "AGENTS" "Applies to every feed" >}}
    {{< stroom-tree "ACME" >}}
      {{< stroom-tree-doc "Documentation" "AGENTS" "Applies only to the ACME feeds" >}}
      {{< stroom-tree-doc "Feed" "ACME-FIREWALL-EVENTS" >}}
    {{< /stroom-tree >}}
  {{< /stroom-tree >}}
{{< /stroom-tree >}}

Working on the `ACME-FIREWALL-EVENTS` feed, the agent reads all three, starting with the one in `System`.
The agent reads those that apply to the folders, feeds and documents it works on, most general first, as the user (so only those they can view), e.g.:

* How XSLT is written, and how fields are mapped
* How feeds, pipelines and other documents are named
* Folders that searches should leave out

Each read is recorded in the audit log.

Some sections of an `AGENTS` document are applied by the tools themselves, not only given to the agent.
Each is a heading followed by bullets of the form `- key: value, value`:

* `## Required imports`: shared XSLTs that every XSLT of a stage imports (stages: `translation`, `records`, `indexing`, `reference`, `cef`).
  Every XSLT the agent generates for that stage imports them, and one written by hand without them is refused when saved.

  ```markdown
  ## Required imports
  - translation: Stream-Meta-V1
  - indexing: Common-Index-V1, Lookups-V2
  ```

* `## Component templates`: Elasticsearch component templates your index templates always (`include`) or never (`exclude`) use.
  The index templates the agent proposes follow them, and a template that breaks them is pointed out.

  ```markdown
  ## Component templates
  - include: logs-ilm-90d, org-base
  - exclude: legacy-base
  ```

* `## Documentation`: how a pipeline's documentation lays out its field mapping: by event type (the default: the fields every event type has in one table, then a table per event type), or `compact` (one table).

  ```markdown
  ## Documentation
  - field mapping: compact
  ```

The agent also follows how your environment's pipelines already write common elements: shared templates that two or more of your event (or indexing) pipelines call are used in its new XSLTs in the same way, and it warns when an XSLT doesn't call one.


### Suggesting Standing Instructions

Choices you make again and again in the chat, such as how a field is mapped or what a feed is called, are lost when each chat ends.
The agent can suggest writing them down as standing instructions, so the next build follows them without asking.

It does so in the Ask Stroom AI chat only, at two points:

* **When you ask**, e.g. _"Suggest standing instructions for /Feeds/Acme from my recent chats"_.
* **After a build is promoted**: once you have what you need about the promotion, the agent looks for repeated choices and, if it finds any, offers once to propose them for the feed's folder.
  It doesn't offer if it finds none, or if the folder's `AGENTS` document says them already.

The agent works from your own chats only:

1. It reads your chats from the last 90 days (up to the 200 most recent), and gathers the answers you gave its forms, grouped by question, and what you wrote yourself.
   A choice made the same way in two or more chats, and never another way, is _repeated_; one made different ways is _mixed_, and is not a rule.
1. It drafts rules only from repeated choices, or from what you said you always want, citing the chats each comes from.
   It reads the folder's `AGENTS` documents first, so nothing is said twice.
   A preference that is yours alone goes in your [memory]({{< relref "../how-it-works/memory" >}}) instead, as it isn't a rule for everyone working in the folder.
1. It proposes the rules for a folder as a diff, with a summary of what they do and why, and a _Review and apply_ button.
   Nothing changes until you apply it, and you can leave out any part of it.

What applying does depends on the folder:

* **A folder with an `AGENTS` document**: the change is applied to the document's editor, unsaved, for you to check and save, which needs Edit permission on it.
* **A folder without one**: applying creates the `AGENTS` document in the folder, with the parts you kept, and saves it, which needs Create permission in the folder.
  If someone has created one since the proposal was made, applying is refused, and you can ask for the change to be proposed to that document instead.

A line in one of the sections the tools apply themselves that names nothing they know (e.g. a misspelt stage such as `indexng`) is pointed out with the proposal, so it can be corrected before you apply it.
Creating or changing an `AGENTS` document is recorded in the audit log, as any other document change is.

Two settings, under `stroom.ai.instructionSuggestions`, control what counts as a repeated choice:

Setting | Default | What it does
-- | -- | --
`evidenceWindow` | `90d` | How far back a user's chats are read. Chats already deleted by `stroom.ai.chatRetention` aren't read.
`minChats` | `2` | How many chats must make a choice the same way, and none another way, before it is suggested as a rule.


## Guides for the Agent

The agent also works from built-in guides on XSLT, the event-logging schema, Data Splitter, JSON input, reference data, indexing, CEF and documentation, which MCP clients can read too (`stroom://guide/<name>`).
