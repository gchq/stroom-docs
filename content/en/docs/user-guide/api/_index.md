---
title: "Application Programming Interfaces (API)"
linkTitle: "API"
#weight:
date: 2022-02-16
tags:
  - api
description: >
  Stroom' public REST APIs for querying and interacting with all aspects of Stroom.

---

_Stroom_ has many public REST {{< glossary "API" "APIs">}} to allow other systems to interact with _Stroom_.
Everything that can be done via the user interface can also be done using the API.
All methods on the API will are authenticated and authorised, so the permissions will be exactly the same as when using the Stroom user interface directly.


## Swagger

The APIs are available as a _Swagger_ Open API specification in the following forms:

* JSON - {{< external-link "stroom.json" "https://gchq.github.io/stroom/v@@VERSION@@/stroom.json" >}} 
* YAML - {{< external-link "stroom.yaml" "https://gchq.github.io/stroom/v@@VERSION@@/stroom.yaml" >}}

A dynamic {{< external-link "Swagger user interface" "https://gchq.github.io/stroom/v@@VERSION@@" >}} is also available for viewing the API endpoints.

The API methods are also listed in the logs when Stroom boots up, e.g. 

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


## Authentication

In order to use the API endpoints you will need to authenticate.
Authentication is achieved using an {{< glossary "API Key" >}}.

You will either need to create an API key for your personal Stroom user account or for a shared processing user account.
Whichever user account you use it will need to have the necessary permissions for each API endpoint it is to be used with.


To create an API key for a user:
1. In the top menu, select:

{{< stroom-menu "Tools" "API Keys" >}}</br>

1. Click _Create_.
1. Enter a suitable expiration date.
   Short expiry periods are more secure in case the key is compromised.
1. Select the user account that you are creating the key for.
1. Click {{< stroom-btn "OK" >}}
1. Select the newly created API Key from the list of keys and double click it to open it.
1. Click {{< stroom-btn "Copy Key" >}} to copy the key to the clipboard.

To make an authenticated API call you need to provide a header of the form `Authorization:Bearer ${TOKEN}`, where `${TOKEN}` is your API Key as copied from Stroom.


