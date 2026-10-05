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
  * [`hash`]({{< relref "conversion#hash" >}})
  * [`hex-to-dec`]({{< relref "conversion#hex-to-dec" >}})
  * [`hex-to-oct`]({{< relref "conversion#hex-to-oct" >}})
  * [`hex-to-string`]({{< relref "conversion#hex-to-string" >}})
  * [`json-to-xml`]({{< relref "conversion#json-to-xml" >}})
  {{< /card >}}

  {{< card header="Date Functions" >}}
  * [`current-time`]({{< relref "date#current-time" >}})
  * [`current-unixTime`]({{< relref "date#current-unixTime" >}})
  * [`format-dateTime`]({{< relref "date#format-dateTime" >}})
  * [`format-date`]({{< relref "date#format-date" >}})
  * [`from-unixTime`]({{< relref "date#from-unixTime" >}})
  * [`parse-dateTime`]({{< relref "date#parse-dateTime" >}})
  * [`to-unixTime`]({{< relref "date#to-unixTime" >}})
  {{< /card >}}

  {{< card header="String Functions" >}}
  * [`link`]({{< relref "string#link" >}})
  {{< /card >}}

{{< /cardpane >}}

{{< cardpane >}}

  {{< card header="Value Functions" >}}
  * [`current-user`]({{< relref "value#current-user" >}})
  * [`random-integer`]({{< relref "value#random-integer" >}})
  * [`random`]({{< relref "value#random" >}})
  {{< /card >}}

  {{< card header="URI Functions" >}}
  * [`decode-url`]({{< relref "uri#decode-url" >}})
  * [`encode-url`]({{< relref "uri#encode-url" >}})
  * [`parse-uri`]({{< relref "uri#parse-uri" >}})
  {{< /card >}}

  {{< card header="Network Functions" >}}
  * [`cidr-to-numeric-ip-range`]({{< relref "network#cidr-to-numeric-ip-range" >}})
  * [`fetch-json`]({{< relref "network#fetch-json" >}})
  * [`host-address`]({{< relref "network#host-address" >}})
  * [`host-name`]({{< relref "network#host-name" >}})
  * [`http-call`]({{< relref "network#http-call" >}})
  * [`ip-in-cidr`]({{< relref "network#ip-in-cidr" >}})
  * [`numeric-ip`]({{< relref "network#numeric-ip" >}})
  {{< /card >}}

{{< /cardpane >}}

{{< cardpane >}}

  {{< card header="Stroom Pipeline Functions" >}}
  * [`add-meta`]({{< relref "pipeline#add-meta" >}})
  * [`bitmap-lookup`]({{< relref "pipeline#bitmap-lookup" >}})
  * [`classification`]({{< relref "pipeline#classification" >}})
  * [`col-from`]({{< relref "pipeline#col-from" >}})
  * [`col-to`]({{< relref "pipeline#col-to" >}})
  * [`dictionary`]({{< relref "pipeline#dictionary" >}})
  * [`feed-name`]({{< relref "pipeline#feed-name" >}})
  * [`get`]({{< relref "pipeline#get" >}})
  * [`line-from`]({{< relref "pipeline#line-from" >}})
  * [`line-to`]({{< relref "pipeline#line-to" >}})
  * [`log`]({{< relref "pipeline#log" >}})
  * [`lookup`]({{< relref "pipeline#lookup" >}})
  * [`manifest`]({{< relref "pipeline#manifest" >}})
  * [`meta-attribute`]({{< relref "pipeline#meta-attribute" >}})
  * [`meta-keys`]({{< relref "pipeline#meta-keys" >}})
  * [`meta-stream`]({{< relref "pipeline#meta-stream" >}})
  * [`meta`]({{< relref "pipeline#meta" >}})
  * [`parent-for-id`]({{< relref "pipeline#parent-for-id" >}})
  * [`parent-id`]({{< relref "pipeline#parent-id" >}})
  * [`part-no`]({{< relref "pipeline#part-no" >}})
  * [`pipeline-name`]({{< relref "pipeline#pipeline-name" >}})
  * [`put`]({{< relref "pipeline#put" >}})
  * [`record-no`]({{< relref "pipeline#record-no" >}})
  * [`search-id`]({{< relref "pipeline#search-id" >}})
  * [`source-id`]({{< relref "pipeline#source-id" >}})
  * [`source`]({{< relref "pipeline#source" >}})
  {{< /card >}}

  {{< card header="Other Functions" >}}
  * [`ask-ai`]({{< relref "other#ask-ai" >}})
  * [`cosine-similarity`]({{< relref "other#cosine-similarity" >}})
  * [`pointIsInsideXYPolygon`]({{< relref "other#pointIsInsideXYPolygon" >}})
  * [`split-document`]({{< relref "other#split-document" >}})
  {{< /card >}}

{{< /cardpane >}}


