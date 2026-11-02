---
title: "The chat interface"
linkTitle: "The chat interface"
weight: 5
date: 2026-10-27
tags:
  - ai
description: >
  A tour of the Ask Stroom AI chat panel: chats and their history, modes, models, auto-approve, sending, stopping and steering, attachments, suggestions and settings.
---

## Opening the Chat

Click {{< stroom-icon "ai.svg" "Ask Stroom AI" >}} _Ask Stroom AI_ in the main toolbar to open or close the chat.
The button's badge shows when a chat needs you, is working, or has an answer you haven't read.

The chat is docked beside Stroom's tabs by default.
To give it more room, choose {{< stroom-icon "maximise.svg" "Open in a Tab" >}} _Open in a Tab_, and {{< stroom-icon "minimise.svg" "Move Back to the Panel" >}} _Move Back to the Panel_ to dock it again.
Where it docks (left, right, top or bottom), or whether it opens as a tab or a dialog, is set in **Settings** (see [Your Settings](#your-settings)); drag its edge to resize it.

The panel has, from top to bottom:

* The chat's title, which opens the list of your chats, with {{< stroom-icon "add.svg" "Start a new chat" >}} _New chat_, {{< stroom-icon "explore.svg" "Chat history navigation" >}} _Chat history navigation_ and the {{< stroom-icon "ellipses-vertical.svg" "More" >}} _More_ menu
* The conversation
* The task list, while the agent works through a task with several steps
* The attachments, above the input box
* The input box, with the mode, {{< stroom-icon "shield.svg" "Auto-approve" >}} _Auto-approve_, the model, the context meter, and the {{< stroom-icon "play.svg" "Send message" >}} _Run_ and {{< stroom-icon "stop.svg" "Stop" >}} _Stop_ buttons


## Chats

Each conversation is a _chat_, kept on the server: it carries on if you close the panel, move to another tab or close your browser, and you can come back to it later, from any browser.
A question keeps being worked on while you are away, but only tools that cannot change anything run once no one has been watching the chat for a while (10 minutes by default); anything else waits until you come back.
Signing out of Stroom, or your session expiring, stops your chats' work.

* **New chat**: {{< stroom-icon "add.svg" "Start a new chat" >}} _New chat_, or `/new [question]`.
  A chat that is still empty is new already.
* **Your chats**: Click the chat's title to list your chats, most recently active first, and click one to open it.
  Type in _Search chats_ to find chats by their titles and your questions in them; Escape clears the search.
  {{< stroom-icon "delete.svg" "Delete chat" >}} deletes a chat.
* **Titles**: A chat is named after your first question, then retitled by the model as the conversation goes on.
  Once you rename it ({{< stroom-icon "edit.svg" "Rename Chat" >}} _Rename Chat_ in the {{< stroom-icon "ellipses-vertical.svg" "More" >}} menu), it keeps your name.
* **Status**: Each chat's icon in the list says how it is:

  Icon | Meaning
  -- | --
  {{< stroom-icon "alert.svg" "Needs you" >}} | Needs you: waiting for your answer or approval.
  Spinner | Working on your question, or queued behind other questions.
  {{< stroom-icon "error.svg" "Failed" >}} | Failed: the last question ended with an error.
  {{< stroom-icon "pause.svg" "Stopped" >}} | Stopped or interrupted: _Resume_ carries on from the last question.
  {{< stroom-icon "dot.svg" "Unread" >}} | Has an answer you haven't read.

  You can work in several chats at once: by default, three of your questions are worked on at a time, and others wait their turn.

Chats you haven't used for 90 days (by default) are deleted.


## Modes

The mode, chosen beside the model, says what the agent may do:

Mode | What the agent may do
-- | --
_Agent_ | Does what you ask, with all the tools it is given.
_Ask_ | Answers questions, with only the tools that cannot change anything.
_Plan_ | Works out a step-by-step plan for what you ask, with only the tools that cannot change anything, without carrying it out. Switch to _Agent_ to have it done.

`/mode agent|ask|plan` changes the mode, and `/plan <task>` switches to _Plan_ and asks in one step.
A chat keeps its mode, including for work carried on after an approval or a resume.


## Choosing a Model

The model box beside the mode lists the models your administrator has set up.
The one you choose is kept in your settings, and used from the next question of the open chat.
If you haven't chosen one, or yours has been removed, the default model is used.
If you choose the default model, you follow it: when your administrator changes the default model, you use the new one from your next new chat.
While you follow the default, a chat that has already been answered keeps the model it was answered with, including when you go back to it later, unless you choose another for it.

The model box shows the model the open chat's next question will use: the one you picked for this chat, else your own choice, else the one the chat has been answered with, else the default.

Models differ in what they are good at and in the size of their context window, which the context meter shows (see [Context and Memory]({{< relref "using-the-chat#context-and-memory" >}})).


## Auto-approve

Stroom asks you before some tool calls run (see [Approvals]({{< relref "using-the-chat#approvals" >}})).
{{< stroom-icon "shield.svg" "Auto-approve" >}} _Auto-approve_, if your administrator allows it, lets tools that change data keep running without asking for the rest of this chat, even once it has read data that could hold planted instructions.
The shield is highlighted while it is on; click it again to turn it off.
It never covers the tools of an untrusted MCP server, destructive tools or those that reach outside Stroom, or tools set to _Ask every time_, and it doesn't apply while no one is watching the chat.

Use it only for work you are watching, on data you trust.
To allow one tool rather than all of them, choose to allow it for the rest of the chat on its approval card; **Tool Approvals** in the {{< stroom-icon "ellipses-vertical.svg" "More" >}} menu lists what you have allowed, to revoke.


## Asking, Stopping and Steering

* **Asking**: Type in the box and press {{< key-bind "enter" >}} ({{< key-bind "shift+enter" >}} for a new line), or click {{< stroom-icon "play.svg" "Send message" >}} _Run_.
  Type `/` to list the [commands]({{< relref "using-the-chat#commands" >}}).
* **Following the work**: Everything the agent does is shown as it happens: its reasoning, what it writes along the way, each tool call (click one to see its arguments and result), and its answer.
  A _Working…_ line at the bottom says what it is doing now.
  If you scroll up, the chat stops following; _Scroll to the latest message_ follows it again.
* **Stopping**: {{< stroom-icon "stop.svg" "Stop" >}} _Stop_ stops everything the chat is doing, including tool calls and downloads, and any form or question waiting for you.
  A stopped question can be resumed with _Resume_.
  If the agent stops short (at its step limit, or having only said what it would do next), say _"carry on"_: it picks up from the steps it took, rather than starting again.
* **Steering**: Send a message while the agent works, e.g. _"Only look at the last day"_.
  It is shown queued (_Waiting for the current step to finish_), and the agent reads it before its next step.
  {{< stroom-icon "fast-forward.svg" "Send now" >}} _Send now_ on the queued message has the agent stop waiting for another server's tool and read it at once.
* **Answering instead**: A message sent while the chat waits for you to fill in a form, or to approve a tool call, answers it: the form is put aside, or the calls are refused with your message as the reason, and the agent carries on.

Each message has buttons:

* Your questions: {{< stroom-icon "edit.svg" "Edit" >}} _Edit_ and ask again, and {{< stroom-icon "refresh.svg" "Ask again" >}} _Ask again_ (both send the attached tab as it is now)
* Answers: {{< stroom-icon "copy.svg" "Copy as Markdown" >}} _Copy as Markdown_ and _Copy as text_
* {{< stroom-icon "delete.svg" "Delete message" >}} _Delete message_

Code blocks in answers have a copy button, inline code copies when clicked, and each heading in an answer can be collapsed.


## Attaching Tabs, Documents and Tables

The agent only sees what you attach: nothing is shared just because a tab is open.
Attachments are shown as chips above the input box.

* **The tab you are on**: Click the dashed {{< stroom-icon "add.svg" "Attach" >}} chip naming it.
  It stays attached (shown as _Tab: name_, with _(unsaved)_ while it has unsaved changes) until you remove it or close the tab, and each question sends it as you see it then.
  One tab is attached at a time.
* **Documents**: Right-click documents in the Explorer and select {{< stroom-icon "ai.svg" "Attach to chat" >}} **Attach to chat**.
* **Tables and charts**: Click {{< stroom-icon "ai.svg" "Ask Stroom AI" >}} _Ask Stroom AI_ on a dashboard table, a query's results or a chart, which attaches its rows.

Documents and tables go with your next question; the tab stays for every question.
Remove an attachment with {{< stroom-icon "close.svg" "Remove" >}} on its chip.
See [Attaching a Tab]({{< relref "using-the-chat#attaching-a-tab" >}}) for what the agent is given.


## Suggestions

The chat suggests questions as links above the input box; click one to ask it.

* When you attach something, it suggests questions about it, e.g. what a feed has received, why a query has no results, or, for a feed or folder, onboarding a new source.
* After an answer, it suggests up to three follow-ups.

Suggestions aren't offered while the chat is working, or after a turn in which the agent asked you for something.
Your administrator can turn off the model's suggestions.


## The Task List

For work with several steps (e.g. onboarding a source), the agent writes a task list before it starts and keeps it up to date, shown above the input box with how many steps are done, and each step marked as not started, in progress or done.
Click its heading to fold it away.


## Chat History Navigation

{{< stroom-icon "explore.svg" "Chat history navigation" >}} _Chat history navigation_ shows the chat as a flowchart of what you did (your questions, messages, answers and approvals), joined by lines saying which tools the agent called in between and how long it took.
Click a step to go to it in the conversation.

* {{< stroom-icon "search.svg" "Search the chat history" >}} Searches the steps; {{< key-bind "enter" >}} goes to the next match and {{< key-bind "shift+enter" >}} the one before.
* {{< stroom-icon "zoom-in.svg" "Zoom in" >}}, {{< stroom-icon "zoom-out.svg" "Zoom out" >}} (or {{< key-bind "ctrl" >}} and the mouse wheel) and {{< stroom-icon "fit-width.svg" "Fit to the panel's width" >}} zoom it.


## The More Menu

{{< stroom-icon "ellipses-vertical.svg" "More" >}} _More_ has, for this chat:

* {{< stroom-icon "edit.svg" "Rename Chat" >}} **Rename Chat**.
* {{< stroom-icon "collapse-up.svg" "Compact Context" >}} **Compact Context**: shortens the chat's earlier turns for the model, as `/compact` does.
* {{< stroom-icon "ok.svg" "Tool Approvals" >}} **Tool Approvals**: the tools you have allowed for the chat, to revoke.
* {{< stroom-icon "download.svg" "Download History" >}} **Download History**: the whole conversation as a file.
* {{< stroom-icon "delete.svg" "Delete Chat" >}} **Delete Chat**.

and, for all your chats:

* {{< stroom-icon "info.svg" "Memory" >}} **Memory**: what the agent remembers, to view, edit and undo (see [Memory]({{< relref "../how-it-works/memory" >}})).
* {{< stroom-icon "settings.svg" "Settings" >}} **Settings**.


## Your Settings

**Settings** holds your own chat settings:

Setting | Description
-- | --
_Model_ | The model your chats use.
_Dock Type_, _Dock Location_ | How the chat is shown: docked (and where), as a tab, or as a dialog.
_Chat System Prompt_, _History Summary Prompt_ | The prompts the chat starts from, and summarises earlier turns with. Change them only if you know what you need.
_Show tool calls_ | Shows the agent's tool calls in the conversation. Turning it off only hides them.
_Show reasoning_ | Shows the model's reasoning, where the model gives it and its settings keep it.
_Show request detail_ | Keeps and shows what the model was sent for each answer, for troubleshooting.
_Enable browser notifications_ | Notifies you when a chat finishes or needs you while you are elsewhere.

Until you press **OK**, you use the defaults your administrator sets, and follow any change to them.
**Restore From Defaults** puts the defaults back in the dialog.
See [Default Chat Settings]({{< relref "setting-up#default-chat-settings" >}}) for how administrators set them.
