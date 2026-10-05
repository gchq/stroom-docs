---
title: "Event"
linkTitle: "Event"
description: >
  An event is a single auditable event, e.g. a user logging in to a system.
  A _Stream_ typically contains multiple events.
---

In a {{< glossary "Raw Events" >}} an event is typically represented as block of XML or JSON, a single line for CSV data.
In an {{< glossary "Events" >}} {{< glossary "Stream" >}} an event is identified by its `Event ID` which its position in that stream (as a one-based number).
The `Event ID` combined with a `Stream ID` provide a unique identifier for an event within a Stroom instance.

{{% see-also %}}
* {{< glossary "Stream">}}
* {{< glossary "Raw Events">}}
* {{< glossary "Events">}}
{{% /see-also %}}
