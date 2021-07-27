---
title: "Cast Functions"
linkTitle: "Cast Functions"
#weight:
date: 2021-07-27
tags: 
description: >
  A set of functions for converting between different data types or for working with data types.
---

## To Boolean

Attempts to convert the passed value to a _boolean_ data type.

```clike
toBoolean(arg1)
```

Examples:

```clike
toBoolean(1)
> true
toBoolean(0)
> false
toBoolean('true')
> true
toBoolean('false')
> false
```

## To Double

Attempts to convert the passed value to a _double_ data type.

```clike
toDouble(arg1)
```

Examples:

```clike
toDouble('1.2')
> 1.2
```

## To Integer

Attempts to convert the passed value to a _integer_ data type.

```clike
toInteger(arg1)
```

Examples:

```clike
toInteger('1')
> 1
```

## To Long

Attempts to convert the passed value to a _long_ data type.

```clike
toLong(arg1)
```

Examples:

```clike
toLong('1')
> 1
```

## To String

Attempts to convert the passed value to a _string_ data type.

```clike
toString(arg1)
```

Examples:

```clike
toString(1.2)
> '1.2'
```
