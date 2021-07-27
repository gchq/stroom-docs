---
title: "XML Fragments"
linkTitle: "XML Fragments"
#weight:
date: 2021-07-27
tags: 
description: >
  Handling XML data without root level elements.
---

Some input XML data may be missing an XML declaration and root level enclosing elements.
This data is not a valid XML document and must be treated as an XML fragment.
To use XML fragments the input type for a translation must be set to 'XML Fragment'.
A fragment wrapper must be defined in the XML conversion that tells Stroom what declaration and root elements to place around the XML fragment data.

Here is an example:

```xml
<?xml version="1.1" encoding="UTF-8"?>
<!DOCTYPE records [
<!ENTITY fragment SYSTEM "fragment">
]>
<records
  xmlns="records:2"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="records:2 file://records-v2.0.xsd"
  version="2.0">
  &fragment;
</records>
```

During conversion Stroom replaces the fragment text entity with the input XML fragment data.
Note that XML fragments must still be well formed so that they can be parsed correctly.
