---
title: "Rounding Functions"
linkTitle: "Rounding Functions"
#weight:
date: 2021-07-27
tags: 
description: >
  Functions for rounding data to a set precision.
---

These functions require a value, and an optional decimal places.
If the decimal places are not given it will give you nearest whole number.

## Ceiling

```clike
ceiling(value, decimalPlaces<optional>)
```

Examples

```clike
ceiling(8.4234)
> 9
ceiling(4.56, 1)
> 4.6
ceiling(1.22345, 3)
> 1.223
```

## Floor

```clike
floor(value, decimalPlaces<optional>)
```

Examples

```clike
floor(8.4234)
> 8
floor(4.56, 1)
> 4.5
floor(1.2237, 3)
> 1.223
```

## Round

```clike
round(value, decimalPlaces<optional>)
```

Examples

```clike
round(8.4234)
> 8
round(4.56, 1)
> 4.6
round(1.2237, 3)
> 1.224
```

