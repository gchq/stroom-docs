---
title: "Using the chat"
linkTitle: "Using the chat"
weight: 10
date: 2026-10-22
tags:
  - ai
description: >
  Approvals, questions and forms, steps for you, links, attaching tabs, documents and tables, commands, and memory.
---
## Approvals

Stroom's own tools act as you and can only do what you can.
Those that only read run without asking.
Those that change something run without asking until the chat has read something that could hold instructions planted for the model by someone else (such as streams, events, documents, an attached table, or another MCP server's results); from then on, each asks first on an approval card.
Results that hold only Stroom's own text or your own answers, such as the time or the chat's task list, don't count.
Some tools also ask you to confirm what they are about to do in their own form (see below), and aren't asked about a second time.
The onboarding tools that can only change the documents in their own build folder (e.g. saving a draft XSLT) don't ask either, as nothing outside the build changes until it is promoted, which asks you itself (see [Onboarding a data source]({{< relref "../pipeline-admin/onboarding" >}})).
The tools of other MCP servers may ask first, depending on how the server is set up and what the tool does: an approval card shows the call in full, what kind of tool it is, and lets you allow or deny it (with a reason, which the model is told).
You can allow a tool for the rest of the chat, or all of a trusted server's read-only tools, and review the tools you have allowed in **Tool Approvals** (from the chat's {{< stroom-icon "ellipses-vertical.svg" "Menu" >}} menu), where Stroom's own tools are listed as `Stroom (built-in)`.
A change to a tool's name or description, or to its server's settings, asks again.
A request you don't answer expires after 24 hours.
If an administrator allows it, the {{< stroom-icon "shield.svg" "Auto-approve" >}} shield beside the model turns on _Auto-approve_ for the chat (see [Trust and untrusted content]({{< relref "../how-it-works/trust" >}})).

If no one is watching a chat (no browser has polled it for a while), only tools that cannot change anything run; anything else waits for you.


## Questions and Forms

When the agent can't carry on without a decision from you (which feed to use, whether to replace an existing pipeline), it asks you in a card, one question at a time, with suggested answers to click (the one it recommends first) and usually a box for your own answer.
The work carries on with your answers.

Some tools ask you to confirm what they are about to do in a short form, e.g. a new feed's name, which you can correct before it is made.
A form is for a short question: what you are to review at length (an index template, a promotion's layout, the records kept as Unknown events) is shown in the chat first, and the form then asks you to confirm it.
A form from another MCP server with a message over 2,000 characters, more than 20 fields, or a schema over 16,000 characters isn't shown: the chat says it is a problem with that server, for an administrator to report.

An XSLT the agent writes may not reach outside Stroom.
If it newly calls {{< xslt-func-link "host-name" >}} or {{< xslt-func-link "host-address" >}} (which look up names on the network), saving or stepping it asks you first in a form naming each call; your answer is remembered for that document for the rest of the chat.
Other functions that reach outside Stroom ({{< xslt-func-link "http-call" >}}, {{< xslt-func-link "fetch-json" >}} and {{< xslt-func-link "ask-ai" >}}) are always refused.


## Steps for You

Some steps are yours to take, such as enabling a processor filter, or giving an Elasticsearch request to your cluster admin.
The chat shows them as buttons in a _Steps for you_ card.
The model can neither make nor click one: nothing happens until you do, and each click is checked again and done as you.
A button works for 24 hours, only for you, and one that changes something works once; the chat notes it for the agent.
Another MCP server can offer only four kinds of step: enabling or disabling a processor filter, opening a document, and an Elasticsearch request for your cluster admin.
An Elasticsearch request is shown for you to copy, never run, and only if it is `PUT _index_template/<name>`, `DELETE _data_stream/<index>` or `DELETE <index>` (no wildcards or lists), for an index the result's pipelines write to.

The agent can also offer buttons that open Stroom's own New Query or New Dashboard dialog with what it wrote, or apply a proposed change to the query, dashboard or code you have open (_Apply to query_, _Apply to dashboard_, _Review and apply…_), unsaved, for you to check and save.
On a dashboard, it can also offer to create a chart (_Create visualisation_, see [Creating charts]({{< relref "charts" >}})) or a search extraction (_Create extraction pipeline…_, see [Adding fields from events]({{< relref "search-extraction" >}})).


## Links in Answers

The documents and streams an answer names are linked, so you can open them from the chat.
Only those the agent's tools actually gave (and, for documents, that you can view) are linked, so nothing the model made up is.


## Attaching a Tab

The chat only sees what you attach to it.
Above the input box, a {{< stroom-icon "add.svg" "Attach" >}} chip names the tab you are on: click it to attach that tab.
Each question is then sent with the tab as you see it, including unsaved changes and the inner tab shown (e.g. a pipeline's Stepping view with the selected element's input, output and code).
The tab stays attached until you remove it or close the tab.

You can also attach documents from the Explorer (right-click a document and select {{< stroom-icon "ai.svg" "Attach to chat" >}} **Attach to chat**), and tables from a dashboard or query.
Attached tables are downloaded into the chat's workspace for the agent to work through.
A chart's {{< stroom-icon "ai.svg" "Ask Stroom AI" >}} _Ask Stroom AI_ button attaches the data the chart draws.

When you attach something, the chat offers up to three questions about it, e.g. what a feed has received, or what stands out on a chart.
For a feed or a folder, the first offered is to onboard a new data source into it.
After each answer, the chat offers follow-up questions; `stroom.ai.suggestFollowUps` turns the model's suggestions off.


## Workspace Files

Each chat has a workspace.
A large result (a query's rows, a stream's records) is saved there under `/outputs/` rather than given to the model whole, and the agent reads it with its file tools.
Files made from Stroom data are checked against your permissions each time they are used.


## Commands

Type `/` in the input box to list the commands:

Command | Does
-- | --
`/new [question]` | Starts a new chat.
`/mode agent\|ask\|plan` | Changes the chat's mode.
`/plan <task>` | Switches to Plan mode and asks.
`/compact [focus]` | Shortens the chat's earlier turns for the model, to make room.
`/remember <fact>` | Adds a fact to your memory, which every chat loads.
`/clear` | Clears the chat's messages, attachments, workspace files and the chat's own memory, after asking (it can't be undone). The chat, its mode and its tool approvals are kept, as is your own memory.

{{< warning >}}
`/clear` can't be undone.
{{< /warning >}}

To send a message that starts with `/`, start it with `//`.


## Context and Memory

The context meter beside the model shows how much of the model's context window the chat uses.
When a chat gets long, earlier turns are replaced (for the model only) by short digests.
A long piece of work within one question (such as onboarding a source) can fill the context window by itself; the model then summarises its earlier steps in their place, so that what it found is kept.
Everything stays stored, and the agent can read an earlier step again.

The agent has memory: your own, loaded into every chat, and the chat's own.
A change to your memory from a chat that has read data needs your approval.
You can view, edit and undo changes in **Memory** (from the chat's {{< stroom-icon "ellipses-vertical.svg" "Menu" >}} menu).

See [How it Works]({{< relref "../how-it-works" >}}) for how runs, context, memory and workspaces work in detail.
