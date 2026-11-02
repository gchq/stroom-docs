---
title: "Ask Stroom AI"
linkTitle: "Ask Stroom AI"
weight: 10
date: 2026-10-22
tags:
  - ai
description: >
  A chat inside Stroom, in which an AI model answers questions about Stroom and your data, and builds and changes content with you.
---

_Ask Stroom AI_ is a chat panel in the Stroom UI.
You ask a question, and a model answers it using Stroom's own tools: it can find and read documents, run StroomQL queries, read streams, step pipelines, look into processing, build feeds, translations, pipelines and indexes with you, and chart and extend your dashboards.
Every tool runs as you, with your permissions, so the model can only see and change what you can.

An administrator has to set up a model before the chat can be used: see [Setting up Ask Stroom AI]({{< relref "setting-up" >}}).


## Asking a Question

Open the chat with the {{< stroom-icon "ai.svg" "Ask Stroom AI" >}} _Ask Stroom AI_ button in the main toolbar, or from a table's or chart's {{< stroom-icon "ai.svg" "Ask Stroom AI" >}} _Ask Stroom AI_ button to ask about its rows.
Type a question in the box at the bottom and press {{< key-bind "enter" >}}.

The answer streams in as the model writes it.
Everything the model does to answer is shown in the conversation, in the order it happens: its reasoning (if the model gives it), what it writes to you along the way, each tool it calls (with the result, which you can expand), and its answer.
While it works, a _Working…_ line at the bottom says what it is doing.

A message sent while the chat is working steers it: the model reads it once its current step finishes.
{{< stroom-icon "fast-forward.svg" "Send now" >}} _Send now_, on a message waiting to be read, sends it without waiting for the step to finish.
{{< stroom-icon "stop.svg" "Stop" >}} _Stop_ stops everything the chat is doing.


## Modes

Each chat has a mode, chosen beside the model:

Mode | What the model may do
-- | --
_Agent_ | Does what you ask, with all the tools it is given.
_Ask_ | Answers questions, with only the tools that cannot change anything.
_Plan_ | Works out a step-by-step plan without carrying it out, with only the tools that cannot change anything. Switch to _Agent_ to have it done.


## What the Model Can be Given

Which of Stroom's tools you are given is set by your administrator's [MCP Tool Policies]({{< relref "../agent-tools/tool-policies" >}}): by category, and either only the tools that cannot change anything or all of them.
A model can also be given the tools of other MCP servers your administrator has connected to it.
