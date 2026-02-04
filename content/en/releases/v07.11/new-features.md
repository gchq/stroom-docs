---
title: "New Features"
linkTitle: "New Features"
weight: 10
date: hdate
tags: 
description: >
  New features in Stroom version 7.11.
---

# Integrated Pipeline Construction and Translation Development (Stepping)

{{% todo %}}
Add content
{{% /todo %}}

# Ask Stroom AI
The new Ask Stroom AI feature provides information and AI insights into data contained in search result tables or any other tabular data in Stroom.
Ask Stroom UI can be accessed from any table context menu or the toolbar wherever you see this icon:

{{</* stroom-icon "ai.svg" */>}}

One or more AI models must be configured to be able to use Ask Stroom AI.
The models used must conform to the OpenAI API standard.
Once configured users can ask questions such as "Summarise this table" and the Ask Stroom AI feature will provide AI insights for the provided data.

# Dense Vector LLM (AI)
Dense vector index field support allows Stroom to perform approximation queries to find document containing similar words, similar meaning or sentiment, similar spelling plus errors etc.

Dense vector support leverages the AI model configuration provided for the Ask Stroom AI feature.
Support is included for LLM embedded tokenisation and dense vector field storage in both Elastic and Lucene search indices.
The Elastic and Lucene implementations are different and both are experimental in this release.

For the Lucene version you can now create a new field type in the UI and set it to be a dense vector field.
The dense vector field has many configuration options to choose from such as the AI embedding model to use and limits on context size etc.
Once an index is created with a dense vector field and the LLM has provided the tokens for the field data Stroom is able to search using the field.

When querying search terms are substituted for tokens using the LLM and then matched against the dense vector field.
This mechanism allows for connections between words and tokens in both the data and the query to find documents approximately related to the search terms.

# Plan B Histograms, Metrics, Sessions
Multiple improvements to Plan B to store:
* Histogram data, e.g. counts of things within specific time periods.
* Metric data, e.g. values at points in time, CPU Use %, Memory Use % etc.
* Session data, recording start and end periods for certain events, e.g. user uses application X between time A and B.

# Trace Log Support In Plan B
Plan B can now store trace logs supplied via pipelines.
There are new additions to the Plan B schema to capture trace log data so it can be supplied to a Plan B store. 

# Pathways (experimental)
Trace logs describe the operation of applications and user interactions with applications.
Pathways is designed to analyse trace logs over a period of time and remember patterns of activity.
The intent is for Pathways to identify unexpected behaviour or changes to services once regular behaviour has been learnt. 

Once trace logs have been added to a Plan B store it can be analysed with Pathways.
Pathways examines trace logs and identifies unique paths in trace logs between methods or service calls, e.g. A -> B -> C.
It also records alternate paths, e.g. A -> B -> D.
Each path is remembered by Pathways and logged to an output stream.
Whenever a new unique path is found the fact is logged so that it is easy to identify changes.

Pathways also records and monitors changes to span attributes within traces.

Pathways makes no judgement about the changes it logs, it is up to users to add analytic rules to fire against pathway logs.

# Improved Annotations
Annotations have been improved to add several new features and improvements: 
* Labels
* Collections
* Data Retention
* Access permissions
* Links between annotations
* Recording table row details
* Instant update of decorated tables after annotation edits

# Pipeline Processing Dependencies and Delayed Execution
It is now possible to delay processing of event data until required reference data is present.
For each dependency Stroom will delay processing until reference data arrives that is newer than the event data you want to process.
Stroom needs to wait until reference data arrives that is newer than the event data it needs to process so that it knows it has definitely received effective reference data for the events.

## Minimum Delay
Once reference data has been received and processed we can process the event data, however as reference data is cached we may want to add additional delay to the processing, this is achieved by setting a minimum delay.
Even without any processing dependencies a minimum delay can be added so Stroom will wait the specified period of time before processing.

