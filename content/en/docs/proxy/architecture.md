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

Data representing one queue item is placed into a directory.
That directory is atomically moved into a queue directory with a new name to represent its position in the queue.
The directory is consumed from the directory queue by atomically moving it to a different path, typically this will be a numbered directory that acts as a staging area where it can be worked on before moving it to a different directory queue.

These sub-directories are placed in a path structure that indicates the position in the queue, e.g.:

```text
./50_forwarding/downstream/02_retry/2/012/345/012345678
```

In the above example:

* `./50_forwarding/downstream/02_retry` represents the base directory of the queue.
* `/2/` represents the depth of the directory tree, i.e. the queue item has two sub-directories above it.
* `/012/` is a sub-directory containing items 12,000,000 to 12,999,999.
* `/345/` is a sub-directory containing items 12,345,000 to 12,345,999.
* `/012345678/` is the queue item containing the data to be processed.
  The number is the position in the queue and the number of digits is always left padded with zeros to be a multiple of three.

This structure ensures that there are never more than 999 items in each directory and the head/tail of the queue can be found quickly.


### Numbered Directories

Typically between each queue is a numbered directory that acts as a staging area to work on the data.
Numbered directories are sequentially numbered directories that all exist in a single parent directory.
They are expected to be transient in nature, i.e. only existing until they can be move to another queue.

For example, `01_receiving_simple` contains numbered directories and each one is used to stage non-ZIP data that has been received into proxy:

```text
./01_receiving_simple/0000001407/
./01_receiving_simple/0000001408/
./01_receiving_simple/0000001409/
```

Each directory represents data for a single request into Stroom Proxy.
Once the data has been successfully written to one of these directories, the directory will be atomically moved to one of the directory queues, e.g.

```text
./01_receiving_simple/0000001407/ => 20_pre_aggregate_input_queue/0/382/
```

The directory then becomes the responsibility of the queue directory it was moved into.


### Directory Structure

The following is a list of the directories used by Stroom-Proxy in its data directory (as configured by `proxyConfig.path.data`).

<!-- Use `tree -F --charset=ascii` to generate this -->
```treeview
|-- 01_receiving_simple/
|-- 01_receiving_zip/
|-- 02_split_zip_input_queue/
|-- 03_split_zip_splits/
|-- 20_pre_aggregate_input_queue/
|-- 21_pre_aggregates/
|-- 22_splitting/
|-- 23_split_output/
|-- 30_aggregate_input_queue/
|-- 31_aggregates/
|-- 40_forwarding_input_queue/
|-- 50_forwarding/
|   |-- <destination name 1>/
|   |   |-- 01_forward/
|   |   |-- 02_retry/
|   |   `-- 03_failure/
|   `-- <destination name 2>/
|       |-- 01_forward/
|       |-- 02_retry/
|       `-- 03_failure/
|-- 99_deleting/
|-- event/
`-- temp_forward_copies/
```

The following diagram illustrates how data flows between the various queues and numbered directories.

{{< image "proxy/architecture.puml.svg" "800x" />}}


#### `/01_receiving_simple/`

This directory is the reception for area for data that is NOT a {{< glossary "ZIP" >}} file, i.e. uncompressed or `gzip` compressed data.
It contains numbered directories.

Data will be written to this directory before the client receives the HTTP response.

Each numbered directory will contain two files:

* `/01_receiving_simple/0000002034/0000000001.meta` - The meta sidecar file containing the HTTP headers.
* `/01_receiving_simple/0000002034/0000000001.dat` - The file containing the received payload data.

The filenames are always the same as it is only dealing with a single stream.


#### `/02_receiving_zip/`

This directory is the reception for area for data that has been received as a {{< glossary "ZIP" >}} file which may contain one or more streams of data and associated metadata.
It contains numbered directories.

Received ZIP files will be written to a numbered sub-directory in this directory before the client receives the HTTP response.

All `.meta` files in the ZIP file will be updated to add the HTTP headers from the request.
In order to do this, Stroom Proxy will first write the ZIP as a `.zip.staging` file.
It will clone all the ZIP entries in this file into a `.zip` file, updating the `.meta` entries as it goes.
The `.zip.staging` file will be deleted once complete.

The ZIP entries will be scanned and all valid entries will be written to a `.entries` sidecar file for subsequent processes to use.
This `.entries` file defines the entries in the ZIP that are valid for further processing and allows subsequent processing to use this file as a reference rather than having to re-scan the ZIP.

The scanning process will also establish how many groups are in the ZIP.
A group is defined as a combination of the _Feed_ and the _Stream Type_.

