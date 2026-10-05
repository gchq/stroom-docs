---
title: "Expression tree"
linkTitle: "Expression tree"
description: >
  A tree of expression terms that each evaluate to a boolean (True/False) value.
  Terms can be grouped together within an expression operator (AND, OR, NOT).
---

For example:

```text
AND (
  Feed is CSV_FEED
  Type = Raw Events
)
```

Expression Trees are used in {{< glossary "Processor Filter" "Processor Filters" >}} and {{< glossary "Query" >}} expressions.

{{% see-also %}}
* {{< glossary "Query">}}
* [Expression functions]({{< relref "docs/reference-section/expressions" >}})
{{% /see-also %}}
