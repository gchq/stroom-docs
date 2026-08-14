---
title: "String & Encoding"
linkTitle: "String & Encoding"
weight: 50
date: 2026-08-14
tags:
  - xslt
description: >
  XSLT functions for string and encoding.
---

## decode-url()

Decode the provided url.

```text
decode-url(String encodedUrl)
```


## encode-url()

Encode the provided url.

```text
encode-url(String url)
```


## hash()

```text
hash(String value)
hash(String value, String algorithm)
hash(String value, String algorithm, String salt)
```

* `hash(String value)` - Hash a string value using the default `SHA-256` algorithm and no salt
* `hash(String value, String algorithm)` - Hash a string value using the specified hashing algorithm and no salt.
* `hash(String value, String algorithm, String salt)` - Hash a string value using the specified hashing algorithm and supplied salt value.
  The algorithm can be any digest algorithm supported by the Java runtime, e.g. `SHA-256`, `SHA-512`, `MD5`.


## hex-to-dec()

Convert hex to dec representation.

```text
hex-to-dec(String hex)
```


## hex-to-oct()

Convert hex to oct representation.

```text
hex-to-oct(String hex)
```


## hex-to-string()

For a hexadecimal input string, decode it using the specified character set to its original form.

Valid character set names are listed at: https://www.iana.org/assignments/character-sets/character-sets.xhtml.
Common examples are: `ASCII`, `UTF-8` and `UTF-16`.


#### Input

```xml
<string><xsl:value-of select="stroom:hex-to-string('74 65 73 74 69 6e 67 20 31 32 33', 'UTF-8')" /></string>
```


#### Output

```xml
<string>testing 123</string>
```
