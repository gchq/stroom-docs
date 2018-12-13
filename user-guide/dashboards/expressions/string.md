# String Functions

<!-- vim-markdown-toc GFM -->
* [Concat](#concat)
* [Decode](#decode)
* [Exclude](#exclude)
* [Hash](#hash)
* [Include](#include)
* [Index Of](#index-of)
* [Last Index Of](#last-index-of)
* [Link](#link)
* [Lower Case](#lower-case)
* [Match](#match)
* [Replace](#replace)
* [String Length](#string-length)
* [Substring](#substring)
* [Substring After](#substring-after)
* [Substring Before](#substring-before)
* [Upper Case](#upper-case)
<!-- vim-markdown-toc -->

## Concat
Appends all the arguments end to end in a single string
```
concat(args...)
```

Example
```
concat('this ', 'is ', 'how ', 'it ', 'works')
> 'this is how it works'
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

## Exclude
If the supplied string matches one of the supplied match strings then return null, otherwise return the supplied string
```
exclude(aString, match...)
```

Example
```
exclude('hello', 'hello', 'hi')
> null
exclude('hi', 'hello', 'hi')
> null
exclude('bye', 'hello', 'hi')
> 'bye'
```

## Hash
Cryptographically hashes a string
```
hash(value)
hash(value, algorithm)
hash(value, algorithm, salt)
```

Example
```
hash(${val}, 'SHA-512', 'mysalt')
> A hashed result...
```

If not specified the `hash()` function will use the `SHA-256` algorithm. Supported algorithms are determined by Java runtime environment.

## Include
If the supplied string matches one of the supplied match strings then return it, otherwise return null
```
include(aString, match...)
```

Example
```
include('hello', 'hello', 'hi')
> 'hello'
include('hi', 'hello', 'hi')
> 'hi'
include('bye', 'hello', 'hi')
> null
```

## Index Of
Finds the first position of the second string within the first
```
indexOf(firstString, secondString)
```

Example
```
indexOf('aa-bb-cc', '-')
> 2
```

## Last Index Of
Finds the last position of the second string within the first
```
lastIndexOf(firstString, secondString)
```

Example
```
lastIndexOf('aa-bb-cc', '-')
> 5
```

## Link
Create a string that represents a hyperlink for display in a dashboard table.
```
link(url)
link(title, url)
link(title, url, type)
```

Example
```
link('http://www.somehost.com/somepath')
> [http://www.somehost.com/somepath](http://www.somehost.com/somepath)
link('Click Here','http://www.somehost.com/somepath')
> [Click Here](http://www.somehost.com/somepath)
link('Click Here','http://www.somehost.com/somepath', 'dialog')
> [Click Here](http://www.somehost.com/somepath){dialog}
link('Click Here','http://www.somehost.com/somepath', 'dialog|Dialog Title')
> [Click Here](http://www.somehost.com/somepath){dialog|Dialog Title}
```

Type can be one of:
* `dialog` : Display the content of the link URL within a stroom popup dialog.
* `tab` : Display the content of the link URL within a stroom tab.
* `browser` : Display the content of the link URL within a new browser tab.
* `dashboard` : Used to launch a stroom dashboard internally with parameters in the URL.

## Lower Case
Converts the string to lower case
```
lowerCase(aString)
```

Example
```
lowerCase('Hello DeVeLoPER')
> 'hello developer'
```

## Match
Test an input string using a regular expression to see if it matches
```
match(input, regex)
```

Example
```
match('this', 'this')
> true
match('this', 'that')
> false
```

## Replace
Perform text replacement on an input string using a regular expression to match part (or all) of the input string and a replacement string to insert in place of the matched part
```
replace(input, regex, replacement)
```

Example
```
replace('this', 'is', 'at')
> 'that'
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

## Substring After
Get the substring from the first string that occurs after the presence of the second string
```
substringAfter(firstString, secondString)
```

Example
```
substringAfter('aa-bb', '-')
> 'bb'
```

## Substring Before
Get the substring from the first string that occurs before the presence of the second string
```
substringBefore(firstString, secondString)
```

Example
```
substringBefore('aa-bb', '-')
> 'aa'
```

## Upper Case
Converts the string to upper case
```
upperCase(aString)
```

Example
```
upperCase('Hello DeVeLoPER')
> 'HELLO DEVELOPER'
```
