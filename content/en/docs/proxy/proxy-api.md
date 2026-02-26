---
title: "Proxy API"
linkTitle: "Proxy API"
weight: 40
date: 2026-02-26
tags: 
description: >
  Details of the various APIs presented by Stroom-Proxy.
---

## Application APIs

These are the public APIs of the Stroom-Proxy application.
Administrators may still want to restrict access to specific endpoints, e.g. making the `/datafeed` API public, but limiting the REST API to within the Stroom estate as the REST APIs are typically called by other Stroom-Proxy instances.


### `/datafeed`

Stroom-Proxy presents the same `/datafeed` API as Stroom.
This also has a legacy alias of `/stroom/datafeed`.

For more details of how to use this API, see [Sending Data to Stroom]({{< relref "docs/sending-data" >}}).


### `/ui`

This returns HTML and is intended to be used in a browser.
It will display something like:

```text
Stroom Proxy v7.10.20 built on 2026-02-25T15:32:45.708Z
Send data to http://localhost:8090/datafeed
```


### `/status`

This provides a basic status response for Stroom-Proxy.
It returns a JSON object like this:

```json
{
  "upTime": 1772119560408,
  "buildVersion": "v7.10.20",
  "buildTime": 1772033565708
}
```


### `/debug`

This endpoint can be used for debugging datafeed requests.
A datafeed request can be POSTed to this endpoint instead, so that the client can see what headers and payload are reaching the server.

This example POSTs a simple bit of data with one extra header.

