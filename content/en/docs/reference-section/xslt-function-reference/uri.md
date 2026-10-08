---
title: "URI/URL Functions"
linkTitle: "URI Functions"
#weight:
date: 2025-09-25
tags: 
description: >
  Functions relating to parsing and manipulating URI/URLs. 
---

<!-- 
The xslt-func shortcode outputs all the XsltFunctionDef annotation content for the function.
You can add any additional content for the function (e.g. examples) underneath the shortcode call.
-->

## decode-url

{{< xslt-func "decode-url" >}}


## encode-url

{{< xslt-func "encode-url" >}}


## parse-uri

{{< xslt-func "parse-uri" >}}


{{% see-also %}}
See either [RFC 2306: Uniform Resource Identifiers (URI): Generic Syntax](http://www.ietf.org/rfc/rfc2396.txt) or Java's java.net.URI Class for details regarding the components.
{{% /see-also %}}


### Example Usage

Given that `rURI` contains the following text:

```text
http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&amp;p2=v2#more-details
```

**XSLT:**

```xml
<!-- Display and parse the URI contained within the text of the rURI element -->
<xsl:variable name="uri" select="stroom:parse-uri(rURI)" />

<URI>
  <xsl:value-of select="rURI" />
</URI>
<URIDetail>
  <xsl:copy-of select="$uri"/>
</URIDetail>
```

**XML:**

```xml
<URI>http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&amp;p2=v2#more-details</URI>
<URIDetail>
  <authority xmlns="uri">foo:bar@w1.superman.com:8080</authority>
  <fragment xmlns="uri">more-details</fragment>
  <host xmlns="uri">w1.superman.com</host>
  <path xmlns="uri">/very/long/path.html</path>
  <port xmlns="uri">8080</port>
  <query xmlns="uri">p1=v1&amp;p2=v2</query>
  <scheme xmlns="uri">http</scheme>
  <schemeSpecificPart xmlns="uri">//foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&amp;p2=v2</schemeSpecificPart>
  <userInfo xmlns="uri">foo:bar</userInfo>
</URIDetail>
```
