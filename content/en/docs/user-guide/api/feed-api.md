---
title: "Feed API"
linkTitle: "Feed API"
#weight:
date: 2024-06-11
tags: 
  - api
  - feed
description: >
  The API for fetching and updating feeds.
  
---

## Creating a Feed

In order to create a Feed you must first [create the skeleton document]({{< relref "explorer-api" >}}) using the Explorer API.


## Updating a Feed

To modify a feed you must first fetch the existing Feed document.
This is done as follows:

{{< command-line >}}
curl \
  -s \
  -H "Authorization:Bearer ${TOKEN}" \
  "http://localhost:8080/api/feed/v1/${feed_uuid}" \
{{</ command-line >}}

Where `${feed_uuid}` is the {{< glossary "UUID" >}} of the feed in question.

This will return the Feed document JSON.

```json
{
  "type": "Feed",
  "uuid": "0dafc9c2-dcd8-4bb6-88ce-5ee228babe78",
  "name": "MY_FEED",
  "version": "32dae12f-a696-4e0e-8acb-47cf0ad3c77f",
  "createTimeMs": 1718103980225,
  "updateTimeMs": 1718103980225,
  "createUser": "admin",
  "updateUser": "admin",
  "reference": false,
  "streamType": "Raw Events",
  "status": "RECEIVE"
}
```

You can use `jq` to modify this JSON to add/change any of the document settings.


### Example Script

The following is an example `bash` script for creating and modifying multiple Feeds.
It requires `curl` and `jq` to run.

```bash
#!/usr/bin/env bash

set -e -o pipefail

main() {

  # Your API key
  local TOKEN="sak_d5752a32b2_mv1JYUYUuvRUDpikW75G5w4kQUq7EEjShQ9DiRjN14yEFonKTW42KbeQogui52gTjq9RDRufNEz2MXt1PRCThudzHU5RVpLMbZKThCgyyEX2y2sBrk31rYMJRKNg2yMG"
  # UUID of the dest folder
  local FOLDER_UUID="fc617580-8cf0-4ac3-93dd-93604603aef0"

  local feed_name
  local create_feed_req
  local feed_uuid
  local feed_doc

  for i in {1..2}; do
    # Use date to make a unique name for the test
    feed_name="MY_FEED_$(date +%s)_${i}"

    # Set the feed name and its destination
    create_feed_req=$(cat <<-END
      {
        "docType": "Feed",
        "docName": "${feed_name}",
        "destinationFolder": {
          "type": "Folder",
          "uuid": "${FOLDER_UUID}",
          "rootNodeUuid": "0"
        },
        "permissionInheritance": "DESTINATION"
      }
END
    )

    # Create the skeleton feed and extract its new UUID from the response
    feed_uuid=$( \
      curl \
        -s \
        -X POST \
        -H "Authorization:Bearer ${TOKEN}" \
        -H 'Content-Type: application/json' \
        --data "${create_feed_req}" \
        http://localhost:8080/api/explorer/v2/create/ \
      | jq -r '.uuid'
    )

    echo "Created feed $i with name '${feed_name}' and UUID '${feed_uuid}'"

    # Fetch the created feed
    feed_doc=$( \
      curl \
        -s \
        -H "Authorization:Bearer ${TOKEN}" \
        "http://localhost:8080/api/feed/v1/${feed_uuid}" \
      )

    echo -e "Skeleton Feed doc for '${feed_name}'\n$(jq '.' <<< "${feed_doc}")"

    # Add/modify propeties on the feed doc
    feed_doc=$(jq '
      .classification="HUSH HUSH" 
      | .encoding="UTF8" 
      | .contextEncoding="ASCII" 
      | .streamType="Events"
      | .volumeGroup="Default Volume Group"' <<< "${feed_doc}")

    #echo -e "Updated feed doc for '${feed_name}'\n$(jq '.' <<< "${feed_doc}")"

    # Update the feed with the new properties
    curl \
      -s \
      -X PUT \
      -H "Authorization:Bearer ${TOKEN}" \
      -H 'Content-Type: application/json' \
      --data "${feed_doc}" \
      "http://localhost:8080/api/feed/v1/${feed_uuid}" \
    > /dev/null

    # Fetch the created feed
    feed_doc=$( \
      curl \
        -s \
        -H "Authorization:Bearer ${TOKEN}" \
        "http://localhost:8080/api/feed/v1/${feed_uuid}" \
      )

    echo -e "Updated Feed doc for '${feed_name}'\n$(jq '.' <<< "${feed_doc}")"
    echo
  done
}

main "$@"
```


