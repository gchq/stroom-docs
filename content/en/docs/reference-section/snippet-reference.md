---
title: "Editor Completion Snippets"
linkTitle: "Editor Snippets"
weight: 70
date: 2023-11-08
tags: 
description: >
  Reference for built in completion snippets.
---


## Overview

Completion snippets are a way to quickly insert snippets of text into the editor.
This is very useful for example when editing XSLT documents as you can quickly insert common chunks of XSLT.

This page lists all the snippets available in Stroom.
Snippets are specific to the type of content being edited, e.g. When editing an XSLT, you will only be able to use _XML/XSLT_ snippets.


### Tab Positions

A snippet is not just a static block of text, it can contain various tab position placeholders.
The following is an example of a snippet with multiple tab positions:

```xml
<xsl:apply-templates select="${1:*}">
  <xsl:with-param name="${2:param}">${3}</xsl:with-param>
  ${0}
</xsl:apply-templates>
```

Tab positions are expressed like `${n}` or `${n:xxx}`, where `n` is a number indication the order of the tab position and `xxx` is the default value at that tab position. Sometimes `xxx` will not be a default value, but will instead be a string to hint at the kind of thing the user is expected to overtype with where no obvious default is available.
`${0}` is a special tab position in that it defines the last tab position.

To insert a snippet do one of the following:

* Type the whole Tab Trigger then hit {{< key-bind "tab" >}}.
* Type some characters from the Name then hit {{< key-bind "ctrl,space" >}} to select it from the list.

The snippet will be inserted (replacing the Tab Trigger if used) and the cursor will be position on the first tab position (`${1}` if present, otherwise `${0}`).
If the tab position has a default value then the whole of that default value will be selected allowing the user to quickly over type it.
Once the user is happy with the first tab position (whether they inserted text, over typed or did nothing), they can hit `tab` to move to the next tab position.


### Advanced Tab Positions

It is possible for a tab position to be used multiple times in a snippet, like in the following example.
All subsequent uses of a tab stop will take the value entered by the user on the first use of it.
The subsequent uses will not act as tab stops.

```xml
<xsl:stylesheet xmlns="${1}" xpath-default-namespace="${1}">
  ${0}
</xsl:stylesheet>
```

If you want a reused tab position to also be a tab stop so that the user can chose to override the re-used value, then you can nest the tab stops like in this example:

```xml
<xsl:stylesheet xmlns="${1}" xpath-default-namespace="${2:${1}}">
  ${0}
</xsl:stylesheet>
```

## Adding Snippets to Stroom

We have plans for improving how completion snippets are defined, i.e. allowing users to define their own.
Therefore, available snippets may be subject to change.

However, until then, if there are any generic snippets that you think would be useful to add to Stroom then please raise an issue on {{< external-link "GitHub" "https://github.com/gchq/stroom/issues" >}}.


<!-- 
******************* IMPORTANT *********************

Everything below here is semi-auto-generated using

stroom.app.docs.GenerateSnippetsDoc#main on 7.3+

Run that main method then copy the content from the console
and paste it below this message.

******************* IMPORTANT ********************* 
-->

<!-- #~#~#~#~#~# GENERATED CONTENT START #~#~#~#~#~#~# -->
## XML/XSLT Snippets

### Apply-templates with-param (`wapply`)

**Name**: `Apply-templates with-param`, **Tab Trigger**: `wapply`

```xml
<xsl:apply-templates select="${1:*}">
  <xsl:with-param name="${2:param}">${3}</xsl:with-param>
  ${0}
</xsl:apply-templates>
````


### Apply-templates sort-by (`applysort`)

**Name**: `Apply-templates sort-by`, **Tab Trigger**: `applysort`

```xml
<xsl:apply-templates select="${1:*}">
  <xsl:sort select="${2:node}" order="${3:ascending}" data-type="${4:text}">${5}
</xsl:apply-templates>
${0}
````


