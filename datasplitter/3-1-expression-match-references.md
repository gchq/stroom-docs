# Expression match references

Referencing matches in expressions is done using `$`. In addition to this a match group number may be added to just retrieve part of the expression match. The applicability and effect that this has depends on the type of expression used.

## <a id="sec_3_1_1"></a>References to &lt;split&gt; Match Groups

In the following example a line matched by a parent `<split>` expression is referenced by a child `<data>` element.

```xml
<split delimiter="\n" >
  <data name="line" value="$"/>
</split>
```

A `<split>` element matches content up to and including the specified [delimiter](2-2-expressions.md#sec_2_2_1_1_2), so the above reference would output the entire line plus the delimiter. However there are various match groups that can be used by child `<group>` and `<data>` elements to reference sections of the matched content.

To illustrate the content provided by each match group, take the following example:

```
"This is some text\, that we wish to match", "This is the next text"
```

And the following `<split>` element:

```xml
<split delimiter="," escape="\">
```

The match groups are as follows:

* $ or $0: The entire content that is matched including the specified delimiter at the end

`"This is some text\, that we wish to match",`

* $1: The content up to the specified delimiter at the end

`"This is some text\, that we wish to match"`

* $2: The content up to the specified delimiter at the end and filtered to remove escape characters (more expensive than $1)

`"This is some text, that we wish to match"`

In addition to this behaviour match groups 1 and 2 will omit outermost whitespace and container characters if specified, e.g. with the following content:

```
"  This is some text\, that we wish to match  "  , "This is the next text"
```

And the following `<split>` element:

```xml
<split delimiter="," escape="\" containerStart="&quot" containerEnd="&quot">
```

The match groups are as follows:

* $ or $0: The entire content that is matched including the specified delimiter at the end

`"  This is some text\, that we wish to match  "  ,`

* $1: The content up to the specified delimiter at the end and strips outer containers.

`This is some text\, that we wish to match`

* $2: The content up to the specified delimiter at the end and strips outer containers and filtered to remove escape characters (more computationally expensive than $1)

`This is some text, that we wish to match`

## <a id="sec_3_1_2"></a>References to &lt;regex&gt; Match Groups

Like the `<split>` element various match groups can be referenced in a `<regex>` expression to retrieve portions of matched content. This content can be used as values for `<group>` and `<data>` elements.

Given the following input:

```
ip=1.1.1.1 user=user1
```

And the following `<regex>` element:

```xml
<regex pattern="ip=([^ ]+) user=([^ ]+)">
```

The match groups are as follows:

* $ or $0: The entire content that is matched by the expression

`ip=1.1.1.1 user=user1`

* $1: The content of the first match group

`1.1.1.1`

* $2: The content of the second match group

`user1`

Match group numbers in regular expressions are determined by the order that their open bracket appears in the expression.

## <a id="sec_3_1_3"></a>References to &lt;any&gt; Match Groups

The `<any>` element does not have any match groups and always returns the entire content that was passed to it when referenced with $.