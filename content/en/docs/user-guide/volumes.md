---
title: "Volumes"
linkTitle: "Volumes"
weight: 170
date: 2021-07-27
tags:
  - volume
description: >
  Stroom's logical storage volumes for storing event and index data.
---

{{< todo >}}
Describe volumes
{{< /todo >}}


## Index Volumes

An index volume is where the shards of Lucene indexes are written.
Every index volume belongs to a {{< glossary "Volume Group" >}}, and an index is set to use a volume group.
Index volumes are managed from the main menu:

{{< stroom-menu "Administration" "Index Volumes" >}}

An index volume has a _Type_:

* **Local** - A disk that only one node can see.
  The volume belongs to that node, and only that node can search or write to its shards.
* **Shared** - One mount that every node can see.
  The volume has no node, and any node can search or write to its shards.

See [Shared Index Volumes]({{< relref "docs/user-guide/indexing/shared-index-volumes" >}}).