### Apply-templates plain (`apply`)

**Name**: `Apply-templates plain`, **Tab Trigger**: `apply`

```xml
<xsl:apply-templates select="${1:*}" />
${0}
````


### Attribute blank (`attr`)

**Name**: `Attribute blank`, **Tab Trigger**: `attr`

```xml
<xsl:attribute name="${1:name}">${2}</xsl:attribute>
${0}
````


### Attribute value-of (`attrval`)

**Name**: `Attribute value-of`, **Tab Trigger**: `attrval`

```xml
<xsl:attribute name="${1:name}">
  <xsl:value-of select="${2:*}" />
</xsl:attribute>
${0}
````


### Call-template (`call`)

**Name**: `Call-template`, **Tab Trigger**: `call`

```xml
<xsl:call-template name="${1:template}" />
${0}
````


### Call-template with-param (`wcall`)

**Name**: `Call-template with-param`, **Tab Trigger**: `wcall`

```xml
<xsl:call-template name="${1:template}">
  <xsl:with-param name="${2:param}">${3}</xsl:with-param>${4}
</xsl:call-template>
${0}
````


### Choose (`choose`)

**Name**: `Choose`, **Tab Trigger**: `choose`

```xml
<xsl:choose>
  <xsl:when test="${1:value}">
    ${2}
  </xsl:when>${3}
</xsl:choose>
${0}
````


### Copy-of (`copyof`)

**Name**: `Copy-of`, **Tab Trigger**: `copyof`

```xml
<xsl:copy-of select="${1:*}" />
${0}
````


### Element blank (`elem`)

**Name**: `Element blank`, **Tab Trigger**: `elem`

```xml
<xsl:element name="${1:name}">
  ${2}
</xsl:element>
${0}
````


### For-each (`foreach`)

**Name**: `For-each`, **Tab Trigger**: `foreach`

```xml
<xsl:for-each select="${1:*}">
  ${2}
</xsl:for-each>
${0}
````


### If (`if`)

**Name**: `If`, **Tab Trigger**: `if`

```xml
<xsl:if test="${1:test}">
  ${2}
</xsl:if>
${0}
````


### Import (`imp`)

**Name**: `Import`, **Tab Trigger**: `imp`

```xml
<xsl:import href="${1:stylesheet}" />
${0}
````


### Include (`inc`)

**Name**: `Include`, **Tab Trigger**: `inc`

```xml
<xsl:include href="${1:stylesheet}" />
${0}
````


### Otherwise (`otherwise`)

**Name**: `Otherwise`, **Tab Trigger**: `otherwise`

```xml
<xsl:otherwise>
  ${1}
</xsl:otherwise>
$0
````


### Param (`param`)

**Name**: `Param`, **Tab Trigger**: `param`

```xml
<xsl:param name="${1:name}">
  ${2}
</xsl:param>
${0}
````


### Stylesheet (`style`)

**Name**: `Stylesheet`, **Tab Trigger**: `style`

```xml
<xsl:stylesheet
    version="1.0"
    xmlns="${1}"
    xpath-default-namespace="${2:${1}}"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  ${0}
</xsl:stylesheet>
````


### Template (`temp`)

**Name**: `Template`, **Tab Trigger**: `temp`

```xml
<xsl:template match="${1:*}">
  ${2}
</xsl:template>
$0
````


### Template named (`ntemp`)

**Name**: `Template named`, **Tab Trigger**: `ntemp`

```xml
<xsl:template name="${1:name}">
  ${2}
</xsl:template>
$0
````


### Text (`text`)

**Name**: `Text`, **Tab Trigger**: `text`

```xml
<xsl:text>${1}</xsl:text>
$0
````


### Value-of (`valof`)

**Name**: `Value-of`, **Tab Trigger**: `valof`

