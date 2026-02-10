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
|-- 02_split_zip/
|-- 20_pre_aggregate_input_queue/
|-- 21_pre_aggregates/
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


#### `/02_receiving_zip/`

This directory is the reception for area for data that has been received as a {{< glossary "ZIP" >}} file which may contain one or more streams of data and associated metadata.

Data will be written to this directory before the client receives the HTTP response.


#### `/02_split_zip/`

If a received {{< glossary "ZIP" >}} file contains data for more that one {{< glossary "Feed" >}} it will be places into this directory for splitting.

ZIP files in this directory will be un-zipped into a subdirectory
