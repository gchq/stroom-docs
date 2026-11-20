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
!!! IMPORTANT !!!

NOTE:
Stroom has hard coded anchors to link to the keyword headings on this page so don't
change the headings without changing the anchors in Stroom.

!!! IMPORTANT !!!
-->


## Query Format

Stroom Query Language (StroomQL) is a text based replacement for the existing {{< glossary "Dashboard" >}} query builder and allows you to express the same queries in text form as well as providing additional functionality.
It is currently used on the _Query_ entity as the means of defining a query.

The following shows the supported syntax for a StroomQL query.

```stroomql
from <DATA_SOURCE> [as <ALIAS>]
[sql] """<NATIVE_QUERY>"""
[join] <DATA_SOURCE> [as <ALIAS>] on <FIELD> = <ALIAS>.<FIELD> [and ...]
where <FIELD> <CONDITION> <VALUE> [and|or|not]
[and|or|not]
[window] <TIME_FIELD> by <WINDOW_SIZE> [advance <ADVANCE_SIZE>] [offset <OFFSET>]
[filter] <FIELD> <CONDITION> <VALUE> [and|or|not]
[and|or|not]
[eval...] <FIELD> = <EXPRESSION>
[having] <FIELD|EXPRESSION> <CONDITION> <VALUE|EXPRESSION> [and|or|not]
[group by] <FIELD>
[sort by] <FIELD> [desc|asc] // asc by default
[limit] <MAX_ROWS> 
select <FIELD> [as <COLUMN NAME>], ...
[show as] <VIS_NAME> (<VIS_CONTROL_ID_1> = <COLUMN_1>, <VIS_CONTROL_ID_2> = <COLUMN_2>)
```

For the full grammar, see [StroomQL Grammar]({{< relref "docs/reference-section/stroomql-grammar" >}}).


## Fields

Fields are the fields in a data source.
Fields are case-sensitive.

If the field name contains white space then it **must** be surround by braces and preceded by a dollar sign, e.g `${Create Time}`.

If the field name does not contain spaces it can be written with or without the braces, e.g. `Status` or `${Status}`.

Fields can added to the query text in one of three ways:

* Directly typing the field name (with braces as required).
* Double clicking the field name in the Field picker in the left hand pane.
  Field names with spaces will be pasted in with braces.
* Using code completion.
  In the query editor hit {{< key-bind "ctrl,space" >}} to bring up a list of context aware completion terms, e.g. field names, then hit tab to insert it.
  You could also type a few characters from the name before hitting {{< key-bind "ctrl,space" >}} to pre-filter the list.
  Field names with spaces will be pasted in with braces.


## Keywords

Keywords are the reserved words that define the structure of the query, e.g. `from`, `select`, `where`.
Unlike fields, they are case-insensitive.


### From

The first part of a StroomQL expression is the `from` clause that defines the single data source to query.
All queries must include the `from` clause.

Select the data source to query, e.g.

```stroomql
from my_source
```

If the name of the data source contains white space then it must be quoted using `"` double quotes, e.g.

```stroomql
from "my source"
```


### Sql

Some data sources run a query of their own before Stroom works on the results: a [Data Connection]({{< relref "docs/user-guide/search/data-sources/data-connections" >}}) of type JDBC or Amazon Athena runs SQL, and one of type LDAP runs a search filter.
That query goes in a `sql` clause, straight after the data source it is for, e.g. after `from`:

```stroomql
from "Reports DB"
sql """
  select name, team, joined
  from staff
  where joined >= :from and joined < :to
"""
where team = "Platform"
sort by joined desc
select name, joined
```

