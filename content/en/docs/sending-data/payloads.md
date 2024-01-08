---
title: "Payload Formats"
linkTitle: "Payload Formats"
weight: 40
date: 2021-07-27
tags: 
description: >
  Description of the format of the payloads when sending event (and optionally context data) data to stroom.
---

Stroom can support multiple payload formats with different compression applied.
However all data once uncompressed must be text and not binary.

{{% note %}}
This section covers the payload format rather than the format of the text based event/context data itself.
For details on the format of the actual event/context data and details about character encoding, see [Event Data Formats]({{< relref "data-formats" >}}).
{{% /note %}}

Stroom can receive data in the following formats:


## Uncompressed

Text data is sent to Stroom and no compression flag is set in the header arguments.
This format is only suitable for sending event data, if you need to send additional context data you will need to use the [ZIP]({{< relref "#zip" >}}) format.
This is not recommended for large volumes of data due to the amount of data that has to be sent over the network.

The following is an example of sending uncompressed data to Stroom using {{< external-link "cURL" "https://curl.se" >}}:

{{< command-line "user" "localhost" >}}
curl -k --data-binary @file.dat "https://<Stroom_HOST>/stroom/datafeed" \
-H "Feed:EXAMPLE_FEED" \
-H "System:EXAMPLE_SYSTEM" \
-H "Environment:EXAMPLE_ENVIRONMENT"
{{</ command-line >}}


## gzip

Text data is {{< external-link "gzip" "https://en.wikipedia.org/wiki/Gzip" >}} compressed and the `Compression` flag is set to `GZIP` in the [Headers]({{< relref "header-arguments" >}}).
This format is only suitable for sending event data, if you need to send additional context data you will need to use the [ZIP]({{< relref "#zip" >}}) format.

The following is an example of sending gzipped data to Stroom using {{< external-link "cURL" "https://curl.se" >}}:

{{< command-line "user" "localhost" >}}
curl -k --data-binary @file.dat "https://<Stroom_HOST>/stroom/datafeed" \
-H "Compression:GZIP" \
-H "Feed:EXAMPLE_FEED" \
-H "System:EXAMPLE_SYSTEM" \
-H "Environment:EXAMPLE_ENVIRONMENT"
{{</ command-line >}}


## ZIP

Data can be sent to Stroom as a {{< external-link "ZIP" "https://en.wikipedia.org/wiki/ZIP_(file_format)" >}} archive.
This allows one or more text files to be sent in one go.
It allows allows additional {{< external-link "sidecar files" "https://en.wikipedia.org/wiki/Sidecar_file" >}} to be sent.

A ZIP archive is sent to Stroom with the `Compression` flag set to `ZIP` in the [Headers]({{< relref "header-arguments" >}}).
The contents of the ZIP archive is described below.

The following is an example of sending a ZIP archive to Stroom using {{< external-link "cURL" "https://curl.se" >}}:

{{< command-line "user" "localhost" >}}
curl -k --data-binary @data.zip "https://<Stroom_HOST>/stroom/datafeed" \
-H "Compression:ZIP" \
-H "Feed:EXAMPLE_FEED" \
-H "System:EXAMPLE_SYSTEM" \
-H "Environment:EXAMPLE_ENVIRONMENT"
{{</ command-line >}}


### Stroom ZIP Format

Stroom has a standard for how to send/store data in ZIP archive.
This format is used for:

* Receiving data from clients.
* Transferring data from a Stroom-Proxy to a downstream Stroom or Stroom-Proxy.
* Downloading a stream or streams from within Stroom.


#### Sidecar Files and File Extensions

The ZIP format allows not only multiple event data files to be sent, but each event data file can be optionally accompanied by one or more sidecar files.

Stroom has a standard set of reserved file extensions that are used for different types of sidecar file.

| Type       | Extension | Legacy Extensions      |
| --------   | --------- | ---------------------- |
| Event Data | `dat`     |                        |
| Context    | `ctx`     | `context`              |
| Manifest   | `mf`      | `manifest`             |
| Meta       | `meta`    | `hdr`, `header`, `met` |

Any file without a reserved file extension (or without any file extension) will be assumed to be an event data file.
For example the following ZIP archive contains four event data files and no sidecar files.

```treeview
|-- 2023-11-16.0001
|-- 2023-11-16.0002
|-- 2023-11-16.0003
`-- 2023-11-16.0004
```


#### Base File Name

Event data files are associated with their sidecar files by the base name.
The base name is the part of the file name that is common to all files.

The following is an example of two event data files with associated sidecar files.
In this example, the base names are `001` and `002`.

```treeview
|-- 001.dat
|-- 01.ctx
|-- 01.meta
|-- 02.dat
|-- 02.ctx
`-- 02.meta
```

While it is very much preferred for all files to be given the appropriate reserved file extension, omitting the file extension for event data files is supported.

