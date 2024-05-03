---
title: "New Features"
linkTitle: "New Features"
weight: 10
date: 2023-10-20
tags: 
description: >
  New features in Stroom version 7.2.
---

## Look and Feel

### New User Interface Design

The user interface has had a bit of a re-design to give it a more modern look and to make it conform to accessibility standards.

{{< image "releases/07.02/new-look.png" "400x" />}}


### User Preferences

Now you can customise Stroom with your own personal preferences.
From the main menu {{< stroom-icon "menu.svg" "Main Menu">}}, select:

{{< stroom-menu "User" "Preferences" >}}

You can also change the following:

* **Layout Density** - This controls the layout spacing to fit more or less user interface elements in the available space.

* **Font** - Change font used in Stroom.

* **Font Size** - Change the font size used in Stroom.

* **Transparency** - Enables partial transparency of dialog windows.
  Entirely cosmetic.


#### Theme

Choose between the traditional light theme and a new dark theme with light text on a dark background.

{{< cardpane >}}
{{< image "releases/07.02/theme-light.png" "250" />}}
{{< image "releases/07.02/theme-dark.png" "250" />}}
{{< /cardpane >}}


#### Editor Preferences

The Ace text editor used within Stroom is used for editing things like XSLTs and viewing stream data.
It can now be personalised with the following options:

* **Theme** - The colour theme for the editor.
  The theme options will be applicable to the main user interface theme, i.e. light/dark editor themes.
  The theme affects the colours used for the syntax highlight content.

* **Key Bindings** - Allows you to set the editor to use {{< external-link "Vim" "https://en.wikipedia.org/wiki/Vim_(text_editor)" >}} key bindings for more powerful text editing.
  If you don't know what Vim is then it is best to stick to _Standard_.
  If you would like to learn how to use Vim, install `vimtutor`.
  Note: The Ace editor does not fully emulate Vim, not all Vim key bindings work and there is limited command mode support.

* **Live Auto Completion** - Set this to _On_ if you want the editor code completion to make suggestions as you type.
  When set to _Off_ you need to press {{< key-bind "ctrl+space" >}} to show the suggestion dialog.


#### Date and Time

You can now change the format used for displaying the date and time in the user interface.
You can also set the time zone used for displaying the date and time in the user interface.

{{% note %}}
Stroom works in {{< glossary "UTC" >}} time internally.
Changing the time zone only affects display of dates/times, not how data is stored or the dates/times in events.
{{% /note %}}


### Dashboard Changes

#### Design Mode

A Design Mode has been introduced to {{< glossary "Dashboard" "Dashboards" >}} and is toggled using the button {{< stroom-icon "edit.svg" "Enter/Exit Design Mode">}}.
When a _Dashboard_ is in design mode, the following functionality is enabled:

* Adding components to the _Dashboard_.
* Removing components from the _Dashboard_.
* Moving _Dashboard_ components within panes, to new panes or to existing panes.
* Changing the constraints of the _Dashboard_.

On creation of a new _Dashboard_, Design Mode will be on so the user has full functionality.
On opening an existing _Dashboard_, Design Mode will be off.
This is because typically, _Dashboards_ are viewed more than they are modified.


#### Visual Constraints

Now it is possible to control the horizontal and vertical constraints of a _Dashboard_.
In Stroom 7.0, a dashboard would always scale to fit the user's screen.
Sometimes it is desirable for the dashboard canvas area to be larger than the screen so that you have to scroll to see it all.
For example you may have a dashboard with a large number of component panes and rather than squashing them all into the available space you want to be able to scroll vertically in order to see them all.

It is now possible to change the horizontal and/or vertical constraints to fit the available width/height or to be fixed by clicking the {{< stroom-icon "resize.svg" "Set Constraints" >}} button.

{{< cardpane >}}
{{< image "releases/07.02/dashboard-canvas.png" "300" />}}
{{< image "releases/07.02/dashboard-set-constraints.png" "100" />}}
{{< /cardpane >}}

The edges of the canvas can be moved to shrink/grow it.


### Explorer Filter Matches

Filtering in the explorer has been changed to highlight the filter matches and to search in folders that themselves are a match.
In Stroom v7.0 folders that matched were not expanded.
Match highlighting makes it clearer what items have matched.

{{< image "releases/07.02/explorer-filter-matches.png" "200" />}}


### Document Permissions Screen

The document and folder permissions screens have been re-designed with a better layout and item highlighting to make it clearer which permissions have been selected.

{{< image "releases/07.02/folder-permissions.png" "300" />}}


### Editor Completion snippets

The number of available [editor completion snippets]({{< relref "docs/user-guide/content/editing-text#auto-completion-and-snippets" >}}) has increased.
For a list of the available completion snippets see the [Completion Snippet Reference]({{< relref "docs/reference-section/snippet-reference" >}}).

