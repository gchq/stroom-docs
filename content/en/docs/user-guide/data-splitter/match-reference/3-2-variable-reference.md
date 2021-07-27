---
title: "Variable reference"
linkTitle: "Variable reference"
#weight:
date: 2021-07-27
tags: 
description: >
  
---

Variables are added to Data Splitter configuration using the `<var>` element, see [variables](2-3-variables.md). Each variable must have a unique id so that it can be referenced. References to variables have the form `$VARIABLE_ID$`, e.g.

```xml
<data name="$heading$" value="$" />
```

## <a name="sec-3-2-1"></a>Identification

Data Splitter validates the configuration on load and ensures that all element ids are unique and that referenced ids belong to a variable.

A variable will only store data if it is referenced so variables that are not referenced will do nothing. In addition to this a variable will only store data for match groups that are referenced, e.g. if `$heading$1` is the only reference to a variable with an id of ‘heading’ then only data for match group 1 will be stored for reference lookup.

## <a name="sec-3-2-2"></a>Scopes

Variables have two scopes which affect how data is retrieved when referenced:

* [Local scope](#sec-3-2-2-1)
* [Remote scope](#sec-3-2-2-2)

### <a name="sec-3-2-2-1"></a>Local Scope

Variables are local to a reference if the reference exists as a descendant of the variables parent expression, e.g.

```xml
<split delimiter="\n" >
  <var id="line" />

  <group value="$1">
    <regex pattern="ip=([^ ]+) user=([^ ]+)">
      <data name="line" value="$line$"/>
      <data name="ip" value="$1"/>
      <data name="user" value="$2"/>
    </regex>
  </group>
</split>
```

In the above example, matches for the outermost `<split>` expression are stored in the variable with the id of `line`. The only reference to this variable is in a data element that is a descendant of the variables parent expression `<split>`, i.e. it is nested within split/group/regex.

Because the variable is referenced locally only the most recent parent match is relevant, i.e. no retrieval of values by 
[iteration](#sec-3-2-2-2-1), [iteration offset](#sec-3-2-2-2-2) or [fixed position](#sec-3-2-2-2-3) is applicable. These features only apply to remote variables that store multiple values.

### <a name="sec-3-2-2-2"></a>Remote Scope

The [CSV example with a heading](1-2-simple-csv-example-with-heading.md) is an example of a variable being referenced from a remote scope.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd" version="3.0">

  <!-- Match heading line (note that maxMatch="1" means that only the first line will be matched by this splitter) -->
  <split delimiter="\n" maxMatch="1">

    <!-- Store each heading in a named list -->
    <group>
      <split delimiter=",">
        <var id="heading" />
      </split>
    </group>
  </split>

  <!-- Match each record -->
  <split delimiter="\n">

    <!-- Take the matched line -->
    <group value="$1">

      <!-- Split the line up -->
      <split delimiter=",">

        <!-- Output the stored heading for each iteration and the value from group 1 -->
        <data name="$heading$1" value="$1" />
      </split>
    </group>
  </split>
</dataSplitter>
```

In the above example the parent expression of the variable is not the ancestor of the reference in the `<data>` element. This makes the `<data>` elements reference to the variable a remote one. In this situation the variable knows that it must store multiple values as the remote reference `<data>` may retrieve one of many values from the variable based on:

1. The match count of the parent expression.
2. The match count of the parent expression, plus or minus an offset.
3. A fixed position in the variable store.

#### <a name="sec-3-2-2-2-1"></a>Retrieval of value by iteration

In the above example the first line is taken then repeatedly matched by delimiting with commas. This results in multiple values being stored in the ‘heading’ variable. Once this is done subsequent lines are matched and then also repeatedly matched by delimiting with commas in the same way the heading is.

Each time a line is matched the internal match count of all sub expressions, (e.g. the `<split>` expression that is delimited by comma) is reset to 0. Every time the sub `<split>` expression matches up to a comma delimiter the match count is incremented. Any references to remote variables will, by default, use the current match count as an index to retrieve one of the many values stored in the variable. This means that the `<data>` element in the above example will retrieve the corresponding heading for each value as the match count of the values will match the storage position of each heading.

#### <a name="sec-3-2-2-2-2"></a>Retrieval of value by iteration offset

In some cases there may be a mismatch between the position where a value is stored in a variable and the match count applicable when remotely referencing the variable.

Take the following input:

```csv
BAD,Date,Time,IPAddress,HostName,User,EventType,Detail
01/01/2010,00:00:00,192.168.1.100,SOMEHOST.SOMEWHERE.COM,user1,logon,
```

In the above example we can see that the first heading ‘BAD’ is not correct for the first value of every line. In this situation we could either adjust the way the heading line is parsed to ignore ‘BAD’ or just adjust the way the heading variable is referenced.

To make this adjustment the reference just needs to be told what offset to apply to the current match count to correctly retrieve the stored value. In the above example this would be done like this:

```xml
<data name="$heading$1[+1]" value="$1" />
```

The above reference just uses the match count plus 1 to retrieve the stored value. Any integral offset plus or minus may be used, e.g. [+4] or [-10]. Offsets that result in a position that is outside of the storage range for the variable will not return a value.

#### <a name="sec-3-2-2-2-3"></a>Retrieval of value by fixed position

In addition to retrieval by offset from the current match count, a stored value can be returned by a fixed position that has no relevance to the current match count.

In the following example the value retrieved from the ‘heading’ variable will always be ‘IPAddress’ as this is the fourth value stored in the ‘heading’ variable and the position index starts at 0.

```xml
<data name="$heading$1[3]" value="$1" />
```
