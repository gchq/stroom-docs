# Aggregate Functions

<!-- vim-markdown-toc GFM -->
* [Average](#average)
* [Count](#count)
* [Count Groups](#count-groups)
* [Count Unique](#count-unique)
* [Max](#max)
* [Min](#min)
* [Standard Deviation](#standard-deviation)
* [Sum](#sum)
* [Variance](#variance)
<!-- vim-markdown-toc -->

## Average
Takes an average value of the arguments
```
average(arg)
mean(arg)
```

Examples
```
average(${val})
${val} = [10, 20, 30, 40]
> 25

mean(${val})
${val} = [10, 20, 30, 40]
> 25
```

## Count
Counts the number of records that are passed through it. Doesn't take any notice of the values of any fields.

```
count()
```

Examples
```
Supplying 3 values...

count()
> 3
```

## Count Groups
This is used to count the number of unique values where there are multiple group levels.
For Example, a data set grouped as follows
1. Group by Name
2. Group by Type

A groupCount could be used to count the number of distinct values of 'type' for each value of 'name'

## Count Unique
This is used to count the number of unique values passed to the function where grouping is used to aggregate values in other columns.
For Example, a data set grouped as follows
1. Group by Name
2. Group by Type

`countUnique()` could be used to count the number of distinct values of 'type' for each value of 'name'

Examples
```
countUnique(${val})
${val} = ['bill', 'bob', 'fred', 'bill']
> 3
```

## Max
Determines the maximum value given in the args
```
max(arg)
```

Examples
```
max(${val})
${val} = [100, 30, 45, 109]
> 109

# They can be nested
max(max(${val}), 40, 67, 89)
${val} = [20, 1002]
> 1002
```

## Min
Determines the minimum value given in the args
```
min(arg)
```

Examples
```
min(${val})
${val} = [100, 30, 45, 109]
> 30
```
They can be nested
```
min(max(${val}), 40, 67, 89)
${val} = [20, 1002]
> 20
```

## Standard Deviation
Calculate the standard deviation for a set of input values.

```
stDev(arg)
```

Examples
```
round(stDev(${val}))
${val} = [600, 470, 170, 430, 300]
> 147
```

## Sum
Sums all the arguments together
```
sum(arg)
```

Examples
```
sum(${val})
${val} = [89, 12, 3, 45]
> 149
```

## Variance
Calculate the variance of a set of input values.

```
variance(arg)
```

Examples
```
variance(${val})
${val} = [600, 470, 170, 430, 300]
> 21704
```
