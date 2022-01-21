---
title: "Type Checking Functions"
linkTitle: "Type Checking Functions"
#weight:
date: 2021-07-27
tags: 
description: >
  Functions for evaluating the type of a value.
---

## Is Boolean

Checks if the passed value is a _boolean_ data type.

```clike
isBoolean(arg1)
```

Examples:

```clike
isBoolean(toBoolean('true'))
> true
```

## Is Double

Checks if the passed value is a _double_ data type.

```clike
isDouble(arg1)
```

Examples:

```clike
isDouble(toDouble('1.2'))
> true
```

## Is Error

Checks if the passed value is an error caused by an invalid evaluation of an expression on passed values, e.g. some values passed to an expression could result in a divide by 0 error.
Note that this method must be used to check for `error` as error equality using `x=err()` is not supported.

```clike
isError(arg1)
```

Examples:

```clike
isError(toLong('1'))
> false
isError(err())
> true
```

## Is Integer

Checks if the passed value is an _integer_ data type.

```clike
isInteger(arg1)
```

Examples:

```clike
isInteger(toInteger('1'))
> true
```

## Is Long

Checks if the passed value is a _long_ data type.

```clike
isLong(arg1)
```

Examples:

```clike
isLong(toLong('1'))
> true
```

## Is Null

Checks if the passed value is `null`.
Note that this method must be used to check for `null` as null equality using `x=null()` is not supported.

```clike
isNull(arg1)
```

Examples:

```clike
isNull(toLong('1'))
> false
isNull(null())
> true
```

## Is Number

Checks if the passed value is a numeric data type.

```clike
isNumber(arg1)
```

Examples:

```clike
isNumber(toLong('1'))
> true
```

## Is String

Checks if the passed value is a _string_ data type.

```clike
isString(arg1)
```

Examples:
```
isString(toString(1.2))
> true
```

## Is Value

Checks if the passed value is a value data type, e.g. not `null` or `error`.

```clike
isValue(arg1)
```

Examples:

```clike
isValue(toLong('1'))
> true
isValue(null())
> false
```

## Type Of

Returns the data type of the passed value as a string.

```clike
typeOf(arg1)
```

Examples:

```clike
typeOf('abc')
> string
typeOf(toInteger(123))
> integer
typeOf(err())
> error
typeOf(null())
> null
typeOf(toBoolean('false'))
> false
```
