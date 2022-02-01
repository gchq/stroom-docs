---
title: "Quick Start Guide"
linkTitle: "Quick Start Guide"
weight: 10
date: 2021-07-09
tags: 
description: >
  How to setup an instance of Stroom and get started processing data.
---

In this quick-start guide you will learn how to use Stroom to get from a file that looks like this:

{{< textfile "quick-start-guide/mock_stroom_data.csv" "csv">}}Quick start test data{{< /textfile >}}

To this XML:

```xml
<?xml version="1.1" encoding="UTF-8"?>
<Events xmlns:stroom="stroom" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <Event>
      <Id>1</Id>
      <Guid>10990cde-1084-4006-aaf3-7fe52b62ce06</Guid>
      <FromIp>159.161.108.105</FromIp>
      <ToIp>217.151.32.69</ToIp>
      <Application>Tres-Zap</Application>
   </Event>
   <Event>
      <Id>2</Id>
      <Guid>633aa1a8-04ff-442d-ad9a-03ce9166a63a</Guid>
      <FromIp>210.14.34.58</FromIp>
      <ToIp>133.136.48.23</ToIp>
      <Application>Sub-Ex</Application>
   </Event>
  ...
```

You will go from a clean vanilla Stroom to having a simple [pipeline]({{< relref "../user-guide/pipelines" >}}) that takes in CSV data and outputs that data transformed into XML.
Stroom is a generic and powerful tool for ingesting and processing data: it's flexible because it's generic so if you do want to start processing data we would recommend you follow this tutorial otherwise you'll find yourself struggling.

We're going to do the following:

All the things we create here are available as a {{< external-link "content pack" "https://github.com/gchq/stroom-content/releases/tag/stroom-101-v1.0" >}}, so if you just wanted to see it running you could get there quite easily.

> **Note:** The CSV data used in _mock_stroom_data.csv_ (linked to above) is randomly generated and any association with any real world IP address or name is entirely coincidental.

We're going to do follow the links below in this order:
