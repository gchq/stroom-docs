---
title: "XSLT Functions"
linkTitle: "XSLT Functions"
weight: 20
date: 2026-08-14
tags:
  - xslt
description: >
  Custom XSLT functions available in Stroom.
---

Stroom provides a set of custom functions for use in your XSLT translations.
To use them, include the `stroom` namespace in your stylesheet:

```xml
xmlns:stroom="stroom"
```

E.g.

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet
    xmlns="event-logging:3"
    xmlns:stroom="stroom"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="2.0">
```

A function is then called with that prefix, e.g. `stroom:format-date(...)`.

The functions are grouped as follows.

{{< cardpane >}}
  {{< card header="Date & Time" >}}
  * [`current-time()`](date-and-time#current-time)
  * [`current-unixTime()`](date-and-time#current-unixtime)
  * [`format-date()`](date-and-time#format-date)
  * [`format-dateTime()`](date-and-time#format-datetime)
  * [`from-unixTime()`](date-and-time#from-unixtime)
  * [`parse-dateTime()`](date-and-time#parse-datetime)
  * [`to-unixTime()`](date-and-time#to-unixtime)
  {{< /card >}}

  {{< card header="Reference Data" >}}
  * [`bitmap-lookup()`](reference-data#bitmap-lookup)
  * [`dictionary()`](reference-data#dictionary)
  * [`lookup()`](reference-data#lookup)
  {{< /card >}}

  {{< card header="Stream & Source" >}}
  * [`classification()`](stream-and-source#classification)
  * [`col-from()`](stream-and-source#col-from)
  * [`col-to()`](stream-and-source#col-to)
  * [`feed-attribute()`](stream-and-source#feed-attribute)
  * [`feed-name()`](stream-and-source#feed-name)
  * [`line-from()`](stream-and-source#line-from)
  * [`line-to()`](stream-and-source#line-to)
  * [`manifest()`](stream-and-source#manifest)
  * [`manifest-for-id()`](stream-and-source#manifest-for-id)
  * [`meta()`](stream-and-source#meta)
  * [`meta-attribute()`](stream-and-source#meta-attribute)
  * [`meta-keys()`](stream-and-source#meta-keys)
  * [`meta-stream()`](stream-and-source#meta-stream)
  * [`meta-stream-for-id()`](stream-and-source#meta-stream-for-id)
  * [`parent-for-id()`](stream-and-source#parent-for-id)
  * [`parent-id()`](stream-and-source#parent-id)
  * [`part-no()`](stream-and-source#part-no)
  * [`record-no()`](stream-and-source#record-no)
  * [`source()`](stream-and-source#source)
  * [`source-id()`](stream-and-source#source-id)
  * [`stream-id()`](stream-and-source#stream-id)
  {{< /card >}}

{{< /cardpane >}}

{{< cardpane >}}
  {{< card header="Networking & URI" >}}
  * [`cidr-to-numeric-ip-range()`](networking-and-uri#cidr-to-numeric-ip-range)
  * [`host-address()`](networking-and-uri#host-address)
  * [`host-name()`](networking-and-uri#host-name)
  * [`ip-in-cidr()`](networking-and-uri#ip-in-cidr)
  * [`numeric-ip()`](networking-and-uri#numeric-ip)
  * [`parse-uri()`](networking-and-uri#parse-uri)
  {{< /card >}}

  {{< card header="String & Encoding" >}}
  * [`decode-url()`](string-and-encoding#decode-url)
  * [`encode-url()`](string-and-encoding#encode-url)
  * [`hash()`](string-and-encoding#hash)
  * [`hex-to-dec()`](string-and-encoding#hex-to-dec)
  * [`hex-to-oct()`](string-and-encoding#hex-to-oct)
  * [`hex-to-string()`](string-and-encoding#hex-to-string)
  {{< /card >}}

  {{< card header="HTTP & JSON" >}}
  * [`fetch-json()`](http-and-json#fetch-json)
  * [`http-call()`](http-and-json#http-call)
  * [`json-to-xml()`](http-and-json#json-to-xml)
  {{< /card >}}

{{< /cardpane >}}

{{< cardpane >}}
  {{< card header="Output & Logging" >}}
  * [`add-meta()`](output-and-logging#add-meta)
  * [`link()`](output-and-logging#link)
  * [`log()`](output-and-logging#log)
  {{< /card >}}

  {{< card header="Values & Context" >}}
  * [`current-user()`](values-and-context#current-user)
  * [`get()`](values-and-context#put-and-get)
  * [`pipeline-name()`](values-and-context#pipeline-name)
  * [`put()`](values-and-context#put-and-get)
  * [`random()`](values-and-context#random)
  * [`search-id()`](values-and-context#search-id)
  {{< /card >}}

  {{< card header="Maths & Vectors" >}}
  * [`cosine-similarity()`](maths-and-vectors#cosine-similarity)
  * [`pointIsInsideXYPolygon()`](maths-and-vectors#pointisinsidexypolygon)
  * [`split-document()`](maths-and-vectors#split-document)
  {{< /card >}}

  {{< card header="AI" >}}
  * [`ask-ai()`](ai#ask-ai)
  {{< /card >}}

{{< /cardpane >}}
