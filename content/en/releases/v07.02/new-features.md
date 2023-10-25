---
title: "New Features"
linkTitle: "New Features"
weight: 10
date: 2023-10-20
tags: 
description: >
  New features in Stroom version 7.2.
---

## New Document types

The following new types of document can be created and managed in the explorer tree.


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

The Query {{< stroom-icon "document/Query.svg">}} entity provides a new way to query data in Stroom.
It is a functional but evolving feature that is likely to be enhanced further in future versions.

Rather than using the query expression builder and table column expressions as used in Dashboards, it uses the new text based [Stroom Query Language]({{< relref "docs/user-guide/dashboards/stroom-query-language" >}}) to define the query.

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

Editing StroomQL queries in the editor is also made easier by the code completion (using `ctrl-space`) to suggest data sources, fields, functions and StroomQL language terms.


### _Analytic Rule_

Analytics is a new experimental feature in Stroom that is functional but still evolving so may well not perform well at scale.
It allows the user to create scheduled or streaming Analytic Rule {{< stroom-icon "document/AnalyticRule.svg">}} that will fire alerts when events matching the rule are seen.

{{< cardpane >}}
  {{< image "releases/07.02/analytic-rule.png" "300x" />}}
  {{< image "releases/07.02/analytic-rule-notification.png" "200x" />}}
{{< /cardpane >}}

Analytic rules rely on the new [Stroom Query Language]({{< relref "#stroom-query-language-stroomql" >}}) to define what events will match the rule.
An _Analytic Rule_ can be created directly from a _Query_ by clicking the Create Analytic Rule {{< stroom-icon "ruleset.svg" "Create Analytic Rule">}} icon.

{{% todo %}}
Add more content to this section
{{% /todo %}}


### _Documentation_

It is now possible to create a _Documentation_ {{< stroom-icon "document/Documentation.svg" >}} entity in the explorer tree.
This is designed to hold any text or documentation that the user chooses to write in {{< glossary "Markdown" >}} format.
These can be useful for providing documentation within a folder in the tree to collectively describe all the items in that folder, or to provide a useful README type document.
It is not possible to add documentation to a folder entity itself, so this is useful substitute.

{{% see-also %}}
See [Documenting Content]({{< relref "/docs/user-guide/content/documentation" >}}) for details on the Markdown syntax.
{{% /see-also %}}


### _Elastic Cluster_

_Elastic Cluster_ {{< stroom-icon "document/ElasticCluster.svg">}} provides a means to define a connection to an {{< glossary "Elasticsearch" >}} Cluster.
You would create one of these documents for each Elasticsearch cluster that you want to connect to.
It defines the location and authentication details for connecting to an elastic cluster.

{{< image "releases/07.02/elastic-cluster.png" "200x" />}}

{{% see-also %}}
[Using Elasticsearch to index data]({{< relref "/docs/user-guide/indexing/elasticsearch" >}}) and [searching an Elasticsearch index]({{< relref "/docs/user-guide/dashboards/elasticsearch" >}})
{{% /see-also %}}

Thanks to Pete K for his help adding the new Elasticsearch integration features.


### _Elastic Index_

An _Elastic Index_ {{< stroom-icon "document/ElasticIndex.svg">}} document is a data source for searching one or more indexes on Elasticsearch.

{{< image "releases/07.02/elastic-index.png" "200x" />}}

{{% see-also %}}
[Searching an Elasticsearch index]({{< relref "/docs/user-guide/dashboards/elasticsearch" >}})
{{% /see-also %}}


## New Searchables

A {{< glossary "Searchable" >}} is one of the data sources that appear at the top level of the tree pickers but not in the explorer tree.


### _Analytics_

Adds the ability to query data from _Table Builder_ type _Analytic Rules_.

{{% todo %}}
Complete this section
{{% /todo %}}


## New Pipeline Elements

### _DynamicIndexingFilter_

{{< pipe-elm "DynamicIndexingFilter" >}}

{{% todo %}}
Needs filling in
{{% /todo %}}


### _DynamicSearchResultOutputFilter_

{{< pipe-elm "DynamicSearchResultOutputFilter" >}}

{{% todo %}}
Needs filling in
{{% /todo %}}


### _ElasticIndexingFilter_

{{< pipe-elm "ElasticIndexingFilter" >}}

_ElasticIndexingFilter_ is used to pass fields from an event to an Elasticsearch cluster to index.

