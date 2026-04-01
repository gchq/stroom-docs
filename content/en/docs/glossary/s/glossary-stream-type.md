---
title: "Stream type"
linkTitle: "Stream type"
description: >
  All _Streams_ must have a Stream Type.
  The list of Stream Types is configured using the {{< glossary "Property" >}} `stroom.data.meta.metaTypes`.
---

Additional Stream Types can be added however the list of Stream Types must include the following built-in types:

* Context
* Error
* {{< glossary "Events" >}}
* Meta
* {{< glossary "Raw Events" >}}
* Raw Reference
* Reference

Some Stream Types, such as `Meta` and `Context` only exist as [child streams]({{< relref "docs/user-guide/concepts/streams#child-stream-types" >}}) within another Stream.

{{% see-also %}}
[Streams Concept]({{< relref "docs/user-guide/concepts/streams" >}})
{{< glossary "Events" >}}
{{< glossary "Raw Events" >}}
{{% /see-also %}}

