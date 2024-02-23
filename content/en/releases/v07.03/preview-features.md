---
title: "Preview Features (experimental)"
linkTitle: "Preview Features"
weight: 20
date: 2024-02-23
tags: 
description: >
  Preview experimental features in Stroom version 7.3.
---

## S3 Storage

Integration with S3 storage has been added to allow Stroom to read/write to/from S3 storage, e.g. S3 on AWS.
A data volume can now be create as either `Standard` or `S3`.
If configured as `S3` you need to supply the `S3` configuration data.

{{< image "releases/07.03/add-volume.png" "400x" >}}Add Volume screen.{{< /image >}}

This is an experimental feature at this stage and may be subject to change.
The way Stroom reads and writes data has not been optimised for S3 so performance at scale is currently unknown.


