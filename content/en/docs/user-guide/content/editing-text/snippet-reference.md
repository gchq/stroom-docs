---
title: "Completion Snippet Reference"
linkTitle: "Snippet Reference"
weight: 20
date: 2023-11-08
tags: 
description: >
  Reference for built in completion snippets.
---

{{% warning %}}
We have plans for improving how completion snippets are defined, i.e. allowing users to define their own.
Therefore, available snippets may be subject to change.
{{% /warning %}}


<!--
To semi-automate the process of creating these tables you can do the following:
1. Open the snippet file, e.g. stroom-core-client-widget/src/main/java/edu/ycp/cs/dh/acegwt/public/ace/snippets/markdown.js
1. Copy the `exports.snippets = [ ..... ];` array.
1. Execute the following javascript (in a browser dev tools console or online js shell)

exports.snippets = [ 
..... 
];
console.log(JSON.stringify(exports.snippets));

1. Copy the generated JSON into a file /tmp/json
1. Run this jq command

jq -r '.[] | "| " + .name + " | `" + .tabTrigger + "` | ` " + (.content | gsub("\n"; " `<br/>` ") | gsub("\\|"; "\\|")) + " ` | "' < /tmp/json

1. Paste the output of that under the heading rows, or if you are in vim you can read the jq command output directly in, e.g.:

:r !jq -r '.[] | "| " + .name + " | `" + .tabTrigger + "` | ` " + (.content | gsub("\n"; " `<br/>` ") | gsub("\\|"; "\\|")) + " ` | "' < /tmp/json

Simples, sort of.
-->

To insert a snippet do one of the following:

* Type the whole Tab Trigger then hit `tab`.
* Type some characters from the Name then hit `ctrl+space` to select it from the list.


## XML/XSLT

