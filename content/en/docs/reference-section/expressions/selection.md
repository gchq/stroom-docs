---
title: "Selection Functions"
linkTitle: "Selection Functions"
#weight:
date: 2021-07-27
tags: 
description: >
  Functions for selecting a sub-set of a set of data.
---

Selection functions are a form of aggregate function operating on grouped data.
They select a sub-set of the child values.

{{% see-also %}}
Aggregate functions [`joining()`]({{< relref "./aggregate#joining" >}}) and [`distinct()`]({{< relref "./aggregate#distinct" >}}) that work in a similar way to these selection functions.
{{% /see-also %}}


## Any

Selects the first value found in the group that is not `null()` or `err()`.
If no explicit ordering is set then the value selected is indeterminate.

```clike
any(${val})
```

Examples

```clike
any(${val})
${val} = [10, 20, 30, 40]
> 10
```


## Bottom

Selects the bottom N values and returns them as a delimited string in the order they are read.

```clike
bottom(${val}, delimiter, limit)
```

Example

```clike
bottom(${val}, ', ', 2)
${val} = [10, 20, 30, 40]
> '30, 40'
```


## First

Selects the first value found in the group even if it is `null()` or `err()`.
If no explicit ordering is set then the value selected is indeterminate.

```clike
first(${val})
```

Example

```clike
first(${val})
${val} = [10, 20, 30, 40]
> 10
```


## Last

Selects the last value found in the group even if it is `null()` or `err()`.
If no explicit ordering is set then the value selected is indeterminate.

```clike
last(${val})
```

Example

```clike
last(${val})
${val} = [10, 20, 30, 40]
> 40
```


## Nth

Selects the Nth value in a set of grouped values.
If there is no explicit ordering on the field selected then the value returned is indeterminate.

```clike
nth(${val}, position)
```

Example

```clike
nth(${val}, 2)
${val} = [20, 40, 30, 10]
> 40
```


## Top

Selects the top N values and returns them as a delimited string in the order they are read.

```clike
top(${val}, delimiter, limit)
```

Example

```clike
top(${val}, ', ', 2)
${val} = [10, 20, 30, 40]
> '10, 20'
```

