---
title: "Conversion Functions"
linkTitle: "Conversion Functions"
#weight:
date: 2025-09-25
tags: 
description: >
  Functions for converting a value from one form to another, e.g. hexToString. 
---

<!-- 
The xslt-func shortcode outputs all the XsltFunctionDef annotation content for the function.
You can add any additional content for the function (e.g. examples) underneath the shortcode call.
-->

## hash
{{< xslt-func "hash" >}}


## hex-to-dec

{{< xslt-func "hex-to-dec" >}}


## hex-to-oct

{{< xslt-func "hex-to-oct" >}}


## hex-to-string

{{< xslt-func "hex-to-string" >}}


### Example

**XSLT:**

```xml
<string><xsl:value-of select="stroom:hex-to-string('74 65 73 74 69 6e 67 20 31 32 33', 'UTF-8')" /></string>
```

**XML:**

```xml
<string>testing 123</string>
```


## json-to-xml

{{< xslt-func "json-to-xml" >}}

