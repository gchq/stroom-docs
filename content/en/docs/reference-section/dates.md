---
title: "Dates & Times"
linkTitle: "Dates & Times"
weight: 20
date: 2024-04-26
tags: 
description: >
  How dates and times are parsed/formatted in Stroom.
---

## Standard Format

Stroom's standard format for displaying dates and times is {{< external-link "ISO 8601" "https://en.wikipedia.org/wiki/ISO_8601" >}} and specifically in the format

`yyyy-MM-dd'T'HH:mm:ss.SSSXX`

(where `'T'` is the constant `T` and `XX` is the timezone offset or `Z` for Zulu/UTC).

The time part is always represented with three digits for the millisecond part.


## Parsing

Parsing is the action of reading a string like `2010-01-01T23:59:59.123Z` and converting it into a date/time value.

There are two types of parsing, standard parsing and parsing with an explicit format.


### Standard Parsing

The [standard format]({{< relref "#standard-format" >}}) is used when parsing dates with no specific date format, for example in the `EffectiveTime` header that is used when sending reference data to Stroom.

There is a degree of leniency when parsing date time strings with no explicit format.
The following table shows the acceptable date time strings and how they are represented in the standard form.

Input String                    | Standard Form
---------                       | ------------
`2010-01-01T23:59:59.1Z`        | `2010-01-01T23:59:59.100Z`
`2010-01-01T23:59:59.123Z`      | `2010-01-01T23:59:59.123Z`
`2010-01-01T23:59:59.123456Z`   | `2010-01-01T23:59:59.123Z`
`2010-01-01T23:59:59.000123Z`   | `2010-01-01T23:59:59.000Z`
`2010-01-01T23:59:59.0Z`        | `2010-01-01T23:59:59.000Z`
`2010-01-01T23:59:59.000Z`      | `2010-01-01T23:59:59.000Z`
`2010-01-01T23:59Z`             | `2010-01-01T23:59:00.000Z`
`2010-01-01T23:59:59Z`          | `2010-01-01T23:59:59.000Z`
`2010-01-01T23:59:59+02:00`     | `2010-01-01T23:59:59.000+0200`
`2010-01-01T23:59:59.123+02`    | `2010-01-01T23:59:59.123+0200`
`2010-01-01T23:59:59.123+00:00` | `2010-01-01T23:59:59.123Z`
`2010-01-01T23:59:59.123+02:00` | `2010-01-01T23:59:59.123+0200`
`2010-01-01T23:59:59.123-03:00` | `2010-01-01T23:59:59.123-0300`


### Parsing With Explicit Format

Parsing with an explicit date time format is done in a few places in Stroom.

* The XSLT function [`format-date()`]({{< relref "docs/user-guide/pipelines/xslt/xslt-functions#format-date" >}}).
  This function is a bit of a misnomer as it is both parsing and formatting.

* The Dashboard/Query expression [`parseDate()`]({{< relref "docs/reference-section/expressions/date#parse-date" >}}).

Stroom uses Java's {{< external-link "SimpleDateFormat" "https://docs.oracle.com/javase/8/docs/api/java/text/SimpleDateFormat.html" >}} syntax for expressing an explicit date format.

The following table lists the letters that have special meaning in the syntax:

Letter  | Date or Time Component                           | Presentation       | Examples
------- | ------------------------                         | --------------     | ---------
`G`     | Era designator                                   | Text               | `AD`
`y`     | Year                                             | Year               | `1996`, `96`
`Y`     | Week year                                        | Year               | `2009`, `09`
`M`     | Month in year (context sensitive)                | Month              | `July`, `Jul`, `07`
`L`     | Month in year (standalone form)                  | Month              | `July`, `Jul`, `07`
`w`     | Week in year                                     | Number             | `27`
`W`     | Week in month                                    | Number             | `2`
`D`     | Day in year                                      | Number             | `189`
`d`     | Day in month                                     | Number             | `10`
`F`     | Day of week in month                             | Number             | `2`
`E`     | Day name in week                                 | Text               | `Tuesday`, `Tue`
`u`     | Day number of week (1 = Monday, ..., 7 = Sunday) | Number             | `1`
`a`     | Am/pm marker                                     | Text               | `PM`
`H`     | Hour in day (0-23)                               | Number             | `0`
`k`     | Hour in day (1-24)                               | Number             | `24`
`K`     | Hour in am/pm (0-11)                             | Number             | `0`
`h`     | Hour in am/pm (1-12)                             | Number             | `12`
`m`     | Minute in hour                                   | Number             | `30`
`s`     | Second in minute                                 | Number             | `55`
`S`     | Millisecond                                      | Number             | `978`
`z`     | Time zone                                        | General time zone  | `Pacific Standard Time`, `PST`, `GMT-08:00`
`Z`     | Time zone                                        | RFC 822 time zone  | `-0800`
`X`     | Time zone                                        | ISO 8601 time zone | `-08`, `-0800`, `-08:00`

