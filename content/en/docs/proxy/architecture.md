---
title: "Proxy Architecture"
linkTitle: "Proxy Architecture"
#weight:
date: 2025-04-11
tags: 
  - proxy
description: >
  An overview of the architecture of Stroom-Proxy (v7.8 or later).
---

## Overview

Stroom-Proxy has a number of moving parts and it can be configured in a variety of ways.
This document aims to describe some typical configurations of Stroom-Proxy.


### Directories as Queues

Stroom-Proxy makes heavy use of multiple file system directories as work queues.
These queues act as the interface between the different processing steps in Stroom-Proxy.

Data in its various states is held in sub-directories that are moved atomically between the different queue directories.

These sub-directories are placed in a path structure that indicates the position in the queue, e.g.:

```text
./50_forwarding/downstream/02_retry/2/012/345/012345678
```

In the above example:

* `./50_forwarding/downstream/02_retry` represents the base directory of the queue.
* `/2/` represents the depth of the directory tree, i.e. the queue item has two sub-directories above it.
* `/012/` is a sub-directory containing items 1,000,000 to 999,999,999.
* `/345/` is a sub-directory containing items 12,345,000 to 12,345,999.
* `/012345678/` is the queue item containing the data to be processed.
  The number is the position in the queue and the number of digits is always left padded with zeros to be a multiple of three.

This structure ensures that there are never more than 999 items in each directory and the head/tail of the queue can be found quickly.


### Data Directories

The following is a list of the directories used by Stroom-Proxy in its data directory (as configured by `proxyConfig.path.data`).

<!-- Use `tree -F --charset=ascii` to generate this -->
```treeview
|-- 01_receiving_simple/
|-- 01_receiving_zip/
|-- 02_split_zip_input_queue/
|-- 03_split_zip_splits/
|-- 20_pre_aggregate_input_queue/
|-- 22_splitting/
|-- 23_split_output/
|-- 30_aggregate_input_queue/
|-- 31_aggregates/
|-- 40_forwarding_input_queue/
|-- 50_forwarding/
|   |-- downstream/
|   |   |-- 01_forward/
|   |   |-- 02_retry/
|   |   `-- 03_failure/
|   `-- Local_filesystem/
|       |-- 01_forward/
|       |-- 02_retry/
|       `-- 03_failure/
|-- 99_deleting/
|-- event/
`-- temp_forward_copies/
```


#### `/01_receiving_simple/`

This directory is the reception for area for data that is NOT a {{< glossary "ZIP" >}} file, i.e. uncompressed or `gzip` compressed data.

Data will be written to this directory before the client receives the HTTP response.

It will write a numbered directory (e.g. `2/012/345/012345678`) containing two files:

* `0000000001.meta` - The meta sidecar file containing the HTTP headers.
* `0000000001.dat` - The file containing the received payload data.

The filenames are always the same as it is only dealing with a single stream.


#### `/02_receiving_zip/`

This directory is the reception for area for data that has been received as a {{< glossary "ZIP" >}} file which may contain one or more streams of data and associated metadata.

Received ZIP files will be written to a sub-directory in this directory before the client receives the HTTP response.

All `.meta` files in the ZIP file will be updated to add the HTTP headers from the request.
In order to do this, Stroom Proxy will first write the ZIP as a `.zip.staging` file.
It will clone all the ZIP entries in this file into a `.zip` file, updating the `.meta` entries as it goes.

The ZIP entries will be scanned and all valid entries will be written to a `.entries` sidecar file for subsequent processes to use.
This file defines the entries in the ZIP that are valid for further processing.

Once complete the sub-directory containing TODO


#### `/02_split_zip_input_queue/`

If a received {{< glossary "ZIP" >}} file contains data for more that one {{< glossary "Feed" >}} it will be moved into this directory queue for splitting.

Also, any ZIP files that are not in the correct [Stroom ZIP Format]({{< relref "docs/sending-data/payloads#stroom-zip-format" >}}) will also be moved into this directory for re-packaging in the correct format.
This is to ensure that all ZIP files received downstream are in a consistent format.


Each ZIP file in this directory will be reun-zipped into a new sub-directory in `03_split_zip_splits`.
