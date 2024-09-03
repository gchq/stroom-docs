---
title: "Change Log"
linkTitle: "Change Log"
weight: 50
date: 2024-04-25
tags: 
description: >
  Link to the full CHANGELOG.
---

The follow changes are in 7.5 but not in 7.4:

<!--
To build this list run diff_changelog.sh in the root of the stroom repo.
E.g. ./diff_changelog.sh 7.4 7.5 | sed -E -e 's/^/\n/' -e 's|Issue \*\*#([0-9]+)\*\*|Issue **{{< external-link "#\1" "https://github.com/gchq/stroom/issues/\1" >}}**|g'
-->

* Issue **{{< external-link "#4383" "https://github.com/gchq/stroom/issues/4383" >}}** : Add an authentication error screen to be shown when a user tries to login and there is an authentication problem or the user's account has been locked/disabled. Previously the user was re-directed to the sign-in screen even if cert auth was enabled.  Added the new property `stroom.ui.authErrorMessage` to allow setting generic HTML content to show the user when an authentication error occurs.

* Issue **{{< external-link "#4412" "https://github.com/gchq/stroom/issues/4412" >}}** : Fix `/` key not working in quick filter text input fields.

* Issue **{{< external-link "#4400" "https://github.com/gchq/stroom/issues/4400" >}}** : Fix missing styling on `sessionList` servlet.

* Fix broken description pane in the stroomQL code completion.

* Change API endpoint `/Authentication/v1/noauth/reset` from GET to POST and from a path parameter to a POST body.

* Fix various issues relating to unauthenticated servlets. Add new servlet paths e.g. `/stroom/XXX` becomes `/XXX` and `/stroom/XXX`. The latter will be removed in some future release. Notable new servlet paths are `/dashboard`, `/status`, `/swagger-ui`, `/echo`, `/debug`, `/datafeed`, `/sessionList`.

* Change `sessionList` servlet to require manage users permission.

* Issue **{{< external-link "#4360" "https://github.com/gchq/stroom/issues/4360" >}}** : Fix quick time settings popup.

* Improve styling of Jobs screen so disabled jobs/nodes are greyed out.

* Add _Next Scheduled_ column to the detail pane of the Job screen.

* Add _Build Version_ and _Up Date_ columns to the Nodes screen. Also change the styling of the _Ping_ column so an enabled node with no ping stands out while a disabled node does not. Also change the row styling for disabled nodes.

* Add a Run now icon to the jobs screen to execute a job on a node immediately.

* Change the FS Volume and Index Volume tables to low-light CLOSED/INACTIVE volumes. Add tooltips to the path and last updated columns. Change the _Use%_ column to a percentage bar. Add red/green colouring to the _Full_ column values.

* Issue **{{< external-link "#4327" "https://github.com/gchq/stroom/issues/4327" >}}** : Add a Jobs pane to the Nodes screen to view jobs by node. Add linking between job nodes on the Nodes screen and the Jobs screen.

* Issue **{{< external-link "#4339" "https://github.com/gchq/stroom/issues/4339" >}}** : Allow user selection of analytic duplicate columns.

* Issue **{{< external-link "#2126" "https://github.com/gchq/stroom/issues/2126" >}}** : Add experimental state store.

* Issue **{{< external-link "#4334" "https://github.com/gchq/stroom/issues/4334" >}}** : Popup explorer text on mouse hover.

* Issue **{{< external-link "#4278" "https://github.com/gchq/stroom/issues/4278" >}}** : Make document deletion also delete the permission records for that document. Also run migration `V07_04_00_005__Orphaned_Doc_Perms` which will delete all document permissions (in table `doc_permission`) for docs that are not a folder, not the System doc, are not a valid doc (i.e. in the `doc` table) and are not a pipeline filter. Deleted document permission records will first be copied to a backup table `doc_permission_backup_V07_04_00_005`.

* Change document Copy and Move to check that the user has Owner permission (or admin) on the document being copied/moved if the permissions mode is None, Destination or Combined. This is because those modes will change the permissions which is something only an Owner/admin can do.

* Issue **{{< external-link "#3989" "https://github.com/gchq/stroom/issues/3989" >}}** : Improve pause behaviour in dashboards and general presentation of `busy` state throughout UI.

* Issue **{{< external-link "#2111" "https://github.com/gchq/stroom/issues/2111" >}}** : Add index assistance to find content feature.

For a detailed list of all the changes in v7.5 see:
{{< external-link "v7.5 CHANGELOG" "https://github.com/gchq/stroom/blob/7.5/CHANGELOG.md" >}} 
