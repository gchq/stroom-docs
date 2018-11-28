# Dashboard Expressions

Expressions can be used to manipulate data on Stroom Dashboards.

Each function has a name, and some have additional aliases.

In some cases, functions can be nested. The return value for some functions being used
as the arguments for other functions. Each function documented below will indicate if it can
contain nested children.

The arguments can either be literal values, or they can refer to fields on the input data using the ${} syntax.
A function Generator is given arrays of values for each 'row':
A FieldIndexMap is used to map named fields to indexes of these arrays

Example
``` java
FieldIndexMap fim = FieldIndexMap.forFields("name", "age", "occupation")
Generator g = parseExpression("concat(${name}, ${age})")

g.addData("JDoe", 45, "Butcher")
g.addData("JBloggs", 23, "Baker")
g.addData("JSmith", 34, "Candlestick Maker")

g.eval
```

```
> [
    'JDoe45',
    'JBloggs23',
    'JSmith34'
]
```


# Table of Contents

<!-- vim-markdown-toc GFM -->
* [Mathematics Functions](#mathematics-functions)
    * [Add](#add)
    * [Subtract](#subtract)
    * [Multiply](#multiply)
    * [Divide](#divide)
    * [Power](#power)
    * [Negate](#negate)
    * [Random](#random)
* [Logic Functions](#logic-functions)
    * [Equals](#equals)
    * [Greater Than](#greater-than)
    * [Less Than](#less-than)
    * [Greater Than or Equal To](#greater-than-or-equal-to)
    * [Less Than or Equal To](#less-than-or-equal-to)
* [Aggregation Functions](#aggregation-functions)
    * [Max](#max)
    * [Min](#min)
    * [Sum](#sum)
    * [Average](#average)
* [Rounding Functions](#rounding-functions)
    * [Ceiling](#ceiling)
    * [Floor](#floor)
    * [Round](#round)
    * [Ceiling Year/Month/Day/Hour/Minute/Second](#ceiling-yearmonthdayhourminutesecond)
    * [Floor Year/Month/Day/Hour/Minute/Second](#floor-yearmonthdayhourminutesecond)
    * [Round Year/Month/Day/Hour/Minute/Second](#round-yearmonthdayhourminutesecond)
* [Counting Functions](#counting-functions)
    * [Count](#count)
    * [Count Groups](#count-groups)
* [String Functions](#string-functions)
    * [Replace](#replace)
    * [Concatenate](#concatenate)
    * [String Length](#string-length)
    * [Upper Case](#upper-case)
    * [Lower Case](#lower-case)
    * [Substring](#substring)
    * [Decode](#decode)
* [URI Functions](#uri-functions)
    * [extractAuthorityFromUri](#extractauthorityfromuri)
    * [extractFragmentFromUri](#extractfragmentfromuri)
    * [extractHostFromUri](#extracthostfromuri)
    * [extractPathFromUri](#extractpathfromuri)
    * [extractPortFromUri](#extractportfromuri)
    * [extractQueryFromUri](#extractqueryfromuri)
    * [extractSchemeFromUri](#extractschemefromuri)
    * [extractSchemeSpecificPartFromUri](#extractschemespecificpartfromuri)
    * [extractUserInfoFromUri](#extractuserinfofromuri)
    
* [Cast Functions](#cast-functions)
    * [To Boolean](#to-boolean)
    * [To Double](#to-double)
    * [To Integer](#to-integer)
    * [To Long](#to-long)
    * [To String](#to-string)
* [Type Checking Functions](#type-checking-functions)
    * [Is Boolean](#is-boolean)
    * [Is Double](#is-double)
    * [Is Integer](#is-integer)
    * [Is Long](#is-long)
    * [Is String](#is-string)
    * [Is Number](#is-number)
    * [Is Value](#is-value)
    * [Is Null](#is-null)
    * [Is Error](#is-error)
    * [Type Of](#type-of)
* [Constant Functions](#constant-functions)
    * [True](#true)
    * [False](#false)
    * [Null](#null)
    * [Err](#err)

<!-- vim-markdown-toc -->

# Mathematics Functions

## Add
Allows Nesting: Yes
```
arg1 + arg2
```
Or reduce the args by successive addition
```
add(args...)
```

Examples
```
34 + 9
> 43
add(45, 6, 72)
> 123
```

## Subtract
Allows Nesting: Yes
```
arg1 - arg2
```
Or reduce the args by successive subtraction
```
subtract(args...)
```

Examples
```
29 - 8
> 21
subtract(100, 20, 34, 2)
> 44
```

## Multiply
Allows Nesting: Yes
Multiplies arg1 by arg2
```
arg1 * arg2
```
Or reduce the args by successive multiplication
```
multiply(args...)
```

Examples
```
4 * 5
> 20
multiply(4, 5, 2, 6)
> 240
```

## Divide
Allows Nesting: Yes
Divides arg1 by arg2
```
arg1 / arg2
```
Or reduce the args by successive division
```
divide(args...)
```

Examples
```
42 / 7
> 6
divide(1000, 10, 5, 2)
> 10
divide(100, 4, 3)
> 8.33
```

## Power
Allows Nesting: Yes
Raises arg1 to the power arg2
```
arg1 ^ arg2
```
Or reduce the args by successive raising to the power
```
power(args...)
```

Examples
```
4 ^ 3
> 64
power(2, 4, 3)
> 4096
```

## Negate
Allows Nesting: Yes
Multiplies arg1 by -1
```
negate(arg1)
```

Examples
```
negate(80)
> -80
negate(23.33)
> -23.33
negage(-9.5)
> 9.5
```

## Random
Allows Nesting: No
Generates a random number between 0.0 and 1.0
```
random()
```

Examples
```
random()
> 0.78
random()
> 0.89
...you get the idea
```

# Logic Functions

## Equals
Allows Nesting: Yes
Evaluates if arg1 is equal to arg2
```
arg1 = arg2
equals(arg1, arg2)
```

Examples
```
equals(${val1}, ${val2})
g.setValues("plop", "plip");
g.eval()
> false

equals(${val1}, 'blob')
g.setValues("blob");
g.eval()
> true
```

Note that `equals` cannot be applied to `null` and `error` values, e.g. `x=null()` or `x=err()`. The [`isNull()`](#is-null) and [`isError()`](#is-error) functions must be used instead.

## Greater Than
Allows Nesting: Yes
Evaluates if arg1 is greater than to arg2
```
arg1 > arg2
greaterThan(arg1, arg2)
```

Examples
```
greaterThan(${val1}, 50)
g.setValues(70);
g.eval()
> true

g.setValues(20);
g.eval()
> false
```

## Less Than
Allows Nesting: Yes
Evaluates if arg1 is less than to arg2
```
arg1 < arg2
lessThan(arg1, arg2)
```

Examples
```
lessThan(${val1}, 30)
g.setValues(45);
g.eval()
> false

g.setValues(15);
g.eval()
> true
```

## Greater Than or Equal To
Allows Nesting: Yes
Evaluates if arg1 is greater than or equal to arg2
```
arg1 >= arg2
greaterThanOrEqualTo(arg1, arg2)
```

Examples
```
greaterThanOrEqualTo(${val1}, 50)
g.setValues(70);
g.eval()
> true

g.setValues(50);
g.eval()
> true

g.setValues(49);
g.eval()
> false
```

## Less Than or Equal To
Allows Nesting: Yes
Evaluates if arg1 is less than or equal to arg2
```
arg1 <= arg2
lessThanOrEqualTo(arg1, arg2)
```

Examples
```
lessThanOrEqualTo(${val1}, 25)
g.setValues(45);
g.eval()
> false

g.setValues(25);
g.eval()
> true

g.setValues(24);
g.eval()
> true
```

# Aggregation Functions

## Max
Allows Nesting: Yes
Determines the maximum value given in the args
```
max(args...)
```

Examples
```
max(100, 30, 45, 109)
> 109

# They can be nested
max(max(${val}), 40, 67, 89)
${val} = [20, 1002]
> 1002
```

## Min
Allows Nesting: Yes
Determines the minimum value given in the args
```
min(args...)
```

Examples
```
min(100, 30, 45, 109)
> 30

# They can be nested
min(max(${val}), 40, 67, 89)
${val} = [20, 1002]
> 20
```

## Sum
Allows Nesting: Yes
Sums all the arguments together
```
sum(args...)
```

Examples
```
sum(89, 12, 3, 45)
> 149
```

## Average
Allows Nesting: Yes
Takes an average value of the arguments
```
average(args...)
mean(args...)
```

Examples
```
average(10, 20, 30, 40)
> 25
mean(8.9, 24, 1.2, 1008)
> 260.525
```

# Rounding Functions
Allows Nesting: Yes

These functions require a value, and an optional decimal places.
If the decimal places are not given it will give you nearest whole number.


## Ceiling
```
ceiling(value, decimalPlaces<optional>)
```

Examples
```
ceiling(8.4234)
> 9
ceiling(4.56, 1)
> 4.6
ceiling(1.22345, 3)
> 1.223
```

## Floor
```
floor(value, decimalPlaces<optional>)
```

Examples
```
floor(8.4234)
> 8
floor(4.56, 1)
> 4.5
floor(1.2237, 3)
> 1.223
```

## Round
```
round(value, decimalPlaces<optional>)
```

Examples
```
round(8.4234)
> 8
round(4.56, 1)
> 4.6
round(1.2237, 3)
> 1.224
```

## Ceiling Year/Month/Day/Hour/Minute/Second
```
ceilingYear(args...)
ceilingMonth(args...)
ceilingDay(args...)
ceilingHour(args...)
ceilingMinute(args...)
ceilingSecond(args...)
```

Examples
```
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
```
floorYear(args...)
floorMonth(args...)
floorDay(args...)
floorHour(args...)
floorMinute(args...)
floorSecond(args...)
```

Examples
```
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
```
roundYear(args...)
roundMonth(args...)
roundDay(args...)
roundHour(args...)
roundMinute(args...)
roundSecond(args...)
```

Examples
```
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

# Counting Functions
These are aggregation functions

## Count
Allows Nesting: No

Counts the number of records that are passed through it. Doesn't take any notice of the values of any fields.

```
count()
```

Examples
```
g = count()

g.setData(...)
g.setData(...)
g.setData(...)

g.eval()
> 3
```

## Count Groups
Allows Nesting: No

This is used to count the number of unique values where there are multiple group levels.
For Example, a data set grouped as follows
1. Group by Name
2. Group by Type

A groupCount could be used to count the number of distinct values of 'type' for each value of 'name'

# String Functions

## Replace
1. A regex
2. The string to replace
3. The replacement string
```
replace(input, findThis, replaceWithThis)
```

Example
```
replace('this', 'is', 'at')

> 'that'
```

## Concatenate
Appends all the arguments end to end in a single string
```
concat(args...)
```

Example
```
concat('this ', 'is ', 'how ', 'it ', 'works')
> 'this is how it works'
```

## String Length
Takes the length of a string
```
stringLength(aString)
```

Example
```
stringLength('hello')
> 5
```

## Upper Case
Converts the string to upper case
```
upperCase(aString)
```

Example
```
upperCase('Hello DeVeLoPER')
> HELLO DEVELOPER
```

## Lower Case
Converts the string to lower case
```
lowerCase(aString)
```

Example
```
lowerCase('Hello DeVeLoPER')
> hello developer
```

## Substring
Take a substring based on start/end index of letters
```
substring(aString, startIndex, endIndex)
```

Example
```
substring('this', 1, 2)
> 'h'
```

## Decode
The arguments are split into 3 parts
1. The input value to test
2. Pairs of regex matchers with their respective output value
3. A default result, if the input doesn't match any of the regexes

```
decode(input, test1, result1, test2, result2, ... testN, resultN, otherwise)
```

It works much like a Java Switch/Case statement

Example
```
decode(${val}, 'red', 'rgb(255, 0, 0)', 'green', 'rgb(0, 255, 0)', 'blue', 'rgb(0, 0, 255)', 'rgb(255, 255, 255)')
${val}='blue'
> rgb(0, 0, 255)
${val}='green'
> rgb(0, 255, 0)
${val}='brown'
> rgb(255, 255, 255) // falls back to the 'otherwise' value
```

in Java, this would be equivalent to
```java

String decode(value) {
    switch(value) {
        case "red":
            return "rgb(255, 0, 0)"
        case "green":
            return "rgb(0, 255, 0)"
        case "blue":
            return "rgb(0, 0, 255)"
        default:
            return "rgb(255, 255, 255)"
    }
}
```

```
decode('red')
> 'rgb(255, 0, 0)'

```

# URI Functions

Fields containing a Uniform Resource Identifier (URI) in string form can queried to extract the URI's individual components of `authority`, `fragment`, `host`, `path`, `port`, `query`, `scheme`, `schemeSpecificPart` and `userInfo`. See either [RFC 2306: Uniform Resource Identifiers (URI): Generic Syntax](http://www.ietf.org/rfc/rfc2396.txt) or Java's java.net.URI Class for details regarding the components. If any component is not present within the passed URI, then an empty string is returned.

The extraction functions are

* extractAuthorityFromUri\(\) - extract the Authority component
* extractFragmentFromUri\(\) - extract the Fragment component
* extractHostFromUri\(\) - extract the Host component
* extractPathFromUri\(\) - extract the Path component
* extractPortFromUri\(\) - extract the Port component
* extractQueryFromUri\(\) - extract the Query component
* extractSchemeFromUri\(\) - extract the Scheme component
* extractSchemeSpecificPartFromUri\(\) - extract the Scheme specific part component
* extractUserInfoFromUri\(\) - extract the UserInfo component

If the URI is `http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&amp;p2=v2#more-details` the table below displays the extracted components

Expression | Extraction
--- | ---
extractAuthorityFromUri(${URI})	| foo:bar@w1.superman.com:8080
extractFragmentFromUri(${URI}) | more-details
extractHostFromUri(${URI}) | w1.superman.com
extractPathFromUri(${URI}) | /very/long/path.html
extractPortFromUri(${URI}) | 8080
extractQueryFromUri(${URI}) | p1=v1&amp;p2=v2
extractSchemeFromUri(${URI}) | http
extractSchemeSpecificPartFromUri(${URI}) | //foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&amp;p2=v2
extractUserInfoFromUri(${URI}) | foo:bar

## extractAuthorityFromUri
Extracts the Authority component from a URI

`extractAuthorityFromUri(uri)`

Example
```
extractAuthorityFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> foo:bar@w1.superman.com:8080
```

## extractFragmentFromUri
Extracts the Fragment component from a URI

`extractFragmentFromUri(uri)`

Example
```
extractFragmentFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> more-details
```

## extractHostFromUri
Extracts the Host component from a URI

`extractHostFromUri(uri)`

Example
```
extractHostFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> w1.superman.com
```

## extractPathFromUri
Extracts the Path component from a URI

`extractPathFromUri(uri)`

Example
```
extractPathFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> /very/long/path.html
```

## extractPortFromUri
Extracts the Port component from a URI

`extractPortFromUri(uri)`

Example
```
extractPortFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> 8080
```

## extractQueryFromUri
Extracts the Query component from a URI

`extractQueryFromUri(uri)`

Example
```
extractQueryFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> p1=v1&p2=v2
```

## extractSchemeFromUri
Extracts the Scheme component from a URI

`extractSchemeFromUri(uri)`

Example
```
extractSchemeFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> http
```

## extractSchemeSpecificPartFromUri
Extracts the SchemeSpecificPart component from a URI

`extractSchemeSpecificPartFromUri(uri)`

Example
```
extractSchemeSpecificPartFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> //foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2
```

## extractUserInfoFromUri
Extracts the UserInfo component from a URI

`extractUserInfoFromUri(uri)`

Example
```
extractUserInfoFromUri('http://foo:bar@w1.superman.com:8080/very/long/path.html?p1=v1&p2=v2#more-details')
> foo:bar
```

# Cast Functions
A set of functions for converting between different data types or for working with data types.

## To Boolean
Allows Nesting: Yes
Attempts to convert the passed value to a _boolean_ data type.
```
toBoolean(arg1)
```
Examples:
```
toBoolean(1)
> true
toBoolean(0)
> false
toBoolean('true')
> true
toBoolean('false')
> false
```

## To Double
Allows Nesting: Yes
Attempts to convert the passed value to a _double_ data type.
```
toDouble(arg1)
```
Examples:
```
toDouble('1.2')
> 1.2
```

## To Integer
Allows Nesting: Yes
Attempts to convert the passed value to a _integer_ data type.
```
toInteger(arg1)
```
Examples:
```
toInteger('1')
> 1
```

## To Long
Allows Nesting: Yes
Attempts to convert the passed value to a _long_ data type.
```
toLong(arg1)
```
Examples:
```
toLong('1')
> 1
```

## To String
Allows Nesting: Yes
Attempts to convert the passed value to a _string_ data type.
```
toString(arg1)
```
Examples:
```
toString(1.2)
> 1.2
```

# Type checking functions

## Is Boolean
Allows Nesting: Yes
Checks if the passed value is a _boolean_ data type.
```
isBoolean(arg1)
```
Examples:
```
isBoolean(toBoolean('true'))
> true
```

## Is Double
Allows Nesting: Yes
Checks if the passed value is a _double_ data type.
```
isDouble(arg1)
```
Examples:
```
isDouble(toDouble('1.2'))
> true
```

## Is Integer
Allows Nesting: Yes
Checks if the passed value is an _integer_ data type.
```
isInteger(arg1)
```
Examples:
```
isInteger(toInteger('1'))
> true
```

## Is Long
Allows Nesting: Yes
Checks if the passed value is a _long_ data type.
```
isLong(arg1)
```
Examples:
```
isLong(toLong('1'))
> true
```

## Is String
Allows Nesting: Yes
Checks if the passed value is a _string_ data type.
```
isString(arg1)
```
Examples:
```
isString(toString(1.2))
> true
```

## Is Number
Allows Nesting: Yes
Checks if the passed value is a numeric data type.
```
isNumber(arg1)
```
Examples:
```
isNumber(toLong('1'))
> true
```

## Is Value
Allows Nesting: Yes
Checks if the passed value is a value data type, e.g. not `null` or `error`.
```
isValue(arg1)
```
Examples:
```
isValue(toLong('1'))
> true
isValue(null())
> false
```

## Is Null
Allows Nesting: Yes
Checks if the passed value is `null`. Note that this method must be used to check for `null` as null equality using `x=null()` is not supported.
```
isNull(arg1)
```
Examples:
```
isNull(toLong('1'))
> false
isNull(null())
> true
```

## Is Error
Allows Nesting: Yes
Checks if the passed value is an error caused by an invalid evaluation of an expression on passed values, e.g. some values passed to an expression could result in a divide by 0 error. Note that this method must be used to check for `error` as error equality using `x=err()` is not supported.
```
isError(arg1)
```
Examples:
```
isError(toLong('1'))
> false
isError(err())
> true
```

## Type Of
Allows Nesting: Yes
Returns the data type of the passed value as a string.
```
typeOf(arg1)
```
Examples:
```
typeOf('abc')
> string
typeOf(toInteger(123))
> integer
typeOf(err())
> error
typeOf(null())
> null
typeOf(toBoolean('false'))
> false
```

# Constant functions

## True
Allows Nesting: No
Returns _boolean_ true.
```
true()
```

## False
Allows Nesting: No
Returns _boolean_ false.
```
false()
```

## Null
Allows Nesting: No
Returns _null_.
```
null()
```

## Err
Allows Nesting: No
Returns _err_.
```
err()
```
