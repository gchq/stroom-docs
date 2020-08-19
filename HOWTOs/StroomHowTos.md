# Stroom HOWTOs
This is a series of *HOWTOs* that are designed to get one started with Stroom. The *HOWTOs* are broken down into different functional concepts or areas of Stroom.

**NOTE:** These *HOWTOs* will match the development of Stroom and as a result, various elements will be updated over time, including screen captures.
In some instances, screen captures will contain timestamps and so you may note inconsistent date or time movements within a complete HOWTO,
although if a sequence of captures is contained within a section of a document, they all will be replaced.

## Installation
The [Installation Scenarios](Install/InstallHowTo.md "Stroom Installation Deployments") HOWTO is provided to assist users in setting up a number
of different Stroom deployments.

## Event Feed Processing
The [Event Feed Processing](EventFeeds/ProcessingHowTo.md "Event Feed Processing") HOWTO is provided to assist users in setting up Stroom to process inbound event logs and transform them into the Stroom Event Logging XML Schema.

The [Apache HTTPD Event Feed](EventFeeds/CreateApacheHTTPDEventFeed.md "Apache HTTPD Event Feed") is interwoven into other HOWTOs that utilise this feed as a datasource.

## Reference Feeds
Reference Feeds are used to provide look up data for a translation. The reference feed HOWTOs illustrate how to create reference feeds and how to use look up reference data maps to enrich the data you are processing.

## Searches and Indexing
This section covers Indexing and Searching for data in Stroom
 * [Search using bash](Search/SearchFromBash.md "Search using Bash")
 * [Simple Solr integration](Search/SimpleSolr.md "Simple Solr integration")

## General
[Raw Source Tracking](General/RawSourceTracking.md "Raw Source Tracking") show how to associate a processed Event with the source line that generated it

Other topics in this section are
1. [Feed Management](General/TasksHowTo.md "Feed Management").
1. [Tasks](General/TasksHowTo.md "Tasks")
