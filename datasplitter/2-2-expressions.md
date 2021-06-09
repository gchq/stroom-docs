# Expressions

Expressions match some data supplied by a parent content provider. The content matched by an expression depends on the type of expression and how it is configured.

The `<split>`, `<regex>` and `<all>` elements are all expressions and match content as described below.

## <a name="sec_2_2_1"></a>The &lt;split&gt; element

The `<split>` element directs Data Splitter to break up content using a specified character sequence as a delimiter. In addition to this it is possible to specify characters that are used to escape the delimiter as well as characters that contain or "quote" a value that may include the delimiter sequence but allow it to be ignored.

### <a name="sec_2_2_1_1"></a>Attributes

The `<split>` element has the following attributes:

* [id](#sec_2_2_1_1_1)
* [delimiter](#sec_2_2_1_1_2)
* [escape](#sec_2_2_1_1_3)
* [containerStart](#sec_2_2_1_1_4)
* [containerEnd](#sec_2_2_1_1_5)
* [maxMatch](#sec_2_2_1_1_6)
* [minMatch](#sec_2_2_1_1_7)
* [onlyMatch](#sec_2_2_1_1_8)

#### <a name="sec_2_2_1_1_1"></a>id

Optional attribute used to debug the location of expressions causing errors, see [id](2-1-content-providers.md#sec_2_1_2_1_1).

#### <a name="sec_2_2_1_1_2"></a>delimiter

A required attribute used to specify the character string that will be used as a delimiter to split the supplied content unless it is preceded by an escape character or within a container if specified. Several of the previous examples use this attribute.

#### <a name="sec_2_2_1_1_3"></a>escape

An optional attribute used to specify a character sequence that is used to escape the delimiter. Many delimited text formats have an escape character that is used to tell any parser that the following delimiter should be ignored, e.g. often a character such as '\' is used to escape the character that follows it so that it is not treated as a delimiter. When specified this escape sequence also applies to any container characters that may be specified.

#### <a name="sec_2_2_1_1_4"></a>containerStart

An optional attribute used to specify a character sequence that will make this expression ignore the presence of delimiters until an end container is found. If the character is preceded by the specified escape sequence then this container sequence will be ignored and the expression will continue matching characters up to a delimiter.

If used `containerEnd` must also be specified. If the container characters are to be ignored from the match then match group 1 must be used instead of 0.

#### <a name="sec_2_2_1_1_5"></a>containerEnd

An optional attribute used to specify a character sequence that will make this expression stop ignoring the presence of delimiters if it believes it is currently in a container. If the character is preceded by the specified escape sequence then this container sequence will be ignored and the expression will continue matching characters while ignoring the presence of any delimiter.

If used `containerStart` must also be specified. If the container characters are to be ignored from the match then match group 1 must be used instead of 0.

#### <a name="sec_2_2_1_1_6"></a>maxMatch

An optional attribute used to specify the maximum number of times this expression is allowed to match the supplied content. If you do not supply this attribute then the Data Splitter will keep matching the supplied content until it reaches the end. If specified Data Splitter will stop matching the supplied content when it has matched it the specified number of times.

This attribute is used in the ['CSV with header line'](1-2-simple-csv-example-with-heading.md) example to ensure that only the first line is treated as a header line.

#### <a name="sec_2_2_1_1_7"></a>minMatch

An optional attribute used to specify the minimum number of times this expression should match the supplied content. If you do not supply this attribute then Data Splitter will not enforce that the expression matches the supplied content. If specified Data Splitter will generate an error if the expression does not match the supplied content at least as many times as specified.

Unlike `maxMatch`, `minMatch` does not control the matching process but instead controls the production of error messages generated if the parser is not seeing the expected input.

#### <a name="sec_2_2_1_1_8"></a>onlyMatch

Optional attribute to use this expression only for specific instances of a match of the parent expression, e.g. on the 4th, 5th and 8th matches of the parent expression specified by '4,5,8'. This is used when this expression should only be used to subdivide content from certain parent matches.

## <a name="sec_2_2_2"></a>The &lt;regex&gt; element

The `<regex>` element directs Data Splitter to match content using the specified regular expression pattern. In addition to this the same match control attributes that are available on the `<split>` element are also present as well as attributes to alter the way the pattern works.

### <a name="sec_2_2_2_1"></a>Attributes

The `<regex>` element has the following attributes:

* [id](#sec_2_2_2_1_1)
* [pattern](#sec_2_2_2_1_2)
* [dotAll](#sec_2_2_2_1_3)
* [caseInsensitive](#sec_2_2_2_1_4)
* [maxMatch](#sec_2_2_2_1_5)
* [minMatch](#sec_2_2_2_1_6)
* [onlyMatch](#sec_2_2_2_1_7)
* [advance](#sec_2_2_2_1_8)

#### <a name="sec_2_2_2_1_1"></a>id

Optional attribute used to debug the location of expressions causing errors, see [id](2-1-content-providers.md#sec_2_1_2_1_1).

#### <a name="sec_2_2_2_1_2"></a>pattern

This is a required attribute used to specify a regular expression to use to match on the supplied content. The pattern is used to match the content multiple times until the end of the content is reached while the maxMatch and onlyMatch conditions are satisfied.

#### <a name="sec_2_2_2_1_3"></a>dotAll

An optional attribute used to specify if the use of '.' in the supplied pattern matches all characters including new lines. If 'true' '.' will match all characters including new lines, if 'false' it will only match up to a new line. If this attribute is not specified it defaults to 'false' and will only match up to a new line.

This attribute is used in many of the multiline examples above.

#### <a name="sec_2_2_2_1_4"></a>caseInsensitive

An optional attribute used to specify if the supplied pattern should match content in a case insensitive way. If 'true' the expression will match content in a case insensitive manner, if 'false' it will match the content in a case sensitive manner. If this attribute is not specified it defaults to 'false' and will match the content in a case sensitive manner.

#### <a name="sec_2_2_2_1_5"></a>maxMatch

This is used in the same way it is on the `<split>` element, see [maxMatch](#sec_2_2_1_1_6).

#### <a name="sec_2_2_2_1_6"></a>minMatch

This is used in the same way it is on the `<split>` element, see [minMatch](#sec_2_2_1_1_7).

#### <a name="sec_2_2_2_1_7"></a>onlyMatch

This is used in the same way it is on the `<split>` element, see [onlyMatch](#sec_2_2_1_1_8).

#### <a name="sec_2_2_2_1_8"></a>advance

After an expression has matched content in the buffer, the buffer start position is advanced so that it moves to the end of the entire match. This means that subsequent expressions operating on the content buffer will not see the previously matched content again. This is normally required behaviour, but in some cases some of the content from a match is still required for subsequent matches. Take the following example of name value pairs:

```
name1=some value 1 name2=some value 2 name3=some value 3
```

The first name value pair could be matched with the following expression:

```xml
<regex pattern="([^=]+)=(.+?) [^= ]+=">
```

The above expression would match as follows:

```
name1=some value 1 name2=some value 2 name3=some value 3
```

In this example we have had to do a reluctant match to extract the value in group 2 and not include the subsequent name. Because the reluctant match requires us to specify what we are reluctantly matching up to, we have had to include an expression after it that matches the next name.

By default the parser will move the character buffer to the end of the entire match so the next expression will be presented with the following:

```
some value 2 name3=some value 3
```

Therefore `name2` will have been lost from the content buffer and will not be available for matching.

This behaviour can be altered by telling the expression how far to advance the character buffer after matching. This is done with the advance attribute and is used to specify the match group whose end position should be treated as the point the content buffer should advance to, e.g.

```xml
<regex pattern="([^=]+)=(.+?) [^= ]+=" advance="2">
```

In this example the content buffer will only advance to the end of match group 2 and subsequent expressions will be presented with the following content:

```
name2=some value 2 name3=some value 3
```

Therefore `name2` will still be available in the content buffer.

It is likely that the advance feature will only be useful in cases where a reluctant match is performed. Reluctant matches are discouraged for performance reasons so this feature should rarely be used. A better way to tackle the above example would be to present the content in [reverse](2-1-content-providers.md#sec_2_1_2_1_5), however this is only possible if the expression is within a group, i.e. is not a root expression. There may also be more complex cases where reversal is not an option and the use of a reluctant match is the only option.

## <a name="sec_2_2_3"></a>The &lt;all&gt; element

The `<all>` element matches the entire content of the parent group and makes it available to child groups or `<data>` elements. The purpose of `<all>` is to act as a catch all expression to deal with content that is not handled by a more specific expression, e.g. to output some other unknown, unrecognised or unexpected data.

```xml
<group>
  <regex pattern="^\s*([^=]+)=([^=]+)\s*">
    <data name="$1" value="$2" />
  </regex>

  <!-- Output unexpected data -->
  <all>
    <data name="unknown" value="$" />
  </all>
</group>
```

The `<all>` element provides the same functionality as using `.*` as a pattern in a `<regex>` element and where dotAll is set to true, e.g. `<regex pattern=".*" dotAll="true">`. However it performs much faster as it doesn’t require pattern matching logic and is therefore always preferred.

### <a name="sec_2_2_3_1"></a>Attributes

The `<all>` element has the following attributes:

* [id](#sec_2_2_3_1_1)

#### <a name="sec_2_2_3_1_1"></a>id

Optional attribute used to debug the location of expressions causing errors, see [id](2-1-content-providers.md#sec_2_1_2_1_1).
