---
title: "XSLT Functions"
linkTitle: "XSLT Functions"
#weight:
date: 2025-09-24
tags: 
description: >
    A reference of all custom XSLT functions available in Stroom.
---

Stroom has a number of built in custom XSLT functions that can be called from within the {{< pipe-elm "XSLTFilter" >}} [pipeline]({{< relref "docs/user-guide/pipelines" >}}) element.
These functions provide additional capabilities and access to data held in Stroom.


## Using Stroom XSLT Functions

To use a Stroom custom XSLT function you need to add the `xmlns:stroom="stroom"` namespace declaration to the XSLT document.
The convention is to use the namespace prefix `stroom` to make it clear that function calls are to a Stroom built-in function, but
any prefix can be used.

```xml
<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:stroom="stroom"
  xmlns="event-logging:3"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  ...>
```

The following is an example of calling the `hash` custom XSLT function to produce a hash of the username value.

```xml
  <xsl:template match="/record">
    <HashedUser>
      <xsl:value-of select="stroom:hash(data[@name='username']/@value, 'SHA-256')"/>
    </HashedUser>
  </xsl:template>
```

## Return values

XSLT functions can return the following data types:

* Boolean - True/false.
* Date - A date value (`xs:date`).
* Date-Time - A date and time value (`xs:datetime`).
* Decimal - A decimal or floating point value (`xs:decimal`).
* Integer - A number with no decimal part (`xs:integer`).
* String - A simple string value (`xs:string`).
* Sequence - Any sequence of nodes or atomic values, e.g. a single node, a list of nodes or a list of strings.

## Functions

{{< cardpane >}}

  {{< card header="Conversion Functions" >}}
  * [hash](conversion#hash)
  {{< /card >}}

  {{< card header="Date Functions" >}}
  * [](date#)
  {{< /card >}}

  {{< card header="Network Functions" >}}
  * [](network#)
  {{< /card >}}

  {{< card header="Other Functions" >}}
  * [](other#)
  {{< /card >}}

{{< /cardpane >}}

{{< cardpane >}}

  {{< card header="Stroom Pipeline Functions" >}}
  * [](pipeline#)
  {{< /card >}}

  {{< card header="String Functions" >}}
  * [](string#)
  {{< /card >}}

  {{< card header="URI Functions" >}}
  * [](uri#)
  {{< /card >}}

  {{< card header="Value Functions" >}}
  * [random](value#random)
  {{< /card >}}

{{< /cardpane >}}
