---
title: "New Features"
linkTitle: "New Features"
weight: 10
date: 2024-02-29
tags: 
description: >
  New features in Stroom version 7.5.
---

This section contains the significant new features or changes in Stroom.
For a full list of changes see [Change Log]({{< relref "./change-log" >}}).

## User Interface

### Jobs Screen

{{< image "releases/07.05/Jobs.png" "900x" >}}The Jobs screen{{</ image >}}

* Rows are now greyed out if one of the following is true:

  * The parent job is disabled.

  * The job is disabled on a specific node.

  * The node itself is disabled.

* The column _Next Scheduled_ has been added to the detail pane to show the time that the job will next run.

* The details pane now has an Actions menu ({{< stroom-icon "ellipses-horizontal.svg" "Actions...">}}) where it is possible to do the follow actions to a job on a specific node.

  * Edit the schedule for job on the selected node.

  * Run the job on the selected node now.
    This will run the job within 10s or so once clicked.
    Monitor the _Last Executed_ column to see when it has run.

  * Show in Server Tasks (selected node).
    This will open the Server Tasks screen with the quick filter set to the selected job and node.

  * Show in Server Tasks (all nodes).
    This will open the Server Tasks screen with the quick filter set to the selected job.

  It is now possible to link directly to the Nodes screen by clicking the Open {{< stroom-icon "open.svg" "Open">}} hover button next to the node name.


### Nodes Screen

{{< image "releases/07.05/Nodes.png" "900x" >}}The Nodes screen{{</ image >}}

* A jobs detail pane has been added to show the jobs on that node.
  This shows all jobs and allows jobs to be enabled/disabled on a node.
  It also shows the state of the parent job and the node.
  The {{< stroom-icon "filter.svg" "Click to show only enabled jobs">}} button can be used to show only the enabled jobs on that node.

  An auto-refresh button {{< stroom-icon "auto-refresh.svg" "Turn Auto Refresh On">}} has also been added to keep refreshing the jobs detail pane so the _Last Executed_ and _Next Scheduled_ columns are updated.

  It is also possible to link directly to the Jobs screen by clicking the Open {{< stroom-icon "open.svg" "Open">}} hover button next to the job name.

* Nodes rows are now greyed out if the node is disabled.

* Job rows are not greyed out if one of the following is true:
  * The node is disabled.
  * The parent job is disabled.
  * The job is disabled on a specific node.

* The column _Build Version_ has been added to show the version of Stroom that the node is running.
  This is to highlight any nodes running the wrong version.

* The column _Up Date_ have been added to the Nodes screen to show the time that Stroom was last booted on that node.

* The _Ping_ column screen has been changed so an enabled node with no ping stands out while a disabled node does not.


### New Look and Feel

The Login, Change Password and Manage Accounts screens have been changed to bring their look and feel in line with the rest of the application.
The screens may look a little different but are functionally the same.

{{< image "releases/07.05/Accounts.png" "900x" >}}The Manage Accounts screen{{</ image >}}

{{< cardpane >}}
    {{< image "releases/07.05/NewAccount.png" "250x" >}}The New Account screen{{</ image >}}
    {{< image "releases/07.05/EditAccount.png" "250x" >}}The Edit Account screen{{</ image >}}
    {{< image "releases/07.05/Login.png" "250x" >}}The Login screen{{</ image >}}
    {{< image "releases/07.05/ChangePassword.png" "250x" >}}The Change Password screen{{</ image >}}
{{</ cardpane >}}


### Dictionaries

The Dictionary {{< stroom-icon "document/Dictionary.svg">}} screen has been changed to make it easier to manage the import of other Dictionaries.

The _Import_ sub-tab has been changed to include a detail pane that shows the effective word list for each imported Dictionary.
This will show all words in the imported dictionary along with any from Dictionaries that it imports from.

{{< image "releases/07.05/DictionaryImports.png" "300x" />}}

