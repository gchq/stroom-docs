# Type checking functions

<!-- vim-markdown-toc GFM -->
* [Is Boolean](#is-boolean)
* [Is Double](#is-double)
* [Is Error](#is-error)
* [Is Integer](#is-integer)
* [Is Long](#is-long)
* [Is Null](#is-null)
* [Is Number](#is-number)
* [Is String](#is-string)
* [Is Value](#is-value)
* [Type Of](#type-of)
<!-- vim-markdown-toc -->

## Is Boolean
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
Checks if the passed value is a _double_ data type.
```
isDouble(arg1)
```
Examples:
```
isDouble(toDouble('1.2'))
> true
```

## Is Error
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

## Is Integer
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
Checks if the passed value is a _long_ data type.
```
isLong(arg1)
```
Examples:
```
isLong(toLong('1'))
> true
```

## Is Null
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

## Is Number
Checks if the passed value is a numeric data type.
```
isNumber(arg1)
```
Examples:
```
isNumber(toLong('1'))
> true
```

## Is String
Checks if the passed value is a _string_ data type.
```
isString(arg1)
```
Examples:
```
isString(toString(1.2))
> true
```

## Is Value
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

## Type Of
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