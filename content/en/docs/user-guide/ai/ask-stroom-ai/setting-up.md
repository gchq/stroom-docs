---
title: "Setting up Ask Stroom AI"
linkTitle: "Setting up"
weight: 30
date: 2026-10-22
tags:
  - ai
  - configuration
description: >
  For administrators: setting up models, everyone's default chat settings, table analysis, charting libraries, MCP tool servers and Ask Stroom AI's configuration.
---

Setting up Ask Stroom AI takes these steps, most of which need the _Manage Properties_ application permission:

1. [Set up a model](#setting-up-a-model): An {{< stroom-icon "document/OpenAI.svg" >}} **OpenAI Model** document.
1. [Set the default chat settings](#default-chat-settings), the default model among them, for everyone.
1. Check the [tool policies](#tool-policies), which say which of Stroom's tools each user is given.
1. Optionally, install a [charting library](#charting-libraries), connect [MCP tool servers](#mcp-tool-servers), and adjust the [configuration](#configuration).


## Setting up a Model

A model is an {{< stroom-icon "document/OpenAI.svg" >}} **OpenAI Model** document.
Any server with an OpenAI-compatible API can be used: a hosted service, or a self-hosted one such as vLLM.
You can have several models, e.g. a large one for the chat and a small, fast one, and let users choose between them.

1. Create an **OpenAI Model** document in the Explorer.
1. On its **Settings** tab, fill in:

   Setting | Description
   -- | --
   _Base URL_ | The API's base URL, e.g. `https://model-server.example.com/v1`.
   _API Key_ | The credential holding the API key (see {{< stroom-menu "Security" "Credentials" >}}), if the server needs one.
   _Model ID_ | The model's id on the server, e.g. `gpt-4.1` or `Qwen/Qwen3-32B`.
   _Maximum context window tokens_ | The model's context window, in tokens. Stroom uses it to keep what it sends within the window, and to show the context meter. With `0`, chats are never compacted automatically.
   _Reasoning Effort_ | `low`, `medium` or `high`, for a model that supports it; blank otherwise.
   _Embedding model dimensions_ | Only for embedding models, not used by the chat.
   _Tools enabled_ | Whether the model is given tools. Turn it off for a model that can't call tools: it then answers from what it is sent, and [attached tables are analysed in batches]({{< relref "analytics#models-without-tools" >}}).
   _Show reasoning_ | Whether the model's reasoning, when it gives any, is kept and shown to users. On by default.
   _Maximum tools per request_ | The most tool definitions sent to the model in one request, for a server that limits them; `0` for no limit.

1. Optionally, _Set Http Client Config_ sets how Stroom connects to the server: timeouts, TLS, a proxy, and **Headers** sent with every request (e.g. `anthropic-version` for Anthropic's OpenAI-compatible endpoint).

   {{< warning >}}
   Don't put secrets in headers: the API key belongs in the credential.
   {{< /warning >}}

1. {{< stroom-icon "ok.svg" "Test Model" >}} _Test Model_ connects to the server with the settings as they are in the form, and checks that it serves the _Model ID_: it must be listed by the server's `/models`, or found when asked for by its id (`/models/<id>`), as gateways that route by pattern answer.
   Found, the test shows that model's entry; not found, it says so, and its detail lists the models the server does serve.
   Testing needs Edit permission on the model document, as only someone who could save the settings may make Stroom connect with them.
1. Save the document, and [make it the default model](#default-chat-settings).

For testing without a model, set the _Model ID_ to `__stub__`.
The stub answers at once; a question that includes `[[think]]` gets some reasoning, and one that includes `[[tool:NAME {json arguments}]]` calls that tool first.


## Default Chat Settings

Each user's chat settings are in the chat's **Settings** dialog (from the chat's {{< stroom-icon "ellipses-vertical.svg" "Menu" >}} menu).
Its **General** tab holds:

Setting | Property under `stroom.askStroomAi` | Default | Description
-- | -- | -- | --
_Model_ | `modelRef` | None | The model the chat uses.
_Dock Type_ | `dockType` | `DOCK` | How the chat is shown: docked beside Stroom's tabs (`DOCK`), as a tab (`TAB`), or in a dialog (`DIALOG`).
_Dock Location_ | `dockLocation` | `RIGHT` | Where a docked chat sits: `LEFT`, `RIGHT`, `TOP` or `BOTTOM`.
_Chat System Prompt_ | `chatSystemPrompt` | Stroom's own | The system prompt every chat starts from (see [Runs and context]({{< relref "../how-it-works/runs-and-context#what-the-model-is-sent" >}})).
_History Summary Prompt_ | `historySummaryPrompt` | Stroom's own | The prompt for summarising a chat's earlier turns when it is compacted.
_Show tool calls_ | `showToolCalls` | `true` | Whether tool calls are shown in the conversation. Off only hides them; the agent works the same.
_Show reasoning_ | `showReasoning` | `true` | Whether the model's reasoning is shown, where the model's own _Show reasoning_ keeps it.
_Show request detail_ | `enableDebugDetail` | `true` | Whether each answer's request detail (what the model was sent) is kept and shown.
_Enable browser notifications_ | `browserNotifications` | `true` | Whether the browser notifies the user when a chat finishes or needs them.

The property defaults are those every user starts with.


### How Users' Settings Follow the Defaults

* A user who has never saved their chat settings uses the defaults, and follows any later change to them.
* A user's settings are saved as their own when they press **OK** in the **Settings** dialog, choose a model in the chat's model box, or move the chat's dock.
  From then on, they no longer follow later changes to the defaults, apart from the model.
* The model is followed on its own.
  A user whose saved settings have the default model chosen keeps following the default model, so they get a new default model when it is changed.
  Only a user who chose a different model keeps using it.
* A chat keeps the model it started with.
  A new default model is used from each user's next new chat, so a chat already under way isn't switched to another model part-way through.
* The chat fetches the user's settings and the defaults again each time it is opened, so a change an administrator makes reaches users with Stroom open without them reloading it.
  The **Settings** dialog also fetches them again before it is shown.
* Moving the dock or choosing a model saves only that change, on top of the settings Stroom holds for the user now, so it doesn't put back a choice an administrator has cleared, or undo a change the user made in another browser.
* A user whose settings name no model, or a model that no longer exists, gets the default model.
  With no default model set, the chat says to choose one or to ask an administrator.


### Setting the Defaults

A user with the _Manage Properties_ permission sees three more buttons in the **Settings** dialog:

* **Set As Default** makes the settings in the dialog everyone's defaults, by writing them to the `stroom.askStroomAi` properties.
  Users who use the defaults get them when they next open the chat.
  If this changes the default model, you are then asked whether to make everyone use it now: confirming clears the choice of model from every user's saved settings, keeping their other settings, so that users who chose their own model use the new default too, from their next new chat; chats already under way keep their model.
  The change is recorded in the audit log.
* **Reset Everyone to Defaults…**, after you confirm, removes every user's saved chat settings, so that everyone uses the defaults (model, prompts, dock position and so on).
  Their own choices are lost.
  Users with Stroom open get the defaults when they next open the chat.
  The reset is recorded in the audit log.
* **Restore From Defaults**, which every user sees, fills the dialog with the defaults, e.g. to undo their own changes.
  Pressing **OK** then saves them as the user's own settings.
  The user follows the default model again from then on, but not the other defaults; to follow those again, an administrator can use **Reset Everyone to Defaults…**.

To set up the defaults for a new installation:

1. Open the chat's **Settings**.
1. Choose the _Model_, and check the other settings.
1. Press **Set As Default**.

The defaults can also be set as properties, in {{< stroom-menu "Administration" "Properties" >}} or in `config.yml` under `appConfig.askStroomAi`, e.g. to give a new installation its default model before anyone opens the chat.
`modelRef` is the model document's reference (its type, `OpenAIModel`, UUID and name).


## Table Analysis

The **Table Analysis** tab of the **Settings** dialog, shown only to users with _Manage Properties_, sets how [tables attached to a chat]({{< relref "analytics" >}}) are handled.
These settings apply to everyone, not just the user, and are saved when you press **OK**.

Setting | Property under `stroom.askStroomAi` | Default | Description
-- | -- | -- | --
_Max Rows Downloaded_ | `tableAnalysis.maxTotalRows` | `50000` | The most rows of an attached table downloaded into the chat's workspace.
_Max Rows Without Tools_ | `tableAnalysis.maxRowsWithoutTools` | `10000` | The most rows of each table given to a model without tools.
_Max Rows Per Batch_ | `tableAnalysis.maxRowsPerBatch` | `1000` | The most rows in one batch, when tables that don't fit a model's context window are analysed in batches. A batch is also limited to half the window.
_Max Batches at Once_ | `tableAnalysis.maxParallelBatches` | `4` | The most batches analysed at once.
_Attachment Download Timeout (ms)_ | `attachmentDownloadTimeoutMs` | `60000` | How long downloading an attached table may take.
_Batch System Prompt_ | `tableAnalysis.tableQuerySystemPrompt` | Stroom's own | The system prompt for analysing one batch.
_Batch User Prompt_ | `tableAnalysis.tableQueryUserPrompt` | Stroom's own | The prompt for one batch: `{{query}}` is the user's question, `{{table}}` the batch and `{{context}}` the conversation so far.
_Merge Prompt_ | `tableAnalysis.multiSummaryMergePrompt` | Stroom's own | The prompt for merging the batches' answers: `{{query}}` is the user's question and `{{summaries}}` the answers.


## Tool Policies

Which of Stroom's own tools each user is given is set by [MCP Tool Policies]({{< relref "../agent-tools/tool-policies" >}}), for the chat and outside MCP clients alike.
Stroom adds a policy giving everyone the tools that cannot change anything when it finds no policies (on a new install or the upgrade); tools that change things, such as those that onboard a data source, need a policy that grants read and write.


## Charting Libraries

For the agent to generate [charts]({{< relref "charts" >}}), install ECharts (version 6 or later) or D3 (version 3 or later), or both, each as a {{< stroom-icon "document/Script.svg" >}} Script document holding the library's build (e.g. `echarts.min.js`).
Stroom finds a library by its content, wherever its Script document is, and uses the newest version installed.
Upgrade a library by putting a newer release's build in its Script document.

The first time a chart is created, Stroom adds its own adapter Script document beside the library.
Stroom always serves that document's adapter from the running release, so every generated chart draws with the current adapter, whatever the document holds.


## MCP Tool Servers

A model can also be given the tools of other MCP servers.
Add each one on the model's **MCP Tool Servers** tab, with {{< stroom-icon "add.svg" "Add" >}}.
Each chat keeps its own connection to each server, closed when idle.

Setting | Description
-- | --
_Enabled_ | Whether the server's tools are offered.
_Trusted server_ | Mark a server trusted only if you control it. Only a trusted server's tool annotations (read-only, destructive, reaching outside Stroom) are believed, and only its instructions are given to the model (up to 20,000 characters).
_Name_ | A short name for the server.
_Endpoint URL_ | The server's Streamable HTTP endpoint, e.g. `https://fastmcp.example.com/mcp`.
_Authentication_ | How Stroom signs in to the server (see below).
_Credential_, _API key header name_, _API key value prefix_ | The shared credential, and how it is sent, for the authentication modes that use one.
_Token audience_ | For _OAuth2 passthrough_ with Stroom's internal identity provider: the audience of the tokens Stroom issues for the server, e.g. `stroom-mcp`.
_Set Http Client Config_ | Timeouts, TLS, a proxy and headers for the connection. The authentication's own headers take precedence.
_Tool category_ | The category of [MCP Tool Policies]({{< relref "../agent-tools/tool-policies" >}}) that grants the server's tools (Core by default), for each tool of a trusted server that doesn't name a category itself.
_Tool policies_ | Rules, each a regular expression matching a tool's whole name (ignoring case), e.g. `find_.*`, and what to do: _Allow_ (run without asking), _Ask every time_, or _Deny_ (never offered). The first rule to match applies. A tool no rule matches runs without asking if the server is trusted and the tool only reads, and asks otherwise.

_Test Connection_ connects with the settings as they are in the dialog, and lists the tools the server would offer.
It needs Edit permission on the model.

The authentication modes are:

* _OAuth2 passthrough_: Each user is signed in to the server, so the server acts as them.
  * With an external identity provider, the user's own token is passed on; its audience must include both Stroom and the server.
  * With Stroom's internal identity provider, Stroom issues each user a short-lived token (five minutes) for the server's _Token audience_, sent only to a trusted server, over HTTPS or on the same machine.
    Configure the server with Stroom's issuer and JWKS URL, both given by `<stroom>/api/oauth2/v1/.well-known/openid-configuration`, and the audience.
    For the server to call Stroom's API back with the token, add the audience to `stroom.security.authentication.openId.allowedAudiences`.
* _None_, _Bearer token_, _Custom API key header_ and _Basic auth_: one shared credential, so every user's calls run as one account.
  Use them for development, or for servers that make their own checks.

When a model would be offered more MCP tools than `stroom.ai.toolGroupThreshold` (24), they are offered as groups, which the model turns on as it needs them.


## Configuration

Ask Stroom AI is configured under `stroom.ai`.
Among the most used:

Property | Default | Description
-- | -- | --
`maxRunsPerUser` | `3` | Runs (and heavy MCP tool calls) working at once for a user.
`maxRunsPerNode` | `20` | Runs working at once on a node.
`maxRunDuration` | `PT2H` | The longest a run may take.
`maxToolIterations` | `100` | The most calls to the model in answering one question.
`unattendedAfter` | `PT10M` | When a run no one is watching becomes unattended (only tools that cannot change anything run).
`chatRetention` | `P90D` | How long an unused chat is kept.
`workspaceFileRetention` | `P7D` | How long workspace files are kept.
`maxChatTitleWords` | `12` | The most words in a chat's title, which the model writes.
`compaction.thresholdPercent` | `80` | How full the context window gets before a chat is compacted.
`compaction.turnsKeptInFull` | `2` | The latest turns never compacted.
`allowApproveEverything` | `false` | Lets users turn on _Auto-approve_ for a chat.
`shareActiveTab` | `true` | Lets users attach a document tab to a chat.
`maxTabSnapshotBytes` | `2097152` | The most bytes of an attached tab kept for one question.
`askReadOnlyToolsAfterUntrustedContent` | `false` | Makes a trusted MCP server's read-only tools ask once a run has read untrusted data.
`elicitationTimeout` | `PT10M` | How long a form from an MCP tool server's tool waits for the user.
`maxElicitationsPerNode` | `5` | Forms from MCP tool servers that may wait on a node at once.
`toolGroupThreshold` | `24` | When a model is given more MCP tools than this, they are offered as groups (0 never groups).
`suggestFollowUps` | `true` | Whether the model suggests follow-up questions after its answers.
`builds.workspaceFolder` | `MCP Workspace` | The folder below System in which the build tools make each build's folder.
`errorTriage.rules` | `[]` | Your own rules for triaging pipeline errors (blocking, review or benign), checked before Stroom's.
`pipelineStages` | | What marks a pipeline as each stage (translation, indexing, reference and so on), and where each stage's templates are looked for.

The workspace's limits are under `stroom.ai.workspace` (see [Workspaces]({{< relref "../how-it-works/workspaces#limits" >}})), and the MCP endpoint's under `stroom.ai.mcpEndpoint` and `stroom.ai.sampleUploads` (see [Deploying the MCP endpoint]({{< relref "../agent-tools/deployment" >}})).

The _AI Chat Retention_ job (hourly) removes old chats and workspace files, and the chats and memory of deleted users.


## Troubleshooting

* **"The tools of MCP tool server … are unavailable"**: The server couldn't be reached, or its authentication isn't set up (e.g. _OAuth2 passthrough_ with the internal identity provider needs a token audience, a trusted server and HTTPS).
  The chat still works with Stroom's own tools.
* **"The AI model … cannot be found, and no default model is set"**: Set a default model (see [Setting the Defaults](#setting-the-defaults)).
* **"Interrupted because the Stroom node running it stopped"**: The node running the chat went away; _Resume_ carries on from the last question.
* **_Test Model_ says the model isn't found**: The server doesn't serve the _Model ID_ as written; the alert's detail lists the models it does serve.
* **Nothing streams**: Some OpenAI-compatible servers don't stream; the answer then arrives whole.
* **The context meter shows nothing, or chats are never compacted**: The model's _Maximum context window tokens_ is `0`.
* **Users still use an old model after Set As Default**: They chose their own model, and the offer to make everyone use the new one was declined; ask them to choose it in the model box, or use **Reset Everyone to Defaults…** (which resets all their settings, not only the model).
* **Users still see other old settings after Set As Default**: They have saved their own settings; use **Reset Everyone to Defaults…**, or ask them to use **Restore From Defaults**.
