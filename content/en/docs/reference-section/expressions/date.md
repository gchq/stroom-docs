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

## Ceiling Year/Month/Day/Hour/Minute/Second

```clike
ceilingYear(args...)
ceilingMonth(args...)
ceilingDay(args...)
ceilingHour(args...)
ceilingMinute(args...)
ceilingSecond(args...)
```

Examples

```clike
ceilingSecond("2014-02-22T12:12:12.888Z"
> "2014-02-22T12:12:13.000Z"
ceilingMinute("2014-02-22T12:12:12.888Z"
> "2014-02-22T12:13:00.000Z"
ceilingHour("2014-02-22T12:12:12.888Z"
> "2014-02-22T13:00:00.000Z"
ceilingDay("2014-02-22T12:12:12.888Z"
> "2014-02-23T00:00:00.000Z"
ceilingMonth("2014-02-22T12:12:12.888Z"
> "2014-03-01T00:00:00.000Z"
ceilingYear("2014-02-22T12:12:12.888Z"
> "2015-01-01T00:00:00.000Z"
```

## Floor Year/Month/Day/Hour/Minute/Second

```clike
floorYear(args...)
floorMonth(args...)
floorDay(args...)
floorHour(args...)
floorMinute(args...)
floorSecond(args...)
```

Examples

```clike
floorSecond("2014-02-22T12:12:12.888Z"
> "2014-02-22T12:12:12.000Z"
floorMinute("2014-02-22T12:12:12.888Z"
> "2014-02-22T12:12:00.000Z"
floorHour("2014-02-22T12:12:12.888Z"
> 2014-02-22T12:00:00.000Z"
floorDay("2014-02-22T12:12:12.888Z"
> "2014-02-22T00:00:00.000Z"
floorMonth("2014-02-22T12:12:12.888Z"
> "2014-02-01T00:00:00.000Z"
floorYear("2014-02-22T12:12:12.888Z"
> "2014-01-01T00:00:00.000Z"
```

## Round Year/Month/Day/Hour/Minute/Second

```clike
roundYear(args...)
roundMonth(args...)
roundDay(args...)
roundHour(args...)
roundMinute(args...)
roundSecond(args...)
```

Examples

```clike
roundSecond("2014-02-22T12:12:12.888Z")
> "2014-02-22T12:12:13.000Z"
roundMinute("2014-02-22T12:12:12.888Z")
> "2014-02-22T12:12:00.000Z"
roundHour("2014-02-22T12:12:12.888Z"
> "2014-02-22T12:00:00.000Z"
roundDay("2014-02-22T12:12:12.888Z"
> "2014-02-23T00:00:00.000Z"
roundMonth("2014-02-22T12:12:12.888Z"
> "2014-03-01T00:00:00.000Z"
roundYear("2014-02-22T12:12:12.888Z"
> "2014-01-01T00:00:00.000Z"
```
