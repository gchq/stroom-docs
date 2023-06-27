---
title: "Mathematics Functions"
linkTitle: "Mathematics Functions"
#weight:
date: 2021-07-27
tags: 
description: >
  Standard mathematical functions, such as add subtract, multiple, etc.
---

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
modulo(dividend, divisor)
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

