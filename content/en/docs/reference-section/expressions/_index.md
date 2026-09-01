---
title: "Expression functions"
linkTitle: "Expression functions"
weight: 50
date: 2021-07-27
tags:
  - dashboard
  - expression
description: >
  Expression language used to manipulate data on Stroom Dashboards and Queries.
cascade:
  tags:
    - expression
---

Expressions can be used to manipulate data on Stroom Dashboards and Queries.

Each function has a name, and some have additional aliases.

In some cases, functions can be nested.
The return value for some functions being used
as the arguments for other functions.

The arguments to functions can either be other functions, literal values, or they can refer to fields on the input data using the field reference `${val}` syntax.

{{< cardpane >}}

  {{< card header="Aggregate Functions" >}}
  * [Average](aggregate#average)
  * [Count](aggregate#count)
  * [Count Groups](aggregate#count-groups)
  * [Count Unique](aggregate#count-unique)
  * [Distinct](aggregate#distinct)
  * [Joining](aggregate#joining)
  * [Max](aggregate#max)
  * [Min](aggregate#min)
  * [Period](aggregate#period)
  * [Standard Deviation](aggregate#stdev-standard-deviation)
  * [Sum](aggregate#sum)
  * [Variance](aggregate#variance)
  {{< /card >}}

  {{< card header="String Functions" >}}
  * [Concat](string#concat)
  * [Decode](string#decode)
  * [DecodeUrl](string#decodeurl)
  * [EncodeUrl](string#encodeurl)
  * [Exclude](string#exclude)
  * [Hash](string#hash)
  * [Include](string#include)
  * [Index Of](string#index-of)
  * [Jq](string#jq)
  * [Last Index Of](string#last-index-of)
  * [Lower Case](string#lower-case)
  * [Match](string#match)
  * [Param](string#param)
  * [Params](string#params)
  * [Replace](string#replace)
  * [String Length](string#string-length)
  * [Substring](string#substring)
  * [Substring After](string#substring-after)
  * [Substring Before](string#substring-before)
  * [Upper Case](string#upper-case)
  * [XPath](string#xpath)
  {{< /card >}}

  {{< card header="Mathematics Functions" >}}
  * [Add](mathematics#add)
  * [Average](mathematics#average)
  * [Divide](mathematics#divide)
  * [Max](mathematics#max)
  * [Min](mathematics#min)
  * [Modulo](mathematics#modulo)
  * [Multiply](mathematics#multiply)
  * [Negate](mathematics#negate)
  * [Power](mathematics#power)
  * [Random](mathematics#random)
  * [Subtract](mathematics#subtract)
  * [Sum](mathematics#sum)
  {{< /card >}}

  {{< card header="Type Checking Functions" >}}
  * [Is Boolean](type-checking#is-boolean)
  * [Is Double](type-checking#is-double)
  * [Is Error](type-checking#is-error)
  * [Is Integer](type-checking#is-integer)
  * [Is Long](type-checking#is-long)
  * [Is Null](type-checking#is-null)
  * [Is Number](type-checking#is-number)
  * [Is String](type-checking#is-string)
  * [Is Value](type-checking#is-value)
  * [Type Of](type-checking#type-of)
  {{< /card >}}

{{< /cardpane >}}

{{< cardpane >}}
  {{< card header="Link Functions" >}}
  * [Annotation](link#annotation)
  * [Create Annotation](link#create-annotation)
  * [Dashboard](link#dashboard)
  * [Data](link#data)
  * [Link](link#link)
  * [Stepping](link#stepping)
  {{< /card >}}

  {{< card header="Cast Functions" >}}
  * [To Boolean](cast#to-boolean)
  * [To Double](cast#to-double)
  * [To Float](cast#to-float)
  * [To Integer](cast#to-integer)
  * [To Long](cast#to-long)
  * [To String](cast#to-string)
  {{< /card >}}

  {{< card header="Date Functions" >}}
  * [Format Date](date#format-date)
  * [Parse Date](date#parse-date)
  * [Ceiling Functions](date#ceiling-yearmonthweekdayhourminutesecond)
  * [Floor Functions](date#floor-yearmonthweekdayhourminutesecond)
  * [Round Functions](date#round-yearmonthweekdayhourminutesecond)
  * [Is Weekend](date#is-weekend)
  * [Now](date#now)
  * [Current Period Functions](date#current-period-functions)
  * [Parse Duration](date#parse-duration)
  * [Format Duration](date#format-duration)
  * [Parse ISO Duration](date#parse-iso-duration)
  * [Format ISO Duration](date#format-iso-duration)
  {{< /card >}}

  {{< card header="Logic Functions" >}}
  * [Equals](logic#equals)
  * [Greater Than](logic#greater-than)
  * [Greater Than or Equal To](logic#greater-than-or-equal-to)
  * [If](logic#if)
  * [Less Than](logic#less-than)
  * [Less Than or Equal To](logic#less-than-or-equal-to)
  * [Not](logic#not)
  * [Case](logic#case)
  * [InRange](logic#inrange)
  * [Not Equals](logic#not-equals)
  {{< /card >}}

{{< /cardpane >}}

{{< cardpane >}}

  {{< card header="Rounding Functions" >}}
  * [Ceiling](mathematics#rounding-functions)
  * [Floor](mathematics#rounding-functions)
  * [Round](mathematics#rounding-functions)
  {{< /card >}}

  {{< card header="Selection Functions" >}}
  * [Any](selection#any)
  * [Bottom](selection#bottom)
  * [First](selection#first)
  * [Last](selection#last)
  * [Nth](selection#nth)
  * [Top](selection#top)
  {{< /card >}}

  {{< card header="URI Functions" >}}
  * [extractAuthorityFromUri](uri#extractauthorityfromuri)
  * [extractFragmentFromUri](uri#extractfragmentfromuri)
  * [extractHostFromUri](uri#extracthostfromuri)
  * [extractPathFromUri](uri#extractpathfromuri)
  * [extractPortFromUri](uri#extractportfromuri)
  * [extractQueryFromUri](uri#extractqueryfromuri)
  * [extractSchemeFromUri](uri#extractschemefromuri)
  * [extractSchemeSpecificPartFromUri](uri#extractschemespecificpartfromuri)
  * [extractUserInfoFromUri](uri#extractuserinfofromuri)
  {{< /card >}}

  {{< card header="Param Functions" >}}
  * [Current User](param#current-user)
  * [Current User Display Name](param#current-user-display-name)
  * [Current User Full Name](param#current-user-full-name)
  * [Current User Subject Id](param#current-user-subject-id)
  * [Current User Uuid](param#current-user-uuid)
  {{< /card >}}

  {{< card header="AI Functions" >}}
  * [AI](ai#ai)
  {{< /card >}}

  {{< card header="Lookup Functions" >}}
  * [Get State](lookup#get-state)
  {{< /card >}}

  {{< card header="Value Functions" >}}
  * [Err](value#err)
  * [False](value#false)
  * [Format IEC Byte Size](value#format-iec-byte-size)
  * [Format Metric Byte Size](value#format-metric-byte-size)
  * [Null](value#null)
  * [True](value#true)
  {{< /card >}}

{{< /cardpane >}}

