---
title: "How Tos"
linkTitle: "How Tos"
weight: 40
date: 2021-07-09
tags: 
description: >
  This is a series of *HOWTOs* that are designed to get one started with Stroom.
  The *HOWTOs* are broken down into different functional concepts or areas of Stroom.
cascade:
  tags:
    - howto
---

{{% note %}}
These *HOWTOs* will match the development of Stroom and as a result, various elements will be updated over time, including screen captures.
In some instances, screen captures will contain timestamps and so you may note inconsistent date or time movements within a complete HOWTO, although if a sequence of captures is contained within a section of a document, they all will be replaced.
{{% /note %}}

## General

[Raw Source Tracking]({{< relref "General/raw-source-tracking.md" >}}) show how to associate a processed Event with the source line that generated it.

Other topics in this section are
1. [Feed Management]({{< relref "General/tasks-how-to.md" >}}).
1. [Tasks]({{< relref "General/tasks-how-to.md" >}})
1. [Moving Object in Explorer]({{< relref "General/explorer-management-how-to.md" >}})
1. [Enabling Processors]({{< relref "General/enabling-processors-how-to.md" >}})


## Administration

HOWTO documents that illustrate how to perform certain system administration tasks within Stroom: [Manage System Properties]({{< relref "Administration/system-properties.md" >}})


## Authentication

Contains [User Login]({{< relref "Authentication/user-login-how-to.md" >}}), [User Logout]({{< relref "Authentication/user-logout-how-to.md" >}}), [Create User]({{< relref "Authentication/create-user-how-to.md" >}}) HOWTO documents.


## Installation

The [Installation Scenarios]({{< relref "Install/install-how-to.md" >}}) HOWTO is provided to assist users in setting up a number
of different Stroom deployments.


## Event Feed Processing

The [Event Feed Processing]({{< relref "EventFeeds/processing-how-to.md" >}}) HOWTO is provided to assist users in setting up Stroom to process inbound event logs and transform them into the Stroom Event Logging XML Schema.

The [Apache HTTPD Event Feed]({{< relref "EventFeeds/create-apache-httpd-event-feed.md" >}}) is interwoven into other HOWTOs that utilise this feed as a datasource.


## Reference Feeds

Reference Feeds are used to provide look up data for a translation.
The reference feed HOWTOs illustrate how to create reference feeds [Create Reference Feed]({{< relref "ReferenceFeeds/create-simple-reference-feed" >}}) and how to use look up reference data maps to enrich the data you are processing [Use Reference Feed]({{< relref "./ReferenceFeeds/use-simple-reference-feed-how-to" >}}).


## Searches and Indexing

This section covers using Stroom to index and search data.

 * [Stroom API]({{< relref "Search/stroom-api.md" >}})
 * [Elasticsearch]({{< relref "Search/Elasticsearch.md" >}})
 * [Solr]({{< relref "Search/Solr.md" >}})


## Event Post Processing

The [Event Forwarding]({{< relref "EventPostProcessing/event-forwarding-how-to.md" >}}) HOWTO demonstrates how to extract certain events from the Stroom event store and export the events in XML to a file system.

