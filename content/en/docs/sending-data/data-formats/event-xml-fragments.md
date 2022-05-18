---
title: "Event XML Fragments"
linkTitle: "Event XML Fragments"
#weight:
date: 2022-05-17
tags: 
  - xml
  - event
  - fragment
description: >
  Description of the Event XML Fragments
---

This format is a file containing multiple `<Event>...</Event>` element blocks but without any root element, or any XML processing instruction.
For example, a file may look like:

```xml
<Event>
  ...
</Event>
<Event>
  ...
</Event>
<Event>
  ...
</Event>
```

Each `<Evemt>` element is valid against the _event-logging_ XML Schema but the file is not as it contains no root element.
This is the output format used by the [_event-logging_ Java library]({{< relref "../example-clients/event-logging" >}}).
