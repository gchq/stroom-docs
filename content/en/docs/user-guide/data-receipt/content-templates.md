---
title: "Content Templates"
linkTitle: "Content Templates"
weight: 40
date: 2026-03-18
tags: 
description: >
 Describes how Stroom can auto-generate content (i.e. Feeds and Pipelines) upon receipt of new data.
---

The aim of the Content Templates feature is to simplify the process of client systems sending data into Stroom.
Instead of having to pre-create a Feed {{< stroom-icon "document/Feed.svg" >}} and Pipeline {{< stroom-icon "document/Pipeline.svg" >}} before a client can send data, Content Templates can be created to auto-create the content on receipt of the first {{< glossary "Stream" >}}.

Content Templates are a set of expression rules with associated template content to generate when the rule matches on incoming data.
If a client has used the correct headers and a Content Template matches, all the content required to process the data will be created and the data will be processed without any further involvement from the Stroom administrator.

In order to use Content Templates, the property `appConfig.autoContentCreation.enable` must be set to `true`.


## Content Templates Screen

Content Templates can be managed in the Content Templates screen that is accessed from the main menu:

{{< stroom-menu "Administration" "Content Templates" >}}

{{< image "user-guide/data-receipt/ContentTemplates.png" "900x" >}}The Content Templates screen{{</ image >}}

This screen allows a user with the _Manage Content Templates_ application permission to create a number of content templates.

The settings available on a Content Template are as follows:

Template Name
: A name for the template to aid the administrator when looking through a list of different templates.

Descriptions
: An optional and more detailed description of the purpose of the template.

Template Type
: Determines how the Pipeline specified by the  _Pipeline_ setting is used.

  * `INHERIT_PIPELINE` - A new pipeline will be created that inherits from the pipeline specified by _Pipeline_.
    The new pipeline will be created in the explorer tree folder defined by `(app|proxy)Config.receive.destinationExplorerPathTemplate`.

  * `PROCESSOR_FILTER` - A new processor filter will be added to the existing pipeline specified in the template.
    No new documents will be created.

Copy Pipeline Element Dependencies
: If _Copy Pipeline Element Dependencies_ is ticked and the _Template Type_ is `INHERIT_PIPELINE`, any documents that are direct dependencies of the specified Pipeline (e.g. Text Converter {{< stroom-icon "document/TextConverter.svg" >}} or XSLT {{< stroom-icon "document/XSLT.svg" >}}) will be copied into the destination folder.
  The new Pipeline will have its dependencies changed to use the copied dependencies, allowing them to be edited without affecting the parent Pipeline.

Pipeline
: An existing Pipeline to either inherit from or add a processor filter to, depending on the _Template Type_.

Processor Priority
: The priority to assign to the pipeline processor when created.
  The higher the number the higher the priority.
  Value must be between 1 and 100.
  The default priority is 10.

Processor Max Concurrent Tasks
: The maximum number of concurrent tasks to assign to the pipeline processor when created. Zero means un-bounded.

Expression
: Each template has an expression that will be used to match on the headers when auto-generation of content has been triggered.
  The template expressions are evaluated in order from the top, the first to match the data is used.

  If a template's expression matches, content will be created according to settings in the template.


## Configuration

The configuration for the Content Templates can be found [here]({{< relref "configuring-stroom#autocontentcreation" >}}).


## Content Auto-Creation

Depending on the configuration and the settings in the Content Template that matches on the data, the following will happen if the feed does not already exist.
If the feed already exists then it is assumed the content creation has already happened or has been done manually, so nothing will happen.


### `INHERIT_PIPELINE` Mode

* Create a stroom user for the authenticated identity that has sent the data.

* Create a stroom user group using the template defined by property `groupTemplate`.
  * Add the created stroom user to this group.
  * Add this group to the group defined by `groupParentGroupName`.

* If _Copy Pipeline Element Dependencies_ is ticked:
  * Create a stroom user group using the template defined by property `additionalGroupTemplate`.
    * Add the created stroom user to this group.
  * If `additionalGroupParentGroupName` is defined and doesn't exist:
    * Create the Stroom user group specified in this property.

* Create an explorer tree folder using the template defined by property `destinationExplorerPathTemplate`.
    * Grant `VIEW` permission to the created group.
    * Grant `VIEW` permission to the created additional group.

* If _Copy Pipeline Element Dependencies_ is ticked:
  * Create an explorer tree sub folder using the template defined by property `destinationExplorerSubPathTemplate`.
    * Grant `VIEW` permission to the created group.
    * Grant `EDIT` permission to the created additional group.

* Create a Feed {{< stroom-icon "document/Feed.svg" >}} in the folder defined by `destinationExplorerPathTemplate`.
    * Grant `VIEW` permission to the created group.
    * Grant `VIEW` permission to the created additional group.

* Create a Pipeline {{< stroom-icon "document/Pipeline.svg" >}} in the folder defined by `destinationExplorerPathTemplate` and set it to inherit from the Pipeline defined in the Content Template.
  * If _Copy Pipeline Element Dependencies_ is ticked:
    * Copy the dependency documents of the parent Pipeline into this folder.
  * Create a Processor Filter on the new Pipeline (using the priority and concurrency setting taken from the Content Template) with the following expression:

    Feed `is` _X_ AND Type `=` _Y_

    [Where _X_ is the Feed created above and _Y_ is the stream type of the received data.]

