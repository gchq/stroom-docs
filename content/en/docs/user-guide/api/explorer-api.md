---
title: "Explorer API"
linkTitle: "Explorer API"
#weight:
date: 2024-06-11
tags: 
  - api
description: >
  The API for managing the folders and documents in the explorer tree.
---

## Creating a New Document

The explorer API is responsible for creation of all document types.
The explorer API is used to create the initial skeleton of a document then the API specific to the document type in question is used to update the document skeleton with additional settings/content.

This is an example request file `req.json`:

```json
{
  "docType": "Feed",
  "docName": "MY_FEED",
  "destinationFolder": {
    "type": "Folder",
    "uuid": "3dfab6a2-dbd5-46ee-b6e9-6df45f90cd85",
    "name": "My Folder",
    "rootNodeUuid": "0"
  },
  "permissionInheritance": "DESTINATION"
}
```

You need to set the following properties in the JSON:

* `docType` - The type of the document being created, see [Documents]({{< relref "/docs/reference-section/documents" >}}).
* `docName` - The name of the new document.
* `destinationFolder.uuid` - The {{< glossary "UUID" >}} of the destination folder (or `0` if the document is being created in the _System_ root.
* `rootNodeUuid` - This is always `0` for the _System_ root.

To create the skeleton document run the following:

{{< command-line >}}
curl \
  -s \
  -X POST \
  -H "Authorization:Bearer ${TOKEN}" \
  -H 'Content-Type: application/json' \
  --data @"req.json" \
  http://localhost:8080/api/explorer/v2/create/ \
| jq -r '.uuid'
{{</ command-line >}}

This will create the document and return its new UUID to _stdout_.

