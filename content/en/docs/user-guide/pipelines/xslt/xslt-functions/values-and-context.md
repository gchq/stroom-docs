---
title: "Values & Context"
linkTitle: "Values & Context"
weight: 80
date: 2026-08-14
tags:
  - xslt
description: >
  XSLT functions for values and context.
---

## current-user()

Returns the identity of the user that Stroom is processing as.
This is only meaningful for interactive use, e.g. a search, rather than for background stream processing.

```text
current-user()
current-user(String form)
```

The optional `form` argument selects which form of the user's identity is returned.

| `form` | Returns |
| --- | --- |
| `display` | The user's display name, falling back to their subject identifier if they have none. This is the value Stroom uses for auditing, and is the default. |
| `subject` | The unique subject identifier for the user, as supplied by the identity provider. |
| `full` | The user's full name, or an empty string if they do not have one. |

If `form` is omitted, empty or not one of the above values then `display` is used.


## pipeline-name()

Get the name of the pipeline currently processing the stream.

```text
pipeline-name()
```


## put() and get()

You can put values into a map using the `put()` function.
These values can then be retrieved later using the `get()` function.
Values are stored against a key name so that multiple values can be stored.
These functions can be used for many purposes but are most commonly used to count a number of records that meet certain criteria.

The map is in the scope of the current pipeline process so values do not live after the stream has been processed.
Also, the map will only contain entries that were `put()` within the current pipeline process.

An example of how to count records is shown below:

```xml
<!-- Get the current record count -->
<xsl:variable name="currentCount" select="number(stroom:get('count'))" />

<!-- Increment the record count -->
<xsl:variable name="count">
  <xsl:choose>
    <xsl:when test="$currentCount">
      <xsl:value-of select="$currentCount + 1" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="1" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Store the count for future retrieval -->
<xsl:value-of select="stroom:put('count', $count)" />

<!-- Output the new count -->
<data name="Count">
  <xsl:attribute name="Value" select="$count" />
</data>
```


## random()

Get a system generated random number between 0 and 1.

```text
random()
```


## search-id()

Get the id of the batch search when a pipeline is processing as part of a batch search

```text
search-id()
```
