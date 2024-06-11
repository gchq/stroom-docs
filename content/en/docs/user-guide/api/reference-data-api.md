---
title: "Reference Data API"
linkTitle: "Reference Data API"
weight: 50
date: 2023-02-01
tags:
  - api
  - reference-data
description: >
  How to perform reference data loads and lookups using the API.
  
---

The reference data store has an API to allow other systems to access the reference data store.


## `/api/refData/v1/lookup`

The `/lookup` endpoint requires the caller to provide details of the reference feed and loader pipeline so if the effective stream is not in the store it can be loaded prior to performing the lookup.
It is useful for forcing a reference load into the store and for performing ad-hoc lookups.

{{% note %}}
As reference data stores are local to a node, it is best to send the request to a node that does processing as it is more likely to have already loaded the data.
If you send it to a UI node that does not do processing, it is likely to trigger a load as the data will not be there.
{{% /note %}}

Below is an example of a lookup request file `req.json`.

```json
{
  "mapName": "USER_ID_TO_LOCATION",
  "effectiveTime": "2020-12-02T08:37:02.772Z",
  "key": "jbloggs",
  "referenceLoaders": [
    {
      "loaderPipeline" : {
        "name" : "Reference Loader",
        "uuid" : "da1c7351-086f-493b-866a-b42dbe990700",
        "type" : "Pipeline"
      },
      "referenceFeed" : {
        "name": "USER_ID_TOLOCATION-REFERENCE",
        "uuid": "60f9f51d-e5d6-41f5-86b9-ae866b8c9fa3",
        "type" : "Feed"
      }
    }
  ]
}
```

This is an example of how to perform the lookup on the local host.

{{< command-line >}}
curl \
  --json @req.json \
  --request POST \
  --header "Authorization:Bearer ${TOKEN}" \
  http://localhost:8080/api/refData/v1/lookup
(out)staff2
{{</ command-line >}}
