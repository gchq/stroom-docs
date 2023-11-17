---
title: "Character Encoding"
linkTitle: "Character Encoding"
#weight:
date: 2022-05-17
tags: 
description: >
  Details of the character encodings supported by Stroom.
---

When data is sent to Stroom the character encoding of the data should be configured for the [Feed]({{< relref "docs/user-guide/feeds" >}}).
This tells Stroom how to decode the data that has been sent.
All data sent to a feed must be encoded in the character encode configured for that Feed.


## Supported Character Encodings

The currently supported character encodings are:


### UTF-8

This is the default character encoding 
A variable width character encoding consisting of one to four bytes per 'character'.
UTF-8 is supported with or without a [Byte Order Mark]({{< relref "#byte-order-mark-bom" >}}).


### UTF-16

A variable width character encoding consisting of two or four bytes per 'character'.
UTF-16 can be encoded with either Big (UTF16-BE) or Little (UTF16-LE) Endianness depending on the system that encoded it.
The [Byte Order Mark]({{< relref "#byte-order-mark-bom" >}}) will specify the endianness but is optional.


### UTF-32

A fixed width character encoding consisting of four bytes per 'character'.
UTF-32 can be encoded with either Big (UTF32-BE) or Little (UTF32-LE) Endianness depending on the system that encoded it.
The [Byte Order Mark]({{< relref "#byte-order-mark-bom" >}}) will specify the endianness but is optional.


### ASCII

A single byte character encoding supporting only 128 characters.
This character encoding has very limited use as it does not support accented characters or emojis so should be avoided for any logs that capture user input where these characters may occur.


## Byte Order Mark (BOM)

A Byte Order Mark (BOM) is a special Unicode character at the start of a text stream that indicates the byte order (or endianness) of the stream.
It can also be used to determine the character encoding of the stream.

Stroom can handle the presence of BOMs in the stream and can use it to determine the character encoding.

| Encoding | BOM                 |
| -------- | --------------      |
| UTF8     | `EF` `BB` `BF`      |
| UTF16-LE | `FF` `FE`           |
| UTF16-BE | `FE` `FF`           |
| UTF32-LE | `FF` `FE` `00` `00` |
| UTF32-BE | `00` `00` `FE` `FF` |
