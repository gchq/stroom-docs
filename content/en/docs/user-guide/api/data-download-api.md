---
title: "Data Download API"
linkTitle: "Data Download API"
#weight:
date: 2026-02-24
tags:
description: >
  The API for downloading stream data in ZIP form.
---

## Download ZIP

This endpoint provides the means to download one or more streams (and their associated meta data and child streams) that match the supplied criteria as a single ZIP file.

The Swagger specification for the endpoint can be found {{< external-link "here" "https://gchq.github.io/stroom/v@@VERSION@@/#/Data%20Download/downloadZip" >}}.

The endpoint requires a JSON payload in the `POST` request to provide the filter criteria.
The following is an example of a criteria object to fetch the `Raw Events` streams for a given Feed and time range.

```json
{
  "expression" : {
    "type" : "operator",
    "children" : [ {
      "type" : "term",
      "field" : "Feed",
      "condition" : "IS_DOC_REF",
      "docRef" : {
        "type" : "Feed",
        "uuid" : "cb305f67-a460-40f2-a9bb-d855010e2922",
        "name" : "ZIP_TEST-DATA_SPLITTER-EVENTS"
      }
    }, {
      "type" : "term",
      "field" : "Status",
      "condition" : "EQUALS",
      "value" : "Unlocked"
    }, {
      "type" : "term",
      "field" : "Create Time",
      "condition" : "BETWEEN",
      "value" : "2025-08-13T00:00:00.000Z,2026-05-13T00:00:00.000Z"
    }, {
      "type" : "term",
      "field" : "Type",
      "condition" : "EQUALS",
      "value" : "Raw Events"
    } ]
  }
}
```

If the above JSON has been written to the file `criteria.json`, the following `curl` command will download all streams that match the criteria to `data.zip`.

{{< command-line >}}
TOKEN="...API KEY GOES IN HERE..."
curl \
  --silent \
  --request POST \
  --data-binary @criteria.json \
  --header Content-Type: application/json' \
  --header "Authorization:Bearer ${TOKEN}" \
  --output data.zip \
  https://stroom-fqdn/api/dataDownload/v1/downloadZip
{{</ command-line >}}

