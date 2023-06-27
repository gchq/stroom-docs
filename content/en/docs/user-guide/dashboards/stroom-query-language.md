---
title: "Stroom Query Language"
linkTitle: "Stroom Query Language"
weight: 70
date: 2023-06-26
tags: 
  - search
description: >
  Stroom Query Language (StroomQL) is a query language for retrieving data in Stroom.
---

<!--
NOTE:
Stroom has hard coded anchors to link to the keyword headings on this page so don't
change the headings without changing the anchors in Stroom.
-->

{{% warning %}}
Stroom Query Language is an experimental feature that is currently in Beta so is subject to change without warning.
{{% /warning %}}

## Query Format

Stroom Query Language (StroomQL) is a text based replacement for the existing {{< glossary "Dashboard" >}} query builder and allows you to express the same queries in text form as well as providing additional functionality.
It is currently used on the _Query_ entity as the means of defining a query.

The following shows the supported syntax for a StroomQL query.

```stroomql
from <DATA_SOURCE>
where <FIELD> <CONDITION> <VALUE> [and|or|not]
[and|or|not]
[window] <TIME_FIELD> by <WINDOW_SIZE> [advance <ADVANCE_WINDOW_SIZE>]
[filter] <FIELD> <CONDITION> <VALUE> [and|or|not]
[and|or|not]
[eval...] <FIELD> = <EXPRESSION>
[having] <FIELD> <CONDITION> <VALUE> [and|or|not]
[group by] <FIELD>
[sort by] <FIELD> [desc|asc] // asc by default
select <FIELD> [as <COLUMN NAME>], ...
[limit] <MAX_ROWS> 
```


## Keywords

### From

The first part of a StroomQL expression is the `from` clause that defines the single data source to query.

Select the data source to query, e.g.
```stroomql
from my_source
```

If the name of the data source contains whitespace then it must be quoted, e.g.
```stroomql
from "my source"
```


### Where

Use `where` to construct query criteria, e.g.

```text
where feed = "my feed"
```

Add boolean logic with `and`, `or` and `not` to build complex criteria, e.g.

```text
where feed = "my feed"
or feed = "other feed"
```

Use brackets to group logical sub expressions, e.g.

```text
where user = "bob"
and (feed = "my feed" or feed = "other feed")
```


#### Conditions

Supported conditions are:

* `=`
* `!=`
* `>`
* `>=`
* `<`
* `<=`
* `is null`
* `is not null`


#### And|Or|Not

Logical operators to add to where and filter clauses.


#### Bracket groups

You can force evaluation of items in a specific order using bracketed groups.

```stroomql
and X = 5 OR (name = foo and surname = bar)
```


### Window

```stroomql
window <TIME_FIELD> by <WINDOW_SIZE> [advance <ADVANCE_WINDOW_SIZE>]
```

Windowing groups data by a specified window size applied to a time field.
A window inserts additional rows for future periods so that rows for future periods contain count columns for previous periods.

Specify the field to window by and a duration.
Durations are specified in simple terms e.g. `1d`, `2w` etc.

By default, a window will insert a count into the next period row.
This is because by default we advance by the specified window size.
If you wish to advance by a different duration you can specify the advance amount which will insert counts into multiple future rows.


### Filter

Use `filter` to filter values that have not been indexed during search retrieval.
This is used the same way as the `where` clause but applies to data after being retrieved from the index, e.g.

```stroomql
filter obscure_field = "some value"
```

Add boolean logic with `and`, `or` and `not` to build complex criteria as supported by the `where` clause.
Use brackets to group logical sub expressions as supported by the `where` clause.

{{% note %}}
As filters do not make use of the index they can be considerably slower than a `where` clause, however they allow filtering on fields that have not been indexed for some reason.
Frequent use of `filter` on a field suggests you may want to consider including that field in an index.
{{% /note %}}


### Eval

Use `eval` to assign the value returned from a function to a named variable, e.g.

```stroomql
eval my_count = count()
```

Here the result of the `count()` function is being stored in a variable called `my_count`.
Functions can be nested and applied to variables, e.g.
```stroomql
eval new_name = concat(
  substring(name, 3, 5),
  substring(name, 8, 9))
```

Note that all fields in the data source selected using `from` will be available as variables by default.

Multiple `eval` statements can also be used to breakup complex function expressions and make it easier to comment out individual evaluations, e.g.
```stroomql
eval name_prefix = substring(name, 3, 5)
eval name_suffix = substring(name, 8, 9)
eval new_name = concat(
  name_prefix,
  name_suffix)
```

