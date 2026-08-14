---
title: "Maths & Vectors"
linkTitle: "Maths & Vectors"
weight: 90
date: 2026-08-14
tags:
  - xslt
description: >
  XSLT functions for maths and vectors.
---

## cosine-similarity()

Returns the cosine similarity of two numeric vectors, i.e. a value between `-1` and `1` describing how closely the two vectors point in the same direction.
It is intended for comparing sets of embeddings produced by a large language model.

```text
cosine-similarity(Number[] vectorA, Number[] vectorB)
```

* `vectorA` - A sequence of numbers.
* `vectorB` - A sequence of numbers, of the same length as `vectorA`.

Both vectors must have the same number of elements, otherwise an error is raised.
If either vector has a magnitude of zero then `0` is returned.

```xml
<xsl:variable name="a" select="(1, 0, 1)" as="xs:double*" />
<xsl:variable name="b" select="(1, 1, 1)" as="xs:double*" />
<Similarity><xsl:value-of select="stroom:cosine-similarity($a, $b)" /></Similarity>
```

```xml
<Similarity>0.8164965809277259</Similarity>
```


## pointIsInsideXYPolygon()

Returns true if the specified point is inside the specified polygon.
Useful for determining if a user is inside a physical zone based on their location and the boundary of that zone.

```text
pointIsInsideXYPolygon(Number xPos, Number yPos, Number[] xPolyData, Number[] yPolyData)
```

Arguments:

* `xPos` - The X value of the point to be tested.
* `yPos` - The Y value of the point to be tested.
* `xPolyData` - A sequence of X values that define the polygon.
* `yPolyData` - A sequence of Y values that define the polygon.

The list of values supplied for `xPolyData` must correspond with the list of values supplied for `yPolyData`.
The points that define the polygon must be provided in order, i.e. starting from one point on the polygon and then travelling round the path of the polygon until it gets back to the beginning.

<!-- TODO add example XSLT -->


## split-document()

Split a document for LLM tokenisation (experimental).

```text
split-document(String doc, Number segmentSize, Number overlapSize)
```