* If `groupParentGroupName` is defined:
  * Create the Stroom user group specified in this property if it doesn't exist.
  * Add the group defined by `groupTemplate` to this group.

* If _Copy Pipeline Element Dependencies_ is ticked and `additionalGroupParentGroupName` is defined:
  * Create the Stroom user group specified in this property if it doesn't exist.
  * Add the group defined by `additionalGroupTemplate` to this group.


#### Copy Dependencies Example

The following is an example of the content that will be created with the following assumptions:

* The Feed name is `1234-AV_SCANNER-XML-EVENT_LOGGING`.
* `AccountId: 1234` in the Meta data.
* _Copy Pipeline Element Dependencies_ is ticked on the Content Template.
* Default `autoContentCreation` configuration.

{{< stroom-tree "System" "" >}}
  {{< stroom-tree "Feeds" "(Administrators: OWNER)" >}}
    {{< stroom-tree "1234" "(Administrators: OWNER, grp-1234: VIEW, grp-1234-dev: VIEW)" >}}
      {{< stroom-tree "Content" "(Administrators: OWNER, grp-1234: VIEW, grp-1234-dev: EDIT)" >}}
        {{< stroom-tree-doc "TextConverter" "1234-AV_SCANNER-XML-EVENT_LOGGING-dsParser" "(Administrators: OWNER, grp-1234: VIEW, grp-1234-dev: EDIT)" >}}
        {{< stroom-tree-doc "XSLT" "1234-AV_SCANNER-XML-EVENT_LOGGING-translationFilter" "(Administrators: OWNER, grp-1234: VIEW, grp-1234-dev: EDIT)" >}}
      {{< /stroom-tree >}}
      {{< stroom-tree-doc "Feed" "1234-AV_SCANNER-XML-EVENT_LOGGING" "(Administrators: OWNER, grp-1234: VIEW, grp-1234-dev: VIEW)" >}}
      {{< stroom-tree-doc "Pipeline" "1234-AV_SCANNER-XML-EVENT_LOGGING" "(Administrators: OWNER, grp-1234: VIEW, grp-1234-dev: VIEW)" >}}
    {{< /stroom-tree >}}
  {{< /stroom-tree >}}
{{< /stroom-tree >}}


#### Don't Copy Dependencies Example

The following is an example of the content that will be created with the following assumptions:

* The Feed name is `1234-AV_SCANNER-XML-EVENT_LOGGING`.
* `AccountId: 1234` in the Meta data.
* _Copy Pipeline Element Dependencies_ is **NOT** ticked on the Content Template.
* Default `autoContentCreation` configuration.

{{< stroom-tree "System" "" >}}
  {{< stroom-tree "Feeds" "(Administrators: OWNER)" >}}
    {{< stroom-tree "1234" "(Administrators: OWNER, grp-1234: VIEW)" >}}
      {{< stroom-tree-doc "Feed" "1234-AV_SCANNER-XML-EVENT_LOGGING" "(Administrators: OWNER, grp-1234: VIEW)" >}}
      {{< stroom-tree-doc "Pipeline" "1234-AV_SCANNER-XML-EVENT_LOGGING" "(Administrators: OWNER, grp-1234: VIEW)" >}}
    {{< /stroom-tree >}}
  {{< /stroom-tree >}}
{{< /stroom-tree >}}


### `PROCESSOR_FILTER` Mode

* Create a stroom user for the authenticated identity that has sent the data.

* Create a stroom user group using the template defined by property `groupTemplate`.
  * Add the created stroom user to this group.

* Create an explorer tree folder using the template defined by property `destinationExplorerPathTemplate`.
    * Grant `VIEW` permission to the created group.

* Create a Feed {{< stroom-icon "document/Feed.svg" >}} in the folder defined by `destinationExplorerPathTemplate`.
    * Grant `VIEW` permission to the created group.

* Create a Processor Filter on the new Pipeline (using the priority and concurrency setting taken from the Content Template) with the following expression:

  Feed `is` _X_ AND Type `=` _Y_

  [Where _X_ is the Feed created above and _Y_ is the stream type of the received data.]

* If `groupParentGroupName` is defined:
  * Create the Stroom user group specified in this property if it doesn't exist.
  * Add the group defined by `groupTemplate` to this group.


#### Example

The following is an example of the content that will be created with the following assumptions:

* The Feed name is `1234-AV_SCANNER-XML-EVENT_LOGGING`.
* `AccountId: 1234` in the Meta data.
* Default `autoContentCreation` configuration.

{{< stroom-tree "System" "" >}}
  {{< stroom-tree "Feeds" "(Administrators: OWNER)" >}}
    {{< stroom-tree "1234" "(Administrators: OWNER, grp-1234: VIEW)" >}}
      {{< stroom-tree-doc "Feed" "1234-AV_SCANNER-XML-EVENT_LOGGING" "(Administrators: OWNER, grp-1234: VIEW)" >}}
    {{< /stroom-tree >}}
  {{< /stroom-tree >}}
{{< /stroom-tree >}}


## Expression Fields

When creating the expression in a Content Template, the user will be limited to a set of fields to match on.
These fields will be matched against the meta data of the Stream.
The list of fields that can be used are configured using the property `.autoContentCreation.templateMatchFields`.

