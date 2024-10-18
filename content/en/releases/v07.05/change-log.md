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

* Issue **{{< external-link "#4501" "https://github.com/gchq/stroom/issues/4501" >}}** : Fix Query editor syntax highlighting.

* Add query help and editor completions for Dictionary Docs for use with `in dictionary`.

* Issue **{{< external-link "#4487" "https://github.com/gchq/stroom/issues/4487" >}}** : Fix nasty error when running a stats query with no columns.

* Issue **{{< external-link "#4498" "https://github.com/gchq/stroom/issues/4498" >}}** : Make the explorer tree Expand/Collapse All buttons respect the current Quick Filter input text.

* Issue **{{< external-link "#4518" "https://github.com/gchq/stroom/issues/4518" >}}** : Change the Stream Upload dialog to default the stream type to that of the feed.

* Issue **{{< external-link "#4470" "https://github.com/gchq/stroom/issues/4470" >}}** : On import of Feed or Index docs, replace unknown volume groups with the respective configured default volume group (or null if not configured).

* Issue **{{< external-link "#4460" "https://github.com/gchq/stroom/issues/4460" >}}** : Change the way we display functions with lots of arguments in query help and code completion popup.

* Issue **{{< external-link "#4526" "https://github.com/gchq/stroom/issues/4526" >}}** : Change Dictionary to not de-duplicate words as this is breaking JSON when used for holding SSL config in JSON form.

* Issue **{{< external-link "#4528" "https://github.com/gchq/stroom/issues/4528" >}}** : Make the Reindex Content job respond to stroom shutdown.

* Issue **{{< external-link "#4532" "https://github.com/gchq/stroom/issues/4532" >}}** : Fix Run Job Now so that it works when the job or jobNode is disabled.

* Issue **{{< external-link "#4444" "https://github.com/gchq/stroom/issues/4444" >}}** : Change the `hash()` expression function to allow the `algorithm` and `salt` arguments to be the result of functions, e.g. `hash(${field1}, concat('SHA-', ${algoLen}), ${salt})`.

* Issue **{{< external-link "#4534" "https://github.com/gchq/stroom/issues/4534" >}}** : Fix NPE in include/exclude filter.

* Issue **{{< external-link "#4527" "https://github.com/gchq/stroom/issues/4527" >}}** : Change the non-regex search syntax of _Find in Content_ to not use Lucene field based syntax so that `:` works correctly. Also change the regex search to use Lucene and improve the styling of the screen.

* Issue **{{< external-link "#4536" "https://github.com/gchq/stroom/issues/4536" >}}** : Fix NPE.

* Issue **{{< external-link "#4539" "https://github.com/gchq/stroom/issues/4539" >}}** : Improve search query logging.

* Improve the process of (re-)indexing content. It is now triggered by a user doing a content search. Users will get an error message if the index is still being initialised. The `stroom.contentIndex.enabled` property has been removed.

* Issue **{{< external-link "#4513" "https://github.com/gchq/stroom/issues/4513" >}}** : Add primary key to `doc_permission_backup_V07_05_00_005` table for MySQL Cluster support.

* Issue **{{< external-link "#4514" "https://github.com/gchq/stroom/issues/4514" >}}** : Fix HTTP 307 with calling `/api/authproxy/v1/noauth/fetchClientCredsToken`.

* Issue **{{< external-link "#4475" "https://github.com/gchq/stroom/issues/4475" >}}** : Change `mask()` function to `period()` and add `using` to apply a function to window.

* Issue **{{< external-link "#4341" "https://github.com/gchq/stroom/issues/4341" >}}** : Allow download from query table.

* Issue **{{< external-link "#4507" "https://github.com/gchq/stroom/issues/4507" >}}** : Fix index shard permission issue.

* Issue **{{< external-link "#4510" "https://github.com/gchq/stroom/issues/4510" >}}** : Fix right click in editor pane.

* Issue **{{< external-link "#4511" "https://github.com/gchq/stroom/issues/4511" >}}** : Fix StreamId, EventId selection in query tables.

* Issue **{{< external-link "#4485" "https://github.com/gchq/stroom/issues/4485" >}}** : Improve dialog move/resize behaviour.

