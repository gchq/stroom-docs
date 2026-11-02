---
title: "AI"
linkTitle: "AI"
weight: 15
date: 2026-10-22
tags:
  - ai
  - mcp
description: >
  Stroom's AI features: the Ask Stroom AI chat, and Stroom's tools for AI agents over MCP.
---

Stroom offers AI help in two ways, which share one set of tools:

* [Ask Stroom AI]({{< relref "ask-stroom-ai" >}}): A chat inside Stroom, in which a model answers questions about Stroom and your data, and builds and changes content with you.

* [Agent Tools]({{< relref "agent-tools" >}}): Stroom's tools offered to AI agents outside Stroom (e.g. VS Code, Claude Code or Claude Desktop) through Stroom's MCP endpoint, `/mcp`.

[Pipeline Administration]({{< relref "pipeline-admin" >}}) covers onboarding data sources and editing pipelines with the agent, for pipeline administrators.
[How it Works]({{< relref "how-it-works" >}}) explains the technical side: runs and the model's context, memory, workspaces, and how untrusted content is handled.

Whichever way a tool is called, it runs as the signed-in user, with their permissions, and only the tools their [MCP Tool Policies]({{< relref "agent-tools/tool-policies" >}}) grant are offered.
