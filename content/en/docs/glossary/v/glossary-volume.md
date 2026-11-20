---
title: "Volume"
linkTitle: "Volume"
description: >
  In Stroom a Volume is a logical storage area that Stroom can write data to.
  Volumes are associated with a path on a file system that can either be local to the Stroom node or on a shared file system.
---

Stroom has two types of Volume; Index Volumes and Data Volumes.

* _Index Volume_ - Where the Lucene Index Shards are written to.
  An Index Volume must belong to a {{< glossary "Volume Group" >}}.
  An Index Volume is either _Local_, a disk that only one node can see, or _Shared_, one mount that every node can see.
  Any node can search or write to the Index Shards on a Shared Index Volume.
* _Data Volume_ - Where streams are written to.
  When writing {{< glossary "Stream" >}} data Stroom will pick a data volume using a volume selector as configured by the {{< glossary "Property" >}} `stroom.data.filesystemVolume.volumeSelector`.

{{< see-also >}}
{{< glossary "Volume Group" >}}
[User Guide]({{< relref "docs/user-guide/volumes" >}})
[Shared Index Volumes]({{< relref "docs/user-guide/indexing/shared-index-volumes" >}})
{{< /see-also >}}