{{< command-line "stroomuser" "localhost" >}}
echo "Today is $(date)" \
| curl -X POST --data-binary @- -H "Feed:MY_FEED" http://localhost:8090/debug
(out)
(out)HTTP Header
(out)===========
(out)[Accept]=[*/*]
(out)[User-Agent]=[curl/8.18.0]
(out)[Host]=[localhost:8090]
(out)[Content-Length]=[38]
(out)[Feed]=[MY_FEED]
(out)[Content-Type]=[application/x-www-form-urlencoded]
(out)
(out)HTTP Header
(out)===========
(out)contentLength=38
(out)HTTP Payload
(out)============
(out)Today is Thu 26 Feb 16:23:50 GMT 2026
{{</ command-line >}}


### `/queues`

This endpoint returns HTML and is intended as a means for an admin to monitor the state of the various internal queues within Stroom-Proxy.
It is intended to be called from a browser.


### REST API

Stroom-Proxy presents a number of {{< glossary "REST" >}} endpoints:

<!-- TODO Create a swagger UI for proxy rest API - https://github.com/gchq/stroom/issues/5417 -->

* `POST` - `/api/apikey/v2/verifyApiKey` - Allows an upstream Stroom-Proxy to verify an API key.
* `POST` - `/api/event` - The [Event Store API]({{< relref "proxy-functions#event-store-api" >}}) for POSTing individual events.
* `POST` - `/api/feedStatus/v1/getFeedStatus` - Allows an upstream Stroom-Proxy to check the receipt status of a Feed.
* `POST` - `/api/feedStatus/v2/getFeedStatus` - Allows an upstream Stroom-Proxy to check the receipt status of a Feed.
* `GET`  - `/api/ruleset/v2/` - Not supported by Stroom-Proxy.
* `PUT`  - `/api/ruleset/v2/` - Not supported by Stroom-Proxy.
* `GET`  - `/api/ruleset/v2/fetchHashedRules` - Allows an upstream Stroom-Proxy to fetch the obfuscated receipt policy rules.


## Admin APIs

These APIs are presented on the administration port/path which by default is:

`localhost:8091/proxyAdmin/...`.

More details about the admin APIs (with the exception of the Prometheus endpoint) can be found here {{< external-link "Metrics Servlets" "https://www.dropwizard.io/projects/metrics/en/stable/manual/servlets/" >}}.

{{% warning %}}
It is important that access to the administration port/path is tightly controlled as it potentially allows access to destructive actions or exposes information about the Stroom-Proxy that should not be public.

Typically the APIs on the admin path/port should only be accessible to an administrator of the Stroom-Proxy instance.
{{% /warning %}}


### Metrics

Proxy exposes two endpoints for capturing metrics on its inner workings:

* Dropwizard Metrics - `http://localhost:8091/proxyAdmin/metrics`.
  This exposes the metrics as a JSON object.
  For more details see {{< external-link "Dropwizard Metrics" "https://metrics.dropwizard.io" >}}.

* Prometheus Metrics - `http://localhost:8091/proxyAdmin/prometheusMetrics`.
  Exposes the same data as Dropwizard Metrics, but in a format suitable for scraping by {{< external-link "Prometheus" "https://prometheus.io" >}}.


### Health Check

`http://localhost:8091/proxyAdmin/healthcheck`  
`http://localhost:8091/proxyAdmin/healthcheck?pretty=true`

Performing a GET request on this endpoint will initiate a health check on all parts of Stroom-Proxy that have registered a health check.
Each registered health check will return health or unhealthy along with any details relating to its state.
If all health checks return healthy then the endpoint will return a `200` status.

It allows the Stroom-Proxy instance to self check its inner workings.

Current registered health checks are:

* _deadlocks_ - Checks for any deadlocked threads.
* _stroom.dropwizard.common.LogLevelInspector_ - Reports the current logger levels that have been set.
  This is not strictly a healthcheck as it will always return _healthy_, more for information purposes.
* _stroom.proxy.app.ProxyConfigHealthCheck_ - Displays the current configuration values.
  This is not strictly a healthcheck as it will always return _healthy_, more for information purposes.
* _stroom.proxy.app.ProxyConfigMonitor_ - Returns _healthy_ if the monitoring of the config file is working correctly.
* _stroom.proxy.app.ReceiveDataRuleSetClient_ - Returns _healthy_ if the receipt policy rules could be fetched from the downstream host.
  Will return _healthy_ if receipt policy checking is not enabled/configured.
* _stroom.proxy.app.handler.RemoteFeedStatusClient_ - Returns _healthy_ if a feed status check could be fetched from the downstream host.
  Will return _healthy_ if receipt policy checking is not enabled/configured.
* _stroom.proxy.app.security.ProxyApiKeyCheckClient_ - Returns _healthy_ if an API Key check could be performed.
  Will return _healthy_ if receipt policy checking is not enabled/configured.
* _stroom.receive.common.DataFeedKeyDirWatcher_ - Returns _healthy_ if the monitoring of the Datafeed Key directory is working correctly.
* _stroom.security.common.impl.ExternalIdpConfigurationProvider_ - Returns _healthy_ if the configuration of the external IDP could be fetched.
  Will return _healthy_ if no external IDP is configured.


### Filtered Health Check

`http://localhost:8091/proxyAdmin/filteredhealthcheck`

This performs the same as the Health Check, but allows for filtering of the checks, which can be useful if there are certain checks that need to be ignored.

It takes the following optional query parameters:

* `allow` - A comma delimited list of health check names to include.
* `deny` - A comma delimited list of health check names to exclude.
* `minimal` - Set to `true` to exclude all the detail in the health check response.
* `pretty` - Set to `true` to format the JSON.


### Tasks

Stroom-Proxy has a number of tasks that can be executed via its tasks API.

The list of available task names can be found by performing a `GET` request on:

`http://localhost:8091/proxyAdmin/tasks`

The following tasks are currently available:

* `clear-all-cache` - Clears all caches in Stroom-Proxy.
* `clear-cache-Authenticated-Data-Feed-Key-Cache` - Clears the Authenticated Datafeed Key cache.
* `clear-cache-Event-Store-Open-Appenders` - Clears the Event Store Open Appenders cache.
* `clear-cache-Remote-Feed-Status-Response-Cache` - Clears the Remote Feed Status Response cache.
* `gc` - Forces a Java garbage collection to destroy unused objects in memory.
* `log-level` - Sets the log level for a named class or package.

Tasks are executed using a `POST` and may require form data if the task requires it.

{{< command-line "stroomuser" "localhost" >}}
curl -X POST http://localhost:8091/proxyAdmin/tasks/clear-all-caches
{{</ command-line >}}

The `log-level` task requires parameters to tell it the log level to set and on which class/package to set it.

{{< command-line "stroomuser" "localhost" >}}
curl -X POST http://localhost:8091/proxyAdmin/tasks/log-level -d "logger=stroom.core.servlet.StatusServlet&level=DEBUG"
{{</ command-line >}}

The task may or may not return content.


### Ping

`http://localhost:8091/proxyAdmin/metrics`

Simple endpoint that will respond with the text `pong` and a `200` status if Stroom-Proxy is running.
This can be used by load balances to determine if Stroom-Proxy is up or not.


### Threads

`http://localhost:8091/proxyAdmin/threads`

Lists the currently running threads with a stack trace for each.
Can be useful for debugging.




