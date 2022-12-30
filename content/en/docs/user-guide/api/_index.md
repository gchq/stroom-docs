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

_Stroom_ has many public REST APIs to allow other systems to interact with _Stroom_.
Everything that can be done via the user interface can also be done using the API.


## Swagger

The APIs are available as a _Swagger_ Open API specification in the following forms:

* JSON - {{< external-link "stroom.json" "https://gchq.github.io/stroom/v@@VERSION@@/stroom.json" >}} 
* YAML - {{< external-link "stroom.yaml" "https://gchq.github.io/stroom/v@@VERSION@@/stroom.yaml" >}}

A dynamic {{< external-link "Swagger user interface" "https://gchq.github.io/stroom/v@@VERSION@@" >}} is also available for viewing the API endpoints.


## Authentication

In order to use the API endpoints you will need to authenticate.
Authentication is achieved using an {{< glossary "API Key" >}} or {{< glossary "Token" >}}.

You will either need to create an API key for your personal Stroom user account or for a shared processing user account.
Whichever user account you use it will need to have the necessary permissions for each API endpoint it is to be used with.

To create an API key for a user:
1. Select _Tools_ => _API Keys_ from the top menu.
1. Click _Create_.
1. Enter a suitable expiration date.
   Short expiry periods are more secure in case the key is compromised.
1. Select the user account that you are creating the key for.
1. Click _OK_.
1. Select the newly created API Key from the list of keys and double click it to open it.
1. Click _Copy key_ to copy the key to the clipboard.

To make an authenticated API call using `curl` do the following:

{{< command-line "user" "localhost" >}}
TOKEN='eyJhbG...TRUNCATED...t3-Lw' \
curl -s -k -H "Authorization:Bearer ${TOKEN}" https://localhost/api/node/v1/info/node1a
(out){"discoverTime":"2022-02-16T17:28:37.710Z","buildInfo":{"buildDate":"2022-01-19T15:27:25.024677714Z","buildVersion":"7.0-beta.175","upDate":"2022-02-16T09:28:11.733Z"},"nodeName":"node1a","endpointUrl":"http://192.168.1.64:8080","itemList":[{"nodeName":"node1a","active":true,"master":true}],"ping":2}
{{</ command-line >}}


## Handling JSON

{{< external-link "jq" "https://stedolan.github.io/jq/" >}} is a utility for processing JSON and is very useful when using the API methods.

For example to get just the build version from the node info endpoint:

{{< command-line "user" "localhost" >}}
TOKEN='eyJhbG...TRUNCATED...t3-Lw' \
curl -s -k -H "Authorization:Bearer ${TOKEN}" https://localhost/api/node/v1/info/node1a \
| jq -r '.buildInfo.buildVersion'
(out)7.0-beta.175
{{</ command-line >}}




