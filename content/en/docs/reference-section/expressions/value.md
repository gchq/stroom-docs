---
title: "Value Functions"
linkTitle: "Value Functions"
#weight:
date: 2021-07-27
tags: 
description: >
  Functions that return a static value.
---

## Err

Returns _err_

```clike
err()
```


## False

Returns boolean _false_

```clike
false()
```


## Format IEC Byte Size

Formats a number of bytes as a more human readable string, using IEC units, i.e. multiples of 1024.

```clike
formatIECByteSize(bytes)
formatIECByteSize(bytes, omitTrailingZeros)
formatIECByteSize(bytes, omitTrailingZeros, significantFigures)
```

* `bytes` - The number of bytes.
* `omitTrailingZeros` - Whether to omit trailing zeros, default `false`.
* `significantFigures` - The number of significant digits required.
  If the number of integer digits is greater then that will be used instead, so that the integer part is always shown in full, e.g. `1023B` where `significantFigures` is `3`.

Examples

```clike
formatIECByteSize(1024)
> '1.0K'
formatIECByteSize(1024, true)
> '1K'
formatIECByteSize(9878424780)
> '9.2G'
```


## Format Metric Byte Size

Formats a number of bytes as a more human readable string, using metric units, i.e. multiples of 1000.

```clike
formatMetricByteSize(bytes)
formatMetricByteSize(bytes, omitTrailingZeros)
formatMetricByteSize(bytes, omitTrailingZeros, significantFigures)
```

The arguments are the same as for [Format IEC Byte Size](#format-iec-byte-size).

Examples

```clike
formatMetricByteSize(1000)
> '1.0K'
formatMetricByteSize(1096)
> '1.1K'
```


## Null

Returns _null_

```clike
null()
```


## True

Returns boolean _true_

```clike
true()
```