```xml
<xsl:value-of select="${1:*}" />
${0}
````


### Variable blank (`var`)

**Name**: `Variable blank`, **Tab Trigger**: `var`

```xml
<xsl:variable name="${1:name}">
  ${0}
</xsl:variable>
````


### Variable select (`varsel`)

**Name**: `Variable select`, **Tab Trigger**: `varsel`

```xml
<xsl:variable select="${1:*}" />
${0}
````


### When (`when`)

**Name**: `When`, **Tab Trigger**: `when`

```xml
<xsl:when test="${1:test}">
  ${0}
</xsl:when>
````


### With-param (`wparam`)

**Name**: `With-param`, **Tab Trigger**: `wparam`

```xml
<xsl:with-param name="${1:name}">${2}</xsl:with-param>
${0}
````


### With-param select (`wparamsel`)

**Name**: `With-param select`, **Tab Trigger**: `wparamsel`

```xml
<xsl:with-param name="${1:name}" select="${2:*}" />
${0}
````


### Fatal message (`fatal`)

**Name**: `Fatal message`, **Tab Trigger**: `fatal`

```xml
<xsl:message terminate="yes">${1}</xsl:message>
${0}
````


### Error message (`error`)

**Name**: `Error message`, **Tab Trigger**: `error`

```xml
<xsl:message><error>${1}</error></xsl:message>
${0}
````


### Warning message (`warn`)

**Name**: `Warning message`, **Tab Trigger**: `warn`

```xml
<xsl:message><warn>${1}</warn></xsl:message>
${0}
````


### Info message (`info`)

**Name**: `Info message`, **Tab Trigger**: `info`

```xml
<xsl:message><info>${1}</info></xsl:message>
${0}
````


### Identity skeleton (`ident`)

**Name**: `Identity skeleton`, **Tab Trigger**: `ident`

```xml
<xsl:stylesheet version="1.0" xpath-default-namespace="${1:event-logging:3}" xmlns="${2:${1}}" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Whenever you match any node or any attribute -->
  <xsl:template match="node( )|@*">

    <!-- Copy the current node -->
    <xsl:copy>

      <!-- Including any attributes it has and any child nodes -->
      <xsl:apply-templates select="@*|node( )"/>
    </xsl:copy>
  </xsl:template>

  ${0}
</xsl:stylesheet>
````


### Records identity skeleton (`recident`)

**Name**: `Records identity skeleton`, **Tab Trigger**: `recident`

```xml
<xsl:stylesheet version="1.0" xpath-default-namespace="records:2" xmlns="event-logging:3" xmlns:stroom="stroom" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Match Root Object -->
  <xsl:template match="records">
    <Events xmlns="event-logging:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="event-logging:3 file://event-logging-v3.4.2.xsd" Version="3.4.2">
      <xsl:apply-templates />
    </Events>
  </xsl:template>
  <xsl:template match="record">
    <Event>
      <EventTime>
        <TimeCreated>${1:time}</TimeCreated>
      </EventTime>
      <EventSource>
        <System>
          <Name>${2:name}</Name>
          <Environment>${3:environment}</Environment>
        </System>
        <Generator>${4:generator}</Generator>
        <Device>${5:device}</Device>
      </EventSource>
      <EventDetail>
        <TypeId>${6:type}</TypeId>
        ${0}
        <xsl:apply-templates />
      </EventDetail>
    </Event>
  </xsl:template>

  <!-- Whenever you match any node or any attribute -->
  <xsl:template match="node( )|@*">

    <!-- Copy the current node -->
    <xsl:copy>

      <!-- Including any attributes it has and any child nodes -->
      <xsl:apply-templates select="@*|node( )" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
````


### Events identity skeleton (`evtident`)

**Name**: `Events identity skeleton`, **Tab Trigger**: `evtident`