A _Effective Words_ sub-tab has been added to show the effective list of words in the Dictionary, i.e. combining all words from the dictionary, its imports and any dictionaries imported by those imports.

{{< image "releases/07.05/DictionaryEffectiveWords.png" "300x" />}}


### Authentication Error Screen

If there is an authentication error during user login, e.g. the account is disabled or locked, the user will now be redirected to a configurable error screen rather than back to the login screen.

{{< image "releases/07.05/AuthError.png" "300x" />}}

The content of the lower part of the dialog is configurable via the property `stroom.ui.authErrorMessage`.
This property accepts HTML content.
This the message to contain details of how to contact the appropriate Stroom admin team.


### Queries

#### Editor Code Completion

The code completion in the Query {{< stroom-icon "document/Query.svg" >}} editor has been changed to make the code completion suggestions context aware.
For example if you have just typed `in dictionary ` and then hit {{< key-bind "ctrl-space">}} it will suggest the names of Dictionary documents that are visible to the user.

{{< image "releases/07.05/QueryCompletion.png" "500x" />}}

Dictionaries {{< stroom-icon "document/Dictionary.svg">}} and Visualisations {{< stroom-icon "document/Visualisation.svg" >}} have also been added to the list of Query Help items (in the left hand pane) and to the available code completions.


#### Table Download

You can now download the results of a Query using the {{< stroom-icon "download.svg" >}} icon.

{{< image "releases/07.05/QueryDownload.png" "500x" />}}


#### Functions in `select`

Functions, e.g. `count()` can now be used within the `select` clause of a StroomQL query.


### Dashboards

#### Sorting

Now when you change an existing table sort on a dashboard it does not require the query to be executed again.
The table data will change to reflect the new sort settings.
This is particularly useful on complex queries or those operating on large amounts of data.


#### Dictionary List Input

When using a List Input pane on a Dashboard {{< stroom-icon "document/Dashboard.svg" >}} that is configured with a Dictionary {{< stroom-icon "document/Dictionary.svg">}}, the drop-down now shows the source of each Dictionary word.

{{< image "releases/07.05/DictionaryListInput.png" "300x" />}}


### Other UI Changes

* The explorer tree now shows the name of the item in the hover tooltip.
  This is useful if the name extends beyond the limit of the explorer tree pane.

* Issue **{{< external-link "#4339" "https://github.com/gchq/stroom/issues/4339" >}}** : Allow user selection of analytic duplicate columns.

* Issue **{{< external-link "#3989" "https://github.com/gchq/stroom/issues/3989" >}}** : Improve pause behaviour in dashboards and general presentation of `busy` state throughout UI.

* The way dialogs can be moved or resized has been improved so that they can be resized on any edge or corner.
  The area for clicking and dragging to move a dialog has been increased to include all of the title section.


## Permissions

* Document deletion will now also delete all associated document permissions granted to user/groups.
  This previously did not happen on document delete so orphaned document permissions would build up in the database.

  The DB migration `V07_04_00_005__Orphaned_Doc_Perms` which will delete all document permissions (in table `doc_permission`) for docs that are not a folder, not the System doc, are not a valid doc (i.e. in the `doc` table) and are not a pipeline filter. Deleted document permission records will first be copied to a backup table `doc_permission_backup_V07_04_00_005`.

* Document Copy and Move has been changed to check that the user has Owner permission (or admin) on the document being copied/moved if the permissions mode is None, Destination or Combined. This is because those modes will change the permissions which is something only an Owner/admin can do.

{{% note %}}
Significant changes to document permissions are coming in v7.6.
{{% /note %}}


## Content Search

The Find in Content screen added in v7.3 has been changed to add Lucene indexing to speed up content searches.
The Lucene index will be created when a user first uses the content search.
The user may see an error message on first use telling them to wait for the index to be built.

The index is located in `<stroom.path.temp>/doc-index`, which unless explicitly configured will likely be `/tmp/doc-index`.