The SQL or filter is a string, usually in triple double quotes (`"""`).
A triple-quoted string is taken exactly as written: it can span several lines and hold `"` and `\` without escaping, and it ends at the next `"""`.

Its results become the rows that the rest of the query works on, so `where`, `eval`, `group by` and the other clauses work on them as on any other data source.
Named placeholders such as `:team` take the value of the query parameter of that name, and `:from` and `:to` take the ends of the query's time range.

A data source that needs a `sql` clause refuses a query without one, and one that does not take one refuses a query with one.

A joined data source can have a `sql` clause too, straight after it in its join line, and a bracketed query has its own inside its brackets, straight after its `from`, e.g.

```stroomql
from "Windows events"
left join "Reports DB" as staff sql """
  select username, team
  from staff
""" on UserId = staff.username
select UserId, staff.team
```


### Join

Use `join` to join the rows of another data source to the rows of the query, straight after `from`, e.g.

```stroomql
from "Windows events"
left join "HR Users" as hr on UserId = hr.Username
select UserId, hr.Department
```

The kinds of join are `join`, `left join`, `right join`, `full join`, `semi join` and `anti join`.
The joined fields are named `<alias>.<field>`, e.g. `hr.Department`, where the alias is the name after `as`, or the data source's name if there is none.
If that name has spaces, write its fields in braces, e.g. `${HR Users.Department}`.

The joined source can also be a bracketed query, and a query can have several join lines.

See [Joins]({{< relref "joins" >}}) for the kinds of join and examples.


### On

Use `on` to give the keys of a join, whose values must be equal for rows to join, e.g.

```stroomql
on lowerCase(UserId) = hr.Username and Host = hr.Host
```

Keys match exactly, so case matters, and a blank key never matches.

An event-to-event join can also give a time window after its keys, e.g.

```stroomql
from "Windows events" as logon
join "File events" as export
  on logon.UserId = export.UserId
  within 10m after logon.EventTime
select logon.UserId, logon.EventTime, export.FileName
```

See [Joining Events Within a Time Window]({{< relref "joins#joining-events-within-a-time-window" >}}).


### Where

Use `where` to construct query criteria, e.g.

```stroomql
where feed = "my feed"
```

Add boolean logic with `and`, `or` and `not` to build complex criteria, e.g.

```stroomql
where feed = "my feed"
or feed = "other feed"
```

Use brackets to group logical sub expressions, e.g.

```stroomql
where user = "bob"
and (feed = "my feed" or feed = "other feed")
```


#### Conditions

Supported conditions are:

* `=` - Equals.
* `!=` - Not equals.
* `>` - Greater than.
* `>=` - Greater than or equal to.
* `<` - Less than.
* `<=` - Less than or equal to.
* `is null` - The value is `null`.
* `is not null` - The value is not `null`.
* `in` - The value is in a list of allowed values.  
  e.g. `StreamId in (1001, 1002, 2009)`  
  or `Feed in ("FEED_X", "FEED_Y")`.
* `in dictionary` - The value is in a list of allowed values that are contained in a {{< stroom-doc "Dictionary" >}}.  
  e.g. `Feed in dictionary "My Dict"` (using the dictionary's unique name)  
  or  `Feed in dictionary "fb7a8cea-e6b4-4d94-8f7e-47ff3b3c7711"` (using the dictionary's {{< glossary "UUID" >}}).  


#### And|Or|Not

Logical operators to add to where and filter clauses.


#### Bracket Groups

You can force evaluation of items in a specific order using bracketed groups.

```stroomql
and X = 5 OR (name = foo and surname = bar)
```


#### Exists and In

Use `exists` to keep only the rows that have a match in another data source, or `not exists` to keep those with none, as in SQL, e.g.

```stroomql
from People as p
where exists (from Teams as t where t.team = p.team and t.on_call = true)
select name, team
```

Use `in` or `not in` to compare a field with the one field another data source's query selects, e.g.

```stroomql
from People
where team not in (from Teams select team)
select name, team
```

These are other ways of writing a `semi join` and an `anti join`, and run as them.
They can only be used at the top level of `where`, joined to its other conditions by `and`.
See [Exists and In]({{< relref "joins#exists-and-in" >}}).


### Window

```stroomql
window <TIME_FIELD> by <WINDOW_SIZE> [advance <ADVANCE_SIZE>] [offset <OFFSET>]
```

Use `window` to put rows into windows of time and to group them by the window they are in, e.g.

```stroomql
from "File events"
window EventTime by 1d
group by UserId
select windowStart() as Day, UserId, count() as Events
```

This gives a row for each user for each day.
Rows are grouped by their window as well as by the `group by` columns.
No columns are added to the table, so select [`windowStart()`]({{< relref "docs/reference-section/expressions/date#window-start" >}}) or [`windowEnd()`]({{< relref "docs/reference-section/expressions/date#window-end" >}}) to show the times of a row's window.

A window includes its start and not its end, so an event at midnight is in the day that starts then.
The time field must hold a date and time.
A field that the data source lists as some other type is refused.
Rows with no time in the field are left out, and the search gives a warning that says how many.


#### Window Sizes

A size is a number and a unit, e.g. `10m` or `1d`.

Unit | Meaning
---- | -------
`ms` | Milliseconds
`s`  | Seconds
`m`  | Minutes
`h`  | Hours
`d`  | Days
`w`  | Weeks
`M`  | Months
`y`  | Years

Sizes in hours or less are fixed lengths of time, counted from midnight, so windows of `1h` start on the hour and `24h` is always 24 hours.

Sizes in days, weeks, months and years follow the calendar in the time zone of the query.
A window of `1d` is 23 or 25 hours long when the clocks change, weeks start on Monday and months on the 1st.
An analytic rule that has no time zone uses UTC.

{{< note >}}
`7d` is not the same as `1w`.
`1w` is the calendar week from Monday, whereas `7d` is every seven days counted from 1 January 1970, which starts on Thursdays.
{{< /note >}}


#### Overlapping Windows

Add `advance` to make windows that overlap, e.g.

```stroomql
window EventTime by 1h advance 10m
```

A window of an hour then starts every 10 minutes, and each event is counted in every window that covers it, which is six windows here.
Without `advance`, each window starts where the one before it ends.

The size must be a whole number of advances.
The advance can be in a smaller unit than the size where the units divide exactly, so a year can advance by months, a week by days or less and a day by hours or less.
Months and years can't advance by weeks, days or less.


#### Offset

Add `offset` to move where windows start, e.g.

```stroomql
window EventTime by 1d offset 6h
```

Each day then runs from 06:00 to 06:00.
Use a minus sign to move the start earlier, e.g. `offset -2h`.
`advance` and `offset` can be given in either order.


#### Comparing Windows

Use [`lag()`]({{< relref "docs/reference-section/expressions/aggregate#lag" >}}) and [`lead()`]({{< relref "docs/reference-section/expressions/aggregate#lead" >}}) to compare a window with an earlier or later one, e.g.

```stroomql
from "File events"
window EventTime by 1d
eval Change = count() - lag(count(), 1)
group by UserId
select windowStart() as Day, UserId, count() as Events, Change
```

`lag(count(), 1)` is the count of the window one size before, for the same user, and `lead(count(), 1)` is the count of the window one size after.
The other window is a number of sizes away, whatever the advance, so with `by 1h advance 10m` it is the window that starts an hour before.

What `lag()` and `lead()` give depends on the other window:

* A window that has events gives the value of the aggregate for it.
* A window with no events for the group gives the empty value of the aggregate, which is `0` for `count()`.
* A window before the first window that has events, or after the last, gives no value.
  The first and last windows are those of all the events of the search, not of the group.

Give a third value to use where there is no value, e.g. `lag(count(), 1, 0)`.

A user with no events in a window still gets a row for that window if a window either side of it reads it, and the window is not before the first or after the last that has events.
In the example above, a user with events on Monday and none on Tuesday gets a row for Tuesday with `Events` of `0` and `Change` of minus Monday's count, as long as another user has events on Tuesday or later.

To keep only the windows that have changed, compare them in [`having`](#having), e.g.

```stroomql
from "File events"
window EventTime by 1d
group by UserId
having count() > lag(count(), 1) * 2
select windowStart() as Day, UserId, count() as Events
```


#### Window Limits

* An event is added to the results once for each window it is in, and once more for each of those for each different distance used by `lag()` and `lead()`.
  A query that would add an event more than 100 times is refused.
  Administrators set this limit with the `search.resultStore.maxWindowCopiesPerEvent` property.
* `window` can be used in a bracketed query and with a join, but not with a [join within a time window]({{< relref "joins#joining-events-within-a-time-window" >}}).
* `lag()` and `lead()` can only be used in a query that has a `window` clause.

{{< see-also >}}
[Time Windows in Analytic Rules]({{< relref "docs/user-guide/search/analytics/query#time-windows" >}})
{{< /see-also >}}


### Filter

Use `filter` to test values that `where` can't, such as a field that has not been indexed or the result of an `eval`.
It is written the same way as the `where` clause, but is tested on each row after its values have been retrieved, rather than being part of the search, e.g.

```stroomql
from my_source
where feed = "my feed"
eval domain = substringAfter(user, "@")
filter obscure_field = "some value" and domain = "example.com"
select user, domain, obscure_field
```

`where` names fields of the data source, but `filter` names the columns of `select`, so a column must be selected to be filtered on.
If a column is renamed with `as`, `filter` uses the new name.

Add boolean logic with `and`, `or` and `not` to build complex criteria as supported by the `where` clause.
Use brackets to group logical sub expressions as supported by the `where` clause.

Text is compared without regard to case, and `*` and `?` can be used as wildcards with `=` and `!=`.

{{< note >}}
As filters do not make use of the index they can be considerably slower than a `where` clause, however they allow filtering on fields that have not been indexed for some reason.
Frequent use of `filter` on a field suggests you may want to consider including that field in an index.
{{< /note >}}

See [Filter]({{< relref "docs/reference-section/stroomql-grammar#filter" >}}) for the differences between `where` and `filter` in full.


### Eval

Use `eval` to assign the value returned from an [Expression Function]({{< relref "docs/reference-section/expressions" >}}) to a named variable, e.g.

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
Note that when reusing a variable name, the assignment can depend on the previous value assigned to that variable.

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
A condition can test a column by its name, e.g.

```stroomql
having count > 3
```

A condition can also test an expression, so the value does not have to be a column, e.g.

```stroomql
having count() > 3 and max(Bytes) < 1000
```

Two expressions can be compared with `=`, `!=`, `>`, `>=`, `<` or `<=`, e.g.

```stroomql
having count() > lag(count(), 1) * 2
```

A single name on the right of a comparison is a column if an `eval` or `select` gives one of that name, and text if not.

A row is kept only if the comparison is true, so a row with nothing to compare with is left out.
With [`window`](#window), this means the first window that has events is left out of a comparison with `lag()`.
To keep it, give `lag()` a value to use, e.g. `lag(count(), 1, 0)`.


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


### Limit

Limit the number of results, e.g.

```stroomql
limit 10
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


### Show

The `show` keyword is used to tell StroomQL how to show the data resulting from the `select`.
A Stroom visualisation can be specified and then passed column values from the `select` for the visualisation control properties.

```stroomql
show LineChart(x = EventTime, y = count)
show Doughnut(names = Feed, values = count)
```

For visualisations that contain spaces in their names it is necessary to use quotes, e.g.

```stroomql
show "My Visualisation" (x = EventTime, y = count)
```


## Comments

### Single Line

StroomQL supports single line comments using `//`.
For example:

```stroomql
from "index_view" // view
where EventTime > now() - 1227d
// and StreamId = 1210
select StreamId as "Stream Id", EventTime as "Event Time"
```


### Multi Line

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
limit 10
select Sl, StreamId as "Stream Id", EventId as "Event Id", EventTime as "Event Time", UserId as "User Id", FirstName, count
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
limit 10
select Sl, StreamId as "Stream Id", EventId as "Event Id", EventTime as "Event Time", UserId as "User Id", FirstName, count
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
// limit 10
select StreamId as "Stream Id", EventId as "Event Id"
```

```stroomql
from "index_view" // view
// add each user's department, keeping users not in the HR list
left join "HR Users" as hr on UserId = hr.Username
where EventTime > now() - 1227d
eval count = count()
group by UserId, hr.Department
sort by count desc
select UserId as "User Id", hr.Department as "Department", count
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
limit 10
select Sl, StreamId as "Stream Id", EventId as "Event Id", EventTime as "Event Time", UserId as "User Id", FirstName, count
```


## Help Pane

The left hand pane of the Query editor provides help for building a StroomQL query.
It contains the following items:

* _Data Sources_ - The list of data sources (visible to the user) that can be queried.
* _Structure_ - The list of keywords available to use, e.g. `select`.
* _Annotation Fields_ - The list of special fields for accessing data from Annotations linked to the data being queried.
  The fields list will only be available once a complete `from ...` clause has been added that uses a data source that supports Annotations, e.g. an Index.
* _Fields_ - The list of fields that can be used in the Query.
  The fields list will only be available once a complete `from ...` clause has been added.
* _Functions_ - The list of [Expression Functions]({{< relref "docs/reference-section/expressions" >}}) that can be used.
* _Visualisations_ - The list of {{< stroom-doc "Visualisation" >}} documents that can be included in the {{< stroom-doc "Query" >}}.
* _Dictionaries_ - The list of {{< stroom-doc "Dictionary" >}} documents that can be used in [`in dictionary`]({{< relref "#conditions" >}}) terms.

Clicking on an item will show some detailed help about that item in the bottom of the pane.

Double clicking on the item will insert it into the query editor.
It will be inserted with double quotes or braces as appropriate to the item being inserted.


## Code Completion

The StroomQL editor benefits from code completion to speed up the writing of queries.

Pressing {{< key-bind "ctrl" "space" >}} in the query editor will bring up a context aware context menu listing items that can be inserted into the query, e.g. fields, functions, keywords, dictionaries, data sources, etc.

If you type some letters of the item you want, e.g. `sub` then {{< key-bind "ctrl" "space" >}}, it will bring up a list of items that contain the letters `sub` in that order, e.g. `substring(..)`, `isDouble(..)`, etc.

You can either use the cursor keys to scroll up/down the list or continue typing letters to further refine the filtering of the list.
Hit {{< key-bind "enter" >}} or {{< key-bind "tab" >}} to insert the item into the editor.

The context menu also includes [completion snippets]({{< relref "docs/reference-section/snippet-reference#stroom-query-language-snippets" >}}).

The context menu also shows some more detailed help, e.g. to describe the argument to functions.


### Functions

[Expression Functions]({{< relref "docs/reference-section/expressions" >}}) are inserted with _tab stops_ to enable fast population of the function arguments.
For example:

1. Type `sub` then hit {{< key-bind "ctrl" "space" >}}.
1. Select `substring(..)` from the list and hit {{< key-bind "tab" >}}.  
   `substring(input, startIndex, endIndex)` is inserted, with `input` highlighted.
1. Type `Feed` to replace `input` with `Feed`, then hit {{< key-bind "tab" >}}.  
   `substring(Feed, startIndex, endIndex)` is displayed, with `startIndex` highlighted.
1. Type `0` to replace `startIndex` with `0`, then hit {{< key-bind "tab" >}}.  
   `substring(Feed, 0, endIndex)` is displayed, with `endIndex` highlighted.
1. Type `5` to replace `endIndex` with `5`, then hit {{< key-bind "tab" >}}.  
   `substring(Feed, 0, 5)` is displayed, with the cursor now positioned after the closing bracket.