```xml
<xsl:stylesheet version="1.0" xpath-default-namespace="event-logging:3" xmlns="event-logging:3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Match Root Object -->
  <xsl:template match="Events">
    <Events xmlns="event-logging:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="event-logging:3 file://event-logging-v3.4.2.xsd" Version="3.4.2">
      <xsl:apply-templates />
    </Events>
  </xsl:template>
  ${0}

  <!-- Whenever you match any node or any attribute -->
  <xsl:template match="node( )|@*">

    <!-- Copy the current node -->
    <xsl:copy>

      <!-- Including any attributes it has and any child nodes -->
      <xsl:apply-templates select="@*|node( )" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
````
## Data Splitter Snippets

### CSV Splitter (`csv`)

**Name**: `CSV Splitter`, **Tab Trigger**: `csv`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter
    xmlns="data-splitter:3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd"
    version="3.0">

  <!-- Match each line using a new line character as the delimiter -->
  <split delimiter="\n">

    <!-- Take the matched line (using group 1 ignores the delimiters,
    without this each match would include the new line character) -->
    <group value="\$1">

    <!-- Match each value separated by a comma as the delimiter -->
    <split delimiter=",">

      <!-- Output the value from group 1 (as above using group 1
        ignores the delimiters, without this each value would include
      the comma) -->
      <data value="\$1"/>
      ${0}
    </split>
    </group>
  </split>
</dataSplitter>
````


### CSV Splitter with heading (`csvh`)

**Name**: `CSV Splitter with heading`, **Tab Trigger**: `csvh`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter
    xmlns="data-splitter:3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd"
    version="3.0">

  <!-- Match heading line (note that maxMatch="1" means that only the
  first line will be matched by this splitter) -->
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
    <group value="\$1">

      <!-- Split the line up -->
      <split delimiter=",">

        <!-- Output the stored heading for each iteration and the value
        from group 1 -->
        <data name="\$heading\$1" value="\$1" />
        ${0}
      </split>
    </group>
  </split>
</dataSplitter>
````


### Data Splitter Template (`ds`)

**Name**: `Data Splitter Template`, **Tab Trigger**: `ds`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter
    xmlns="data-splitter:3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd"
    version="3.0">
  ${0}
</dataSplitter>
````


### Data element with name attribute (`nval`)

**Name**: `Data element with name attribute`, **Tab Trigger**: `nval`

```xml
<data name="${1}" value="${2}"/>
${0}
````


### Data element without name attribute (`val`)

**Name**: `Data element without name attribute`, **Tab Trigger**: `val`

```xml
<data value="${1}"/>
${0}
````


### Var element (`var`)

**Name**: `Var element`, **Tab Trigger**: `var`

```xml
<var id="${1}"/>
${0}
````


### Split element (`spl`)

**Name**: `Split element`, **Tab Trigger**: `spl`

```xml
<split delimiter="${1:\n}">
  <group value="${2:\$1}">
    ${3}
  </group>
</split>
${0}
````


### Group element (`gr`)

**Name**: `Group element`, **Tab Trigger**: `gr`

```xml
<group value="${1:\$1}">
  ${2}
</group>
${0}
````


### All element (`all`)

**Name**: `All element`, **Tab Trigger**: `all`

```xml
<all>
  ${1}
</all>
${0}
````


### Regex element (`reg`)

**Name**: `Regex element`, **Tab Trigger**: `reg`

```xml
<regex ${1:dotall="true" }${2:caseInsensitive="true" }pattern="${3}">
  <group>
    ${0}
  </group>
</regex>
````
## XMLFragmentParser Snippets

### Events fragment template (`evt`)

**Name**: `Events fragment template`, **Tab Trigger**: `evt`

