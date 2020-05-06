# Stroom HOWTOs

This is a series of *HOWTOs* that are designed to get one started with Stroom. The *HOWTOs* are broken down into different functional concepts or areas of Stroom.

**NOTE:** These *HOWTOs* will match the development of Stroom and as a result, various elements will be updated over time, including screen captures.
In some instances, screen captures will contain timestamps and so you may note inconsistent date or time movements within a complete HOWTO,
although if a sequence of captures is contained within a section of a document, they all will be replaced.

## General

This section contains HOWTO documents with instruction on general maintenence and configuration tasks: The [Feed Management](General/FeedManagementHowTo.md "Stroom Feed Management"), [Task Management](General/TasksHowTo.md "Task Management"), [Moving Object in Explorer](General/ExplorerManagementHowTo.md "Moving Object in Explorer"), [Enabling Processors](General/EnablingProcessorsHowTo.md "Enabling Processors")

## Authentication

Contains [User Login](Authentication/UserLoginHowTo.md "User Login"), [User Logout](Authentication/UserLogoutHowTo.md "User Logout"), [Create User](Authentication/CreateUserHowTo.md "Create User") HOWTO documents.

## Installation

The [Installation Scenarios](Install/InstallHowTo.md "Stroom Installation Deployments") HOWTO is provided to assist users in setting up a number
of different Stroom deployments.

## Event Feed Processing

The [Event Feed Processing](EventFeeds/ProcessingHowTo.md "Event Feed Processing") HOWTO is provided to assist users in setting up Stroom to process inbound event logs and transform them into the Stroom Event Logging XML Schema.

The [Apache HTTPD Event Feed](HOWTOs/EventFeeds/CreateApacheHTTPDEventFeed.md "Apache HTTPD Event Feed") is interwoven into other HOWTOs that utilise this feed as a datasource.

## Reference Feeds

Reference Feeds are used to provide look up data for a translation. The reference feed HOWTOs illustrate how to create reference feeds [Create Reference Feed](ReferenceFeeds/CreateSimpleReferenceFeed.md "Create Reference Feeds") and how to use look up reference data maps to enrich the data you are processing [Use Reference Feed](ReferenceFeeds/UseSimpleReferenceFeedHowTo.md "Use Reference Feeds").

## Event Post Processing

The [Event Forwarding](EventPostProcessing/EventForwardingHowTo.md "Event Forwarding") HOWTO demonstrates how to extract xertain events from the Stroom event store and export the events in XML to a file system.

## Administration

HOWTO documents that illustrate how to perform certain system administration tasks within Stroom: [Manage System Properties](Administration/SystemProperties.md "Manage System Properties")