---
title: "Templating"
linkTitle: "Templating"
weight: 100
date: 2024-05-03
tags: 
description: >
  Jinja text templating syntax and context.
---

## Overview

Templating is the process of creating a reusable format or layout for presenting data in a consistent manner.
Templating is currently used in Stroom for creating email templates for Analytic Rule {{< stroom-icon "document/AnalyticRule.svg" >}}detections.

Stroom's templating uses a sub-set of the template syntax called _jinja_ and specifically the JinJava library.
The templating syntax includes support for variables, filters, condition blocks, loops, etc.
Full details of the syntax can be found {{< external-link "here" "https://developers.hubspot.com/docs/cms/hubl" >}}.

When a template is rendered, Stroom will populate the [template context]({{< relref "#template-context" >}}) with data that can be used by the template.


## Basic Templating Syntax

Jinja templating is very powerful and has a rich language so this is quick guide to the very basic features.
See the full syntax here {{< external-link "here" "https://developers.hubspot.com/docs/cms/hubl" >}}.


### Data Types

The following data types are available in the Jinja language.

Data type  | What does it represent                                                 | Example values
---------- | ---------------------------------------------------------------------- | ---------------
None       | Represents no or lack of value.                                        | `none`, `None`
Integer    | Whole numbers.                                                         | `42`, `12`, `3134`
Boolean    | Boolean value, i.e. true/false.                                        | `true`, `True`, `false`, `False`
Float      | Real numbers (with decimal separator).                                 | `12.34`, `423.52341`, `3.1415`, `15.0`
String     | Any string of characters.                                              | `"dog"`, `'Cat'`
List       | List/array of items of any type. Can be modified after being assigned. | `[1, 2, 3]`, `["Apple", "Orange"]`
Tuple      | Like a list but cannot be modified.                                    | `(1, 2, 3)`, `("Apple", "Orange")`
Dictionary | Object containing key/value pairs, also known as a map.                | `{ "fruit": "Apple", "weight": 320 }`


#### Accessing Collection Items

A List/tuple item can be accessed by its index (zero based), e.g. `fruits[0]` returns `Apple`.

