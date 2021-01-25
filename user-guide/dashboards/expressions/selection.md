# Selection Functions

<!-- vim-markdown-toc GFM -->

* [Any](#any)
* [Bottom](#bottom)
* [First](#first)
* [Last](#last)
* [Nth](#nth)
* [Top](#top)

<!-- vim-markdown-toc -->

Selection functions are a form of aggregate function operating on grouped data.

## Any

Selects the first value found in the group that is not `null()` or `err()`.
If no explicit ordering is set then the value selected is indeterminate.

```
any(${val})
```

Examples
```
any(${val})
${val} = [10, 20, 30, 40]
> 10
```


## Bottom

Selects the bottom N values and returns them as a delimited string in the order they are read.

```
bottom(${val}, delimiter, limit)
```

Examples
```
bottom(${val}, ', ', 2)
${val} = [10, 20, 30, 40]
> '30, 40'
```

## First

Selects the first value found in the group even if it is `null()` or `err()`.
If no explicit ordering is set then the value selected is indeterminate.

```
first(${val})
```

Examples
```
first(${val})
${val} = [10, 20, 30, 40]
> 10
```


## Last

Selects the last value found in the group even if it is `null()` or `err()`.
If no explicit ordering is set then the value selected is indeterminate.

```
last(${val})
```

Examples
```
last(${val})
${val} = [10, 20, 30, 40]
> 40
```


## Nth
Selects the Nth value in a set of grouped values.
If there is no explicit ordering on the field selected then the value returned is indeterminate.

```
nth(${val}, position)
```

Examples
```
nth(${val}, 2)
${val} = [20, 40, 30, 10]
> 40
```


## Top

Selects the top N values and returns them as a delimited string in the order they are read.

```
top(${val}, delimiter, limit)
```

Examples
```
top(${val}, ', ', 2)
${val} = [10, 20, 30, 40]
> '10, 20'
```







