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

Stroom uses Java's {{< external-link "DateTimeFormatter" "https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/time/format/DateTimeFormatter.html" >}} syntax for expressing an explicit date format.

All letters `A` to `Z` and `a` to `z` are reserved as pattern letters.
The following pattern letters are defined:


Symbol   | Meaning                    | Presentation | Examples
-------- | -------------------------- | ------------ | --------
`G`      | era                        | text         | `AD`, `Anno Domini`, `A`
`u`      | year                       | year         | `2004`, `04`
`y`      | year-of-era                | year         | `2004`, `04`
`D`      | day-of-year                | number       | `189`
`M/L`    | month-of-year              | number/text  | `7`, `07`, `Jul`, `July`, `J`
`d`      | day-of-month               | number       | `10`
`g`      | modified-julian-day        | number       | `2451334`
`Q/q`    | quarter-of-year            | number/text  | `3`, `03`, `Q3`, `3rd quarter`
`Y`      | week-based-year            | year         | `1996`, `96`
`w`      | week-of-week-based-year    | number       | `27`
`W`      | week-of-month              | number       | `4`
`E`      | day-of-week                | text         | `Tue`, `Tuesday`, `T`
`e/c`    | localized day-of-week      | number/text  | `2`, `02`, `Tue`, `Tuesday`, `T`
`F`      | aligned-week-of-month      | number       | `3`
`a`      | am-pm-of-day               | text         | `PM`
`B`      | period-of-day              | text         | `in the morning`
`h`      | clock-hour-of-am-pm (1-12) | number       | `12`
`K`      | hour-of-am-pm (0-11)       | number       | `0`
`k`      | clock-hour-of-day (1-24)   | number       | `24`
`H`      | hour-of-day (0-23)         | number       | `0`
`m`      | minute-of-hour             | number       | `30`
`s`      | second-of-minute           | number       | `55`
`S`      | fraction-of-second         | fraction     | `978`
`A`      | milli-of-day               | number       | `1234`
`n`      | nano-of-second             | number       | `987654321`
`N`      | nano-of-day                | number       | `1234000000`
`V`      | time-zone ID               | zone-id      | `America/Los_Angeles`, `Z`, `-08:30`
`v`      | generic time-zone name     | zone-name    | `Pacific Time`, `PT`
`z`      | time-zone name             | zone-name    | `Pacific Standard Time`, `PST`
`O`      | localized zone-offset      | offset-O     | `GMT+8`, `GMT+08:00`, `UTC-08:00`
`X`      | zone-offset `Z` for zero   | offset-X     | `Z`, `-08`, `-0830`, `-08:30`, `-083015`, `-08:30:15`
`x`      | zone-offset                | offset-x     | `+0000`, `-08`, `-0830`, `-08:30`, `-083015`, `-08:30:15`
`Z`      | zone-offset                | offset-Z     | `+0000`, `-0800`, `-08:00`
`p`      | pad next                   | pad modifier | `1`
`'`      | escape for text            | delimiter    |
`''`     | single quote               | literal      | `'`
`[`      | optional section start     |              |
`]`      | optional section end       |              |
`#`      | reserved for future use    |              |
`{`      | reserved for future use    |              |
`}`      | reserved for future use    |              |

The count of pattern letters determines the format.

### Presentation Types

* **Text**: The text style is determined based on the number of pattern letters used.
  Less than 4 pattern letters will use the short form
  Exactly 4 pattern letters will use the full form
  Exactly 5 pattern letters will use the narrow form
  Pattern letters `L`, `c`, and `q` specify the stand-alone form of the text styles.

* **Number**: If the count of letters is one, then the value is output using the minimum number of digits and without padding
  Otherwise, the count of digits is used as the width of the output field, with the value zero-padded as necessary
  The following pattern letters have constraints on the count of letters
  Only one letter of `c` and `F` can be specified
  Up to two letters of `d`, `H`, `h`, `K`, `k`, `m`, and `s` can be specified
  Up to three letters of `D` can be specified.

* **Number/Text**: If the count of pattern letters is 3 or greater, use the Text rules above
  Otherwise use the Number rules above.