Variables can be reused, e.g.

```stroomql
eval name_prefix = substring(name, 3, 5)
eval new_name = substring(name, 8, 9)
eval new_name = concat(
  name_prefix,
  new_name)
```

In this example, the second assignment of `new_name` will override the value initially assigned to it.
Note that that when reusing a variable name, the assignment can depend on the previous value assigned to that variable.

Add boolean logic with `and`, `or` and `not` to build complex criteria, e.g. 

```stroomql
where feed = "my feed" or feed = "other feed"
```

Use brackets to group logical sub expressions, e.g. 
```stroomql
where user = "bob" and (feed = "my feed" or feed = "other feed")
```


### Having

A post aggregate filter that is applied at query time to return only rows that match the `having` conditions.

```stroomql
having count > 3
```


### Group By

Use to group by columns, e.g.
```stroomql
group by feed
```

You can group across multiple columns, e.g.
```stroomql
group by feed, name
```

You can create nested groups, e.g.
```stroomql
group by feed
group by name
```


### Sort By

Use to sort by columns, e.g.

```stroomql
sort by feed
```

You can sort across multiple columns, e.g.

```stroomql
sort by feed, name
```

You can change the sort direction, e.g.

```stroomql
sort by feed asc
```

Or

```stroomql
sort by feed desc
```


### Select

The `select` keyword is used to define the fields that will be selected out of the data source (and any `eval`'d fields) for display in the table output.

```stroomql
select feed, name
```

You can optionally rename the fields so that they appear in the table with more human friendly names.

```stroomql
select feed as 'my feed column',
  name as 'my name column'
```


### Limit

Limit the number of results, e.g.
```stroomql
limit 10
```


## Comments

### Single line

StroomQL supports single line comments using `//`.
For example:

```stroomql
from "index_view" // view
where EventTime > now() - 1227d
// and StreamId = 1210
select StreamId as "Stream Id", EventTime as "Event Time"
```


### Multi line

Multiple lines can be commented by surrounding sections with `/*` and `*/`.
For example:

```stroomql
from "index_view" // view
where EventTime > now() - 1227d
/*
eval FirstName = lowerCase(substringBefore(UserId, '.'))
eval FirstName = any(FirstName)
*/
select StreamId as "Stream Id", EventTime as "Event Time"
```


## Examples

The following are various example queries.

```stroomql
// add a where
from "index_view" // view
where EventTime > now() - 1227d
// and StreamId = 1210
eval UserId = any(upperCase(UserId))
eval FirstName = lowerCase(substringBefore(UserId, '.'))
eval FirstName = any(FirstName)
eval Sl = stringLength(FirstName)
eval count = count()
group by StreamId
sort by Sl desc
select Sl, StreamId as "Stream Id", EventId as "Event Id", EventTime as "Event Time", UserId as "User Id", FirstName, count
limit 10
```

```stroomql
from "index_view" // view
// add a where
where EventTime > now() - 1227d
// and StreamId = 1210
eval UserId = any(upperCase(UserId))
eval FirstName = lowerCase(substringBefore(UserId, '.'))
eval FirstName = any(FirstName)
eval Sl = stringLength(FirstName)
eval count = count()
group by StreamId
sort by Sl desc
select Sl, StreamId as "Stream Id", EventId as "Event Id", EventTime as "Event Time", UserId as "User Id", FirstName, count
limit 10
```

```stroomql
from "index_view" // view
// add a where
where EventTime > now() - 1227d
// and StreamId = 1210
eval UserId = any(upperCase(UserId))
eval FirstName = lowerCase(substringBefore(UserId, '.'))
eval FirstName = any(FirstName)
eval Sl = stringLength(FirstName)
// eval count = count()
// group by StreamId
// sort by Sl desc
select StreamId as "Stream Id", EventId as "Event Id"
// limit 10
```

```stroomql
from "index_view" // view
// add a where
where EventTime > now() - 1227d
// and StreamId = 1210
eval UserId = any(upperCase(UserId))
eval FirstName = lowerCase(substringBefore(UserId, '.'))
eval FirstName = any(FirstName)
eval Sl = stringLength(FirstName)
eval count = count()
group by StreamId
sort by Sl desc
select Sl, StreamId as "Stream Id", EventId as "Event Id", EventTime as "Event Time", UserId as "User Id", FirstName, count
limit 10
```