{{% note %}}
Completion snippets are an evolving feature so if you have an requests for generic completion snippets then raise an issue on GitHub and we will consider adding them in.
{{% /note %}}


## Partitioned Reference Data Stores

In Stroom v7.0 reference data is loaded using a reference loader pipeline and the key/value pairs are stored in a single disk backed reference data store on each Stroom node for fast lookup.
This single store approach has led to high contention and performance problems when purge operations are running against it at the same time or multiple reference _Feeds_ are being loaded at the same time.

In Stroom v7.2 the reference data key/value pairs are now stored in multiple reference data stores on each node, with one store per _Feed_.
This reduces contention as reference data for one _Feed_ can be loading while a purge operation is running on the store for another _Feed_ or reference data for multiple _Feeds_ can be loaded concurrently.
Performance is still limited by the file system that the stores are hosted on.

All reference data stores are stored in the directory defined by `stroom.pipeline.referenceData.lmdb.localDir`.

{{% see-also %}}
See the [upgrade notes]({{< relref "upgrade-notes#reference-data-store" >}}) for the reference data stores.
{{% /see-also %}}


## Improved OAuth2.0/OpenID Connect Support

The support for Open ID Connect (OIDC) authentication has been improved in v7.2.
Stroom can be integrated with AWS Cognito, MS Azure AD, KeyCloak and other OIDC {{< glossary "IDP" "Identity Providers (IDPs)" >}}.

Data receipt in Stroom and Stroom-Proxy can now enforce OIDC token authentication as well as certificate authentication.
The data receipt authentication is configured via the properties:

* `stroom.receive.authenticationRequired`
* `stroom.receive.certificateAuthenticationEnabled`
* `stroom.receive.tokenAuthenticationEnabled`

Stroom and Stroom-Proxy have also been changed to use OIDC tokens for API endpoints and inter-node communications.
This currently requires the OIDC IDP to support the client credentials flow.

Stroom can still be used with its own internal IDP if you do not have an external IDP available.


### User Naming Changes

The changes to add integration with external OAuth 2.0/OpenID Connect identity provides has required some changes to the way users in Stroom are identified.

Previously in Stroom a user would have a unique username that would be set when creating the account in Stroom.
This would typically by a human friendly name like `jbloggs` or similar.
It would be used in all the user/permission management screens to identify the user, for functions like `current-user()`, for simple audit columns in the database (`create_user` and `update_user`) and for the audit events stroom produces.

With the integration to external identity providers this has had to change a little.
Typically in OpenID Connect IDPs the unique identity of a principle (user) is fairly unfriendly {{< glossary "UUID" >}}.
The user will likely also have a more human friendly identity (sometimes called the `preferred_username`) that may be something like `jblogs` or `jblogs@somedomain.x`.
As per the OpenID Connect specification, this friendly identity may not be unique within the IDP, so Stroom has to assume this also.
In reality this identity is typically unique on the IDP though.
The IDP will often also have a full name for the user, e.g. `Joe Bloggs`.

Stroom now stores and can display all of these identities.

{{< image "releases/07.02/application-permissions.png" "500" />}}

* **Display Name** - This is the (potentially non-unique) preferred user name held by the IDP, e.g. `jbloggs` or  `jblogs@somedomain.x`.
* **Full Name** - The user's full name, e.g. `Joe Bloggs`, if known by the IDP.
* **Unique User Identity** - The unique identity of the user on the IDP, which may look like `ca650638-b52c-45af-948c-3f34aeeb6f86`.


In most screens, Stroom will display the _Display Name_.
This will also be used for any audit purposes.
The permissions screen show all three identities so an admin can be sure which user they are dealing with and be able to correlate it with one on the IDP.


### User Creation

When using an external IDP, a user visiting Stroom for the first time will result in the creation of a Stroom User record for them.
This Stroom User will have no permissions associated with it.
To improve the experience for a new user it is preferable for the Stroom administrator to pre-create the Stroom User account in Stroom with the necessary permissions.

This can be done from the Application Permissions screen accessed from the Main menu ({{< stroom-icon "menu.svg" "Main Menu">}}).

{{< stroom-menu "Security" "Application Permissions" >}}

You can create a single Stroom User by clicking the {{< stroom-icon "add.svg" "Add User">}} button.

{{< image "releases/07.02/create-single-user.png" "300" />}}

Or you can create multiple Stroom Users by clicking the {{< stroom-icon "add-multiple.svg" "Add Multiple Users">}} button.

{{< image "releases/07.02/create-multiple-users.png" "300" />}}

