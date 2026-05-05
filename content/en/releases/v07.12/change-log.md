---
title: "Change Log"
linkTitle: "Change Log"
weight: 50
date: 2026-03-18
tags: 
description: >
  Full list of changes in this release.
---

<!--
To build this list run diff_changelog.sh in the root of the stroom repo that has all the latest commits
for the two branches being compared. You can run it between tags (e.g. v7.11-beta.21 v7.11-beta.22) if
you need to add in the changes for a patch release.

E.g. ./diff_changelog.sh 7.11 7.12 | sed -E -e 's/^/\n/' -e 's@(Issue|Bug|Feature|Build|Dependency|Refactor) \*\*#([0-9]+)\*\*@\1 **{{< external-link "#\2" "https://github.com/gchq/stroom/issues/\2" >}}**@g'

OR, if you use Vim use this command (changing the path to the stroom repo) to read it straight into this buffer
(Hash '#' needs to be escaped with '\' to stop vim replacing it with the current file path)
:r !../stroom_v7_12/diff_changelog.sh 7.11 7.12 | sed -E -e 's/^/\n/' -e 's@(Issue|Bug|Feature|Build|Dependency|Refactor) \*\*\#([0-9]+)\*\*@\1 **{{< external-link "\#\2" "https://github.com/gchq/stroom/issues/\2" >}}**@g'
-->


## New Features and Changes

* Feature **{{< external-link "#5427" "https://github.com/gchq/stroom/issues/5427" >}}** : Change the Data Feed Key authentication mechanism to support authentication by X509 certificate DN. Add a new allowed type of `CERTIFICATE_IDENTITY` to `.receive.enabledAuthenticationTypes`. Rename property `.receive.dataFeedKeysDir` to  `.receive.dataFeedIdentitiesDir` and change the structure of the files in it, all files will have to be replaced. Rename property `.receive.dataFeedKeyOwnerMetaKey` to `.receive.dataFeedOwnerMetaKey`. Change the default value of `.receive.dataFeedIdentitiesDir` from `data_feed_keys` to `data_feed_identities`.

* Feature **{{< external-link "#5442" "https://github.com/gchq/stroom/issues/5442" >}}** : Add more configuration options to `stroom.autoContentCreation` to improve the explorer structure and permissions of the generated content. Add properties `additionalGroupParentGroupName`, `destinationExplorerSubPathTemplate` and `groupParentGroupName`. All have sensible defaults.

* Feature **{{< external-link "#5473" "https://github.com/gchq/stroom/issues/5473" >}}** : Add `JSON_LINES` to the base list of data formats in the `.data.meta.dataFormats` property.


## Bug Fixes

* Bug **{{< external-link "#5532" "https://github.com/gchq/stroom/issues/5532" >}}** : Relax Data Feed Identities validation so salt is optional.

* Bug : Add missing directories (data_feed_identities, git_repo, lmdb_library, planb, reference_staging_data) as volumes in the docker image.


## Code Refactor

No _Code Refactor_ changes.


## Dependency Changes

No _Dependency_ changes.

