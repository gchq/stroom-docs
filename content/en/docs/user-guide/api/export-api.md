---
title: "Export Content API"
linkTitle: "Export Content API"
weight: 40
date: 2023-01-17
tags:
  - api
  - content
description: >
  An API method for exporting all Stroom content to a zip file.
---

Stroom has {{< glossary "API" >}} methods for exporting {{< glossary "content" >}} in Stroom to a single zip file.


## Export All - `/api/export/v1`

This method will export all content in Stroom to a single zip file.
This is useful as an alternative backup of the content or where you need to export the content for import into another Stroom instance.

In order to perform a full export, the user (identified by their API Key) performing the export will need to ensure the following:

* Have created an [API Key]({{< relref "./#authentication" >}})
* The system property `stroom.export.enabled` is set to `true`.
* The user has the application permission `Export Configuration` or `Administrator`.

Only those items that the user has `Read` permission on will be exported, so to export all items, the user performing the export will need `Read` permission on all items or have the `Administrator` application permission.


### Performing an Export

To export all readable content to a file called `export.zip` do something like the following:

{{< command-line >}}
TOKEN="API KEY GOES IN HERE"
curl \
  --silent \
  --request GET \
  --header "Authorization:Bearer ${TOKEN}" \
  --output export.zip \
  https://stroom-fqdn/api/export/v1/
{{</ command-line >}}

{{% note %}}
If you encounter problems then replace `--silent` with `--verbose` to get more information.
{{% /note %}}


## Export Zip Format

The export zip will contain a number of files for each {{< glossary "document" >}} exported.
The number and type of these files will depend on the type of document, however every document will have the following two file types:

* `.node` - This file represents the document's location in the explorer tree along with its name and UUID.
* `.meta` - This is the metadata for the document independent of the explorer tree.
  It contains the name, type and UUID of the document along with the unique identifier for the version of the document.

Documents may also have files like these (a non-exhaustive list):

* `.json` - JSON data holding the content of the document, as used for Dashboards.
* `.txt` - Plain text data holding the content of the document, as used for Dictionaries.
* `.xml` - XML data holding the content of the document, as used for Pipelines.
* `.xsd` - XML Schema content.
* `.xsl` - XSLT content.

The following is an example of the content of an export zip file:

```text
TEST_FEED_CERT.Feed.fcee4270-a479-4cc0-a79c-0e8f18a4bad8.meta
TEST_FEED_CERT.Feed.fcee4270-a479-4cc0-a79c-0e8f18a4bad8.node
TEST_FEED_PROXY.Feed.f06d4416-8b0e-4774-94a9-729adc5633aa.meta
TEST_FEED_PROXY.Feed.f06d4416-8b0e-4774-94a9-729adc5633aa.node
TEST_REFERENCE_DATA_EVENTS_XXX.XSLT.4f74999e-9d69-47c7-97f7-5e88cc7459f7.meta
TEST_REFERENCE_DATA_EVENTS_XXX.XSLT.4f74999e-9d69-47c7-97f7-5e88cc7459f7.xsl
TEST_REFERENCE_DATA_EVENTS_XXX.XSLT.4f74999e-9d69-47c7-97f7-5e88cc7459f7.node
Standard_Pipelines/Reference_Loader.Pipeline.da1c7351-086f-493b-866a-b42dbe990700.xml
Standard_Pipelines/Reference_Loader.Pipeline.da1c7351-086f-493b-866a-b42dbe990700.meta
Standard_Pipelines/Reference_Loader.Pipeline.da1c7351-086f-493b-866a-b42dbe990700.node
```


### Filenames

When documents are added to the zip, they are added with a directory structure that mirrors the explorer tree.

The filenames are of the form:

```text
<name>.<type>.<UUID>.<extension>
```

As Stroom allows characters in document and folder names that would not be supported in operating system paths (or cause confusion), some characters in the name/directory parts are replaced by `_` to avoid this. e.g. `Dashboard 01/02/2020` would become `Dashboard_01_02_2020`.

If you need to see the contents of the zip as if viewing it within Stroom you can run this bash script in the root of the extracted zip.

```bash
#!/usr/bin/env bash

shopt -s globstar
for node_file in **/*.node; do
  name=
  name="$(grep -o -P "(?<=name=).*" "${node_file}" )"
  path=
  path="$(grep -o -P "(?<=path=).*" "${node_file}" )"

  echo "./${path}/${name}   (./${node_file})"
done
```

This will output something like:
```text
./Standard Pipelines/Json/Events to JSON   (./Standard_Pipelines/Json/Events_to_JSON.XSLT.1c3d42c2-f512-423f-aa6a-050c5cad7c0f.node)
./Standard Pipelines/Json/JSON Extraction   (./Standard_Pipelines/Json/JSON_Extraction.Pipeline.13143179-b494-4146-ac4b-9a6010cada89.node)
./Standard Pipelines/Json/JSON Search Extraction   (./Standard_Pipelines/Json/JSON_Search_Extraction.XSLT.a8c1aa77-fb90-461a-a121-d4d87d2ff072.node)
./Standard Pipelines/Reference Loader   (./Standard_Pipelines/Reference_Loader.Pipeline.da1c7351-086f-493b-866a-b42dbe990700.node)
```




