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

## Average

Takes an average value of the arguments

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
