---
title: "Cron Syntax"
linkTitle: "Cron Syntax"
weight: 10
date: 2024-04-26
tags:
description: >
  The syntax used in Cron schedule expressions.
---

{{< glossary "cron" >}} is a syntax for expressing schedules.

Stroom uses a scheduler called Quartz which supports cron expressions for scheduling.
The full details of the cron syntax supported by Quartz can be found {{< external-link "here" "https://www.quartz-scheduler.org/documentation/quartz-2.3.0/tutorials/crontrigger.html" >}}.

Cron expressions are used in:

* [Stroom Jobs]({{< relref "docs/user-guide/jobs/scheduler#cron-schedules" >}})


## Field Specification

Field Name   | Mandatory | Allowed Values   | Allowed Special Characters
-------------|-----------|------------------|---------------------------
Seconds      | YES       | 0-59             | , - * /
Minutes      | YES       | 0-59             | , - * /
Hours        | YES       | 0-23             | , - * /
Day of month | YES       | 1-31             | , - * ? / L W
Month        | YES       | 1-12 or JAN-DEC  | , - * /
Day of week  | YES       | 1-7 or SUN-SAT   | , - * ? / L #
Year         | NO        | empty, 1970-2099 | , - * /


## Special Characters

* `*` (_all values_) - used to select all values within a field.
  For example, `*` in the minute field means `every minute`.

* `?` (_no specific value_) - useful when you need to specify something in one of the two fields in which the character is allowed, but not the other.
  For example, if I want my trigger to fire on a particular day of the month (say, the 10th), but don’t care what day of the week that happens to be, I would put `10` in the day-of-month field, and `?` in the day-of-week field.
  See the examples below for clarification.

* `-` - used to specify ranges.
  For example, `10-12` in the hour field means _the hours 10, 11 and 12_.

* `,` - used to specify additional values.
  For example, `MON,WED,FRI` in the day-of-week field means _the days Monday, Wednesday, and Friday_.

* `/` - used to specify increments.
  For example, `0/15` in the seconds field means _the seconds 0, 15, 30, and 45_.
  And `5/15` in the seconds field means _the seconds 5, 20, 35, and 50_.
  You can also specify ‘/’ after the ‘’ character - in this case ‘’ is equivalent to having ‘0’ before the ‘/’. ‘1/3’ in the day-of-month field means _fire every 3 days starting on the first day of the month_.

* `L` (_last_) - has different meaning in each of the two fields in which it is allowed.
  For example, the value `L` in the day-of-month field means _the last day of the month_ - day 31 for January, day 28 for February on non-leap years.
  If used in the day-of-week field by itself, it simply means `7` or `SAT`.
  But if used in the day-of-week field after another value, it means _the last xxx day of the month_ - for example `6L` means _the last friday of the month_.
  You can also specify an offset from the last day of the month, such as `L-3` which would mean the third-to-last day of the calendar month.
  When using the ‘L’ option, it is important not to specify lists, or ranges of values, as you’ll get confusing/unexpected results.

* `W` (_weekday_) - used to specify the weekday (Monday-Friday) nearest the given day.
  As an example, if you were to specify `15W` as the value for the day-of-month field, the meaning is: _the nearest weekday to the 15th of the month_.
  So if the 15th is a Saturday, the trigger will fire on Friday the 14th.
  If the 15th is a Sunday, the trigger will fire on Monday the 16th.
  If the 15th is a Tuesday, then it will fire on Tuesday the 15th.
  However if you specify `1W` as the value for day-of-month, and the 1st is a Saturday, the trigger will fire on Monday the 3rd, as it will not ‘jump’ over the boundary of a month’s days.
  The ‘W’ character can only be specified when the day-of-month is a single day, not a range or list of days.

  {{% note %}}
  The 'L' and 'W' characters can also be combined in the day-of-month field to yield 'LW', which translates to *"last weekday of the month"*.
  {{% /note %}}

* `#` - used to specify _the nth_ XXX day of the month.
  For example, the value of `6#3` in the day-of-week field means _the third Friday of the month_ (day 6 = Friday and `#3` = the 3rd one in the month).
  Other examples: `2#1` = the first Monday of the month and `4#5` = the fifth Wednesday of the month.
  Note that if you specify `#5` and there is not 5 of the given day-of-week in the month, then no firing will occur that month.

  {{% note %}}
  The legal characters and the names of months and days of the week are not case sensitive. MON is the same as mon.
  {{% /note %}}


## Examples

Expression                 | Meaning
---------------------------|--------
`0 0 12 * * ?`             | Fire at 12pm (noon) every day
`0 15 10 ? * *`            | Fire at 10:15am every day
`0 15 10 * * ?`            | Fire at 10:15am every day
`0 15 10 * * ? *`          | Fire at 10:15am every day
`0 15 10 * * ? 2005`       | Fire at 10:15am every day during the year 2005
`0 * 14 * * ?`             | Fire every minute starting at 2pm and ending at 2:59pm, every day
`0 0/5 14 * * ?`           | Fire every 5 minutes starting at 2pm and ending at 2:55pm, every day
`0 0/5 14,18 * * ?`        | Fire every 5 minutes starting at 2pm and ending at 2:55pm, AND fire every 5 minutes starting at 6pm and ending at 6:55pm, every day
`0 0-5 14 * * ?`           | Fire every minute starting at 2pm and ending at 2:05pm, every day
`0 10,44 14 ? 3 WED`       | Fire at 2:10pm and at 2:44pm every Wednesday in the month of March.
`0 15 10 ? * MON-FRI`      | Fire at 10:15am every Monday, Tuesday, Wednesday, Thursday and Friday
`0 15 10 15 * ?`           | Fire at 10:15am on the 15th day of every month
`0 15 10 L * ?`            | Fire at 10:15am on the last day of every month
`0 15 10 L-2 * ?`          | Fire at 10:15am on the 2nd-to-last last day of every month
`0 15 10 ? * 6L`           | Fire at 10:15am on the last Friday of every month
`0 15 10 ? * 6L`           | Fire at 10:15am on the last Friday of every month
`0 15 10 ? * 6L 2002-2005` | Fire at 10:15am on every last friday of every month during the years 2002, 2003, 2004 and 2005
`0 15 10 ? * 6#3`          | Fire at 10:15am on the third Friday of every month
`0 0 12 1/5 * ?`           | Fire at 12pm (noon) every 5 days every month, starting on the first day of the month.
`0 11 11 11 11 ?`          | Fire every November 11th at 11:11am.

