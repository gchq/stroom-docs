# Mathematics Functions

<!-- vim-markdown-toc GFM -->
* [Add](#add)
* [Average](#average)
* [Divide](#divide)
* [Max](#max)
* [Min](#min)
* [Multiply](#multiply)
* [Negate](#negate)
* [Power](#power)
* [Random](#random)
* [Subtract](#subtract)
* [Sum](#sum)
<!-- vim-markdown-toc -->

## Add
```
arg1 + arg2
```
Or reduce the args by successive addition
```
add(args...)
```

Examples
```
34 + 9
> 43
add(45, 6, 72)
> 123
```

## Average
Takes an average value of the arguments
```
average(args...)
mean(args...)
```

Examples
```
average(10, 20, 30, 40)
> 25
mean(8.9, 24, 1.2, 1008)
> 260.525
```

## Divide
Divides arg1 by arg2
```
arg1 / arg2
```
Or reduce the args by successive division
```
divide(args...)
```

Examples
```
42 / 7
> 6
divide(1000, 10, 5, 2)
> 10
divide(100, 4, 3)
> 8.33
```

## Max
Determines the maximum value given in the args
```
max(args...)
```

Examples
```
max(100, 30, 45, 109)
> 109

# They can be nested
max(max(${val}), 40, 67, 89)
${val} = [20, 1002]
> 1002
```

## Min
Determines the minimum value given in the args
```
min(args...)
```

Examples
```
min(100, 30, 45, 109)
> 30
```
They can be nested
```
min(max(${val}), 40, 67, 89)
${val} = [20, 1002]
> 20
```

## Multiply
Multiplies arg1 by arg2
```
arg1 * arg2
```
Or reduce the args by successive multiplication
```
multiply(args...)
```

Examples
```
4 * 5
> 20
multiply(4, 5, 2, 6)
> 240
```

## Negate
Multiplies arg1 by -1
```
negate(arg1)
```

Examples
```
negate(80)
> -80
negate(23.33)
> -23.33
negate(-9.5)
> 9.5
```

## Power
Raises arg1 to the power arg2
```
arg1 ^ arg2
```
Or reduce the args by successive raising to the power
```
power(args...)
```

Examples
```
4 ^ 3
> 64
power(2, 4, 3)
> 4096
```

## Random
Generates a random number between 0.0 and 1.0
```
random()
```

Examples
```
random()
> 0.78
random()
> 0.89
...you get the idea
```

## Subtract
```
arg1 - arg2
```
Or reduce the args by successive subtraction
```
subtract(args...)
```

Examples
```
29 - 8
> 21
subtract(100, 20, 34, 2)
> 44
```

## Sum
Sums all the arguments together
```
sum(args...)
```

Examples
```
sum(89, 12, 3, 45)
> 149
```