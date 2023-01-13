---
title: "Aggregate Functions"
linkTitle: "Aggregate Functions"
#weight:
date: 2023-01-13
tags:
description: >
  Functions that produce aggregates over multiple data points.
---

Aggregate functions require that the dashboard columns without aggregate functions have a grouping level applied.
The aggregate function will then be evaluated against the values in the group.


## Average

Takes an average value of the arguments

```clike
average(arg)
mean(arg)
```

Examples

```clike
average(${val})
${val} = [10, 20, 30, 40]
> 25
```

```clike
mean(${val})
${val} = [10, 20, 30, 40]
> 25
```


## Count

Counts the number of records that are passed through it. Doesn't take any notice of the values of any fields.

```clike
count()
```

Example

```clike
Supplying 3 values...

count()
> 3
```


## Count Groups

This is used to count the number of unique values where there are multiple group levels.
For Example, a data set grouped as follows
1. Group by Name
1. Group by Type

A groupCount could be used to count the number of distinct values of 'type' for each value of 'name'


## Count Unique

This is used to count the number of unique values passed to the function where grouping is used to aggregate values in other columns.
For Example, a data set grouped as follows
1. Group by Name
1. Group by Type

`countUnique()` could be used to count the number of distinct values of 'type' for each value of 'name'

Example

```clike
countUnique(${val})
${val} = ['bill', 'bob', 'fred', 'bill']
> 3
```


## Distinct

Concatenates all distinct (unique) values together into a single string.
Works in the same way as [`joining()`]({{< relref "#joining" >}}) except that it discards duplicate values.
Values are concatenated in the order that they are given to the function.
If a delimiter is supplied then the delimiter is placed between each concatenated string.
If a limit is supplied then it will only concatenate up to limit values.

```clike
distinct(values)
distinct(values, delimiter)
distinct(values, delimiter, limit)
```

Examples

```clike
distinct(${val}, ', ')
${val} = ['bill', 'bill', 'bob', 'fred', 'bill']
> 'bill, bob, fred'
```

```clike
distinct(${val}, '|', 2)
${val} = ['bill', 'bill', 'bob', 'fred', 'bill']
> 'bill|bob'
```

{{% see-also %}}
[Selection Functions]({{< relref "./selection" >}}) that work in a similar way to `distinct()`.
{{% /see-also %}}


## Joining

Concatenates all values together into a single string.
Works in the same way as [`distinct()`]({{< relref "#joining" >}}) except that duplicate values are included.
Values are concatenated in the order that they are given to the function.
If a delimiter is supplied then the delimiter is placed between each concatenated string.
If a limit is supplied then it will only concatenate up to limit values.

```clike
joining(values)
joining(values, delimiter)
joining(values, delimiter, limit)
```

Example

```clike
joining(${val}, ', ')
${val} = ['bill', 'bob', 'fred', 'bill']
> 'bill, bob, fred, bill'
```

{{% see-also %}}
[Selection Functions]({{< relref "./selection" >}}) that work in a similar way to `joining()`.
{{% /see-also %}}


## Max

Determines the maximum value given in the args.

```clike
max(arg)
```

Examples

```clike
max(${val})
${val} = [100, 30, 45, 109]
> 109
```

```clike
# They can be nested
max(max(${val}), 40, 67, 89)
${val} = [20, 1002]
> 1002
```


## Min

Determines the minimum value given in the args.

```clike
min(arg)
```

Examples

```clike
min(${val})
${val} = [100, 30, 45, 109]
> 30
```


```clike
# They can be nested
min(max(${val}), 40, 67, 89)
${val} = [20, 1002]
> 20
```


## Standard Deviation

Calculate the standard deviation for a set of input values.

```clike
stDev(arg)
```

Examples

```clike
round(stDev(${val}))
${val} = [600, 470, 170, 430, 300]
> 147
```


## Sum

Sums all the arguments together

```clike
sum(arg)
```

Examples

```clike
sum(${val})
${val} = [89, 12, 3, 45]
> 149
```


## Variance

Calculate the variance of a set of input values.

```clike
variance(arg)
```

Examples

```clike
variance(${val})
${val} = [600, 470, 170, 430, 300]
> 21704
```
