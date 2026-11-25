---
title: "Mathematics Functions"
linkTitle: "Mathematics Functions"
#weight:
date: 2021-07-27
tags: 
description: >
  Standard mathematical functions, such as add subtract, multiple, etc.
---

## Arithmetic Rules

### Numbers

Numbers can be written with decimal places and with an exponent.

```clike
1.5e3
> 1500
2E+2
> 200
1e-3
> 0.001
```


### Order of Operators

Operators are worked out in this order, and from left to right where they are in the same group.
Use brackets to change the order.

1. `^`
1. `*`, `/` and `%`
1. `+` and `-`
1. `>`, `>=`, `<` and `<=`
1. `=` and `!=`

```clike
10 - 3 + 2
> 9
3 < 5 = true()
> true
```


### Null Values

The result of `+`, `-`, `*`, `/`, `%` or `^` is null if either value is null.
Use [If]({{< relref "docs/reference-section/expressions/logic#if" >}}) to give a value to use in place of a null.

```clike
${val} + 1
${val} = null
> null
if(isNull(${val}), 0, ${val}) + 1
${val} = null
> 1
```

The exception is when `+` is used to join text, which leaves out the nulls.

```clike
'a' + null()
> a
```

The [Sum](#sum) function ignores nulls.


### Other Values

Arithmetic on a value that is not a number is an error.

```clike
'5' - 3
> ERR: Expected a number but got '5'
true() + 1
> ERR: Expected a number but got 'true'
```

The [Sum](#sum) function also gives an error for a boolean, but can read a number from text.

Use a [Cast Function]({{< relref "docs/reference-section/expressions/cast" >}}) to turn text into a number, or [If]({{< relref "docs/reference-section/expressions/logic#if" >}}) to turn a boolean into one.

```clike
toDouble('5') - 3
> 2
if(true(), 1, 0) + 1
> 2
```

The exception is when `+` is used with text, which joins the values.

```clike
'5' + 3
> 53
```


## Add

```clike
arg1 + arg2
```

Or reduce the args by successive addition

```clike
add(args...)
```

Examples

```clike
34 + 9
> 43
add(45, 6, 72)
> 123
```


## Divide

Divides arg1 by arg2

```clike
arg1 / arg2
```

Or reduce the args by successive division

```clike
divide(args...)
```

Examples

```clike
42 / 7
> 6
divide(1000, 10, 5, 2)
> 10
divide(100, 4, 3)
> 8.33
```


## Max

Determines the maximum value given in the args

```clike
max(args...)
```

Examples

```clike
max(100, 30, 45, 109)
> 109

# They can be nested
max(max(${val}), 40, 67, 89)
${val} = [20, 1002]
> 1002
```


## Min

Determines the minimum value given in the args

```clike
min(args...)
```

Examples

```clike
min(100, 30, 45, 109)
> 30
```

They can be nested

```clike
min(max(${val}), 40, 67, 89)
${val} = [20, 1002]
> 20
```


## Modulo

Determines the modulus of the dividend divided by the divisor.

```clike
dividend % divisor
modulo(dividend, divisor)
mod(dividend, divisor)
```

Examples

```clike
modulo(100, 30)
> 10
```


## Multiply

Multiplies arg1 by arg2

```clike
arg1 * arg2
```

Or reduce the args by successive multiplication

```clike
multiply(args...)
```

Examples

```clike
4 * 5
> 20
multiply(4, 5, 2, 6)
> 240
```


## Negate

Multiplies arg1 by -1

```clike
negate(arg1)
```

Examples

```clike
negate(80)
> -80
negate(23.33)
> -23.33
negate(-9.5)
> 9.5
```


## Power

Raises arg1 to the power arg2

```clike
arg1 ^ arg2
```

Or reduce the args by successive raising to the power

```clike
power(args...)
```

Examples

```clike
4 ^ 3
> 64
power(2, 4, 3)
> 4096
```


## Random

Generates a random number between 0.0 and 1.0

```clike
random()
```

Examples

```clike
random()
> 0.78
random()
> 0.89
...you get the idea
```


## Subtract

```clike
arg1 - arg2
```

Or reduce the args by successive subtraction

```clike
subtract(args...)
```

Examples

```clike
29 - 8
> 21
subtract(100, 20, 34, 2)
> 44
```


## Sum

Sums all the arguments together

```clike
sum(args...)
```

Examples

```clike
sum(89, 12, 3, 45)
> 149
```


## Rounding Functions

These functions require a value, and an optional decimal places.
If the decimal places are not given it will give you nearest whole number.


### Ceiling

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


### Floor

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


### Round

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


## Statistical Functions

### Average

Takes an average value of the arguments.
The alias `mean` can be used instead.

```clike
average(args...)
mean(args...)
```

Examples

```clike
average(10, 20, 30, 40)
> 25
mean(8.9, 24, 1.2, 1008)
> 260.525
```


### StDev (Standard Deviation)

Calculate the standard deviation for a set of input values.

```clike
stDev(args...)
```

Examples

```clike
round(stDev(600, 470, 170, 430, 300))
> 147
```


### Variance

Calculate the variance of a set of input values.

```clike
variance(args...)
```

Examples

```clike
variance(600, 470, 170, 430, 300)
> 21704
```

