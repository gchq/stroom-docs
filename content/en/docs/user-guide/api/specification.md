---
title: "API Specification"
linkTitle: "API Specification"
weight: 10
date: 2023-02-02
tags: 
  - api
description: >
  Details of the API specifcation and how to find what API endpoints are available.
---

## Swagger UI

The APIs are available as a _Swagger_ Open API specification in the following forms:

* JSON - {{< external-link "stroom.json" "https://gchq.github.io/stroom/v@@VERSION@@/stroom.json" >}} 
* YAML - {{< external-link "stroom.yaml" "https://gchq.github.io/stroom/v@@VERSION@@/stroom.yaml" >}}

A dynamic Swagger user interface is also available for viewing all the API endpoints with details of parameters and data types.
This can be found in two places.

* Published on GitHub for each minor version {{< external-link "Swagger user interface" "https://gchq.github.io/stroom/v@@VERSION@@" >}}.
* Published on a running stroom instance at the path `/stroom/noauth/swagger-ui`.


## API Endpoints in Application Logs

The API methods are also all listed in the application logs when Stroom first boots up, e.g. 

```text
INFO  2023-01-17T11:09:30.244Z main i.d.j.DropwizardResourceConfig The following paths were found for the configured resources:

    GET     /api/account/v1/ (stroom.security.identity.account.AccountResourceImpl)
    POST    /api/account/v1/ (stroom.security.identity.account.AccountResourceImpl)
    POST    /api/account/v1/search (stroom.security.identity.account.AccountResourceImpl)
    DELETE  /api/account/v1/{id} (stroom.security.identity.account.AccountResourceImpl)
    GET     /api/account/v1/{id} (stroom.security.identity.account.AccountResourceImpl)
    PUT     /api/account/v1/{id} (stroom.security.identity.account.AccountResourceImpl)
    GET     /api/activity/v1 (stroom.activity.impl.ActivityResourceImpl)
    POST    /api/activity/v1 (stroom.activity.impl.ActivityResourceImpl)
    POST    /api/activity/v1/acknowledge (stroom.activity.impl.ActivityResourceImpl)
    GET     /api/activity/v1/current (stroom.activity.impl.ActivityResourceImpl)
    ...
```

You will also see entries in the logs for the various servlets exposed by Stroom, e.g.

```text
INFO  ... main s.d.common.Servlets            Adding servlets to application path/port: 
INFO  ... main s.d.common.Servlets            	stroom.core.servlet.DashboardServlet          => /stroom/dashboard 
INFO  ... main s.d.common.Servlets            	stroom.core.servlet.DynamicCSSServlet         => /stroom/dynamic.css 
INFO  ... main s.d.common.Servlets            	stroom.data.store.impl.ImportFileServlet      => /stroom/importfile.rpc 
INFO  ... main s.d.common.Servlets            	stroom.receive.common.ReceiveDataServlet      => /stroom/noauth/datafeed 
INFO  ... main s.d.common.Servlets            	stroom.receive.common.ReceiveDataServlet      => /stroom/noauth/datafeed/* 
INFO  ... main s.d.common.Servlets            	stroom.receive.common.DebugServlet            => /stroom/noauth/debug 
INFO  ... main s.d.common.Servlets            	stroom.data.store.impl.fs.EchoServlet         => /stroom/noauth/echo 
INFO  ... main s.d.common.Servlets            	stroom.receive.common.RemoteFeedServiceRPC    => /stroom/noauth/remoting/remotefeedservice.rpc 
INFO  ... main s.d.common.Servlets            	stroom.core.servlet.StatusServlet             => /stroom/noauth/status 
INFO  ... main s.d.common.Servlets            	stroom.core.servlet.SwaggerUiServlet          => /stroom/noauth/swagger-ui 
INFO  ... main s.d.common.Servlets            	stroom.resource.impl.SessionResourceStoreImpl => /stroom/resourcestore/* 
INFO  ... main s.d.common.Servlets            	stroom.dashboard.impl.script.ScriptServlet    => /stroom/script 
INFO  ... main s.d.common.Servlets            	stroom.security.impl.SessionListServlet       => /stroom/sessionList 
INFO  ... main s.d.common.Servlets            	stroom.core.servlet.StroomServlet             => /stroom/ui 
```

