---
title: "Workspaces"
linkTitle: "Workspaces"
weight: 30
date: 2026-10-27
tags:
  - ai
description: >
  The files a chat or MCP session works with: their layout, storage, limits, permission checks and retention.
---

Each chat has a _workspace_: a tree of files that the agent's tools write and read, such as attached tables, query results, fetched events and large tool results.
It lets the agent work through far more data than fits in the model's context: a tool writes a file, and the agent reads, searches or queries just the part it needs.

An MCP client's session has a workspace too (see [MCP Sessions](#mcp-sessions)).
A chat's or session's workspace is its own: no other chat or session can see its files.


## Layout

Folder | Holds | Agent can write
-- | -- | --
`/attachments/` | Attached tables (`<id>.md`), each with its profile (`<id>.profile.md`). | No
`/tabs/<n>/` | Snapshots of the attached tab, one per question that sent it (unless unchanged since the last): its text parts (e.g. `code.xsl`, `query.sql`), a stepping tab's structure (`structure.md`) and the searches behind its tables of results (`searches.json`). | No
`/tabs/results/` | Snapshots of the rows of the attached tab's tables of results, taken by `current_results`. | No
`/documents/<uuid>/` | Documents' content that `read_document` found too large to give in full. | No
`/outputs/` | What the tools and the agent write: query results, fetched events, search results, column summaries, task lists as CSV, and large tool results. | Yes

Some of the files tools write by default:

* `run_stroomql`: `/outputs/queries/query-<time>.md`
* `fetch_events`: `/outputs/events.xml`
* `search_events`: `/outputs/search_events.csv`
* `stream_meta`: `/outputs/stream_meta.csv`
* `processor_tasks` and `server_tasks`: a CSV file under `/outputs/` (e.g. `/outputs/processor_tasks.csv`) when asked to write all the matching tasks
* `summarise_column`: `/outputs/summaries/`
* `preview_extraction`: `/outputs/extraction.xsl`

The workspace tools (`ls`, `read_file`, `grep`, `wc`, `jq`, `xpath`, `table`, `write_file`, `str_replace`, `delete_file` and others) work on these files.
Only files in `/outputs/` can be written or deleted.
Paths are ASCII, up to 512 characters and 8 levels below the top folder.

The agent can also pass a workspace file (or part of one, picked with jq) as an argument of any tool, Stroom's own or another MCP server's, up to `stroom.ai.workspace.maxToolArgumentBytes` (1 MiB).


## Large Results

A tool result of more than 4,000 characters isn't given to the model whole.
It is saved as `/outputs/turn-<turn>/call-<call>.txt` (JSON pretty-printed first), and the model is given its size and path, a preview of up to 30 lines, its JSON top-level fields, and any next step or hint it gives.
The agent then reads the parts it needs.

Results that ask the model to show the user something for review (e.g. an index template) are given in full, up to 64,000 characters.
Stroom's own tools that keep their results short themselves are given in full.


## Storage

A workspace's files are held in Stroom's database: an index of each chat's files, and their content, compressed (zstd) in chunks of about 1 MiB of whole lines.
So any node can read any chat's files, and a run carries on with them on another node.
Each node also keeps a copy of files it reads under its temporary directory (`ai-attachments/`), rebuilt from the database when missing, and removed by the _AI Chat Retention_ job once out of date.


## Limits

Under `stroom.ai.workspace`:

Property | Default | Description
-- | -- | --
`maxFileBytes` | 20 MiB | The largest file.
`maxChatBytes` | 100 MiB | The most a chat's files may hold in all.
`maxUserBytes` | 500 MiB | The most all of a user's chats' files may hold.
`maxLinesPerRead` | `500` | The most lines a tool gives the model from a file in one call.
`maxCharsPerRead` | `20000` | The most characters a tool gives the model from a file in one call.
`toolTimeLimit` | `PT30S` | The longest a workspace tool call may take.
`queryTimeLimit` | `PT2M` | The longest a `run_stroomql` query may take, writing its results included.
`maxQueryLength` | `10000` | The longest StroomQL query `run_stroomql` may run, in characters.
`maxQueryRows` | `10000` | The most rows a query may give; a query with no limit, or a larger one, is capped.
`maxEventsPerFetch` | `500` | The most events `fetch_events` fetches in one call.
`maxEventBytes` | 1 MiB | The largest event `fetch_events` fetches; larger ones are left out.
`maxStreamStoreReads` | `500` | The most streams `stream_meta` may read from the stream store in one call.
`maxToolArgumentBytes` | 1 MiB | The largest arguments of a tool call, once workspace files are put into them.

An attached tab's snapshot is limited by `stroom.ai.maxTabSnapshotBytes` (2 MiB), and an attached table by `stroom.askStroomAi.tableAnalysis.maxTotalRows` (50,000 rows).


## Permissions

A file made from Stroom data (an attached table, query results, a document's content, a tab's snapshot) remembers the document it came from, and is checked against the user's permissions each time it is used:

* Data searched from a data source (e.g. an attached table or query results) needs _Use_ on it.
* A document's own content (under `/documents/`) or a tab's snapshot (under `/tabs/`) needs _View_ on the document, whatever its type.

If the user no longer has the permission, or the document has been deleted, the file is refused.
It isn't deleted, so it can be used again if the permission is given back.


## Retention

Files are kept for `stroom.ai.workspaceFileRetention` (7 days) from when they were last written; `0` keeps them as long as the chat.
An expired file's content is removed, while its entry stays, marked as no longer available with the reason, so the agent knows what it was.
Files are removed when used after they expire, or by the hourly _AI Chat Retention_ job.

`/clear` deletes a chat's workspace files, and deleting a chat deletes its workspace.


## MCP Sessions

An MCP client's session gets a workspace, held as a hidden chat that never appears in the chat list, made the first time a call needs it.
It is deleted when the session ends (once its running calls have finished), or after `stroom.ai.mcpEndpoint.sessionRetention` (1 day) without requests.
The _MCP Session Maintenance_ job, every minute on each node, ends idle sessions.