* Issue **{{< external-link "#4492" "https://github.com/gchq/stroom/issues/4492" >}}** : Make Lucene behave like SQL for OR(NOT()) queries.

* Issue **{{< external-link "#4494" "https://github.com/gchq/stroom/issues/4494" >}}** : Allow functions in StroomQL select, e.g. `count()`.

* Issue **{{< external-link "#4202" "https://github.com/gchq/stroom/issues/4202" >}}** : Fix default destination not being selected when you do _Save As_.

* Issue **{{< external-link "#4475" "https://github.com/gchq/stroom/issues/4475" >}}** : Add `mask()` function and deprecate `countPrevious()`.

* Issue **{{< external-link "#4491" "https://github.com/gchq/stroom/issues/4491" >}}** : Fix tab closure when deleting items in the explorer tree.

* Issue **{{< external-link "#4502" "https://github.com/gchq/stroom/issues/4502" >}}** : Fix inability to step an un-processed stream.

* Issue **{{< external-link "#4503" "https://github.com/gchq/stroom/issues/4503" >}}** : Make the enabled state of the delete/restore buttons on the stream browser depend on the user's permissions. Now they will only be enabled if the user has the require permission (i.e. DELETE/UPDATE) on at least one of the selected items.

* Issue **{{< external-link "#4486" "https://github.com/gchq/stroom/issues/4486" >}}** : Fix the `format-date` XSLT function for date strings with the day of week in, e.g. `stroom:format-date('Wed Aug 14 2024', 'E MMM dd yyyy')`.

* Issue **{{< external-link "#4458" "https://github.com/gchq/stroom/issues/4458" >}}** : Fix explorer node tags not being copied. Also fix copy/move not selecting the parent folder of the source as the default destination folder.

* Issue **{{< external-link "#4454" "https://github.com/gchq/stroom/issues/4454" >}}** : Show the source dictionary name for each _word_ in the Dashboard List Input selection box. Add sorting and de-duplication of _words_.

* Issue **{{< external-link "#4455" "https://github.com/gchq/stroom/issues/4455" >}}** : Add Goto Document links to the Imports sub-tab of the Dictionary screen. Also add new Effective Words tab to list all the words in the dictionary that include those from its imports (and their imports).

* Issue **{{< external-link "#4468" "https://github.com/gchq/stroom/issues/4468" >}}** : Improve handling of key sequences and detection of key events from ACE editor.

* Issue **{{< external-link "#4472" "https://github.com/gchq/stroom/issues/4472" >}}** : Change the User Preferences dialog to cope with redundant stroom/editor theme names.

* Issue **{{< external-link "#4479" "https://github.com/gchq/stroom/issues/4479" >}}** : Add ability to assume role for S3.

* Issue **{{< external-link "#4202" "https://github.com/gchq/stroom/issues/4202" >}}** : Fix problems with Dashboard Extraction Pipeline picker incorrectly changing the selected pipeline.

* Change the DocRef picker so that it shows a warning icon if the selected DocRef no longer exists or the user doesn't have permission to view it.

* Change the Extraction Pipeline picker on the Index Settings screen to pre-filter on `tag:extraction`. This is configured using the property `stroom.ui.query.indexPipelineSelectorIncludedTags`.

* Issue **{{< external-link "#4146" "https://github.com/gchq/stroom/issues/4146" >}}** : Fix audit events for deleting/restoring streams.

* Change the alert dialog message styling to have a max-height of 600px so long messages get a scrollbar.

* Issue **{{< external-link "#4468" "https://github.com/gchq/stroom/issues/4468" >}}** : Fix selection box keyboard selection behavior when no quick filter is visible.

* Issue **{{< external-link "#4471" "https://github.com/gchq/stroom/issues/4471" >}}** : Fix NPE with stepping filter.

* Issue **{{< external-link "#4451" "https://github.com/gchq/stroom/issues/4451" >}}** : Add S3 pipeline appender.

* Issue **{{< external-link "#4401" "https://github.com/gchq/stroom/issues/4401" >}}** : Improve content search.