```xml
<?xml version="1.1" encoding="utf-8"?>
<!DOCTYPE Events [
<!ENTITY fragment SYSTEM "fragment">]>
<Events
    xmlns="event-logging:${1:3}"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="event-logging:${1} file://event-logging-v${2:3.4.2}.xsd"
    version="${2}">
&fragment;
</records>
${0}
````


### Records fragment template (`rec`)

**Name**: `Records fragment template`, **Tab Trigger**: `rec`

```xml
<?xml version="1.1" encoding="utf-8"?>
<!DOCTYPE Records [
<!ENTITY fragment SYSTEM "fragment">]>
<records
    xmlns="records:${1:2}"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="records:${1} file://records-v${2:2.0}.xsd"
    version="${2}">
&fragment;
</records>
${0}
````
## Documentation (Markdown) Snippets

### Heading level 1 (`h1`)

**Name**: `Heading level 1`, **Tab Trigger**: `h1`

```markdown
# ${1:heading}

${0}
````


### Heading level 2 (`h2`)

**Name**: `Heading level 2`, **Tab Trigger**: `h2`

```markdown
## ${1:heading}

${0}
````


### Heading level 3 (`h3`)

**Name**: `Heading level 3`, **Tab Trigger**: `h3`

```markdown
### ${1:heading}

${0}
````


### Heading level 4 (`h4`)

**Name**: `Heading level 4`, **Tab Trigger**: `h4`

```markdown
#### ${1:heading}

${0}
````


### Heading level 5 (`h5`)

**Name**: `Heading level 5`, **Tab Trigger**: `h5`

```markdown
##### ${1:heading}

${0}
````


### Heading level 6 (`h6`)

**Name**: `Heading level 6`, **Tab Trigger**: `h6`

```markdown
###### ${1:heading}

${0}
````


### Fenced Block (`fence`)

**Name**: `Fenced Block`, **Tab Trigger**: `fence`

````markdown
```${1:language}
${2}
```
${0}
`````


### Fenced block of XML (`fxml`)

**Name**: `Fenced block of XML`, **Tab Trigger**: `fxml`

````markdown
```xml
${1}
```
${0}
`````


### Fenced block of plain text (`ftext`)

**Name**: `Fenced block of plain text`, **Tab Trigger**: `ftext`

````markdown
```text
${1}
```
${0}
`````


### Inline code (`inline`)

**Name**: `Inline code`, **Tab Trigger**: `inline`

```markdown
`${1:code}`${0}
````


### Bold text (`b`)

**Name**: `Bold text`, **Tab Trigger**: `b`

```markdown
**${1:bold_text}**${0}
````


### Italic text (`i`)

**Name**: `Italic text`, **Tab Trigger**: `i`

```markdown
_${1:italic_text}_${0}
````


### Strike-through text (`s`)

**Name**: `Strike-through text`, **Tab Trigger**: `s`

```markdown
~~${1:strikethrough_text}~~${0}
````


### Bold italic text (`bi`)

**Name**: `Bold italic text`, **Tab Trigger**: `bi`

```markdown
***${1:bold_italic_text}***${0}
````
## Stroom Query Language Snippets
All [Expression Functions]({{< relref "docs/reference-section/expressions" >}}) are available as snippets.
They do not currently have `tab` triggers.


### Eval first StreamId (`str`)

**Name**: `Eval first StreamId`, **Tab Trigger**: `str`

```text
eval StreamId = first(StreamId)
$0
````


### Eval first EventId (`evt`)

**Name**: `Eval first EventId`, **Tab Trigger**: `evt`

```text
eval EventId = first(EventId)
$0
````


### Eval first Stream/EventIds (`ids`)

**Name**: `Eval first Stream/EventIds`, **Tab Trigger**: `ids`

```text
eval StreamId = first(StreamId)
eval EventId = first(EventId)
$0
````


### Eval first first value (`first`)

**Name**: `Eval first first value`, **Tab Trigger**: `first`

```text
eval ${1:field_name} = first(${1})
$0
````

## Dashboard Table Expression Editor Snippets

All [Expression Functions]({{< relref "docs/reference-section/expressions" >}}) are available as snippets.
They do not currently have `tab` triggers.

