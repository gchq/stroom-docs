---
title: "Namespace"
linkTitle: "Namespace"
description: >
  In Stroom _Namespace_ typically refers to an _XML Namespace_.
  Namespaces are used in XML to distinguish different elements, e.g. where an _XSLT_ is transforming XML in the `records:2` _Namespace_ into XML in the `event-logging:3` _Namespace_.
---

An XSLT will define short aliases for _Namespaces_ to make them easier to reference within the XSLT document.
For example, in this snippet of an XML document, the aliases are: `stroom`, `evt`, `xsl`, `xsi`.

```xml
<xsl:stylesheet
  xmlns="event-logging:3"
  xpath-default-namespace="records:2"
  xmlns:stroom="stroom"
  xmlns:evt="event-logging:3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  version="2.0">
```

{{% see-also %}}
* {{< external-link "XML Namespace" "https://www.w3schools.com/xml/xml_namespaces.asp" >}}
* {{< glossary "XSLT" >}}
{{% /see-also %}}

