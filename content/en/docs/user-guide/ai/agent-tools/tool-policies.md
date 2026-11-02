---
title: "MCP Tool Policies"
linkTitle: "MCP Tool Policies"
weight: 20
date: 2026-10-22
tags:
  - ai
  - mcp
  - security
description: >
  Granting Stroom's AI tools to users and groups, for MCP clients and the Ask Stroom AI chat.
---

A tool policy grants categories of Stroom's tools to users and groups.
For each category it grants either only the tools that cannot change anything, or all of them.
Policies apply to MCP clients and to the [Ask Stroom AI]({{< relref "../ask-stroom-ai" >}}) chat alike.

A user gets the tools of every enabled policy that covers them, directly or through a group.
With no policy covering them, they get no tools.
A policy only narrows what a user can do: each tool still checks the user's other permissions, as Stroom's own screens do.


## Managing Policies

Policies are managed in {{< stroom-menu "Security" "MCP Tool Policies" >}}, which needs the _Manage MCP Tool Policies_ application permission.

The screen has four panels:

* **Policies** (top left), to add {{< stroom-icon "add.svg" "Add MCP Tool Policy" >}}, edit {{< stroom-icon "edit.svg" "Edit MCP Tool Policy" >}} and delete {{< stroom-icon "delete.svg" "Delete MCP Tool Policy" >}}.
* **The tool categories the selected policy grants** (top right).
  Each category is a row showing its access, which opens to list its tools and what each does.
  The **Read** and **Write** columns show a tick or a cross for whether a tool's calls that only read, and those that change things, are permitted.
  A column is blank for a tool with no calls of that kind, so a tool that only reads has nothing under **Write**.
  A category the policy doesn't grant is greyed out, with a cross for each of its tools.
  Typing in the tool search shows only the tools whose names match, highlighted, in their categories.
* **Assigned members**: The users and groups the selected policy covers, to add {{< stroom-icon "add.svg" "Add User Or Group" >}} and remove {{< stroom-icon "delete.svg" "Remove User Or Group" >}}.
  A group covers everyone in it.
  A policy for all users, such as _Default read-only tool policy_, shows **Everyone**, which can't be removed.
  Changes here are saved at once.
* **Effective access** (bottom).
  Click {{< stroom-icon "search.svg" >}} and choose a user or group to see what every enabled policy covering it grants it together, shown as in the categories panel.
  The **Granted By** column names the policies each permission comes from.

The same effective access is shown on the **MCP Tools** tab of a user's or group's page (opened from {{< stroom-menu "Security" "Users" >}} or {{< stroom-menu "Security" "User Groups" >}}), for those with the _Manage MCP Tool Policies_ permission.

The policy dialog sets:

* **Enabled**: A disabled policy is kept, but grants nothing.
* **Name** and **Description**.
* **Categories**: A row for each category, with a tick box to grant it and its access:
  _Read-only_ (only the tools, and the calls, that cannot change anything) or _Read and write_.
  A newly ticked category starts at _Read and write_, since the default policy already grants everyone read-only access.


## Categories

Category | Tools for
-- | --
Core | Documents, folders and their instructions, the date and time, and working tools: questions, the task list, memory and workspace files.
Search | StroomQL queries, events and data sources.
Content | Creating and changing Stroom documents: translations, pipelines, feeds, queries, dashboards and their charts and search extractions, and documentation.
Indexing | Indexes, their fields, and Elasticsearch index templates.
Processing | Streams, processor filters and tasks, sampling and stepping.
Administration | Configuration properties and server tasks.

The [MCP Tool Reference]({{< relref "tool-reference" >}}) lists the tools in each category.

Reading streams is in Processing, and reading the source events behind search results is in Search, so a policy granting only Core doesn't read raw data.

The tools of an [MCP tool server]({{< relref "../ask-stroom-ai/setting-up" >}}) connected to Ask Stroom AI are in the category its document gives them (Core by default), unless the server is trusted and a tool names a category itself.


## After an Upgrade

When Stroom 7.14 is installed, or upgraded to, with no tool policies, it adds one policy, _Default read-only tool policy_, covering all users with read-only access to every category, so that chat users keep the tools that only read.
Tools that change things need a policy that grants read and write.
