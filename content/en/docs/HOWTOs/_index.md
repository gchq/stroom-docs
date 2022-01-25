---
title: "How Tos"
linkTitle: "How Tos"
weight: 40
date: 2021-07-09
tags: 
description: >
  This is a series of *HOWTOs* that are designed to get one started with Stroom.
cascade:
  tags:
    - howto
---


{{% todo %}}
Add the resources dir to /assets and fix all the img links
{{% /todo %}}


The *HOWTOs* are broken down into different functional concepts or areas of Stroom.

**NOTE:** These *HOWTOs* will match the development of Stroom and as a result, various elements will be updated over time, including screen captures.
In some instances, screen captures will contain timestamps and so you may note inconsistent date or time movements within a complete HOWTO,
although if a sequence of captures is contained within a section of a document, they all will be replaced.

## Installation
The [Installation Scenarios]({{< relref "Install/InstallHowTo.md" >}}) HOWTO is provided to assist users in setting up a number
of different Stroom deployments.

## Event Feed Processing
The [Event Feed Processing]({{< relref "EventFeeds/ProcessingHowTo.md" >}}) HOWTO is provided to assist users in setting up Stroom to process inbound event logs and transform them into the Stroom Event Logging XML Schema.

The [Apache HTTPD Event Feed]({{< relref "EventFeeds/CreateApacheHTTPDEventFeed.md" >}}) is interwoven into other HOWTOs that utilise this feed as a datasource.

## Reference Feeds
Reference Feeds are used to provide look up data for a translation. The reference feed HOWTOs illustrate how to create reference feeds and how to use look up reference data maps to enrich the data you are processing.

## Searches and Indexing
This section covers Indexing and Searching for data in Stroom
 * [Search using bash]({{< relref "Search/SearchFromBash.md" >}})
 * [Elasticsearch integration]({{< relref "Search/Elasticsearch.md" >}})
 * [Solr integration]({{< relref "Search/Solr.md" >}})

## General
[Raw Source Tracking]({{< relref "General/RawSourceTracking.md" >}}) show how to associate a processed Event with the source line that generated it

Other topics in this section are
1. [Feed Management]({{< relref "General/TasksHowTo.md" >}}).
1. [Tasks]({{< relref "General/TasksHowTo.md" >}})