| Name | Tab Trigger | Snippet Content |
| ---- | ----------- | --------------- |
| apply-templates with-param | `wapply` | ` <xsl:apply-templates select="${1:*}"> `<br/>`   <xsl:with-param name="${2:param}">${3}</xsl:with-param> `<br/>`   ${0} `<br/>` </xsl:apply-templates> ` | 
| apply-templates sort-by | `applysort` | ` <xsl:apply-templates select="${1:*}"> `<br/>`   <xsl:sort select="${2:node}" order="${3:ascending}" data-type="${4:text}">${5} `<br/>` </xsl:apply-templates> `<br/>` ${0} ` | 
| apply-templates plain | `apply` | ` <xsl:apply-templates select="${1:*}" /> `<br/>` ${0} ` | 
| attribute blank | `attr` | ` <xsl:attribute name="${1:name}">${2}</xsl:attribute> `<br/>` ${0} ` | 
| attribute value-of | `attrval` | ` <xsl:attribute name="${1:name}"> `<br/>`   <xsl:value-of select="${2:*}" /> `<br/>` </xsl:attribute> `<br/>` ${0} ` | 
| call-template | `call` | ` <xsl:call-template name="${1:template}" /> `<br/>` ${0} ` | 
| call-template with-param | `wcall` | ` <xsl:call-template name="${1:template}"> `<br/>`   <xsl:with-param name="${2:param}">${3}</xsl:with-param>${4} `<br/>` </xsl:call-template> `<br/>` ${0} ` | 
| choose | `choose` | ` <xsl:choose> `<br/>`   <xsl:when test="${1:value}"> `<br/>`     ${2} `<br/>`   </xsl:when>${3} `<br/>` </xsl:choose> `<br/>` ${0} ` | 
| copy-of | `copyof` | ` <xsl:copy-of select="${1:*}" /> `<br/>` ${0} ` | 
| for-each | `foreach` | ` <xsl:for-each select="${1:*}"> `<br/>`   ${2} `<br/>` </xsl:for-each> `<br/>` ${0} ` | 
| if | `if` | ` <xsl:if test="${1:test}"> `<br/>`   ${2} `<br/>` </xsl:if> `<br/>` ${0} ` | 
| import | `imp` | ` <xsl:import href="${1:stylesheet}" /> `<br/>` ${0} ` | 
| include | `inc` | ` <xsl:include href="${1:stylesheet}" /> `<br/>` ${0} ` | 
| otherwise | `otherwise` | ` <xsl:otherwise> `<br/>`   ${1} `<br/>` </xsl:otherwise> `<br/>` $0 ` | 
| param | `param` | ` <xsl:param name="${1:name}"> `<br/>`   ${2} `<br/>` </xsl:param> `<br/>` ${0} ` | 
| stylesheet | `style` | ` <xsl:stylesheet version="1.0" xmlns="${1}" xpath-default-namespace="${2:${1}}" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> `<br/>`   ${0} `<br/>` </xsl:stylesheet> ` | 
| template | `temp` | ` <xsl:template match="${1:*}"> `<br/>`   ${2} `<br/>` </xsl:template> `<br/>` $0 ` | 
| template named | `ntemp` | ` <xsl:template name="${1:name}"> `<br/>`   ${2} `<br/>` </xsl:template> `<br/>` $0 ` | 
| text | `text` | ` <xsl:text>${1}</xsl:text> `<br/>` $0 ` | 
| value-of | `valof` | ` <xsl:value-of select="${1:*}" /> `<br/>` ${0} ` | 
| variable blank | `var` | ` <xsl:variable name="${1:name}"> `<br/>`   ${0} `<br/>` </xsl:variable> ` | 
| variable select | `varsel` | ` <xsl:variable select="${1:*}" /> `<br/>` ${0} ` | 
| when | `when` | ` <xsl:when test="${1:test}"> `<br/>`   ${0} `<br/>` </xsl:when> ` | 
| with-param | `wparam` | ` <xsl:with-param name="${1:name}">${2}</xsl:with-param> `<br/>` ${0} ` | 
| with-param select | `wparamsel` | ` <xsl:with-param name="${1:name}" select="${2:*}" /> `<br/>` ${0} ` | 
| identity skeleton | `ident` | ` <xsl:stylesheet version="1.0" xpath-default-namespace="${1:event-logging:3}" xmlns="${2:${1}}" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> `<br/>`  `<br/>`   <!-- Whenever you match any node or any attribute --> `<br/>`   <xsl:template match="node( )\|@*"> `<br/>`  `<br/>`     <!-- Copy the current node --> `<br/>`     <xsl:copy> `<br/>`  `<br/>`       <!-- Including any attributes it has and any child nodes --> `<br/>`       <xsl:apply-templates select="@*\|node( )"/> `<br/>`     </xsl:copy> `<br/>`   </xsl:template> `<br/>`  `<br/>`   ${0} `<br/>` </xsl:stylesheet> ` | 
| records identity skeleton | `recident` | ` <xsl:stylesheet version="1.0" xpath-default-namespace="records:2" xmlns="event-logging:3" xmlns:stroom="stroom" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> `<br/>`  `<br/>`   <!-- Match Root Object --> `<br/>`   <xsl:template match="records"> `<br/>`     <Events xmlns="event-logging:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="event-logging:3 file://event-logging-v3.4.2.xsd" Version="3.4.2"> `<br/>`       <xsl:apply-templates /> `<br/>`     </Events> `<br/>`   </xsl:template> `<br/>`   <xsl:template match="record"> `<br/>`     <Event> `<br/>`       <EventTime> `<br/>`         <TimeCreated>${1:time}</TimeCreated> `<br/>`       </EventTime> `<br/>`       <EventSource> `<br/>`         <System> `<br/>`           <Name>${2:name}</Name> `<br/>`           <Environment>${3:environment}</Environment> `<br/>`         </System> `<br/>`         <Generator>${4:generator}</Generator> `<br/>`         <Device>${5:device}</Device> `<br/>`       </EventSource> `<br/>`       <EventDetail> `<br/>`         <TypeId>${6:type}</TypeId> `<br/>`         ${0} `<br/>`         <xsl:apply-templates /> `<br/>`       </EventDetail> `<br/>`     </Event> `<br/>`   </xsl:template> `<br/>`  `<br/>`   <!-- Whenever you match any node or any attribute --> `<br/>`   <xsl:template match="node( )\|@*"> `<br/>`  `<br/>`     <!-- Copy the current node --> `<br/>`     <xsl:copy> `<br/>`  `<br/>`       <!-- Including any attributes it has and any child nodes --> `<br/>`       <xsl:apply-templates select="@*\|node( )" /> `<br/>`     </xsl:copy> `<br/>`   </xsl:template> `<br/>` </xsl:stylesheet> ` | 
| events identity skeleton | `evtident` | ` <xsl:stylesheet version="1.0" xpath-default-namespace="event-logging:3" xmlns="event-logging:3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> `<br/>`  `<br/>`   <!-- Match Root Object --> `<br/>`   <xsl:template match="Events"> `<br/>`     <Events xmlns="event-logging:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="event-logging:3 file://event-logging-v3.4.2.xsd" Version="3.4.2"> `<br/>`       <xsl:apply-templates /> `<br/>`     </Events> `<br/>`   </xsl:template> `<br/>`   ${0} `<br/>`  `<br/>`   <!-- Whenever you match any node or any attribute --> `<br/>`   <xsl:template match="node( )\|@*"> `<br/>`  `<br/>`     <!-- Copy the current node --> `<br/>`     <xsl:copy> `<br/>`  `<br/>`       <!-- Including any attributes it has and any child nodes --> `<br/>`       <xsl:apply-templates select="@*\|node( )" /> `<br/>`     </xsl:copy> `<br/>`   </xsl:template> `<br/>` </xsl:stylesheet> ` | 

