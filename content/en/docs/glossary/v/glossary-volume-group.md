---
title: "Volume group"
linkTitle: "Volume group"
description: >
  A Volume Group is a collection of one or more Index Volumes.
  Index volumes must belong to a volume group and Indexes are configured to write to a particular Volume Group.
---

When Stroom is writing data to a Volume Group it will choose which of the Volumes in the group to write to using a volume selector as configured by the {{< glossary "Property" >}} `stroom.volumes.volumeSelector`.

{{% see-also %}}
{{< glossary "Volume" >}}:w
[User Guide]({{< relref "docs/user-guide/volumes" >}})
{{% /see-also %}}

