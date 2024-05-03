---
title: "Preview Features (experimental)"
linkTitle: "Preview Features"
weight: 20
date: 2023-10-31
tags: 
description: >
  Preview experimental features in Stroom version 7.2.
---


## New Document types

{{% warning %}}
The following features are usable but should be considered experimental at this point.
The functionality may be subject to future changes that may break any content created with this version.  
{{% /warning %}}

### _View_

A View {{< stroom-icon "document/View.svg">}} is a document type that has been added in to make using Dashboards and Queries easier.
It encapsulates the data source and an optional extraction pipeline.

{{< image "releases/07.02/view.png" "300x" />}}

Previously a user wanting to create a Dashboard to query Stroom's indexes would need to first select the Index to use as the data source then select an extraction pipeline.
The indexes do not typically store the full event, so extraction pipelines retrieve the full event from the stream store for each matching event returned by the index.
Users should not need to understand the distinction between what is held in the index and what has to be exacted, nor should they need to know how to do that extraction.

A View abstracts the user from this process.
They can be configured by an admin or more senior user so that a standard user can just select an appropriate View as the data source in a Dashboard or Query and the View will silently handle the retrieval/extraction of data.

Views are also used by _Analytic Rules_ so need to define a Meta filter that controls the streams that will be processed by the analytic.
This filer should mirror the processor filter expression used to control data processed by the Index that the View is using.
These two filters may be amalgamated in a future version of Stroom.


### _Query_

The Query {{< stroom-icon "document/Query.svg">}} feature provides a new way to query data in Stroom.
It is a functional but evolving feature that is likely to be enhanced further in future versions.

Rather than using the query expression builder and table column expressions as used in Dashboards, it uses the new text based [Stroom Query Language]({{< relref "docs/user-guide/search/queries/stroom-query-language" >}}) to define the query.

{{< image "releases/07.02/query.png" "300x" />}}


#### Stroom Query Language (StroomQL)

This is an example of a StroomQL query.
It replaces the old dashboard expression 'tree' and table column expressions.
StroomQL has the advantage of being quicker to construct and is easier to copy from one query to another (whole or in part) as it is just plain text.

```sql
FROM "Example View"                           // Define the View to use as the data source
WHERE Action IN("Search", "View")             // Equivalent to the Dashboard expression tree
EVAL hour = floorHour(EventTime)              // Define named fields based on function expressions
EVAL event_count = count()
GROUP BY Feed, Action                         // Equivalent to Dashboard table column grouping
SELECT Feed, Action, event_count AS "Count"   // Equivalent to adding columns to a Dashboard table
```

Editing StroomQL queries in the editor is also made easier by the code completion (using `ctrl+space`) to suggest data sources, fields, functions and StroomQL language terms.
StroomQl queries can be executed easily with `ctrl+enter` or `shift+enter`.


### _Analytic Rule_

Analytic Rules allow the user to create scheduled or streaming Analytic Rule {{< stroom-icon "document/AnalyticRule.svg">}} that will fire alerts when events matching the rule are seen.

{{< cardpane >}}
  {{< image "releases/07.02/analytic-rule.png" "300x" />}}
  {{< image "releases/07.02/analytic-rule-notification.png" "200x" />}}
{{< /cardpane >}}

Analytic rules rely on the new [Stroom Query Language]({{< relref "#stroom-query-language-stroomql" >}}) to define what events will match the rule.
An _Analytic Rule_ can be created directly from a _Query_ by clicking the Create Analytic Rule {{< stroom-icon "document/AnalyticRule.svg" "Create Analytic Rule">}} icon.


