---
title: "Agent Tools"
linkTitle: "Agent Tools"
weight: 20
date: 2026-10-22
tags:
  - ai
  - mcp
description: >
  Stroom's tools for AI agents, served to MCP clients through Stroom's own MCP endpoint.
---

Stroom serves its tools to AI agents through the {{< external-link "Model Context Protocol" "https://modelcontextprotocol.io" >}} (MCP), at its `/mcp` endpoint.
An MCP client, such as VS Code, Claude Code or Claude Desktop, connects to it as a Stroom user and gives its model the tools that user may use: to find and read documents, search data, read streams, step pipelines, and build feeds, translations, pipelines and indexes.

They are the same tools that the [Ask Stroom AI]({{< relref "../ask-stroom-ai" >}}) chat uses, apart from those that only make sense in the chat (its task list, memory, history, the attached tab, and proposals applied with the chat's buttons, such as creating a chart).


## How the Tools are Governed

* **Permissions.**
  A user needs the _Use MCP Tools_ application permission to connect at all.
  Each tool call then runs as that user, so it can only read and change what they can, as in Stroom's own screens.

* **Tool policies.**
  [MCP Tool Policies]({{< relref "tool-policies" >}}) say which categories of tools each user or group is given, and whether only the tools that cannot change anything, or all of them.
  The same policies govern the Ask Stroom AI chat.

* **Approval of changes.**
  A call from an outside client that would change something in Stroom asks the user first.
  The client shows a form (MCP elicitation) to allow or refuse the call.
  The exceptions are the tools that ask the user in a form of their own, and the onboarding tools that can only change the documents in their own build folder, as nothing outside it changes until the build is promoted, which asks the user itself.
  A client that can't show forms can use the tools that only read; a call that would change something is refused, saying why, so that the client's model can never approve a change itself.

* **Audit.**
  Every call, whether made, refused or not approved, is recorded in Stroom's audit log, with the client that made it.
