# Cast Functions
A set of functions for converting between different data types or for working with data types.

<!-- vim-markdown-toc GFM -->
* [To Boolean](#to-boolean)
* [To Double](#to-double)
* [To Integer](#to-integer)
* [To Long](#to-long)
* [To String](#to-string)
<!-- vim-markdown-toc -->

## To Boolean
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
Attempts to convert the passed value to a _string_ data type.
```
toString(arg1)
```
Examples:
```
toString(1.2)
> '1.2'
```