For further details, see the {{< external-link "SimpleDateFormat" "https://docs.oracle.com/javase/8/docs/api/java/text/SimpleDateFormat.html" >}} documentation.


## Formatting

Stroom can format dates with an explicit format in a few places:

* The XSLT function [`format-date()`]({{< relref "docs/user-guide/pipelines/xslt/xslt-functions#format-date" >}}).
  This function is a bit of a misnomer as it is both parsing and formatting.

* The Dashboard/Query expression [`formatDate()`]({{< relref "docs/reference-section/expressions/date#format-date" >}}).

* The User Preferences dialog.

When formatting a date time, the format syntax is the same as used in parsing, as shown [above]({{< relref "#parsing-with-explicit-format" >}}).


## Durations

Durations are represented in Stroom in two different forms, Stroom Durations and ISO 8601 Durations.


### Stroom Duration

Stroom's standard duration syntax takes the form of a numeric value followed by an optional unit suffix, e.g. `10m` for ten minutes.

Prefix | Time Unit
-------|-------------
       | milliseconds
`ms`   | milliseconds
`s`    | seconds
`m`    | minutes
`h`    | hours
`d`    | days

Stroom Duration strings are used in a number of places in Stroom:

* [Frequency Schedules]({{< relref "docs/user-guide/jobs/scheduler#frequency-schedules" >}}).
* [Date Expressions]({{< relref "#date-expressions" >}}).
* [Configuration properties]({{< relref "docs/user-guide/properties#stroom-duration-data-type" >}}).
* Dashboard/Query expression functions `parseDuration` and `formatDuration`.


### ISO 8601 Duration

{{< external-link "ISO 8601 durations" "https://en.wikipedia.org/wiki/ISO_8601#Durations" >}} are an international standard format for expressing durations.

ISO 8601 duration strings are used in a number of places in Stroom:

* [Configuration properties]({{< relref "docs/user-guide/properties#stroom-duration-data-type" >}}).
* Dashboard/Query expression functions `parseISODuration` and `formatISODuration`.


## Date Expressions

Date expressions are a way to represent relative dates or to express simple date arithmetic.
They can be used in the following places in Strom:

* Dashboard expression term values.
* Dashboard/Query time range settings.
* Dashboard/Query expression language.

Date expressions consist of a mixture of:

* [StroomDuration]({{< relref "#stroom-duration" >}}).
* Relative date functions like `minute()`.
* Absolute date/times in the [Standard Format]({{< relref "#standard-format" >}})

The available relative date functions are:

Function  | Meaning                                                       | Example
----------|---------------------------------------------------------------|---------------------------
now()     | The current time                                              | `2024-04-26T17:41:55.239Z`
second()  | The current time rounded down to the last second              | `2024-04-26T17:41:55.000Z`
minute()  | The current time rounded down to the last minute              | `2024-04-26T17:41:00.000Z`
hour()    | The current time rounded down to the last hour                | `2024-04-26T17:00:00.000Z`
day()     | The current time rounded down to the start of the day         | `2024-04-26T00:00:00.000Z`
week()    | The current time rounded down to the start of the last Monday | `2024-04-22T00:00:00.000Z` (Monday)
month()   | The current time rounded down to the start of the month       | `2024-04-01T00:00:00.000Z`
year()    | The current time rounded down to the start of the year        | `2024-01-01T00:00:00.000Z`

In the examples above, the current time is taken to be `2024-04-26T17:41:55.239Z` which is a Friday.

The following are some examples of date expressions:

Expression                       | Result                       | Meaning
-------------------------------- | ---------------------------- | --------
`now()+1d`                       | `2024-04-27T17:41:55.239Z`   | The same time tomorrow.
`day() - 1d`                     | `2024-04-25T00:00:00.000Z`   | The start of yesterday.
`day() +1d +12h`                 | `2024-04-27T12:00:00.000Z`   | Noon tomorrow.
`2024-04-27T17:41:55.239Z - 24y` | `2000-04-27T17:41:55.239Z`   | 24 years before `2024-04-27T17:41:55.239Z`

In the examples above, the current time is taken to be `2024-04-26T17:41:55.239Z` which is a Friday.
