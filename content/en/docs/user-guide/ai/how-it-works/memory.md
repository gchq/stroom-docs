---
title: "Memory"
linkTitle: "Memory"
weight: 20
date: 2026-10-27
tags:
  - ai
description: >
  The agent's memory: the user's own and each chat's, how it is stored and loaded, its limits, and when a change needs the user's approval.
---

The agent has two kinds of memory, both made of short named notes:

Memory | Path | Loaded into | Limits
-- | -- | -- | --
The user's | `/memories/<name>` | Every chat of that user | 16 KiB and 200 lines in all, at most 20 notes
The chat's | `/memories/session/<name>` | That chat only | 64 KiB in all, at most 20 notes

A note's name is up to 64 letters, digits, `.`, `_` and `-` (not starting with `.`); there are no sub-folders.
The limits are fixed, not configured.

Memory is for what should carry over: facts about your environment (_"the ACME feeds are owned by the network team"_), your preferences, or, in a chat's memory, where a long task has got to.
The agent's memory is only available in the chat, not to MCP clients.


## Storage

Notes are held in Stroom's database, one row per note, keyed by the user, the scope (the user's or a chat's) and the note's name.
Each note has a version: a change made by the agent must give the version it read, so that two changes can't overwrite each other unseen.


## How the Agent Uses It

All of a user's memory, and the chat's, is added to the end of the system message on every call to the model (see [Runs and context]({{< relref "runs-and-context#what-the-model-is-sent" >}})), headed by guidance telling the model that memory is data, not instructions.
User memory is shown up to 200 lines, and the chat's memory up to 8,000 characters, with a note saying when there is more.

The agent reads and changes memory with its `memory` tool: `list`, `read`, `write`, `append`, `replace` and `delete`.
A `write` or `delete` of a note that exists must give the version read.


## Approval of Changes

A change to the chat's memory doesn't ask, as it stays in the chat, except while the run is unattended, when it waits for the user as any change does (see [Runs and context]({{< relref "runs-and-context#runs" >}})).

A change to the user's memory lasts, and reaches every later chat, so the user is asked to approve it on an approval card when:

* The chat has read untrusted content, which could have told the model to remember something (see [Trust and untrusted content]({{< relref "trust" >}})).
* The run is unattended.

Until it is approved, the change isn't saved, and the model is told so.
An approval request expires after 24 hours.


## Viewing and Undoing Changes

**Memory**, in the chat's {{< stroom-icon "ellipses-vertical.svg" "Menu" >}} menu, lists the notes of both kinds, to view, edit and delete.
It also lists each change the agent made to the user's memory in that chat, latest first, with what the note held before and after, and _Undo_.
Undo works only while the note still holds exactly what the change left in it.

Your own edits in **Memory** need no approval and aren't listed as changes.

`/remember <fact>` adds the fact to your memory, as a line of the note `/memories/remembered.md` (made with a _Remembered_ heading the first time).
It is your own change, so it isn't asked about.


## Clearing and Retention

* `/clear` deletes the chat's own memory, with its messages and workspace files, and keeps your memory.
* Deleting a chat (including by `stroom.ai.chatRetention`) deletes its memory.
* The user's memory doesn't expire.
  The _AI Chat Retention_ job (hourly) deletes the chats and memory of users who no longer exist.
