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

Counts the number of records that are passed through it.
Doesn't take any notice of the values of any fields.

```clike
count()
```

Example

```clike
Supplying 3 values...

count()
> 3
```


## Count Distinct

Counts the unique values in each group.
Null and error values are not counted.

```clike
countDistinct(values)
```

The count is exact up to a limit for each group, which is 10,000 values unless it has been configured.
Above the limit the count is the same estimate that [`dcount()`](#dcount) gives by default, with a standard error of 0.8%.
There is nothing in the results to show whether a count is exact or an estimate.

{{< note >}}
A count just above the limit can be given as one just below it, because it is an estimate.
Avoid comparing the count with a number close to the limit, such as in a `having` clause or an analytic rule.
{{< /note >}}

Values of different types are different, so the number `1` and the string `'1'` are two unique values.
Values are compared by a 64-bit hash, so the chance that any two of 10,000 values are counted as one is about 3 in a trillion.

The limit is set by a property for where the function is used.
A higher limit takes more space, as 8 bytes are stored for each value that is counted exactly.

Used in                                   | Property
----------------------------------------- | ------------
Queries, dashboards and other searches    | `stroom.search.resultStore.maxCountDistinctValues`
Analytic rules and reports                | `stroom.analytics.resultStore.maxCountDistinctValues`

Example

```clike
countDistinct(${val})
${val} = ['bill', 'bob', 'fred', 'bill']
> 3
```

{{< see-also >}}
[`dcount()`](#dcount), which takes less space if there are many unique values.
{{< /see-also >}}


## Count Groups

This is used to count the number of unique group keys where there are multiple group levels.
For example, a data set grouped as follows

1. Group by Name
1. Group by Type

`countGroups` could be used to count the number of distinct values of 'type' for each value of 'name'.

```clike
countGroups()
```


## Count Unique

DEPRECATED - replaced by [`countDistinct()`](#count-distinct) and [`dcount()`](#dcount), which are far quicker and take less space if there are many unique values.

{{< warning >}}
Don't change an existing Table Builder rule to use one of these, see [Changing the Query]({{< relref "docs/user-guide/search/analytics/table-builder#changing-the-query" >}}).
{{< /warning >}}

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


## Dcount

Estimates the number of unique values in each group.
Null and error values are not counted.

```clike
dcount(values)
dcount(values, accuracy)
```

* `values` - The values to count.
* `accuracy` - `0`, `1` or `2`.
  The default is `1`.

A lower accuracy takes less space, but has a greater error.

Accuracy | Standard error | Most space for each group
-------- | -------------- | ------------
`0`      | 1.6%           | 3 kilobytes
`1`      | 0.8%           | 12 kilobytes
`2`      | 0.4%           | 48 kilobytes

About 99.7% of estimates are within three times the standard error.
With few values the estimate is exact, or all but exact, and takes less space.
This is the case for up to about five thousand values with an accuracy of `1`, for fewer with `0` and for more with `2`.

The estimate uses the HyperLogLog++ algorithm.
It depends only on the values and not on the order that they are given or on which nodes they are read by, so the same values always give the same estimate.

Examples

```clike
dcount(${val})
${val} = ['bill', 'bob', 'fred', 'bill']
> 3
```

```clike
# The estimate with the least error
dcount(${val}, 2)
${val} = ['bill', 'bob', 'fred', 'bill']
> 3
```

{{< see-also >}}
[`countDistinct()`](#count-distinct), which is exact up to a limit.
{{< /see-also >}}


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

{{< see-also >}}
[Selection Functions]({{< relref "./selection" >}}) that work in a similar way to `distinct()`.
{{< /see-also >}}


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

{{< see-also >}}
[Selection Functions]({{< relref "./selection" >}}) that work in a similar way to `joining()`.
{{< /see-also >}}


## Lag

Gives the value that an aggregate has in an earlier time window of the same group, for a StroomQL query with a [`window`]({{< relref "docs/user-guide/search/queries/stroom-query-language#window" >}}) clause.

```clike
lag(aggregate, windows)
lag(aggregate, windows, default)
```

* `aggregate` - An aggregate, such as `count()` or `sum(${Bytes})`, or the name of an `eval` or column that is one.
* `windows` - How many windows earlier, as a whole number from 1.
* `default` - The value to give when the earlier window has no value.
  It can't start with `window:`.

The earlier window is a number of window sizes before the row's own, whatever the advance.
An earlier window with no events for the group gives the empty value of the aggregate, which is `0` for `count()`.
An earlier window that is before the first window of the search that has events gives no value, or `default` if it is given.

Examples

```clike
# With 'window EventTime by 1d', and 4 events on Monday and 10 on Tuesday
# For the row of Tuesday
lag(count(), 1)
> 4
count() - lag(count(), 1)
> 6
# For the row of Monday, the first day that has events
lag(count(), 1)
> null
lag(count(), 1, 0)
> 0
```


## Lead

Gives the value that an aggregate has in a later time window of the same group, for a StroomQL query with a [`window`]({{< relref "docs/user-guide/search/queries/stroom-query-language#window" >}}) clause.

```clike
lead(aggregate, windows)
lead(aggregate, windows, default)
```

* `aggregate` - An aggregate, such as `count()` or `sum(${Bytes})`, or the name of an `eval` or column that is one.
* `windows` - How many windows later, as a whole number from 1.
* `default` - The value to give when the later window has no value.
  It can't start with `window:`.

This works as [`lag()`](#lag) does, but reads the window a number of window sizes after the row's own.

Example

```clike
# With 'window EventTime by 1d', and 4 events on Monday and 10 on Tuesday
# For the row of Monday
lead(count(), 1)
> 10
```


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


## StDev (Standard Deviation)

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

Nulls are ignored.
A boolean gives an error, so use [If]({{< relref "docs/reference-section/expressions/logic#if" >}}) to count the rows where a condition is true.

```clike
sum(if(${val} > 10, 1, 0))
${val} = [89, 12, 3, 45]
> 3
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
