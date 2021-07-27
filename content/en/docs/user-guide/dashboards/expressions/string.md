---
title: "String Functions"
linkTitle: "String Functions"
#weight:
date: 2021-07-27
tags: 
description: >
  Functions for manipulating strings (text data).
---

## Concat

Appends all the arguments end to end in a single string

```clike
concat(args...)
```

Example

```clike
concat('this ', 'is ', 'how ', 'it ', 'works')
> 'this is how it works'
```


## Current User

Returns the username of the user running the query.

```clike
currentUser()
```

Example

```clike
currentUser()
> 'jbloggs'
```

## Decode

The arguments are split into 3 parts

1. The input value to test
1. Pairs of regex matchers with their respective output value
1. A default result, if the input doesn't match any of the regexes

```clike
decode(input, test1, result1, test2, result2, ... testN, resultN, otherwise)
```

It works much like a Java Switch/Case statement

Example

```clike
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

```clike
decode('red')
> 'rgb(255, 0, 0)'

```

## DecodeUrl

Decodes a URL

```clike
decodeUrl('userId%3Duser1')
> userId=user1
```

## EncodeUrl

Encodes a URL

```clike
encodeUrl('userId=user1')
> userId%3Duser1
```

## Exclude

If the supplied string matches one of the supplied match strings then return null, otherwise return the supplied string

```clike
exclude(aString, match...)
```

Example

```clike
exclude('hello', 'hello', 'hi')
> null
exclude('hi', 'hello', 'hi')
> null
exclude('bye', 'hello', 'hi')
> 'bye'
```

## Hash

Cryptographically hashes a string

```clike
hash(value)
hash(value, algorithm)
hash(value, algorithm, salt)
```

Example

```clike
hash(${val}, 'SHA-512', 'mysalt')
> A hashed result...
```

If not specified the `hash()` function will use the `SHA-256` algorithm. Supported algorithms are determined by Java runtime environment.

## Include

If the supplied string matches one of the supplied match strings then return it, otherwise return null

```clike
include(aString, match...)
```

Example

```clike
include('hello', 'hello', 'hi')
> 'hello'
include('hi', 'hello', 'hi')
> 'hi'
include('bye', 'hello', 'hi')
> null
```

## Index Of

Finds the first position of the second string within the first

```clike
indexOf(firstString, secondString)
```

Example

```clike
indexOf('aa-bb-cc', '-')
> 2
```

## Last Index Of

Finds the last position of the second string within the first

```clike
lastIndexOf(firstString, secondString)
```

Example

```clike
lastIndexOf('aa-bb-cc', '-')
> 5
```

## Lower Case

Converts the string to lower case

```clike
lowerCase(aString)
```

Example

```clike
lowerCase('Hello DeVeLoPER')
> 'hello developer'
```

## Match

Test an input string using a regular expression to see if it matches

```clike
match(input, regex)
```

Example

```clike
match('this', 'this')
> true
match('this', 'that')
> false
```

## Query Param

Returns the value of the requested query parameter.

```clike
queryParam(paramKey)
```

Examples

```clike
queryParam('user')
> 'jbloggs'
```


## Query Params

Returns all query parameters as a space delimited string.

```clike
queryParams()
```

Examples

```clike
queryParams()
> 'user=jbloggs site=HQ'
```


## Replace

Perform text replacement on an input string using a regular expression to match part (or all) of the input string and a replacement string to insert in place of the matched part

```clike
replace(input, regex, replacement)
```

Example

```clike
replace('this', 'is', 'at')
> 'that'
```

## String Length

Takes the length of a string

```clike
stringLength(aString)
```

Example

```clike
stringLength('hello')
> 5
```

## Substring

Take a substring based on start/end index of letters

```clike
substring(aString, startIndex, endIndex)
```

Example

```clike
substring('this', 1, 2)
> 'h'
```

## Substring After

Get the substring from the first string that occurs after the presence of the second string

```clike
substringAfter(firstString, secondString)
```

Example

```clike
substringAfter('aa-bb', '-')
> 'bb'
```

## Substring Before

Get the substring from the first string that occurs before the presence of the second string

```clike
substringBefore(firstString, secondString)
```

Example

```clike
substringBefore('aa-bb', '-')
> 'aa'
```

## Upper Case

Converts the string to upper case

```clike
upperCase(aString)
```

Example

```clike
upperCase('Hello DeVeLoPER')
> 'HELLO DEVELOPER'
```