* Issue **{{< external-link "#4417" "https://github.com/gchq/stroom/issues/4417" >}}** : Show stepping progress and allow termination.

* Issue **{{< external-link "#4436" "https://github.com/gchq/stroom/issues/4436" >}}** : Change the way API Keys are verified. Stroom now finds all valid api keys matching the api key prefix and compares the hash of the api key against the hash from each of the matching records. Support has also been added for using different hash algorithms.

* Issue **{{< external-link "#4448" "https://github.com/gchq/stroom/issues/4448" >}}** : Fix query refresh tooltip when not refreshing.

* Issue **{{< external-link "#4457" "https://github.com/gchq/stroom/issues/4457" >}}** : Fix ctrl+enter shortcut for query start.

* Issue **{{< external-link "#4441" "https://github.com/gchq/stroom/issues/4441" >}}** : Improve sorted column matching.

* Issue **{{< external-link "#4449" "https://github.com/gchq/stroom/issues/4449" >}}** : Reload Scheduled Query Analytics between executions.

* Issue **{{< external-link "#4420" "https://github.com/gchq/stroom/issues/4420" >}}** : Make app title dynamic.

* Issue **{{< external-link "#4453" "https://github.com/gchq/stroom/issues/4453" >}}** : Dictionaries will ignore imports if a user has no permission to read them.

* Issue **{{< external-link "#4404" "https://github.com/gchq/stroom/issues/4404" >}}** : Change the Query editor completions to be context aware, e.g. it only lists Datasources after a `from `.

* Issue **{{< external-link "#4450" "https://github.com/gchq/stroom/issues/4450" >}}** : Fix editor completion in Query editor so that it doesn't limit completions to 100. Added the property `stroom.ui.maxEditorCompletionEntries` to control the maximum number of completions items that are shown. In the event that the property is exceeded, Stroom will pre-filter the completions based on the user's input.

* Add Visualisations to the Query help and editor completions. Visualisation completion inserts a snippet containing all the data fields in the Visualisation, e.g. `TextValue(field = Field, gridSeries = Grid Series)`.

* Issue **{{< external-link "#4424" "https://github.com/gchq/stroom/issues/4424" >}}** : Fix alignment of _Current Tasks_ heading on the Jobs screen.

* Issue **{{< external-link "#4422" "https://github.com/gchq/stroom/issues/4422" >}}** : Don't show _Edit Schedule_ in actions menu on Jobs screen for Distributed jobs.

* Issue **{{< external-link "#4418" "https://github.com/gchq/stroom/issues/4418" >}}** : Fix missing css for `/stroom/sessionList`.

* Issue **{{< external-link "#4435" "https://github.com/gchq/stroom/issues/4435" >}}** : Fix for progress spinner getting stuck on.

* Issue **{{< external-link "#4426" "https://github.com/gchq/stroom/issues/4426" >}}** : Add INFO message when an index shard is created.

* Issue **{{< external-link "#4425" "https://github.com/gchq/stroom/issues/4425" >}}** : Fix _Usage Date_ heading alignment on Edit Volume Group screen for both data/index volumes.

* Uplift docker image JDK to `eclipse-temurin:21.0.4_7-jdk-alpine`.

* Issue **{{< external-link "#4416" "https://github.com/gchq/stroom/issues/4416" >}}** : Allow dashboard table sorting to be changed post query.

* Issue **{{< external-link "#4421" "https://github.com/gchq/stroom/issues/4421" >}}** : Change session state XML structure.

* Issue **{{< external-link "#4419" "https://github.com/gchq/stroom/issues/4419" >}}** : Automatically unpause dashboard result components when a new search begins.

* Rename migration from `V07_04_00_005__Orphaned_Doc_Perms` to `V07_05_00_005__Orphaned_Doc_Perms`.

* Issue **{{< external-link "#4383" "https://github.com/gchq/stroom/issues/4383" >}}** : Add an authentication error screen to be shown when a user tries to login and there is an authentication problem or the user's account has been locked/disabled. Previously the user was re-directed to the sign-in screen even if cert auth was enabled.  Added the new property `stroom.ui.authErrorMessage` to allow setting generic HTML content to show the user when an authentication error occurs.

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