```treeview
|-- 023-11-16.0001
|-- 023-11-16.0001.ctx
|-- 023-11-16.0002
`-- 023-11-16.0002.ctx
```

{{% warning %}}
If you had the following files:
```treeview
|-- 01.data1
|-- 01.data2
`-- 01.ctx
```
Then `001.data1` and `001.data2` would both be considered event data files for the base name `001` and Stroom does not allow multiple files of the same type for the same base name.
Therefore the ZIP would be rejected with a _duplicate file_ error.

{{% /warning %}}


#### File Order

The order of files in the zip archive does not matter.


#### Directories

Directories within the ZIP file are supported.

A file's base name includes its full path within the ZIP file, so an event data file and its associated sidecar files **must** all reside in the same directory.

The depth and names of the directories have no bearing on how Stroom processed the data.

When downloading or aggregating large numbers of streams into a ZIP file, Stroom will split the files up into directories with multiple levels to limit the number of files in each directory.


#### _Event Data_ Files

An event data file is the file containing the log/audit data and has the preferred extension of `.dat`.
If the data is being sent to Stroom/Stroom-Proxy then this is Raw Event data.
This data may be in a variety of [data formats]({{< relref "data-formats" >}}), however the ALL event data for a Feed should conform to the same format so that all the Feed's data can be processed in the same way.


#### _Context_ Files

Context files are an optional file that provides additional context reference data for the event data file that it is associated with.
They use the preferred extension `.ctx`.
If provided, a context file can be used to provide a [reference data]({{< relref "/docs/user-guide/pipelines/reference-data" >}}) source that is specific to the data file that has been sent.

Context data is supplementary information that is not contained within logged events.
For example, a system may be collating and sending event logs from a large estate of machines, where the event logs only contain some local identifier for each machine.
This may be the case where you have no control over the content/structure of the logs produced, e.g. when sending logs from a commercial product, rather than a bespoke system.
The context file can contain a record for each machine that contains the local identifier along with richer device information such as the IP address and {{< glossary "FQDN" >}}.
This context data can then be used in pipeline processing to perform lookups using the local identifier in the events to decorate them.

Context data can be in a variety of [data formats]({{< relref "data-formats" >}}) and does **not** need to be in the same format as the event data it is associated with.
For example, the event data may be in CSV format, while the context data is in JSON format.

```json
[
    {
        "localId": "1001",
        "ip": "10.212.33.1",
        "hostname": "server1.somedomain.com"
    }, {
        "localId": "1002",
        "ip": "10.212.33.2",
        "hostname": "server2.somedomain.com"
    },
    ...
]
```


#### _Meta_ Files

Meta files contain meta data relevant to all events in the associated event data file and have the preferred extension `.meta`.
Meta files are not typically supplied by client systems, instead, the HTTP headers are used to supply meta data that is applicable to all files in the ZIP.

Meta files will be present when downloading data from Stroom or when aggregated data is sent from Stroom-Proxy to a downstream Stroom/Stroom-Proxy.

A Meta file contains key value pairs delimited by `:`.
This is an example of a Meta file:

```http
content-type:application/x-www-form-urlencoded
environment:example_environment
feed:test_feed
guid:73254b1c-fadf-40c3-96a9-505d2e365e66
host:localhost:8080
receivedtime:2023-10-24t12:16:53.562z
remoteaddress:[0:0:0:0:0:0:0:1]
remotehost:[0:0:0:0:0:0:0:1]
streamsize:35
system:example_system
uploaduserid:unauthenticated_user
uploadusername:unauthenticated_user
user-agent:curl/8.4.0
```


#### _Manifest_ Files

Manifest files contain a manifest of the associated event data file, with information relating to its storage location in Stroom.
They have the preferred extension `.mf`.
They are generated by Stroom and are **not** intended to be provided by client systems.
A Manifest file will be present if a stream has been downloaded from Stroom.

Like Meta files they contain a simple list of key value pairs delimited by `:`.

The following is an example of a manifest file:

```http
Create Time:1698149813565
Effective Time:1698149813565
Feed:TEST_FEED
File Size:123
Files:/volumes/store/RAW_EVENTS/2023/10/24/004/TEST_FEED=004099.revt.bgz,/volumes/store/RAW_EVENTS/2023/10/24/004/TEST_FEED=004099.revt.meta.bgz,/volumes/store/RAW_EVENTS/2023/10/24/004/TEST_FEED=004099.revt.mf.dat
Id:4099
Raw Size:35
Type:Raw Events
```

{{% warning %}}
If you download a stream (or streams) in Stroom, the Manifest file for each stream will contain the Feed that it came from in Stroom.
If you upload this ZIP file into a different Feed in Stroom, Stroom will respect the `Feed` in the Manifest file so the data will be uploaded into its original Feed.
To prevent this, you can remove the Manifest file from the zip as follows:

{{< command-line >}}
# List the contents of the ZIP
unzip -t "StroomData (20)".zip
(out)Archive:  StroomData (20)_2.zip
(out)    testing: 001.mf                   OK
(out)    testing: 001.dat                  OK
(out)    testing: 001.meta                 OK
(out)No errors detected in compressed data of StroomData (20)_2.zip.
# Remove the manifest file
zip -d 001.mf "StroomData (20)".zip
{{</ command-line >}}

{{% /warning %}}

