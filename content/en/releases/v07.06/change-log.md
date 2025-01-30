---
title: "Change Log"
linkTitle: "Change Log"
weight: 50
date: 2025-01-30
tags: 
description: >
  Full list of changes in this release.
---

<!--
To build this list run diff_changelog.sh in the root of the stroom repo.
E.g. ./diff_changelog.sh 7.4 7.5 | sed -E -e 's/^/\n/' -e 's|Issue \*\*#([0-9]+)\*\*|Issue **{{< external-link "#\1" "https://github.com/gchq/stroom/issues/\1" >}}**|g'
-->

* Issue **{{< external-link "#4671" "https://github.com/gchq/stroom/issues/4671" >}}** : Remove foreign key constraints from the legacy `(app|doc)_permission` tables to `stroom_user` to fix user deletion.

* Issue **{{< external-link "#4670" "https://github.com/gchq/stroom/issues/4670" >}}** : Fix display of disabled users in multiple permission related screens.

* Issue **{{< external-link "#4659" "https://github.com/gchq/stroom/issues/4659" >}}** : Fix refresh selection changes after adding/removing users to/from groups.

* Issue **{{< external-link "#4594" "https://github.com/gchq/stroom/issues/4594" >}}** : Various changes to the permissions screens. Added a new User screen to show all a user's permissions, api keys, and dependencies. Added links between the various permission and user screens. Improved the tables of some of the permissions screens.

* Fix `java.lang.NoClassDeffoundError: jakarta/el/ELManager` error when booting proxy.

* Fix error when creating a document as a user without `Administrator` or `Manager Users`.

* Issue **{{< external-link "#4588" "https://github.com/gchq/stroom/issues/4588" >}}** : Fix the API allowing documents to be moved with only VIEW permission. The UI requires EDIT permission. The API is now in line with that.

* Fix the `Copy As` menu item for ancestor folders that the user does not have VIEW permission on. For these cases, the `Copy As` sub menu now only displays the `Copy as name` entry.

* Change the explorer context menu to include the entries for `Dependencies` and `Dependants` if the user has at least VIEW permission. Previously required OWNER.

* Issue **{{< external-link "#4586" "https://github.com/gchq/stroom/issues/4586" >}}** : Fix error when changing filter on Document Permissions Report.

* Make account creation also create a stroom user. Make an update to an account also update the stroom user if the full name has changed.

* Fix bug in DB migration `V07_06_00_100__annotation_pre_migration_checks`.

* If you are upgrading from a previous v7.6 beta release you will need to run the following SQL. `update analytics_schema_history set checksum = '-86554219' where version = '07.06.00.405';` and `update processor_schema_history set checksum = '-175036745' where version = '07.06.00.305';`.

* Issue **{{< external-link "#4550" "https://github.com/gchq/stroom/issues/4550" >}}** : Fix datasource already in use issue.

* Uplift docker image JDK to `eclipse-temurin:21.0.5_11-jdk-alpine`.

* Issue **{{< external-link "#4580" "https://github.com/gchq/stroom/issues/4580" >}}** : Auto add a permission user when an account is created.

* Issue **{{< external-link "#4582" "https://github.com/gchq/stroom/issues/4582" >}}** : Show all users by default and not just ones with explicit permissions.

* Issue **{{< external-link "#4345" "https://github.com/gchq/stroom/issues/4345" >}}** : Write analytic email notification failures to the analytic error feed.

* Issue **{{< external-link "#4379" "https://github.com/gchq/stroom/issues/4379" >}}** : Improve Stroom permission model.

For a detailed list of all the changes in v7.6 see:
{{< external-link "v7.6 CHANGELOG" "https://github.com/gchq/stroom/blob/7.6/CHANGELOG.md" >}} 
