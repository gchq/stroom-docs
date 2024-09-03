---
title: "New Features"
linkTitle: "New Features"
weight: 10
date: 2024-02-29
tags: 
description: >
  New features in Stroom version 7.5.
---

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


### Authentication Error Screen

If there is an authentication error during user login, e.g. the account is disabled or locked, the user will now be redirected to a configurable error screen rather than back to the login screen.

{{< image "releases/07.05/AuthError.png" "300x" />}}

The content of the lower part of the dialog is configurable via the property `stroom.ui.authErrorMessage`.
This property accepts HTML content.
This the message to contain details of how to contact the appropriate Stroom admin team.


### Other Changes

* The explorer tree now shows the name of the item in the hover tooltip.
  This is useful if the name extends beyond the limit of the explorer tree pane.

* Issue **{{< external-link "#4339" "https://github.com/gchq/stroom/issues/4339" >}}** : Allow user selection of analytic duplicate columns.

* Issue **{{< external-link "#3989" "https://github.com/gchq/stroom/issues/3989" >}}** : Improve pause behaviour in dashboards and general presentation of `busy` state throughout UI.


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

Indexing of the content can be enabled by setting the property `stroom.contentIndex.enabled` to `true`.


## Volumes

{{< image "releases/07.05/Volumes.png" "900x" />}}

* The tables on the Data Volumes and Index Volumes screens have been changed to low-light `CLOSED`/`INACTIVE` volumes.

* Tooltips have been added to the _Path_ and _Last Updated_ columns.

* The _Use%_ column has been changed to a percentage bar.

* Red/green colouring has been added to the to the _Full_ column values to make it clearer which volumes are full.



