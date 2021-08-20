---
title: "Logic Funtions"
linkTitle: "Logic Funtions"
#weight:
date: 2021-07-27
tags: 
description: >
  
---

## Equals

Evaluates if arg1 is equal to arg2

```clike
arg1 = arg2
equals(arg1, arg2)
```

Examples

```clike
'foo' = 'bar'
> false
'foo' = 'foo'
> true
51 = 50
> false
50 = 50
> true

equals('foo', 'bar')
> false
equals('foo', 'foo')
> true
equals(51, 50)
> false
equals(50, 50)
> true
```

Note that `equals` cannot be applied to `null` and `error` values, e.g. `x=null()` or `x=err()`. The [`isNull()`]({{< relref "./type-checking.md#is-null" >}}) and [`isError()`]({{< relref "./type-checking.md#is-error" >}}) functions must be used instead.

## Greater Than

Evaluates if arg1 is greater than to arg2

```clike
arg1 > arg2
greaterThan(arg1, arg2)
```

Examples

```clike
51 > 50
> true
50 > 50
> false
49 > 50
> false

greaterThan(51, 50)
> true
greaterThan(50, 50)
> false
greaterThan(49, 50)
> false
```

## Greater Than or Equal To

Evaluates if arg1 is greater than or equal to arg2

```clike
arg1 >= arg2
greaterThanOrEqualTo(arg1, arg2)
```

Examples

```clike
51 >= 50
> true
50 >= 50
> true
49 >= 50
> false

greaterThanOrEqualTo(51, 50)
> true
greaterThanOrEqualTo(50, 50)
> true
greaterThanOrEqualTo(49, 50)
> false
```

## If

Evaluates the supplied boolean condition and returns one value if true or another if false

```clike
if(expression, trueReturnValue, falseReturnValue)
```

Examples

```clike
if(5 < 10, 'foo', 'bar')
> 'foo'
if(5 > 10, 'foo', 'bar')
> 'bar'
if(isNull(null()), 'foo', 'bar')
> 'foo'
```

## Less Than

Evaluates if arg1 is less than to arg2

```clike
arg1 < arg2
lessThan(arg1, arg2)
```

Examples

```clike
51 < 50
> false
50 < 50
> false
49 < 50
> true

lessThan(51, 50)
> false
lessThan(50, 50)
> false
lessThan(49, 50)
> true
```

## Less Than or Equal To

Evaluates if arg1 is less than or equal to arg2

```clike
arg1 <= arg2
lessThanOrEqualTo(arg1, arg2)
```

Examples

```clike
51 <= 50
> false
50 <= 50
> true
49 <= 50
> true

lessThanOrEqualTo(51, 50)
> false
lessThanOrEqualTo(50, 50)
> true
lessThanOrEqualTo(49, 50)
> true
```

## Not

Inverts boolean values making true, false etc.

```clike
not(booleanValue)
```

Examples

```clike
not(5 > 10)
> true
not(5 = 5)
> false
not(false())
> true
```
