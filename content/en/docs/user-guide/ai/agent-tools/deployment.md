---
title: "Deploying the MCP endpoint"
linkTitle: "Deploying the MCP endpoint"
weight: 30
date: 2026-10-22
tags:
  - ai
  - mcp
  - configuration
description: >
  Configuring Stroom's MCP endpoint, and running it behind a load balancer.
---
## Configuration

The endpoint is configured under `stroom.ai.mcpEndpoint`:

Property | Default | Description
-- | -- | --
`enabled` | `true` | Whether Stroom's MCP endpoint (`/mcp`) serves MCP clients. Each user also needs the _Use MCP Tools_ permission.
`formTimeout` | `PT10M` | How long a form one of Stroom's tools asks an MCP client's user to fill in (e.g. to approve a change) waits for an answer. The tool call, and its thread, wait for it.
`maxFormsPerNode` | `50` | The most forms that may wait for answers from MCP clients' users on a node at once, as each holds a thread. One user may have at most half of them waiting.
`keepAliveInterval` | `PT20S` | How often an MCP session's open stream is sent a ping, so that proxies and load balancers don't close it while it is idle. Keep it under their idle timeouts.
`sessionRetention` | `P1D` | How long a session that has had no requests is kept, with its workspace. A session that ends normally has its workspace deleted once its calls have finished. Idle sessions are ended by the _MCP Session Maintenance_ job, which runs every minute on each node.
`maxSessionsPerUser` | `20` | The most sessions a user may have open on a node. When a user is at the limit, a new session ends their least recently used session that has no call running; if every one has a call running, the new session is refused.

Sample uploads from the user's machine (`upload_sample` with `files`) are configured under `stroom.ai.sampleUploads`:

Property | Default | Description
-- | -- | --
`maxUploadMb` | `100` | The largest file that may be posted to `/mcp/upload`.
`commandsLast` | `PT15M` | How long the upload commands `upload_sample` gives may be used.
`maxPendingPerUser` | `20` | The most sets of upload commands a user may have with files still waiting to be posted, across all nodes.

Each file is posted once: a post claims its file while it stores it, so a second post of the same file (on any node) is refused.
If a node stops part way through a post, the file can be sent again 10 minutes after that post began.
Commands that have run out, and those of deleted users, are deleted by the _AI Chat Retention_ job.

Heavy tool calls (e.g. a StroomQL query, or reading many streams) take one of the user's run slots, as an Ask Stroom AI run does, so the chat's limits (`stroom.ai.maxRunsPerUser`, `stroom.ai.maxRunsPerNode`) cover MCP calls too.
A heavy MCP call when no slot is free is refused, saying so, rather than queued as a chat run is.
The per-user limits apply on each node.


## Behind a Load Balancer

An MCP session lives on the Stroom node that started it: its open stream, any form waiting for an answer, and the calls it makes.
With more than one node, each client must be kept on one node.

A request for a session that a node doesn't have is answered `404`, which tells the client to start a new session, so a client moved to another node recovers, but loses any form or approval it was waiting on, and its session's workspace files.
Sample upload commands (`/mcp/upload`) may reach any node: the files waiting to be posted are held in the database, not by the node that gave the commands, so an upload is taken wherever it lands and a restart doesn't lose it.

Keep each client on one node by its address (the client's first request, which starts the session, carries no session id, so the `Mcp-Session-Id` header can't be used to choose the node):


### Nginx

```text
upstream stroom_mcp {
    ip_hash;
    server stroom-node-1:8080;
    server stroom-node-2:8080;
}

location /mcp {
    proxy_pass http://stroom_mcp;
    proxy_http_version 1.1;
    # The session's stream (Server-Sent Events) must not be buffered, and stays open between requests.
    proxy_buffering off;
    proxy_cache off;
    proxy_read_timeout 3600s;
    proxy_set_header Connection "";
    # Sample uploads (/mcp/upload) post whole files.
    client_max_body_size 100m;
}
```


### Ingress-nginx (Kubernetes)

```yaml
metadata:
  annotations:
    nginx.ingress.kubernetes.io/upstream-hash-by: "$remote_addr"
    nginx.ingress.kubernetes.io/proxy-buffering: "off"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    # Sample uploads (/mcp/upload) post whole files.
    nginx.ingress.kubernetes.io/proxy-body-size: "100m"
```

Within the cluster, a Service in front of the Stroom pods can do the same with `sessionAffinity: ClientIP`.

Clients that reach Stroom through one shared address (e.g. a NAT gateway) all go to one node.


### The Protected Resource Metadata

With an external identity provider, also route `/.well-known/oauth-protected-resource` (and `/.well-known/oauth-protected-resource/mcp`) to Stroom, unauthenticated, so that MCP clients can find where to sign in.


## The API Documentation

The MCP endpoint is not part of Stroom's REST API, so it isn't in the Swagger documentation; it is described here.