{{% see-also %}}
[Using Elasticsearch to index data]({{< relref "/docs/user-guide/indexing/elasticsearch" >}}).
{{% /see-also %}}


## Explorer Tree

Various enhancements have been made to the explorer tree.


### Favourites

Users now have the ability to mark explorer tree entities as favourites.
Favourites are user specific so each user can define their own favourites.
This feature is useful for quick access to commonly used entities.
Any entity or Folder at any level in the explorer tree can be set as a favourite.
Favourites are also visible in the various entity pickers used in Stroom, e.g. Feed pickers.

An entity/folder can be added or removed from the favourites section using the context menu items :

{{< stroom-menu "Add to Favourites" >}}
{{< stroom-menu "Remove from Favourites" >}}

An entity that is a favourite is marked with a {{< stroom-icon "favourites.svg" >}} in the main tree.

{{< image "releases/07.02/favourites.png" "200x" />}}

A change to a child item of a folder marked as a favourite will be reflected in both the main tree and the favourites section.
All items marked as a favourite {{< stroom-icon "favourites.svg" >}} will appear as a top level item underneath the {{< stroom-icon "favourites.svg" >}} Favourites root, even if they have an ancestor folder that is also a favourite.

Thanks to Pete K for adding this new feature.


### Document Tagging

You can now add tags to entities or folders in the explorer tree.
Tags provide an additional means of searching for entities or folders.
It allows entities/folders that reside in different folders to be associated together in one or more ways.

The tags on an entity/folder can be managed from the explorer tree context menu item :

{{< stroom-menu "Tags" >}}

{{< cardpane >}}
  {{< image "releases/07.02/manage-tags.png" "300x" />}}
  {{< image "releases/07.02/tree-tag-filter.png" "300x" />}}
  {{< image "releases/07.02/tree-picker-tag-filter.png" "300x" />}}
{{< /cardpane >}}

Stroom comes pre-configured with some default tags.
The property that sets these is `stroom.explorer.suggestedTags`.
The defaults for this property are `dynamic`, `extraction` and `reference-loader`

These pre-configured tags are also used in some of the tree pickers in stroom to provide extra filtering of entities in the picker.
For example when selecting a Pipeline on an XSLT Filter the filter on the tree picker to select the pipeline will be pre-populated with `tag:reference-loader` so only reference loader pipelines are included.

The following properties control the tags used to pre-populate tree picker filters:

* `stroom.ui.query.dashboardPipelineSelectorIncludedTags`
* `stroom.ui.query.viewPipelineSelectorIncludedTags`
* `stroom.ui.referencePipelineSelectorIncludedTags`

{{% see-also %}}
See the migration task [Tagging Entities]({{< relref "upgrade-notes#tagging-entities" >}}) for details on how to set up these pre-configured tags.
{{% /see-also %}}


### Copy Link to Clipboard

It is not possible to easily copy a direct link to a Document from the explorer tree.
Direct links are useful if for example you want to share a link to a particular stroom dashboard.

To create a direct link, right click on the document you want a link for in the explorer tree and select:

{{< stroom-menu "Copy Link to Clipboard" >}}

You can then paste the link into a browser to jump directly to that document (authenticating as required).


### Dependencies

It is not possible to jump to the Dependencies screen to see the dependencies or dependants of a particular document.
In the explorer tree right click on a document and select one of:

 {{< stroom-menu "Dependencies" >}}
 This will open the Dependencies screen with a filter pre-populated to show all documents that are dependencies of the selected document.

{{< stroom-menu "Dependants" >}}
This will open the Dependencies screen with a filter pre-populated to show all documents that depend on the selected document.


### Broken Dependency Alerts

It is now possible to see alert icons {{< stroom-icon "alert-simple.svg" "Alert" >}} in the explorer tree to highlight documents that have broken dependencies.
The user can hover over these icons to display more information about the broken dependency.
The explorer tree will show the alert icon {{< stroom-icon "alert-simple.svg" "Alert" >}} against all documents with a broken dependency and all of its ancestor folders.

{{< image "releases/07.02/explorer-dependency-alerts.png" "300x" />}}

A broken dependency means a document (e.g. an XSLT) has a dependency on another document (e.g. a reference loader Pipeline) but that document does not exist.
Broken dependencies can occur when a user deletes a document that other documents depend on, or by a partial import of content.

