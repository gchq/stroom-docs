---
title: "Stream & Source"
linkTitle: "Stream & Source"
weight: 20
date: 2026-08-14
tags:
  - xslt
description: >
  XSLT functions for stream and source.
---

## classification()

The classification of the feed for the data being processed

```text
classification()
```


## col-from()

The column in the input that the current record begins on (can be 0).

```text
col-from()
```


## col-to()

The column in the input that the current record ends at.

```text
col-to()
```


## feed-attribute()

**NOTE:** This function is deprecated, use `meta(String key)` instead.
  The value for the supplied feed `attributeKey`.

```text
feed-attribute(String attributeKey)
```


## feed-name()

Name of the feed for the data being processed

```text
feed-name()
```


## line-from()

The line in the input that the current record begins on (1 based).

```text
line-from()
```


## line-to()

The line in the input that the current record ends at.

```text
line-to()
```


## manifest()

Returns an XML structure with the `stroom-meta` namespace detailing the manifest meta of the current stream being processed

```text
manifest()
```


## manifest-for-id()

Returns an XML structure with the `stroom-meta` namespace detailing the manifest meta of the specified stream

```text
manifest-for-id(String streamId)
```


## meta()

Lookup a meta data value for the current stream using the specified key.
  The key can be `Feed`, `StreamType`, `CreatedTime`, `EffectiveTime`, `Pipeline` or any other attribute supplied when the stream was sent to Stroom, e.g. meta('System').

```text
meta(String key)
```


## meta-attribute()

Returns the value of a single attribute from the manifest of the current stream.
These are the same attributes that `manifest()` returns as an XML structure.

```text
meta-attribute(String key)
```

This is not the same as `meta()`.
`meta()` reads the meta data of the part currently being processed, and is what most translations want.
`meta-attribute()` reads the manifest of the whole stream from the data store, so it will open the stream's source.

If the stream has no attribute with the supplied key then no result is returned.


## meta-keys()

When calling this function and assigning the result to a variable, you must specify the variable data type of `xs:string*` (array of strings).

The following fragment is an example of using `meta-keys()` to emit all meta values for a given stream, into an `Event/Meta` element:

```xml
<Event>
  <xsl:variable name="metaKeys" select="stroom:meta-keys()" as="xs:string*" />
  <Meta>
    <xsl:for-each select="$metaKeys">
      <string key="{.}"><xsl:value-of select="stroom:meta(.)" /></string>
    </xsl:for-each>
  </Meta>
</Event>
```


## meta-stream()

Returns an XML structure with the `stroom-meta` namespace detailing the meta data of the current stream being processed

```text
meta-stream()
```


## meta-stream-for-id()

Returns an XML structure with the `stroom-meta` namespace detailing the meta data of the specified stream and part number (1 based)

```text
meta-stream-for-id(String streamId, Integer partNo)
```


## parent-for-id()

Get the parent id of the specified input stream

```text
parent-for-id(String streamId)
```


## parent-id()

Get the parent id of the current input stream this is being processed

```text
parent-id()
```


## part-no()

The current part within a multi part aggregated input stream (AKA the substream number) (1 based)

```text
part-no()
```


## record-no()

The current record number within the current part (substream) (1 based).

```text
record-no()
```


## source()

Returns an XML structure with the `stroom-meta` namespace detailing the current source location.

```text
source()
```


## source-id()

Get the id of the current input stream that is being processed

```text
source-id()
```


## stream-id()

An alias for `source-id` included for backward compatibility.

```text
stream-id()
```
