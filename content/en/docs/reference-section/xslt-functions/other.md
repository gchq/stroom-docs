---
title: "Other Functions"
linkTitle: "Other Functions"
#weight:
date: 2025-09-25
tags: 
description: >
  Functions that don't fit into any other category. 
---

<!-- 
The xslt-func shortcode outputs all the XsltFunctionDef annotation content for the function.
You can add any additional content for the function (e.g. examples) underneath the shortcode call.
-->

## ask-ai

{{< xslt-func "ask-ai" >}}


## cosine-similarity

{{< xslt-func "cosine-similarity" >}}


### Example

**XSLT:**

```xml
<xsl:variable name="a" select="(1, 0, 1)" as="xs:double*" />
<xsl:variable name="b" select="(1, 1, 1)" as="xs:double*" />
<Similarity><xsl:value-of select="stroom:cosine-similarity($a, $b)" /></Similarity>
```

**XML:**

```xml
<Similarity>0.8164965809277259</Similarity>
```



## pointIsInsideXYPolygon

{{< xslt-func "pointIsInsideXYPolygon" >}}

<!-- TODO add example XSLT -->


## split-document

{{< xslt-func "split-document" >}}
