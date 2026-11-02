---
title: "Adding fields from events"
linkTitle: "Adding fields from events"
weight: 24
date: 2026-10-27
tags:
  - ai
  - dashboard
  - search
description: >
  Adding values held only in a dashboard table's events, not in its index, with a search extraction the agent tries out first.
---

A dashboard table can only show the fields of its data source, unless it uses {{< glossary "Search Extraction" >}} to read further values from each row's event.
The agent can build that search extraction with you, e.g. when you ask _"Add each user's department to this table"_ and the department is in the events but not indexed.
The model never writes the extraction's XSLT: it gives the fields to extract, and Stroom writes the XSLT from them.

Attach the dashboard to the chat first (see [Using the chat]({{< relref "using-the-chat#attaching-a-tab" >}})).
See [Search Extraction]({{< relref "docs/user-guide/search/search-extraction" >}}) for how search extraction works.


## How it Works

1. **Finding the values.**
   The agent reads some of the table's events to find where the value is held, and works out each field: a name, the XPath of its value in the event, and a type.
1. **Trying it.**
   The agent tries the extraction on the table's own events, by stepping them through it, without saving anything.
   It shows you a table of the values extracted from each event, and anything to check, such as:
   * A field the data source already has (its extracted value would replace the indexed one in the table, while queries still filter on the indexed one)
   * A field found in only a few events
   * Values that don't fit the field's type
   * Values that differ from those the table shows now
1. **Agreeing the fields.**
   You agree the fields with the agent, which may try again with changes.
1. **Making it.**
   The agent offers a button to make the extraction, with exactly the fields it last tried.

Turning search extraction on fills every value in the table from it, so the extraction must also give every field the table's columns already use.
The agent includes them, and a proposal that leaves one out is refused.


## The Buttons

For a table that doesn't use search extraction yet, the agent offers _Create extraction pipeline…_.
Clicking it opens Stroom's New dialog, in which you name the pipeline and choose its folder.
Stroom then writes an XSLT and a pipeline using it (a child of the Search Extraction template, or a pipeline of its own made as the template is), and sets the table to use it, with a column for each new field, unsaved, for you to check and save.

For a table that already uses an extraction pipeline, the agent offers two buttons:

* **Change** the pipeline's XSLT in place, if you can edit it.
  The change is shown as a diff, with the other dashboards and queries that use the same XSLT, as they will get the new fields too.
  If Stroom AI wrote the XSLT, it is written again from the fields given; if it was written by hand, the new fields are added to it.
* **Create** a new pipeline from the Search Extraction template, with its own copy of the changed XSLT, for this table only, leaving the table's pipeline as it is.

Using one button makes the other unusable.
Before anything is written, Stroom checks that the open dashboard's table still extracts as it did when the button was offered.


## What You Need

* _Pipeline Stepping_ and _Data - View_, to try the extraction on the table's events.
* Permission to create documents in the folder you choose, or Edit permission on the XSLT to change it in place.
* A [tool policy]({{< relref "../agent-tools/tool-policies" >}}) granting you the Content category.
  Read-only access is enough, as the agent only offers buttons, and you make the change.

Where a field is needed in many dashboards, or must be searched on, adding it to the index is often better than extracting it; the agent says so where it applies.