This feature is disabled by default as it can have a significant effect on performance of the explorer tree with large trees.
To enable this feature, set the property `stroom.explorer.dependencyWarningsEnabled` to `true`.

Once enabled at the system level by the property, the display of alerts in the tree can be enabled/disabled by the user using the Toggle Alerts {{< stroom-icon "exclamation.svg" "Toggle Alerts">}} button.


## Entity Documentation

It is now possible to add documentation to all {{< glossary "entity" "entities" >}}/{{< glossary "document" "documents">}} in the explorer tree, e.g. adding documentation on a _Feed_.
Each entity now has a _Documentation_ sub-tab where the user can enter any documentation they choose about that entity.
The documentation is written in {{< glossary "Markdown" >}} syntax.
It is not possible to add documentation to a _Folder_ but you can create one or more a _Documentation_ entities as a child item of that folder, see [Documentation]({{< relref "#_documentation_" >}}).

{{% see-also %}}
See [Documenting Content]({{< relref "/docs/user-guide/content/documentation" >}}) for details on the Markdown syntax.
{{% /see-also %}}


## Find Content

You can now search the content of entities in the explorer tree, e.g. searching within XSLTs, Dictionaries, Pipeline structure, etc.
This feature is available from the main menu {{< stroom-icon "menu.svg" "Main Menu" >}}:

{{< stroom-menu "Navigation" "Find Content" >}}

It can also be accessed by hitting `<ctrl>-<shift>-f` (unless an editor pane has focus).

{{< image "releases/07.02/find-content.png" "300x" />}}

It is useful for finding which pipelines are using a certain element, or what XSLTs are using a certain `stroom:` function.

This is an early evolution of this feature and it is likely to be improved with time.


## Search Result Stores

When a Dashboard/Query search is run, the results are written to a Search Results Store for that query.
This stores reside on disk to reduce the memory used by queries.
The Search Result Stores are stored on a single Stroom node and get created when a query is executed in a _Dashboard_, _Query_ or _Analytic Rule_.

This screen provides an administrator with an overview of all the stores currently in existence in the Stroom cluster, showing details on their state and size.
It can also be used to stop queries that are currently running or to delete the store entirely.
Stores get deleted when the user closes the _Dashboard_ or _Query_ that created them.

{{< image "releases/07.02/search-result-stores.png" "300x" />}}


## Pipeline Stepper Improvements

The pipeline stepper has had a few user interface tweaks to make it easier to use.


### Log Pane

When there are errors, warnings or info messages on a pipeline element they will now also be displayed in a pane at the bottom.
This makes it easer to see all messages in one place.

{{< image "releases/07.02/stepper-log-pane.png" "300x" />}}

The editor still displays icons with hover tips in the gutter on the appropriate line where the message has an associated line number.

The log pane can be hidden by clicking the {{< stroom-icon "exclamation.svg" "Toggle Log Pane">}} icon.


### Highlighting 

The pipeline displayed at the top of the stepper now highlights elements that have log messages against them.
This makes it easier to see when there is a problem with an element as you step through the data.
The elements are given a coloured border according to the highest severity message on that element:

* Info - Blue
* Warning - Yellow
* Error - Red
* Fatal Error - Red (pulsating)

{{< image "releases/07.02/stepper-element-highlight.png" "500x" />}}


### Filtering

Stroom has always had the ability to filter the data being stepped, however the feature was a little hidden (the Mange Step Filters {{< stroom-icon name="filter.svg" title="Manage Step Filters" colour="green" >}} icon).

Now you can right click on a pipeline element to manage the filters on that element.
You can also clear its filters or the filters on all elements.

{{< image "releases/07.02/stepper-context-menu.png" "300x" />}}

The pipeline now shows which elements have an active filter by displaying a filter {{< stroom-icon name="filter.svg" title="Manage Step Filters" colour="green" >}} icon.

{{< image "releases/07.02/stepper-element-filter-icons.png" "400x" />}}


## Server Tasks

### Auto Refresh

You can now enable/disable the auto-refreshing of the Server Tasks table using the {{< stroom-icon "auto-refresh.svg" "Turn Auto Refresh On/Off">}} button.
Auto refresh is enabled by default.
Disabling it is useful when you want to delete a task, as it will stop the table being refreshed just before you hit delete.

### Info

The Info column has been changed to wrap the text so long info messages can be read more easily.
The task info has also been added to the Info {{< stroom-icon "info.svg" >}} popup.



