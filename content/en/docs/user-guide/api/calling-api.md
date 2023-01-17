---
title: "Calling the API"
linkTitle: "Calling the API"
weight: 20
date: 2023-01-17
tags: 
description: >
  How to call the Stroom API using curl.
---


## Calling the API

### HTTP Requests Without a Body

Typically HTTP `GET` requests will have no body/payload
Often `PUT` and `DELETE` requests will also have no body/payload.

The following is an example of how to call an HTTP GET method (i.e. a method that does not require a request body) on the API using `curl`.

{{< command-line "user" "somehost" >}}
TOKEN='API KEY GOES IN HERE' \
curl \
  --silent \
  --insecure \
  --header "Authorization:Bearer ${TOKEN}" \
  https://stroom-fqdn/api/node/v1/info/node1a
(out){"discoverTime":"2022-02-16T17:28:37.710Z","buildInfo":{"buildDate":"2022-01-19T15:27:25.024677714Z","buildVersion":"7.0-beta.175","upDate":"2022-02-16T09:28:11.733Z"},"nodeName":"node1a","endpointUrl":"http://192.168.1.64:8080","itemList":[{"nodeName":"node1a","active":true,"master":true}],"ping":2}
{{</ command-line >}}

{{% warning %}}
The `--insecure` argument is used in this example which means certificate verification will not take place.
It is recommended not to use this argument and instead supply curl with client and certificate authority certificates to make a secure connection.

{{< command-line "user" "localhost" >}}
TOKEN='API KEY GOES IN HERE' \
curl \
  --silent \
  --cert /path/to/client-cert \
  --key /path/to/client-key \
  --cacert /path/to/ca-cert \
  --header "Authorization:Bearer ${TOKEN}" \
  https://stroom-fqdn/api/some/path
{{</ command-line >}}

{{% /warning %}}

You can either call the API via Nginx (or similar reverse proxy) at `https://stroom-fddn/api/some/path` or if you are making the call from one of the stroom hosts you can go direct using `http://localhost:8080/api/some/path`. The former is preferred as it is more secure.


### Requests With a Body

A lot of the API methods in Stroom require complex bodies/payloads for the request.
The following example is an HTTP `POST` to perform a reference data lookup on the local host.

Create a file `req.json` containing:

```json
{
  "mapName": "USER_ID_TO_STAFF_NO_MAP",
  "effectiveTime": "2024-12-02T08:37:02.772Z",
  "key": "user2",
  "referenceLoaders": [
    {
      "loaderPipeline" : {
        "name" : "Reference Loader",
        "uuid" : "da1c7351-086f-493b-866a-b42dbe990700",
        "type" : "Pipeline"
      },
      "referenceFeed" : {
        "name": "STAFF-NO-REFERENCE",
        "uuid": "350003fe-2b6c-4c57-95ed-2e6018c5b3d5",
        "type" : "Feed"
      }
    }
  ]
}
```

Now send the request with `curl`.

{{< command-line >}}
TOKEN='API KEY GOES IN HERE' \
curl \
  --json @req.json \
  --request POST \
  --header "Authorization:Bearer ${TOKEN}" \
  http://localhost:8080/api/refData/v1/lookup
(out)staff2
{{</ command-line >}}

This API method returns plain text or XML depending on the reference data value.

{{% note %}}
This assumes you are using `curl` version `7.82.0` or later that supports the `--json` argument.
If not you will need to replace `--json` with `--data` and add these arguments:

```text
--header "Content-Type: application/json"
--header "Accept: application/json"
```
{{% /note %}}


## Handling JSON

{{< external-link "jq" "https://stedolan.github.io/jq/" >}} is a utility for processing JSON and is very useful when using the API methods.

For example to get just the build version from the node info endpoint:

{{< command-line "user" "localhost" >}}
TOKEN='API KEY GOES IN HERE' \
curl \
    --silent \
    --insecure \
    --header "Authorization:Bearer ${TOKEN}" \
    https://localhost/api/node/v1/info/node1a \
  | jq -r '.buildInfo.buildVersion'
(out)7.0-beta.175
{{</ command-line >}}
