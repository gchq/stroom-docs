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

* _Boolean_ - True/false.
* _Date_ - A date value (`xs:date`).
* _Date-Time_ - A date and time value (`xs:datetime`).
* _Decimal_ - A decimal or floating point value (`xs:decimal`).
* _Integer_ - A number with no decimal part (`xs:integer`).
* _String_ - A simple string value (`xs:string`).
* _Sequence_ - Any sequence of nodes or atomic values, e.g. a single node, a list of nodes or a list of strings.


## Functions

The following table lists all the Stroom XSLT functions.

<!-- This generates a table of all the functions and their categories ordered by func name -->
{{< xslt-functions-table >}}

