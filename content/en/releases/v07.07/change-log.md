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

* Issue **{{< external-link "#4690" "https://github.com/gchq/stroom/issues/4690" >}}** : Fix meta data source fields.

* Issue **{{< external-link "#4691" "https://github.com/gchq/stroom/issues/4691" >}}** : Fix meta data source fields.

* Issue **{{< external-link "#4701" "https://github.com/gchq/stroom/issues/4701" >}}** : Fix selection filter null component.

* Issue **{{< external-link "#4698" "https://github.com/gchq/stroom/issues/4698" >}}** : Fix default S3 Appender options.

* Issue **{{< external-link "#4686" "https://github.com/gchq/stroom/issues/4686" >}}** : StroomQL now uses `stroom.ui.defaultMaxResults` if no `LIMIT` is set.

* Issue **{{< external-link "#4696" "https://github.com/gchq/stroom/issues/4696" >}}** : Fix paging of large numbers of data sources.

* Issue **{{< external-link "#4672" "https://github.com/gchq/stroom/issues/4672" >}}** : Add right click menu to copyable items.

* Issue **{{< external-link "#4719" "https://github.com/gchq/stroom/issues/4719" >}}** : Fix duplicate pipeline dependencies per user due to multiple processor filters.

* Issue **{{< external-link "#4728" "https://github.com/gchq/stroom/issues/4728" >}}** : No longer treat deleted pipeline filters as dependencies.

* Issue **{{< external-link "#4707" "https://github.com/gchq/stroom/issues/4707" >}}** : Fix doc ref info service.

* Issue **{{< external-link "#4713" "https://github.com/gchq/stroom/issues/4713" >}}** : Fix datasource in use issue for API key DAO.

* Issue **{{< external-link "#4714" "https://github.com/gchq/stroom/issues/4714" >}}** : Fix display of disabled `RunAs` users.

* Issue **{{< external-link "#4708" "https://github.com/gchq/stroom/issues/4708" >}}** : Add copy links to stream info pane.

* Issue **{{< external-link "#4687" "https://github.com/gchq/stroom/issues/4687" >}}** : Fix dependencies NPE.

* Issue **{{< external-link "#4717" "https://github.com/gchq/stroom/issues/4717" >}}** : Fix processor filter expression fields.

* Issue **{{< external-link "#4652" "https://github.com/gchq/stroom/issues/4652" >}}** : Add user links to server tasks and search results lists.

* Issue **{{< external-link "#4669" "https://github.com/gchq/stroom/issues/4669" >}}** : Make user dependency list document column resizable.

* Issue **{{< external-link "#4685" "https://github.com/gchq/stroom/issues/4685" >}}** : Fix doc permission layout.

* Issue **{{< external-link "#4705" "https://github.com/gchq/stroom/issues/4705" >}}** : Fix conditional format fall through.

* Issue **{{< external-link "#4672" "https://github.com/gchq/stroom/issues/4672" >}}** : Add context menus to table cells to copy values.

* Issue **{{< external-link "#4632" "https://github.com/gchq/stroom/issues/4632" >}}** : Fix conditional formatting rule id clash.

* Issue **{{< external-link "#4655" "https://github.com/gchq/stroom/issues/4655" >}}** : Allow selection of no conditional style.

* Issue **{{< external-link "#4632" "https://github.com/gchq/stroom/issues/4632" >}}** : Fix conditional formatting rule id clash.

* Issue **{{< external-link "#4657" "https://github.com/gchq/stroom/issues/4657" >}}** : Fix middle pane stream delete.

* Issue **{{< external-link "#4660" "https://github.com/gchq/stroom/issues/4660" >}}** : Show pipelines and rules on processor and task panes.

* Issue **{{< external-link "#4632" "https://github.com/gchq/stroom/issues/4632" >}}** : Fix conditional formatting styles.

* Issue **{{< external-link "#4634" "https://github.com/gchq/stroom/issues/4634" >}}** : Make icons on highlighted rows white.

* Issue **{{< external-link "#4605" "https://github.com/gchq/stroom/issues/4605" >}}** : Allow embedded queried to be re-run independently.

* Issue **{{< external-link "#4631" "https://github.com/gchq/stroom/issues/4631" >}}** : Fix simple expression wildcards.

* Issue **{{< external-link "#4641" "https://github.com/gchq/stroom/issues/4641" >}}** : Reset selections when dashboard table data changes.

* Issue **{{< external-link "#4642" "https://github.com/gchq/stroom/issues/4642" >}}** : Show current dashboard selections to help create selection filters.

* Issue **{{< external-link "#4637" "https://github.com/gchq/stroom/issues/4637" >}}** : Fix StroomQL filter in dictionary.

* Issue **{{< external-link "#4645" "https://github.com/gchq/stroom/issues/4645" >}}** : Add feature to disable notifications.

* Issue **{{< external-link "#4596" "https://github.com/gchq/stroom/issues/4596" >}}** : Add case-sensitive value filter conditions.

* Issue **{{< external-link "#4596" "https://github.com/gchq/stroom/issues/4596" >}}** : Drive visualisations using table quick filters and selection handlers.

* Issue **{{< external-link "#4596" "https://github.com/gchq/stroom/issues/4596" >}}** : Merge include/exclude and column value filter dialogs.

* Issue **{{< external-link "#4596" "https://github.com/gchq/stroom/issues/4596" >}}** : Change conditional formatting to allow custom light and dark colours.

* Issue **{{< external-link "#4596" "https://github.com/gchq/stroom/issues/4596" >}}** : Turn off conditional formatting with user preferences.

* Issue **{{< external-link "#4601" "https://github.com/gchq/stroom/issues/4601" >}}** : Add null handling and better error logging to Excel download.

* Issue **{{< external-link "#4597" "https://github.com/gchq/stroom/issues/4597" >}}** : Fix NPE when opening the Document Permissions Report screen for a user.

* Change the code that counts expression terms and gets all fields/values from an expression tree to no longer ignore NOT operators.

* Issue **{{< external-link "#4596" "https://github.com/gchq/stroom/issues/4596" >}}** : Fix demo bugs.

* Issue **{{< external-link "#4596" "https://github.com/gchq/stroom/issues/4596" >}}** : Add table value filter dialog option.

* Change the permission filtering to use a LinkedHashSet for children of and descendants of terms.

* Issue **{{< external-link "#4523" "https://github.com/gchq/stroom/issues/4523" >}}** : Embed queries in dashboards.

* Issue **{{< external-link "#4504" "https://github.com/gchq/stroom/issues/4504" >}}** : Add column value filters.

* Issue **{{< external-link "#4546" "https://github.com/gchq/stroom/issues/4546" >}}** : Remove redundant dashboard tab options.

* Issue **{{< external-link "#4547" "https://github.com/gchq/stroom/issues/4547" >}}** : Add selection handlers to dashboard tables to quick filter based on component selection.

* Issue **{{< external-link "#4071" "https://github.com/gchq/stroom/issues/4071" >}}** : Add preset theme compatible styles for conditional formatting.

* Issue **{{< external-link "#4157" "https://github.com/gchq/stroom/issues/4157" >}}** : Fix copy of conditional formatting rules.

