---
title: "Content Import and Export"
linkTitle: "Content Import and Export"
weight: 50
date: 2025-07-11
tags: 
  - import
  - export
  - content
description: >
  Importing and exporting Stroom content.
---

All Stroom content can be exported to a file and conversely imported from a file.
Multiple entities can be exported in the same file.

Stroom exports take the form of a zip file containing the exported form of each entity.
Each entity will have at least two files within the zip file.
These zip files are sometimes known as _Content Packs_ as they are essentially a pack of Stroom content.

Stroom has a number of off-the-shelf content packs available for download and import.
There are packs for such things as XML schemas and standard pipelines/translations.
These can be found at {{< external-link "github.com/gchq/stroom-content" "https://github.com/gchq/stroom-content" >}} and {{< external-link "github.com/gchq/stroom-visualisations-dev" "https://github.com/gchq/stroom-visualisations-dev" >}}.


## Exporting Content

Content can be exported using two methods:

* Via the main menu:
  {{< stroom-menu "Tools" "Export" >}}

* Selecting one or more items in the explorer tree then clicking _Export_ from the right-click context menu.
  {{< stroom-menu "Export" >}}

From the dialog that is displayed, the user can select which items to included in the import.
On clicking {{< stroom-btn "OK" >}} a confirmation dialog will be displayed confirming the number of items that will be exported, including a breakdown of counts by document type.

The export will be written to a file called `StroomConfig.zip` that will typically be located in the `Downloads` directory on the users computer.

{{% warning %}}
The import/export file format has changed across different versions of Stroom.
Stroom aims to support the import of older formats but older versions of Stroom may not be able to import a file exported by a newer version of Stroom.
{{% /warning %}}


## Importing Content

Content can be exported using two methods:

* Via the main menu:
  {{< stroom-menu "Tools" "Import" >}}

* Right clicking anywhere in the explorer tree and clicking:
  {{< stroom-menu "Import" >}}


### Importing Content via API

It is possible to import content programmatically via Stroom's API.
This involves a two-step process:

1. Upload the content pack zip file to stroom, where it will be written to a temporary file on the Stroom server.
1. Perform the import of the temporary file, referencing it using a _resource key_.

The process is as follows:

{{< command-line "user" "localhost" >}}
# This uploads the file to the stroom host and saves it in a temporary file
curl \
  -c /tmp/cookie.txt \
  -H "Authorization: Bearer ${TOKEN}" \
  -F "encoding=multipart/form-data" \
  -F fileUpload="@/some/path/myContent.zip" \
  -X POST \
  https://<stroom FQDN>/importfile.rpc
{{</ command-line >}}

This will write session information to `/tmp/cookie.txt` (which must not exist beforehand) and return the resource key details:

```text
#PM#success=true name=myContent.zip key=1c04efc6-1c3b-4ce2-9788-74c8b224c864#PM#
```

From this you will need to extract the `key` and `name` parts to use in the next request.

Create the JSON request `/some/path/importRequest.json`:

```json
{
  "confirmList": [],
  "importSettings": {
    "importMode": "CREATE_CONFIRMATION"
  },
  "resourceKey": {
    "key": "<the key>",
    "name": "<the name>"
  }
}
```

The above is the bare minimum needed for a default import.
For full details of the request format see {{< external-link "swagger" "https://gchq.github.io/stroom/v@@VERSION@@/#/Content/importContent" >}}

{{< command-line "user" "localhost" >}}
# This performs the import
curl \
  -b /tmp/cookie.txt \
  -X POST \
  -H "Authorization:Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  --data @'/some/path/importRequest.json' \
  "https://<stroom FQDN>/api/content/v1/import"
{{</ command-line >}}

The above steps can be done in one simple step using this bash script:

```bash
#!/usr/bin/env bash

# Script to import a single Stroom content pack ZIP file into Stroom.
# Requires that the environment variable TOKEN is set with either a
# valid API Key or an OAuth token.
# Usage:
# import_content.sh CONTENT_ZIP_FILE [URL_BASE]
# e.g. import_content.sh /some/path/StroomConfig.zip
# e.g. import_content.sh /some/path/StroomConfig.zip https://stroom.some.domain

set -e -o pipefail

main() {
  local content_zip_file="${1:?content_zip_file must be provided}"; shift

  local url_base
  if [[ $# -gt 0 ]]; then
    url_base="${1}"; shift
  else
    url_base="http://localhost:8080"
    echo "Using default URL base '${url_base}'"
  fi

  local cookie_file
  # dry-run so we don't create the file, else curl will error
  cookie_file="$( mktemp --dry-run "/tmp/request_cookie.XXXXXXXXXX" )"

  echo "Uploading file '${content_zip_file}' to a temporary file"
  
  local response1
  response1="$( \
    curl \
      --silent \
      --cookie-jar "${cookie_file}" \
      --header "Authorization: Bearer ${TOKEN:? Set TOKEN env var with API key or Oauth token}" \
      --form "encoding=multipart/form-data" \
      --form fileUpload="@${content_zip_file}" \
      --request POST \
      "${url_base}/importfile.rpc" \
  )"

  echo "File uploaded"

  local key
  key="$( \
    grep \
      --only-matching \
      --perl-regexp \
      '(?<=key=)[^ #]+' \
      <<< "${response1}"
  )"

  # name is only really used for logging purposes in stroom, but provide
  # it anyway
  local name
  name="$( \
    grep \
      --only-matching \
      --perl-regexp \
      '(?<=name=)[^ #]+' \
      <<< "${response1}"
  )"

  local import_request
  import_request="{ \"confirmList\": [], \"importSettings\": { \"importMode\": \"IGNORE_CONFIRMATION\" }, \"resourceKey\": { \"key\": \"${key}\", \"name\": \"${name}\" }  }"

  echo "Importing content"

  # Not interested in the response
  curl \
    --silent \
    --cookie "${cookie_file}" \
    --request POST \
    --header "Authorization:Bearer ${TOKEN:? Set TOKEN env var with API key or Oauth token}" \
    --header 'Content-Type: application/json' \
    --data "${import_request}" \
    "${url_base}/api/content/v1/import" \
    > /dev/null

  echo "Content imported successfully"
  echo "Done!"
}

cleanup() {
  if [[ -f "${cookie_file}" ]]; then
    rm "${cookie_file}"
  fi
}

trap cleanup EXIT
trap cleanup SIGINT

main "$@"
```