A value in a dictionary can be accessed using its key, e.g. `myDict['fruit']` returns `Apple`.
If the key does not contain special characters (with the exception of `_`, then you can also used this form `myDict.fruit` to get the same value.


### Conditions

Valid conditions are:

* `==` Compares two objects for equality
* `!=` Compares two objects for inequality
* `>` true if the left-hand side is greater than the right-hand side
* `>=` true if the left-hand side is greater or equal to the right-hand side
* `<` true if the left-hand side is lower than the right-hand side
* `<=` true if the left-hand side is lower or equal to the right-hand side


### Logical Operators

The logic operators for use with boolean values are:

* `and` Boolean and
* `or` Boolean or
* `not` Boolean negation


### Expressions

**Syntax**: `{{ ... }}`

Expressions will render the value of a variable that has been defined in the template context or in a previous _statement_.
An example of a simple value expression is

{{< cardpane >}}
  {{< card header="Template" >}}
```text
The detection time is {{detectionTime}}.
```
  {{< /card >}}
  {{< card header="Rendered" >}}
```text
The detection time is 2024-05-03T09:15:13.454Z.
```
  {{< /card >}}
{{< /cardpane >}}

An expression can also contain variables that are passed through one or more [Filters]({{< relref "#filters" >}}).


### Statements

**Syntax**: `{% ... %}`

Statements are used to create conditional blocks, loops, define variables, etc.


#### Setting Variables

**Syntax**: `{% set <variable name> = <value or expression> %}`

{{< cardpane >}}
  {{< card header="Template" >}}
```text
{% set colour = '#F7761F' %}
Colour: {{colour}}
{% set fruits = ["Apple", "Orange"] %}
Top Fruit: {{ fruits | first }}
{% set fullName = "% %" | format(firstName, surname) %}
Name: {{fullName}}
```
  {{< /card >}}
  {{< card header="Rendered" >}}
```text
Colour: #F7761F
Top Fruit: Apple
Name: Joe Bloggs
```
  {{< /card >}}
{{< /cardpane >}}


#### Conditional Blocks

**Syntax**: 
```text
{% if <value, variable or expression> <condition> <value, variable or expression> %}
  < optional content, expressions or statements>
{% elif <value, variable or expression> <condition> <value, variable or expression>%}
  < optional content, expressions or statements>
{% else %}
  < optional content, expressions or statements>
{% endif %}
```

Conditional blocks can be used to optional render content depending on the value of a variable.
See [conditions]({{< relref "#conditions" >}}) for the list of valid conditions.


{{< cardpane >}}
  {{< card header="Template" >}}
```text
{% if (values | length) > 0 -%}
This detection has {{ values | length }} values.
{%- else -%}
This detection has no values.
{%- endif -%}
```
  {{< /card >}}
  {{< card header="Rendered" >}}
```text
This detection has 10 values.
```
  {{< /card >}}
{{< /cardpane >}}


#### Loops

**Syntax**: 
```text
{% for <item name> in <variable or expression> %}
  <content, expressions or statements to repeat for each item>
{% endif %}
```

For loops allow you to loop over items in a list/tuple or entries in a dictionary.

{{< cardpane >}}
  {{< card header="Template" >}}
```text
{% for key, val in values | dictsort %}
{{ key }}: {{ val }}
{% endfor %}
```
  {{< /card >}}
  {{< card header="Rendered" >}}
```text
fruit: Apple
weight: 320
```
  {{< /card >}}
{{< /cardpane >}}

{{% note %}}
Note, the filter `dictsort` is used here to sort the dictionary by its keys.
{{% /note %}}

{{% note %}}
Note the use of `-` to prevent an additional line break appearing in the rendered output, see [White Space]({{< relref "#white-space" >}}) below.
{{% /note %}}


### Filters

**Syntax**: `... | <filter name>`

Filters are essentially functions that take an input and return an output.
Some functions have additional parameters to control the behaviour of the function.

Filters can be chained together with the output of one filter becoming the input to the next filter in the chain in the same way that Stroom pipeline elements work.

Some useful filters are:

Filter    | Description                                                      | Example
-------   | -------------                                                    | --------
`length`  | The number of items in the list/sequence/tuple/string/dictionary | `{{ "hello" \| length }}` => `5`
`escape`  | Escapes any HTML special characters                              | `<p>{{ "10 > 3" \| escape }}</p>` =>  `<p>10 &gt; 3</p>`
`default` | Return the first argument if the input is undefined or empty     | `{{ None \| default("foo", true) }}` => `foo`

For a full list of filters see {{< external-link "here" "https://developers.hubspot.com/docs/cms/hubl/filters" >}} or {{< external-link "here" "https://hub.synerise.com/developers/inserts/filter/" >}}.


### Comments

**Syntax**: `{# <comment text> #}`

Non-rendered Comments can be added to the template.

{{< cardpane >}}
  {{< card header="Template" >}}
```text
{#- Show the time -#}
The detection time is {{detectionTime}}.
```
  {{< /card >}}
  {{< card header="Rendered" >}}
```text
The detection time is 2024-05-03T09:15:13.454Z.
```
  {{< /card >}}
{{< /cardpane >}}

{{% note %}}
Note the use of `-` to prevent an additional line break appearing in the rendered output, see [White Space]({{< relref "#white-space" >}}) below.
{{% /note %}}


### White Space

When JinJava renders the template, each expression or statement is evaluated and then removed or replaced by it's output, but any white space around them, e.g. line breaks remain.
This can result in unwanted line breaks in the output.

To avoid unwanted white space you can add the `-` character to the opening and/or closing tag to strip leading/trailing whitespace outside the block, e.g.

* `{{ ... }}` => `{{- ... -}}` 
* `{% ... %}` => `{%- ... -%}` 

{{< cardpane >}}
  {{< card header="Template" >}}
```text
{{ firstName -}}
{{ surname }}
```
  {{< /card >}}
  {{< card header="Rendered" >}}
```text
JoeBloggs
```
  {{< /card >}}
{{< /cardpane >}}

For a detailed guide to how white space works see {{< external-link "here" "https://ttl255.com/jinja2-tutorial-part-3-whitespace-control/" >}}.


## Template Context

The _context_ is a data structure that contains the dynamic content to use when rendering the template.
The variables and values in the context are set by Stroom depending on where the template is being used.


### Rule Detections Context

When an email subject/body template is rendered for an Analytic Rule {{< stroom-icon "document/AnalyticRule.svg" "title">}} detection, field values from the detection are placed in the context which allows them to be used in the template.

For example `{{ detectTime }}` will render the date/time the detection happened.
The fields available in the context are those taken from the `detection:1` XMLSchema with some additional fields.

The template has access to the following fields from the detection:

Field Name              | Type                         | Description
----------------------- | ---------------------------- | ------------------
detectTime              | String                       | When the detection occurred.
detectorName            | String                       | Recommended detector detail - name of detector.<br>This should be unique within the system.<br>Some detectors are very specific and only ever create one kind of detection, and in these cases it is likely that the name of the detector will be very similar to the name of the detection headline that it creates.<br>Example: _detectorSourceName_=`Bad Thing Detector` headline=`Bad Thing Detected`.<br>However, it is possible to create detectors that are sufficiently configurable that they can create many kinds of detection.<br>In these cases, this field should always be assigned to the same literal regardless of the detection/headline.<br>Example: _detectorSourceName_=`Really Configurable Detector` headline=`Good Thing Detected`, and _detectorSourceName_=`Really Configurable Detector` headline=`Bad Thing Detected`.<br>For detectors that run within Stroom pipelines, the name of the XSLT can be specified here.
detectorUuid            | String                       | This is the {{< glossary "UUID" >}} of the Analytic Rule {{< stroom-icon "document/AnalyticRule.svg" "title">}} document.
detectorVersion         | String                       | Recommended detector detail - version of detector.<br>This is the version of the detector identified in detectorSourceName field.  Different versions might produce different detections.<br>For detectors that run within Stroom pipelines, the version of the XSLT can be specified here.<br>Example: `v1.0`.
detectorEnvironment     | String                       | Recommended detector detail - where the detector was deployed.<br>For analytics that run within Stroom itself, the name of the processing pipeline can be used.<br>Note: the XSLT function stroom:`pipeline-name()` can be used within Stroom XSLT processing to determine pipeline name.Other analytics might run within an external processing framework, such as Apache Spark.<br>Example: `DevOps Spark Cluster`
headline                | String                       | 
detailedDescription     | String                       | Recommended detection detail.<br>A more detailed description of what was detected than provided by headline.<br>This will normally include some information relating to what triggered the detection, such as a specific device, location, or user.<br>In addition to descriptive text that will be the same for all detections of this kind, there are typically several possible variable dimensions that could be used to populate parts of the string that is assigned to this field.<br> Normally, only one such dimension is selected, based on the likely triage process (the kind of analysis that takes place, and principal area of interest of the analysts).<br>It should be possible to group by this field value to collect all detections that relate to the thing that the analysts are most interested in during triage.<br>Example: `Charitable Donation By 'Freya Bloggs' Detected` or `Charitable Donation To 'Happy Cats Cattery' Detected` depending on anticipated area of analyst interest(perhaps philanthropic activities of individuals or financial transactions to organisations, respectively).<br>For some detections, this field will have the same value as that for headline as no further information is available.
fullDescription         | String                       | Recommended detection detail.<br>Complete description of what was detected.<br>  This will normally include some detail relating to what triggered the detection.<br>  All dimensions with ordinal (literal) values that are useful for triage are output.<br>Numeric and other continuous values such as timestamps are not included in this full description, in order that grouping by this single field will work effectively.<br>Example: `Charitable Donation By 'Freya Bloggs' to 'Happy Cats Cattery' Detected`.<br>For some detections, this field will have the same value as that for _detailedDescription_ as no further information is available.
detectionUniqueId       | String                       | This field does not need to be assigned.<br>  Any assignment should be to a value that is sufficiently unique to identify a specific detection from a specific detector.<br>Typically, but not necessarily, the value of this field is a {{< glossary "UUID" >}}.<br>It can be useful to assign this field in order to support analytic development / debugging.<br>It is necessary to assign this field if _detectionRevision_ field is assigned a value.
detectionRevision       | Integer                      | Can be used, in conjunction with _detectionUniqueId_ to allow detectors that run continuously, in a streaming fashion to revise their detections in the light of new information.<br>For example, it might be useful to revise the same detection with additional linked events and a new standard deviation.<br>Where more than one detection has the same _detectionUniqueId_ value, then the one with the highest _detectionRevision_ will be the current one and all previous revisions (lower numbers in _detectionRevision_ field) are superseded / ignored.
defunct                 | Boolean                      | This field allows a detection to declare that all previous revisions (same _detectionUniqueId_, lower _detectionRevision_ numbers) are now considered invalid.<br>For example, new data might arrive later than expected and invalidate a detection that has already been sent into Stroom.<br>Default value is `false`.
executionSchedule       | String                       | The name of the schedule that fired this detection, if the detection was fired by a Scheduled Query.
executionTime           | String                       | This is the actual wall clock time that the rule ran.
effectiveExecutionTime  | String                       | This is the time used in any relative date expressions [relative data expressions name]({{< relref "docs/reference-section/dates#date-expressions" >}}) in the rule's query or time range, e.g. `day() - 1w`. The effective time is relevant when executing historic time ranges in a scheduled query.
values                  | Dictionary                   | This a dictionary with all the field/column names from the Query (with the exception of `StreamId` and `EventId`) as keys and their respective cell values as the value.
linkedEvents            | List of DetectionLinkedEvent | This is a list of the event(s) that are linked to this detection.


DetectionLinkedEvent fields:

Field Name              | Type                         | Description
----------------------- | ---------------------------- | ------------------
stroom                  | String                       | The Stroom instance within which this event exists, assumed to be this instance of Stroom if not supplied.
streamId                | String                       | The ID of the {{< glossary "Stream" >}} that contains the associated event.
eventId                 | String                       | The ID of the {{< glossary "Event" >}} that is associated with this detection.


{{% warning %}}
When choosing the names of the columns in your rule it may be beneficial to use `snake_case` or `UpperCamelCase` to make it easier to reference those columns in the detection template (see [Accessing Collection Items]({{< relref "#accessing-collection-items" >}}) above). E.g. `myDict.some_key` vs `myDict['some key']`.
{{% /warning %}}