## Documentation (Markdown)

| Name | Tab Trigger | Snippet Content |
| ---- | ----------- | --------------- |
| Heading level 1 | `h1` | ` # ${1:heading} `<br/>`  `<br/>` ${0} ` |
| Heading level 2 | `h2` | ` ## ${1:heading} `<br/>`  `<br/>` ${0} ` |
| Heading level 3 | `h3` | ` ### ${1:heading} `<br/>`  `<br/>` ${0} ` |
| Heading level 4 | `h4` | ` #### ${1:heading} `<br/>`  `<br/>` ${0} ` |
| Heading level 5 | `h5` | ` ##### ${1:heading} `<br/>`  `<br/>` ${0} ` |
| Heading level 6 | `h6` | ` ###### ${1:heading} `<br/>`  `<br/>` ${0} ` |
| Fenced Block | `fence` | ` ```${1:language} `<br/>` ${2} `<br/>` ``` `<br/>` ${0} ` |
| Fenced block of XML | `fxml` | ` ```xml `<br/>` ${1} `<br/>` ``` `<br/>` ${0} ` |
| Fenced block of plain text | `ftext` | ` ```text `<br/>` ${1} `<br/>` ``` `<br/>` ${0} ` |
| Inline code | `inline` | ` `${1:code}`${0} ` |
| Bold text | `b` | ` **${1:bold_text}**${0} ` |
| Italic text | `i` | ` _${1:italic_text}_${0} ` |
| Strike-through text | `s` | ` ~~${1:strikethrough_text}~~${0} ` |
| Bold italic text | `bi` | ` ***${1:bold_italic_text}***${0} ` |


## Stroom Query Language

All [Expression Functions]({{< relref "docs/user-guide/dashboards/expressions" >}}) are available as snippets.
They do not currently have `tab` triggers.

| Name | Tab Trigger | Snippet Content |
| ---- | ----------- | --------------- |
| Eval first StreamId | `str` | ` eval StreamId = first(StreamId) `<br/>` $0 ` |
| Eval first EventId | `evt` | ` eval EventId = first(EventId) `<br/>` $0 ` |
| Eval first Stream/EventIds | `ids` | ` eval StreamId = first(StreamId) `<br/>` eval EventId = first(EventId) `<br/>` $0 ` |
| Eval first first value | `first` | ` eval ${1:field_name} = first(${1}) `<br/>` $0 ` |


## Dashboard Table Expression Editor

All [Expression Functions]({{< relref "docs/user-guide/dashboards/expressions" >}}) are available as snippets.
They do not currently have `tab` triggers.

