---
title: "Date Functions"
linkTitle: "Date Functions"
#weight:
date: 2021-07-27
tags: 
description: >
  Functions for manipulating dates and times.
---

## Parse Date

Parse a date and return a long number of milliseconds since the epoch.
For details of the pattern syntax, see [Dates & Times]({{< relref "docs/reference-section/dates#parsing-with-explicit-format" >}}).

```clike
parseDate(aString)
parseDate(aString, pattern)
parseDate(aString, pattern, timeZone)
```

Example

```clike
parseDate('2014 02 22', 'yyyy MM dd', '+0400')
> 1393012800000
```


## Format Date

Format a date supplied as milliseconds since the epoch.
For details of the format pattern syntax, see [Dates & Times]({{< relref "docs/reference-section/dates#parsing-with-explicit-format" >}}).

```clike
formatDate(aLong)
formatDate(aLong, pattern)
formatDate(aLong, pattern, timeZone)
```

Example

```clike
formatDate(1393071132888, 'yyyy MM dd', '+1200')
> '2014 02 23'
```


## Ceiling Year/Month/Week/Day/Hour/Minute/Second

```clike
ceilingYear(args...)
ceilingMonth(args...)
ceilingWeek(args...)
ceilingDay(args...)
ceilingHour(args...)
ceilingMinute(args...)
ceilingSecond(args...)
ceilingTime(args...)
```

Examples

```clike
ceilingSecond("2014-02-22T12:12:12.888Z")
> "2014-02-22T12:12:13.000Z"
ceilingMinute("2014-02-22T12:12:12.888Z")
> "2014-02-22T12:13:00.000Z"
ceilingHour("2014-02-22T12:12:12.888Z")
> "2014-02-22T13:00:00.000Z"
ceilingDay("2014-02-22T12:12:12.888Z")
> "2014-02-23T00:00:00.000Z"
ceilingWeek("2014-02-22T12:12:12.888Z")
> "2014-02-24T00:00:00.000Z"
ceilingMonth("2014-02-22T12:12:12.888Z")
> "2014-03-01T00:00:00.000Z"
ceilingYear("2014-02-22T12:12:12.888Z")
> "2015-01-01T00:00:00.000Z"
ceilingTime("2014-02-22T12:12:12.888Z", "10m")
> "2014-02-22T12:20:00.000Z"
```


## Floor Year/Month/Week/Day/Hour/Minute/Second

```clike
floorYear(args...)
floorMonth(args...)
floorWeek(args...)
floorDay(args...)
floorHour(args...)
floorMinute(args...)
floorSecond(args...)
floorTime(args...)
```

Examples

```clike
floorSecond("2014-02-22T12:12:12.888Z")
> "2014-02-22T12:12:12.000Z"
floorMinute("2014-02-22T12:12:12.888Z")
> "2014-02-22T12:12:00.000Z"
floorHour("2014-02-22T12:12:12.888Z")
> "2014-02-22T12:00:00.000Z"
floorDay("2014-02-22T12:12:12.888Z")
> "2014-02-22T00:00:00.000Z"
floorWeek("2014-02-22T12:12:12.888Z")
> "2014-02-17T00:00:00.000Z"
floorMonth("2014-02-22T12:12:12.888Z")
> "2014-02-01T00:00:00.000Z"
floorYear("2014-02-22T12:12:12.888Z")
> "2014-01-01T00:00:00.000Z"
floorTime("2014-02-22T12:12:12.888Z", "10m")
> "2014-02-22T12:10:00.000Z"
```


## Round Year/Month/Week/Day/Hour/Minute/Second

```clike
roundYear(args...)
roundMonth(args...)
roundWeek(args...)
roundDay(args...)
roundHour(args...)
roundMinute(args...)
roundSecond(args...)
roundTime(args...)
```

Examples

```clike
roundSecond("2014-02-22T12:12:12.888Z")
> "2014-02-22T12:12:13.000Z"
roundMinute("2014-02-22T12:12:12.888Z")
> "2014-02-22T12:12:00.000Z"
roundHour("2014-02-22T12:12:12.888Z")
> "2014-02-22T12:00:00.000Z"
roundDay("2014-02-22T12:12:12.888Z")
> "2014-02-23T00:00:00.000Z"
roundWeek("2014-02-22T12:12:12.888Z")
> "2014-02-24T00:00:00.000Z"
roundMonth("2014-02-22T12:12:12.888Z")
> "2014-03-01T00:00:00.000Z"
roundYear("2014-02-22T12:12:12.888Z")
> "2014-01-01T00:00:00.000Z"
roundTime("2014-02-22T12:12:12.888Z", "10m")
> "2014-02-22T12:10:00.000Z"
roundTime("2014-02-22T12:15:12.888Z", "10m")
> "2014-02-22T12:20:00.000Z"
```


## Is Weekend

Returns whether a date and time is part of the weekend or not.

```clike
isWeekend(time)
```

Example

```clike
isWeekend('2026-02-04T12:45:11.000Z')
> false
isWeekend('2026-02-01T12:45:11.000Z')
> true
```


## Now

Returns the current date and time.

```clike
now()
```

This is the time the query was run rather than a live clock, so every call to `now()` within a single query returns the same value.


## Current Period Functions

These functions return the current date and time truncated to the start of the named period.
They take no arguments.

```clike
year()
month()
week()
day()
hour()
minute()
second()
```

Each one truncates towards the past, e.g. `hour()` called at `12:45` returns `12:00`, not `13:00`.
A week starts on a Monday.

Like `now()`, these are all based on the time the query was run, so they are consistent with each other within a single query.

These are useful for building relative time ranges without having to write out a date, e.g. comparing a field against `day()` to select today's records.


## Parse Duration

Parses the supplied value as a duration, returning a duration value.

```clike
parseDuration(value)
```

* `value` - The duration as a string, e.g. `10m`, or as a number of milliseconds.

The units that can be used in the string form are `ms`, `s`, `m`, `h` and `d`.


## Format Duration

Formats the supplied duration as a string.

```clike
formatDuration(value)
```

* `value` - The duration, either as a number of milliseconds or as a duration string.

Example

```clike
formatDuration(3600000)
> '1h'
formatDuration(60000)
> '1m'
```


## Parse ISO Duration

Parses the supplied value as an {{< external-link "ISO 8601" "https://en.wikipedia.org/wiki/ISO_8601#Durations" >}} duration, e.g. `PT3H`, returning a duration value.

```clike
parseISODuration(value)
```

* `value` - The duration as an ISO 8601 string, or as a number of milliseconds.


## Format ISO Duration

Formats the supplied duration as an ISO 8601 string.

```clike
formatISODuration(value)
```

* `value` - The duration, either as a number of milliseconds or as an ISO 8601 string.

Example

```clike
formatISODuration(3600000)
> 'PT1H'
```