## Maximum Delay
In some cases we reference data might be late, and we might not want to wait too long before processing.
In these cases the user can set a maximum delay so that processing will occur after the specified time delay even without the dependant data being present.

# Git Integration
You can now create Git controlled folders in Stroom that will synchronise all child content with a Git repository.
Git content can be pulled and pushed if the correct credentials have been provided via the new Credentials feature.

See [case]({{< relref "docs/reference-section/git-repo" >}}) for details.

# Content Store
Stroom now has a mechanism for providing standard content from one or more user defined content stores.
Content stores are lists of specific content items described in files with Git repositories.
The content store shows a list of items in the user interface that the user can choose to add to their Stroom instance, e.g. standard pipelines, schemas and visualisations.

See [case]({{< relref "docs/reference-section/content-store" >}}) for details.

# Credentials
Many features in Stroom require credentials to be provided to authenticate connections to external services, e.g. Git repositories, OpenAI APIs, HTTPS connections.
The credentials feature provides a location to store and manage the secrets required to authenticate these services.
Credentials can manage:
* User name and passwords
* API keys and tokens
* SSH keys
* Key stores and trust stores in JKS and PKCS12 format.

See [case]({{< relref "docs/reference-section/credentials" >}}) for details.












# Content Templates
Content templates (auto creates feed,pipe,filter based on template for frictionless)

# Feed Name Generation
Feed name generation (generates the feed name based on various header args for frictionless)

# Receipt Policy Rules
Receipt policy rules that get pulled down to proxy

# New proxy

{{% todo %}}
Add content
{{% /todo %}}

## Multiple destinations
## File store/queue architecture
## Destination liveness checking
## Retrying and failure




















# Smaller Changes
* Pipeline elements now have user friendly names and can be renamed without breaking pipelines.
* Main Stroom tabs can be reordered, closing left, right, custom selected tab colour.
* Dashboard now allow individual panes to be maximised so that a table or visualisation can be viewed full screen.
* Table cells, rows, columns, selected rows and entire tables, now have numerous copy and export options.

# New XSLT functions
A number of new XSLT functions have been added:

* `add-meta(String key, String value)` - Add meta to be written to output destination.
* `split-document(Sting doc, String segmentSize, String overlapSize)` - Split a document for LLM tokenisation (experimental for Elastic dense vector indexing).

# Dashboard & StroomQL Functions

A number of new dashboard and StroomQL functions have been added:

## Create Annotation

Since annotation editing is now performed as a primary Stroom feature via a button and context menu on dashboard and query tables we no longer need to create or edit annotations via a hyperlink.
There are some remaining use cases where users want to create and initialise some annotation values based on some table row content.
The `createAnnotation` function can be used for this purpose and shows a hyperlink that will open the annotation edit screen pre-populated with the supplied values ready to create a new annotation.

The function takes the arguments:

```
createAnnotation(text, title, subject, status, assignedTo, comment, eventIdList)
```

Example:
```
createAnnotation('Create Annotation', 'My Annotation Title', ${SubjectField}, 'New', 'UserA', 'Look at this thing', '123:2,123444:3')
```

See [case]({{< relref "docs/reference-section/expressions/link#createAnnotation" >}}) for details.

## HostAddress

Returns the host address (IP) for the given host string.

```clike
hostAddress(host)
```

Example

```clike
hostAddress('google.com')
> '142.251.29.102'
```


## HostName

Returns the host name for the given host string.

```clike
hostName(host)
```

Example

```clike
hostName('142.251.29.102')
> 'google.com'
```


## InRange

Returns true if the value is between lower and upper (inclusive).
All parameters must be either numbers or ISO date strings.

1. The input value to test
1. The lower bound (inclusive)
1. The upper bound (inclusive)

```clike
inRange(value, lower, upper)
```

Example

```clike
inRange(5, 2, 6)
> true
inRange(5, 5, 5)
> true
inRange(5, 6, 7)
> false
inRange(5, 3, 4)
> false
```