In both cases the _Unique User ID_ is mandatory, and this must be obtained from the IDP.
The _Display Name_ and _Full Name_ are optional, as these will be obtained automatically from the IDP by Stroom on login.
It can be useful to populate them initially to make it easier for the administrator to see who is who in the list of users.

Once the user(s) are created, the appropriate permissions/groups can be assigned to them so that when they log in for the first time they will be able to see the required content and be able to use Stroom.


## New Document types

The following new types of document can be created and managed in the explorer tree.

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
[Using Elasticsearch to index data]({{< relref "/docs/user-guide/indexing/elasticsearch" >}}) and [searching an Elasticsearch index]({{< relref "/docs/user-guide/search/elasticsearch" >}})
{{% /see-also %}}

Thanks to Pete K for his help adding the new Elasticsearch integration features.


### _Elastic Index_

An _Elastic Index_ {{< stroom-icon "document/ElasticIndex.svg">}} document is a data source for searching one or more indexes on Elasticsearch.

{{< image "releases/07.02/elastic-index.png" "200x" />}}

{{% see-also %}}
[Searching an Elasticsearch index]({{< relref "/docs/user-guide/search/elasticsearch" >}})
{{% /see-also %}}


## New Searchables

A {{< glossary "Searchable" >}} is one of the data sources that appear at the top level of the tree pickers but not in the explorer tree.


### _Analytics_

Adds the ability to query data from _Table Builder_ type _Analytic Rules_.


## New Pipeline Elements

### _DynamicIndexingFilter_

{{< pipe-elm "DynamicIndexingFilter" >}}

This filter element is used by [_Views_]({{< relref "#_view_" >}}) and [_Analytic Rules_]({{< relref "#_analytic-rule_" >}}).
Unlike {{< pipe-elm "IndexingFilter" >}} where you have to specify all the fields in the index up front for them to visible to the user in a _Dashboard_, {{< pipe-elm "DynamicIndexingFilter" >}} allows fields to be dynamically created in the XSLT based on the event being indexed.
These dynamic fields are then 'discovered' after the event has been added to the index.


### _DynamicSearchResultOutputFilter_

{{< pipe-elm "DynamicSearchResultOutputFilter" >}}

This filter element is used by [_Views_]({{< relref "#_view_" >}}) and [_Analytic Rules_]({{< relref "#_analytic-rule_" >}}).
Unlike {{< pipe-elm "SearchResultOutputFilter" >}} this element can discover the fields found in the extracted event when the extraction pipeline creates fields that are not present in the index.
These discovered field are then available for the user to pick from in the _Dashboard_/_Query_.


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

The tags on an entity/folder can be managed from the explorer tree context menu item:

{{< stroom-menu "Edit Tags" >}}

The explorer tree can be filtered by tag using the field prefix `tag:`, i.e. `tag:extraction`.

{{< cardpane >}}
  {{< image "releases/07.02/manage-tags.png" "300x" />}}
  {{< image "releases/07.02/tree-tag-filter.png" "300x" />}}
{{< /cardpane >}}


If multiple entities/folders are selected in the explorer tree then the following menu items are available:

{{< stroom-menu "Add Tags" >}}
{{< stroom-menu "Remove Tags" >}}

{{< cardpane >}}
  {{< image "releases/07.02/tags-add.png" "300x" />}}
  {{< image "releases/07.02/tags-remove.png" "300x" />}}
{{< /cardpane >}}


#### Pre-populated Tag Filters

Stroom comes pre-configured with some default tags.
The property that sets these is `stroom.explorer.suggestedTags`.
The defaults for this property are `dynamic`, `extraction` and `reference-loader`

These pre-configured tags are also used in some of the tree pickers in stroom to provide extra filtering of entities in the picker.
For example when selecting a Pipeline on an XSLT Filter the filter on the tree picker to select the pipeline will be pre-populated with `tag:reference-loader` so only reference loader pipelines are included.

{{< image "releases/07.02/tree-picker-tag-filter.png" "300x" />}}

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

It can also be accessed by hitting {{< key-bind "shift,ctrl,f" >}} (unless an editor pane has focus).

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


### Line Wrapping

You can now enable/disable line wrapping in the Name and Info cells using the {{< stroom-icon "text-wrap.svg" "Turn Cell Line Wrapping On/Off">}} button.
Line wrapping is disable by default.
Enabling this is useful to see long Info cell values.


### Info Popup

The Info {{< stroom-icon "info.svg" >}} popup has been changed to include the value from the Info column.


## Proxy

Stroom-Proxy v7.2 has undergone a significant re-write in an attempt to address certain performance issues, make it more flexible and to allow data to be forked to many destinations.

{{% warning %}}
There are some known performance issues with Stroom-Proxy v7.2 so it is not yet production ready, therefore until these are addressed you are advised to continue using Stroom-Proxy v7.0.
{{% /warning %}}