{{< image "releases/07.05/FindInContent.png" "500x" />}}


## Volumes

{{< image "releases/07.05/Volumes.png" "900x" />}}

* The tables on the Data Volumes and Index Volumes screens have been changed to low-light `CLOSED`/`INACTIVE` volumes.

* Tooltips have been added to the _Path_ and _Last Updated_ columns.

* The _Use%_ column has been changed to a percentage bar.

* Red/green colouring has been added to the to the _Full_ column values to make it clearer which volumes are full.


## Dependency Documents

### Missing Dependencies

Various screens include document pickers to select a dependency document, e.g. selecting an extraction Pipeline {{< stroom-icon "document/Pipeline.svg" >}} in the Dashboard {{< stroom-icon "document/Dashboard.svg" >}} table settings.
The document picker will now show a {{< stroom-icon "warning.svg" >}} icon to indicate the previously selected document is not longer visible to the user or has been deleted.

{{< image "releases/07.05/MissingDoc.png" "400x" />}}


### Tagged Documents

Various screens require the selection of an _extraction_, or _reference loader_ Pipeline, i.e.:

* View {{< stroom-icon "document/View.svg" >}} - Extraction pipeline
* Index {{< stroom-icon "document/Index.svg" >}} - Default extraction pipeline
* Dashboard {{< stroom-icon "document/Dashboard.svg" >}} - Extraction Pipeline
* Pipeline {{< stroom-icon "document/Dashboard.svg" >}} - Reference loader pipeline

To distinguish processing pipelines from extraction or reference loading pipelines, the Pipeline documents can be tagged with pre-configured tags such as `extraction` and `reference-loader`.
This means the Pipeline picker screen can be pre-filtered on the appropriate tag to make finding the right document easier.

It is recommended to tag all such pipelines using these tags to make document selection easier for other users.

{{< image "releases/07.05/ExtractionTag.png" "400x" />}}

This system defined tagging is configured using the following properties

* `stroom.explorer.suggestedTags`
* `stroom.ui.query.dashboardPipelineSelectorIncludedTags`
* `stroom.ui.query.indexPipelineSelectorIncludedTags`
* `stroom.ui.query.viewPipelineSelectorIncludedTags`
* `stroom.ui.referencePipelineSelectorIncludedTags`


## API Keys

The API keys screen has changed to allow selection of the hashing algorithm used to store a hash of the API key.

{{< image "releases/07.05/ApiKeyHash.png" "300x" />}}


## Processing

### S3 Appender

A new S3 pipeline element {{< pipe-elm "S3Appender" >}} has been added to enable the streaming of data to an S3 bucket.

The S3 Appender requires the creation of an S3 Config {{< stroom-icon "document/S3.svg" "S3 Config">}} document to provide the credentials and role details for connecting to the S3 bucket.
The content of the S3 Config {{< stroom-icon "document/S3.svg" "S3 Config">}} document is JSON and the JSON Schema describing its structure can be found {{< external-link "here" "https://raw.githubusercontent.com/gchq/stroom/refs/heads/7.5/stroom-aws/stroom-aws-s3-impl/src/test/resources/stroom/aws/s3/impl/s3config-schema.json" >}}.


## Stepping

The stepper has been changed to allow termination of the step.
This is useful when stepping large streams or when using filtered steps.

{{< image "releases/07.05/StepperTerminate.png" "300x" />}}

The fact that the step is in progress is indicated by a label above the pipeline elements.

{{< image "releases/07.05/StepperStepping.png" "300x" />}}


## Other Changes

* Issue **{{< external-link "#4444" "https://github.com/gchq/stroom/issues/4444" >}}** : Change the `hash()` expression function to allow the `algorithm` and `salt` arguments to be the result of functions rather than just static values, e.g. `hash(${field1}, concat('SHA-', ${algoLen}), ${salt})`.