If the ZIP contains more than one group or the ZIP does not adhere to the correct [Stroom ZIP Format]({{< relref "docs/sending-data/payloads#stroom-zip-format" >}}, the directory will be moved to `/02_split_zip_input_queue/` for splitting.

If the ZIP has a valid format and only contains one group, it will either be moved to the `20_pre_aggregate_input_queue` queue, if aggregation is enabled, or `40_forwarding_input_queue` queue if not.


#### `/02_split_zip_input_queue/`

Each directory placed into this directory queue will contain a ZIP file and a `.entries` file.
The ZIP may be in an invalid format, in which case a new ZIP will be created with the correct entry naming and structure.
This is to ensure that all ZIP files received downstream are in a consistent format.
Alternatively it will contain more than one group, so will need to be split into one ZIP file per group.

A numbered directory will be created in `/03_split_zip_splits/` to hold each split.
For each group of entries in a split, it will create a sub-directory named after the group in the numbered directory, e.g. for two splits:

* `/03_split_zip_splits/0000000392/FEED_X__raw_events/proxy.zip`
* `/03_split_zip_splits/0000000392/FEED_X__raw_events/proxy.entries`
* `/03_split_zip_splits/0000000392/FEED_X__raw_events/proxy.meta`
* `/03_split_zip_splits/0000000392/FEED_Y__raw_events/proxy.zip`
* `/03_split_zip_splits/0000000392/FEED_Y__raw_events/proxy.entries`
* `/03_split_zip_splits/0000000392/FEED_Y__raw_events/proxy.meta`

Once the splitting is complete, each split directory will be moved to the `20_pre_aggregate_input_queue` queue, if aggregation is enabled, or `40_forwarding_input_queue` queue if not.


#### `/20_pre_aggregate_input_queue/`

Each directory on this queue will contain a ZIP file that contains one or more entries for the same group (combination of Feed and Stream Type).

If `proxyConfig.aggregator.splitSources` is set to `true`, Stroom Proxy will inspect the ZIP to see if it needs to be split up into multiple parts, to meet the aggregation targets (defined by `proxyConfig.aggregator.maxItemsPerAggregate` and  `proxyConfig.aggregator.maxUncompressedByteSize`), else the zip will be treated as a single split-part.

If there is just one split-part, the directory will be moved into the current aggregate directory for its group, e.g.

* `/21_pre_aggregates/FEED_X__raw_events/009/proxy.zip`

If there are multiple split-parts the ZIP file will require splitting into multiple ZIP files with one per split-part, i.e. all entries from the input ZIP spread over multiple split-part ZIPs.
Each split-part will be written like this:

* `/22_splitting/0000000343/009_part_1/proxy.zip`
* `/22_splitting/0000000343/009_part_2/proxy.zip`
* `/22_splitting/0000000343/009_part_3/proxy.zip`

Once the splitting has been completed, the common parent directory is moved to `/23_split_output/`:

* `/23_split_output/0000000343/009_part_1/proxy.zip`
* `/23_split_output/0000000343/009_part_1/proxy.zip`
* `/23_split_output/0000000343/009_part_1/proxy.zip`

Each split-part is then moved to `/21_pre_aggregates/`.

* `/21_pre_aggregates/FEED_X__raw_events/011/proxy.zip`

When the aggregate for a Feed|Type group is complete (based on item count and uncompressed size), the aggregate will be closed.
Closing of the aggregate involves moving the parent directory of all the aggregate items to `/30_aggregate_input_queue/`.


#### `/30_aggregate_input_queue/`

Each directory on this queue will contain multiple directory groups (each containing a ZIP file and its associated files) that are to be part of a single aggregate.

If there is only one item in the queue directory, the directory will be moved to `/40_forwarding_input_queue/` for forwarding.

If there are more than one items in the queue directory then a new aggregate ZIP will be created in `/31_aggregates/`.
The entries from each item ZIP will be written into the new aggregate ZIP.

It will also create a set of meta entries for the aggregate.
This will contain only key/value entries that are present in **every** item in the aggregate.

Once the aggregate has been written it is moved to `/40_forwarding_input_queue/`.


#### `/40_forwarding_input_queue/`

Each directory on this queue will contain a single ZIP file that may contain one or more streams (plus associated files).
In addition to the ZIP file will be a combined `.meta` file for the aggregate.

Depending on how forwarding has been configured (using `proxyConfig.forwardFileDestinations` and `proxyConfig.forwardHttpDestinations`), there will be a pair of directory queues for each of the forwarding destinations, with the destination name in the path, e.g.:

* `/50_forwarding/file-dest-1/01_forward/`
* `/50_forwarding/file-dest-1/02_retry/`
* `/50_forwarding/file-dest-2/01_forward/`
* `/50_forwarding/file-dest-2/02_retry/`
* `/50_forwarding/http-dest-1/01_forward/`
* `/50_forwarding/http-dest-1/02_retry/`
* `/50_forwarding/http-dest-2/01_forward/`
* `/50_forwarding/http-dest-2/02_retry/`

Each item on the `/40_forwarding_input_queue/` queue will be copied into each of the `01_forward` queues, then the source item will be deleted.
This keeps each destination independent and prevents a loss of connection to one destination from impacting the others.


#### `/50_forwarding/`

This directory contains multiple directory queues, two per forward destination.

* `..../<destination name>/01_forward/` - Items initially queued for forwarding to the destination.
* `..../<destination name>/02_retry/` - Items that have failed to forward to the destination and have been queued for a retry.

Each forward destination directory also contains a failure directory:

* `..../<destination name>/03_/failure/` - Items that have failed to forward.
  Either they have failed too many times or have failed with an error that prevents retry.


