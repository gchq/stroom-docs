---
title: "Feeds"
linkTitle: "Feeds"
weight: 20
date: 2021-07-09
tags: 
  - feed
description: >
  How to get data into Stroom. 
---

## Getting data into Stroom

### Create the feed

Stroom organises the data it ingests and stores by {{< glossary "Feed" >}}.
A feed will typically be created for each client system and data format.

Data is sent to a Stroom feed using a POST to the `/datafeed` {{< glossary "API" >}}.
We will use `curl` to represent a client system [sending data]({{< relref "/docs/sending-data" >}}) into Stroom.

{{% warning %}}
The _stroom_core_test_ stack that you are running includes a copy of the content created by this quick start guide in the folder _Stroom 101_.
If you want to skip the steps involving creating content then you can just use the pre-loaded _Stroom 101_ content. To delete the folder and all its content, right-click on it and then click delete.

We think you will learn more by deleting this pre-loaded content and following all the steps.
{{% /warning %}}

1. A lot of Stroom's functionality is available through right-click context menus.
   If you right-click  _System_ in the tree you can create new child items.
   Create a new folder and call it something like `Stroom 101`:

   {{< image "quick-start-guide/feed/create-folder.png" >}}Creating a folder{{< /image >}}

1. Right-click on the new _Stroom Quick Start_ folder then click New => {{< stroom-icon "feed.svg" >}}Feed to create a feed.
   The name needs to be capitalised and unique across all feeds.
   Name it `CSV_FEED`.

   {{< image "quick-start-guide/feed/create-feed.png" >}}Creating a feed{{< /image >}}

   This will open a new tab for the feed.

1. We want to emulate a client system sending some data to the feed, so from the command line do

   Download {{< file-link "quick-start-guide/mock_stroom_data.csv" />}} to your computer.
   Then open a terminal session and change directory to the location of the downloaded file.

   {{< command-line >}}
curl -k --data-binary @mock_stroom_data.csv "https://localhost/stroom/datafeeddirect" -H "Feed:CSV_FEED" -H "System:TEST_SYSTEM" -H "Environment:TEST"
   {{</ command-line >}}

The `-H` arguments add HTTP headers to the HTTP POST request.
Stroom uses these headers to determine how to process the data, see [Header Arguments]({{< relref "/docs/sending-data/header-arguments" >}}) for more details.

> In this example we used `/datafeeddirect` rather than `/datafeed`.  
The former goes directly into Stroom, the latter goes via Stoom Proxy where it is aggregated before being picked up by Stroom.

That's it, there's now data in Stroom.
In the _CSV_FEED_ tab, ensure the _Data_ sub-tab is selected then click the new entry in the top pane and finnaly click the {{< stroom-icon "refresh.svg" "Refresh" >}} button:
You should be able to see it in the data table in the bottom pane.

{{< image "quick-start-guide/feed/show-feed-data.png" >}}The data on a feed{{< /image >}}

Now you can do all sorts of things with the data: transform it, visualise it, index it.
It's [Pipelines]({{< relref "process.md" >}}) that allow all these things to happen.
