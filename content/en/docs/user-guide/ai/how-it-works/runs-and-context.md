---
title: "Runs and context"
linkTitle: "Runs and context"
weight: 10
date: 2026-10-27
tags:
  - ai
description: >
  How a question is worked on as a run, what the model is sent with each call, and how a long chat or a long piece of work is made to fit the model's context window.
---

## Runs

A _run_ is one question being answered.
It is worked on in the background, on one Stroom node, as the user who asked, and the browser follows it by polling.
Each run is recorded in the database with its status, its node, the tokens it used and the tools it called.

* **Steps.**
  A run calls the model, carries out the tool calls the model asks for, gives it their results, and calls it again, until the model answers.
  A run makes at most `stroom.ai.maxToolIterations` (100) calls to the model for one question; the last is given no tools, so that it answers.
  A reply that only says what the model will do next, with no tool call, isn't taken as its answer: it is shown as the model's interim words, and the model is told to make the call (at most twice in a row).
* **Unfinished questions.**
  When a question wasn't finished (the model ended on saying what it would do next, or reached the step limit), the next question (e.g. _"go on"_) is given that question's steps in full, with what the model said and found, and told to carry on from them rather than work it all out again.
* **Run slots.**
  A user may have `stroom.ai.maxRunsPerUser` (3) runs working at once across the cluster, and a node `stroom.ai.maxRunsPerNode` (20).
  A run waiting for the user (an approval, a form or a question) doesn't count, and runs beyond the limits wait for a slot.
  Heavy calls from MCP clients (e.g. a StroomQL query) take a slot too, counted on their own node.
* **Time.**
  A run is stopped once it has taken `stroom.ai.maxRunDuration` (2 hours), when its user is disabled or deleted, or when the user's session signs out or expires.
* **Nodes stopping.**
  A working run renews a heartbeat every 10 seconds.
  One whose heartbeat is over a minute old is marked as interrupted, as its node has stopped.
  An interrupted, stopped or failed run can be resumed with _Resume_, which carries on from the last question, on any node.
* **Unattended runs.**
  When no browser has polled any of the user's chats for `stroom.ai.unattendedAfter` (10 minutes), their runs are unattended: only tools that cannot change anything run, and anything else waits for the user.


## What the Model is Sent

Each call to the model is built afresh, from what the chat has stored, in this order:

1. **The system message**: The system prompt (`stroom.askStroomAi.chatSystemPrompt`), guidance on the tools and on the kind of tab attached (for a model with tools), the guidance for the chat's mode (_Ask_ or _Plan_, or _Agent_ for a model with tools), and then the user's and the chat's [memory]({{< relref "memory" >}}).
1. **Digests or a summary of compacted turns**, if the chat has been compacted (see below).
1. **Earlier questions and answers**, in full, with **attached tables and documents** where they were attached.
   Attachments are always kept, even from compacted turns.
   A model with tools is given each table's profile and where it is in the workspace; a model without tools is given the rows.
   The tool calls of earlier turns aren't sent again: only a log of them, a line each, with the start of their arguments and results.
   The agent can read an earlier turn in full with its `read_turn` tool.
1. **The question**, with a note on the attached tab's snapshot.
1. **The current run's steps so far**: The model's tool calls and their results.

A large tool result isn't sent whole: it is saved to the [workspace]({{< relref "workspaces#large-results" >}}), and the model is sent a preview and where to find it.


## Fitting a Long Chat: Compaction

The context meter beside the model shows how much of the model's context window the chat uses.
When a chat reaches `stroom.ai.compaction.thresholdPercent` (80%) of its budget (the window less `compaction.replyReserveTokens`, 4,096 tokens, kept for the reply, but never less than half the window), its earlier turns are compacted:

* Older turns are replaced, for the model only, by digests that Stroom writes itself: the question, each tool called with the start of its arguments, short results copied exactly (up to `compaction.digestMaxResultRows`, 20 lines) or a preview and where the result is stored, the files made, and the first paragraph of the answer.
* The latest `compaction.turnsKeptInFull` (2) turns are kept in full.
* If the digests are still too large, the model folds the oldest into a running summary; if the summary can't be written, the oldest half of those digests are left out of what the model is sent instead, with a warning in the chat.

`/compact [focus]` compacts the chat at once, the model writing a summary with the focus you give.
The latest compaction can be undone while no run is working.

Compaction never deletes anything: every turn stays stored, and the agent can read or search it with its `read_turn` and `search_history` tools.
A model with no context window size set is never compacted automatically.


## Fitting a Long Run

A long piece of work within one question, such as onboarding a source, can fill the window by itself, which compaction (of earlier turns) doesn't help.
Before each call to the model, if the run is too large:

1. With at least six earlier steps besides the latest four, the model summarises them, keeping the latest four as they are, so that what it found is kept rather than read again.
   Once the run has a summary, another waits for twelve more steps.
1. Then the run is shortened a step at a time, least lossy first: earlier tool results (keeping the latest two, and never short ones), then the arguments of earlier calls (e.g. whole code proposed), then all results but the latest, and finally earlier steps put as a line each.
   Results the model read to work from (e.g. a schema's elements or a guide) are kept longer than other results.
If the model still says a request is too large, the run is made smaller and the call tried again, up to five times, before the chat is compacted as far as it will go and the run started again.
A reply cut off as the window filled is continued, up to twice.


## Counting Tokens

Stroom estimates tokens as characters divided by four, corrected by what the model reported for the chat's last call.
Until a call has been measured, the estimate is 25% higher, as XML and JSON take more tokens than prose.
Compaction and the shortening of runs use the same estimate.