* **Fraction**: Outputs the nano-of-second field as a fraction-of-second
  The nano-of-second value has nine digits, thus the count of pattern letters is from 1 to 9
  If it is less than 9, then the nano-of-second value is truncated, with only the most significant digits being output.

* **Year**: The count of letters determines the minimum field width below which padding is used
  If the count of letters is two, then a reduced two digit form is used
  For printing, this outputs the rightmost two digits
  For parsing, this will parse using the base value of 2000, resulting in a year within the range 2000 to 2099 inclusive
  If the count of letters is less than four (but not two), then the sign is only output for negative years as per SignStyle.NORMAL
  Otherwise, the sign is output if the pad width is exceeded, as per SignStyle.EXCEEDS_PAD.

* **ZoneId**: This outputs the time-zone ID, such as `Europe/Paris`
  If the count of letters is two, then the time-zone ID is output
  Any other count of letters throws IllegalArgumentException.

* **Zone names**: This outputs the display name of the time-zone ID
  If the pattern letter is `z` the output is the daylight saving aware zone name
  If there is insufficient information to determine whether DST applies, the name ignoring daylight saving time will be used
  If the count of letters is one, two or three, then the short name is output
  If the count of letters is four, then the full name is output
  Five or more letters throws IllegalArgumentException.

  If the pattern letter is `v` the output provides the zone name ignoring daylight saving time
  If the count of letters is one, then the short name is output
  If the count of letters is four, then the full name is output
  Two, three and five or more letters throw IllegalArgumentException.

* **Offset X and x**: This formats the offset based on the number of pattern letters
  One letter outputs just the hour, such as `+01`, unless the minute is non-zero in which case the minute is also output, such as `+0130`
  Two letters outputs the hour and minute, without a colon, such as `+0130`
  Three letters outputs the hour and minute, with a colon, such as `+01:30`
  Four letters outputs the hour and minute and optional second, without a colon, such as `+013015`
  Five letters outputs the hour and minute and optional second, with a colon, such as `+01:30:15`
  Six or more letters throws IllegalArgumentException
  Pattern letter `X` (upper case) will output `Z` when the offset to be output would be zero, whereas pattern letter `x` (lower case) will output `+00`, `+0000`, or `+00:00`.

* **Offset O**: With a non-zero offset, this formats the localized offset based on the number of pattern letters
  One letter outputs the short form of the localized offset, which is localized offset text, such as `GMT`, with hour without leading zero, optional 2-digit minute and second if non-zero, and colon, for example `GMT+8`
  Four letters outputs the full form, which is localized offset text, such as GMT, with 2-digit hour and minute field, optional second field if non-zero, and colon, for example `GMT+08:00`
  If the offset is zero, only localized text is output
  Any other count of letters throws IllegalArgumentException.

* **Offset Z**: This formats the offset based on the number of pattern letters
  One, two or three letters outputs the hour and minute, without a colon, such as `+0130`
  The output will be `+0000` when the offset is zero
  Four letters outputs the full form of localized offset, equivalent to four letters of Offset-O
  The output will be the corresponding localized offset text if the offset is zero
  Five letters outputs the hour, minute, with optional second if non-zero, with colon
  It outputs `Z` if the offset is zero
  Six or more letters throws IllegalArgumentException.

* **Optional section**: The optional section markers work exactly like calling DateTimeFormatterBuilder.optionalStart() and DateTimeFormatterBuilder.optionalEnd().

* **Pad modifier**: Modifies the pattern that immediately follows to be padded with spaces
  The pad width is determined by the number of pattern letters
  This is the same as calling DateTimeFormatterBuilder.padNext(int).

For example, `ppH` outputs the hour-of-day padded on the left with spaces to a width of 2.

Any unrecognized letter is an error
Any non-letter character, other than `[`, `]`, `{`, `}`, `#` and the single quote will be output directly
Despite this, it is recommended to use single quotes around all characters that you want to output directly to ensure that future changes do not break your application.

{{% see-also %}}
For further details, see the {{< external-link "DateTimeFormatter" "https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/time/format/DateTimeFormatter.html" >}} documentation.
{{% /see-also %}}


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
