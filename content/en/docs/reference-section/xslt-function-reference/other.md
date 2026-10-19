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


## `ask-ai`

{{< xslt-func "ask-ai" >}}

You must hold the `Use` permission on the model document.
Where the model cannot be found, or you do not have permission to use it, a warning is recorded against the stream and an empty sequence is returned.


### Performance

{{< warning >}}
The model is asked once per call, so a pipeline that calls this for every record will make one request per record, each of which may take seconds or longer.
Consider whether the question really needs asking of every record.
{{< /warning >}}

Repeated identical questions are served from a cache rather than being asked again, so calling this with the same model, message and system prompt costs one request however many records ask it.
The cache is configured by the `chatResponseCache` property of the `ai` configuration branch.
Setting its `maximumSize` to `0` asks the model every time.


### Examples

Asking a model to classify a value.

```xml
<xsl:variable name="answer"
              select="stroom:ask-ai('Event Classifier', concat('Is this user agent a bot? Answer yes or no. ', UserAgent))"/>
```

Giving the model a role with a system prompt.

```xml
<xsl:variable name="answer"
              select="stroom:ask-ai(
                  'Event Classifier',
                  Description,
                  'You are a security analyst. Answer in one short sentence.')"/>
```

{{< see-also >}}
* {{< xslt-func-link "split-document" >}} for breaking a large document into chunks that fit a model's context window.
* {{< xslt-func-link "cosine-similarity" >}} for comparing embeddings.
{{< /see-also >}}


## `cosine-similarity`

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


## `pointIsInsideXYPolygon`

{{< xslt-func "pointIsInsideXYPolygon" >}}

<!-- TODO add example XSLT -->


## `send-email`

{{< xslt-func "send-email" >}}


## `split-document`

{{< xslt-func "split-document" >}}
