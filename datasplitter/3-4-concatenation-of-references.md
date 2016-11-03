# Concatenation of references

It is possible to concatenate multiple fixed strings and match group references using the `+` character. As with all references and fixed strings this can be done in `<group>` value and `<data>` name and value attributes. However concatenation does have some performance overhead as new buffers have to be created to store concatenated content.

A good example of concatenation is the production of ISO8601 date format from data in the previous example:

```
01/01/2010,00:00:00
```

Here the following `<regex>` could be used to extract the relevant date, time groups:

```xml
<regex pattern="(\d{2})/(\d{2})/(\d{4}),(\d{2}):(\d{2}):(\d{2})">
```

The match groups from this expression can be concatenated with the following value output pattern in the data element:

```xml
<data name="dateTime" value="$3+’-‘+$2+’-‘+$1+’-‘+’T’+$4+’:’+$5+’:’+$6+’.000Z’" />
```

Using the original example, this would result in the output:

```xml
<data name="dateTime" value="2010-01-01T00:00:00.000Z" />
```

Note that the value output pattern wraps all fixed strings in single quotes. This is necessary when concatenating strings and references so that Data Splitter can determine which parts are to be treated as fixed strings. This also allows fixed strings to contain `$` and `+` characters.

As single quotes are used for this purpose, a single quote needs to be escaped with another single quote if one is desired in a fixed string, e.g.

```
‘this ‘’is quoted text’’’
```

will result in:

```
this ‘is quoted text’
```