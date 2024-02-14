---
title: "Completion Snippet Reference"
linkTitle: "Snippet Reference"
weight: 20
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

* Type the whole Tab Trigger then hit `tab`.
* Type some characters from the Name then hit `ctrl+space` to select it from the list.

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

## XML/XSLT Snippets

### apply-templates with-param

**Tab Trigger**: `wapply`

```xml
<xsl:apply-templates select="${1:*}">
  <xsl:with-param name="${2:param}">${3}</xsl:with-param>
  ${0}
</xsl:apply-templates>
````


### apply-templates sort-by

**Tab Trigger**: `applysort`

```xml
<xsl:apply-templates select="${1:*}">
  <xsl:sort select="${2:node}" order="${3:ascending}" data-type="${4:text}">${5}
</xsl:apply-templates>
${0}
````


### apply-templates plain

**Tab Trigger**: `apply`

```xml
<xsl:apply-templates select="${1:*}" />
${0}
````


### attribute blank

**Tab Trigger**: `attr`

```xml
<xsl:attribute name="${1:name}">${2}</xsl:attribute>
${0}
````


### attribute value-of

**Tab Trigger**: `attrval`

```xml
<xsl:attribute name="${1:name}">
  <xsl:value-of select="${2:*}" />
</xsl:attribute>
${0}
````


### call-template

**Tab Trigger**: `call`

```xml
<xsl:call-template name="${1:template}" />
${0}
````


### call-template with-param

**Tab Trigger**: `wcall`

```xml
<xsl:call-template name="${1:template}">
  <xsl:with-param name="${2:param}">${3}</xsl:with-param>${4}
</xsl:call-template>
${0}
````


### choose

**Tab Trigger**: `choose`

```xml
<xsl:choose>
  <xsl:when test="${1:value}">
    ${2}
  </xsl:when>${3}
</xsl:choose>
${0}
````


### copy-of

**Tab Trigger**: `copyof`

```xml
<xsl:copy-of select="${1:*}" />
${0}
````


### element blank

**Tab Trigger**: `elem`

```xml
<xsl:element name="${1:name}">
  ${2}
</xsl:element>
${0}
````


### for-each

**Tab Trigger**: `foreach`

```xml
<xsl:for-each select="${1:*}">
  ${2}
</xsl:for-each>
${0}
````


### if

**Tab Trigger**: `if`

```xml
<xsl:if test="${1:test}">
  ${2}
</xsl:if>
${0}
````


### import

**Tab Trigger**: `imp`

```xml
<xsl:import href="${1:stylesheet}" />
${0}
````


### include

**Tab Trigger**: `inc`

```xml
<xsl:include href="${1:stylesheet}" />
${0}
````


### otherwise

**Tab Trigger**: `otherwise`

```xml
<xsl:otherwise>
  ${1}
</xsl:otherwise>
$0
````


### param

**Tab Trigger**: `param`

```xml
<xsl:param name="${1:name}">
  ${2}
</xsl:param>
${0}
````


### stylesheet

**Tab Trigger**: `style`

```xml
<xsl:stylesheet version="1.0" xmlns="${1}" xpath-default-namespace="${2:${1}}" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  ${0}
</xsl:stylesheet>
````


### template

**Tab Trigger**: `temp`

```xml
<xsl:template match="${1:*}">
  ${2}
</xsl:template>
$0
````


### template named

**Tab Trigger**: `ntemp`

```xml
<xsl:template name="${1:name}">
  ${2}
</xsl:template>
$0
````


### text

**Tab Trigger**: `text`

```xml
<xsl:text>${1}</xsl:text>
$0
````


### value-of

**Tab Trigger**: `valof`

```xml
<xsl:value-of select="${1:*}" />
${0}
````


### variable blank

**Tab Trigger**: `var`

```xml
<xsl:variable name="${1:name}">
  ${0}
</xsl:variable>
````


### variable select

**Tab Trigger**: `varsel`

```xml
<xsl:variable select="${1:*}" />
${0}
````


### when

**Tab Trigger**: `when`

```xml
<xsl:when test="${1:test}">
  ${0}
</xsl:when>
````


### with-param

**Tab Trigger**: `wparam`

```xml
<xsl:with-param name="${1:name}">${2}</xsl:with-param>
${0}
````


### with-param select

**Tab Trigger**: `wparamsel`

```xml
<xsl:with-param name="${1:name}" select="${2:*}" />
${0}
````


### identity skeleton

**Tab Trigger**: `ident`

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


### records identity skeleton

**Tab Trigger**: `recident`

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


### events identity skeleton

**Tab Trigger**: `evtident`

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
## Documentation (Markdown) Snippets

### Heading level 1

**Tab Trigger**: `h1`

```markdown
# ${1:heading}

${0}
````


### Heading level 2

**Tab Trigger**: `h2`

```markdown
## ${1:heading}

${0}
````


### Heading level 3

**Tab Trigger**: `h3`

```markdown
### ${1:heading}

${0}
````


### Heading level 4

**Tab Trigger**: `h4`

```markdown
#### ${1:heading}

${0}
````


### Heading level 5

**Tab Trigger**: `h5`

```markdown
##### ${1:heading}

${0}
````


### Heading level 6

**Tab Trigger**: `h6`

```markdown
###### ${1:heading}

${0}
````


### Fenced Block

**Tab Trigger**: `fence`

````markdown
```${1:language}
${2}
```
${0}
`````


### Fenced block of XML

**Tab Trigger**: `fxml`

````markdown
```xml
${1}
```
${0}
`````


### Fenced block of plain text

**Tab Trigger**: `ftext`

````markdown
```text
${1}
```
${0}
`````


### Inline code

**Tab Trigger**: `inline`

```markdown
`${1:code}`${0}
````


### Bold text

**Tab Trigger**: `b`

```markdown
**${1:bold_text}**${0}
````


### Italic text

**Tab Trigger**: `i`

```markdown
_${1:italic_text}_${0}
````


### Strike-through text

**Tab Trigger**: `s`

```markdown
~~${1:strikethrough_text}~~${0}
````


### Bold italic text

**Tab Trigger**: `bi`

```markdown
***${1:bold_italic_text}***${0}
````
## Stroom Query Language Snippets
All [Expression Functions]({{< relref "docs/user-guide/dashboards/expressions" >}}) are available as snippets.
They do not currently have `tab` triggers.


### Eval first StreamId

**Tab Trigger**: `str`

```text
eval StreamId = first(StreamId)
$0
````


### Eval first EventId

**Tab Trigger**: `evt`

```text
eval EventId = first(EventId)
$0
````


### Eval first Stream/EventIds

**Tab Trigger**: `ids`

```text
eval StreamId = first(StreamId)
eval EventId = first(EventId)
$0
````


### Eval first first value

**Tab Trigger**: `first`

```text
eval ${1:field_name} = first(${1})
$0
````

## Dashboard Table Expression Editor Snippets

All [Expression Functions]({{< relref "docs/user-guide/dashboards/expressions" >}}) are available as snippets.
They do not currently have `tab` triggers.

