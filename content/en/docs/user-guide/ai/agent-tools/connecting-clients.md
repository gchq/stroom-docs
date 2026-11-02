---
title: "Connecting an MCP client"
linkTitle: "Connecting an MCP client"
weight: 10
date: 2026-10-22
tags:
  - ai
  - mcp
description: >
  How to connect an MCP client, such as VS Code or Claude Code, to Stroom's MCP endpoint.
---
## The Endpoint

Stroom's MCP endpoint is at `/mcp` on Stroom's public URL, e.g. `https://stroom.example.com/mcp`.
It uses MCP's _Streamable HTTP_ transport.

Before you start, check that:

* The endpoint is turned on (`stroom.ai.mcpEndpoint.enabled`, on by default).
* You have the _Use MCP Tools_ application permission.
* An [MCP Tool Policy]({{< relref "tool-policies" >}}) grants you the tools you need.


## Signing In

Every request to the endpoint is signed in, as any request to Stroom's API is.


### With an API Key

An API key works with every identity provider, and is the only way when Stroom uses its own (internal) identity provider.

1. Create an API key for yourself: {{< stroom-menu "Security" "Manage API Keys" >}} (this needs the _Manage API Keys_ permission).
1. Give it to your MCP client as a bearer token: the client sends the header `Authorization: Bearer <api key>` with each request.

Treat the key as a password: the client acts as you with it.


### With an External Identity Provider (OAuth)

When Stroom uses an external OpenID Connect identity provider, an MCP client that supports MCP's OAuth sign-in can sign you in itself.
Stroom's endpoint answers a request without credentials with `401` and a `WWW-Authenticate` header that points to its OAuth protected resource metadata (`/.well-known/oauth-protected-resource`), which names the identity provider.
The client then signs you in there, in your browser.

The client must be registered with the identity provider (or the provider must allow it to register itself), and the provider must issue tokens Stroom accepts: with an audience in `stroom.security.authentication.openId.allowedAudiences`.
The metadata and the `WWW-Authenticate` header are built from `stroom.publicUri`, which must be Stroom's public address.


## Setting up a Client

Any MCP client that speaks Streamable HTTP can use the tools that only read.
To make changes in Stroom (onboarding a source, saving an XSLT, creating a processor filter), the client must also support MCP elicitation, the forms in which you allow or refuse each change.


### VS Code

Add the server to your `mcp.json` (the _MCP: Open User Configuration_ command), for example:

```json
{
  "servers": {
    "stroom": {
      "type": "http",
      "url": "https://stroom.example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${input:stroom-api-key}"
      }
    }
  },
  "inputs": [
    {
      "id": "stroom-api-key",
      "type": "promptString",
      "description": "Stroom API key",
      "password": true
    }
  ]
}
```


### Claude Code

```bash
claude mcp add --transport http stroom https://stroom.example.com/mcp \
  --header "Authorization: Bearer <api key>"
```


## What the Client is Given

When a client connects, Stroom tells it how its tools work (instructions sent with the connection), and offers:

* **Tools**: Those your tool policies grant you.
  If an administrator changes a policy while you are connected, the client is told (if its session is on the node the change was saved on; otherwise the change shows the next time it lists its tools), and lists the tools again.
* **Progress**: Long calls (surveys, index checks, stepping, waiting for processing) report what they are doing as they go, to a client that asks for progress, and stop if the client cancels them.
* **Resources**: The working guides (`stroom://guide/<name>`, with an index at `stroom://guides`) and the field convention profiles (`stroom://conventions/<name>`) the tools refer to.


### Uploading Samples

To onboard a new source, the agent may need samples of its data that are only on your machine.
It then gives you a command for each file (for bash or PowerShell) that posts the file to Stroom's `/mcp/upload` endpoint, as you, with your API key from the `STROOM_API_KEY` environment variable of your terminal.
Your key is never put in the chat or the command.
A command can only send that file, to the feed the agent named, once, and only for a while.


### The Session's Workspace

A large result (e.g. a query's results, or a stream's records) is saved to the session's workspace, under `/outputs/`, rather than given whole.
The workspace tools (`read_file`, `grep`, `jq`, `table` and others) read it.
The workspace belongs to the session: it is deleted when the session ends, or after a day without requests.


## Troubleshooting

* **`403`**: You don't have the _Use MCP Tools_ permission.
* **`404`** for `/mcp`: The endpoint is turned off.
  A `404` for a request in a session means that session has ended (or is on another node); the client starts a new one.
* **A tool you expect isn't listed**: No tool policy grants its category to you, or grants only read-only access and the tool changes things.
* **A call says it needs approval**: It changes something, so you are asked first (see [Agent Tools]({{< relref "_index.md#how-the-tools-are-governed" >}})).
* **A call that changes something is refused**: Your client can't show forms (MCP elicitation), so you can't be asked; its read-only calls still work.
  Use a client that shows forms, such as VS Code or Claude Code.
* **The agent says a tool it needs is missing, or stops at a step**: Clients such as VS Code hide some of a server's tools behind tools that turn a group on (`activate_*`).
  The agent is told to turn the group on; if it doesn't, ask it to, or turn all of Stroom's tools on in the client's tool picker.
* **Large results ask to run a terminal command**: Some clients save a large tool result to a file; the agent is told to read it with the client's own file tool, which needs no approval, not a terminal command.
