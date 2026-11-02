---
title: "Building dashboards"
linkTitle: "Building dashboards"
weight: 21
date: 2026-10-28
tags:
  - ai
  - dashboard
  - query
description: >
  Creating a dashboard from scratch from a request in plain words, as a classic (Expression) or StroomQL dashboard, then building on it with the agent.
---

The agent can create a {{< glossary "Dashboard" >}} from a request in plain words, e.g. _"Build me a dashboard of failed logins by user over the last week"_ or _"A dashboard of web traffic by host, with a data preview"_.
It writes the dashboard's query, checks it, and offers a button that creates the dashboard for you.
Once it is open, attach it to the chat and the agent can add to it: tables, columns, filters, highlighting and charts.

The agent never creates the dashboard itself: nothing is saved until you click its button and confirm Stroom's own New Dashboard dialog.


## Creating a Dashboard

1. **Ask for it**, saying what it should show.
   Name the data source and the time if you know them; the agent finds the rest.
1. **The agent finds the data.**
   If more than one data source could hold what you asked for, it lists them for you to choose from, judging each by its documentation, not just its name.
   It reads the chosen data source's fields, to write the query with fields that exist.
1. **The agent asks you, in one card**, only what your request didn't already say:
   * The kind of dashboard, [classic or StroomQL](#classic-or-stroomql)
   * Which fields the table should show, offered as sets of fields from the data source
   * Whether you want a data preview of the selected row's event
   * Which data source, if more than one fits
1. **The agent writes and checks the query** in StroomQL, whichever kind you chose: a `where` clause for what to find, and a `select` clause for the table's columns, with any grouping, sorting and limit.
   The query is validated against the data source before it is offered, and a dashboard Stroom can't build from it is refused, with why (e.g. a query with no `select` clause, which would give a table with no columns).
1. **The agent offers a _Create dashboard…_ button**, with a sentence saying what the dashboard shows and what it holds (e.g. _"A classic query and a table of 3 columns (EventTime, User, Action), with a data preview"_).
   For a classic dashboard, it also shows the query and table in plain words: what the query selects and from which data source, the table's columns, what they are grouped and sorted by, and the most rows it shows.
1. **Click the button**: Stroom's New Dashboard dialog opens, with the name the agent suggested, in the folder selected in the Explorer tree.
   Choose the name and folder, and once you create it, the dashboard is given its query, table and preview and opened.

You need permission to create documents in the folder, and to use the data source.


## Classic or StroomQL

The agent writes StroomQL either way; the kind you choose decides what the dashboard holds.

Kind | The dashboard holds | Choose it for
-- | -- | --
Classic (Expression) | A Query pane holding an expression built from the query's `where` clause, with the data source; a Table pane with the columns, grouping, sorting and limit of its `select`; and, if asked for, a Data Preview pane. | A dashboard to change through the query's expression tree and the table's column menus, and to add further tables to.
StroomQL | An Embedded Query pane holding the StroomQL itself, which shows its own table of results, and, if asked for, a Data Preview pane. | Queries a classic dashboard can't hold (`window`, `filter`, `having` or `show` clauses), and those who prefer to read and edit the query as text.

The panes are laid out one above the other: the query, the table, then the preview.

* A classic query's `where` clause is turned into the expression's terms, checked against the data source's fields as StroomQL's are.
* A classic table uses the data source's default extraction pipeline, where it has one, so its columns can show values from the events.
* A classic dashboard can't hold StroomQL's `window`, `filter`, `having` or `show` clauses: a query with any of them is refused as classic, and the agent offers to keep it as StroomQL or leave them out.
* A data preview shows the event a row came from, which a grouped row doesn't have.
  For a grouped table, the agent leaves the preview out, or the grouping, and says why.
  On a classic table, it can later turn on the table's detail rows, so that an event can be selected under a group.

For example, _"A dashboard of failed logins per user over the last week, busiest first"_ might be written as:

```text
from "Authentication Events"
where EventTime > day() - 7d and Outcome = "Failure"
select User, count() as Failures
group by User
sort by Failures desc
```

As classic, this gives a Query whose expression has the two terms of the `where` clause, and a table of _User_ and _Failures_, grouped by _User_ and sorted by _Failures_, descending.
As StroomQL, the Embedded Query holds the query as written.


## Building on a Dashboard

Attach the new dashboard to the chat (see [Using the chat]({{< relref "using-the-chat#attaching-a-tab" >}})), and ask for what you want added or changed.
The agent proposes changes as an _Apply to dashboard_ button, which applies them to the open dashboard, unsaved, for you to check and save.
One proposal can make up to 100 changes, so a request like _"Add a tab for each event category"_ is one button.

Change | For example
-- | --
Tables | _"Add a table of the top 10 source IPs"_, or a table for each category in the rows (e.g. a tab per event type), each with the columns that suit it and a filter on the category. Up to 10 tables in one proposal.
Columns | Add, edit, move, hide or show a column; a column worked out with an expression (tried on a snapshot of the rows first), e.g. a domain taken from an email address; its format (General, Number, Date Time or Text).
Grouping, sorting and filtering | Group or ungroup by a column, sort by one or more columns, filter a column's values.
The query | Change a classic query's expression, e.g. _"Only show the last 24 hours"_.
Highlighting | A conditional formatting rule that colours a row's background or text, makes it bold or italic, or hides it, e.g. _"Highlight rows where the status is FAILED in red"_.
A data preview | A Text widget showing the event of the selected row, through a pipeline or as raw data.
Charts | See [Creating charts]({{< relref "charts" >}}); a chart that needs a table change, such as a count per hour, is proposed with it.
Filtering by a chart | Clicks on a chart filtering the query or a table (see [Filtering by a Chart]({{< relref "charts#filtering-by-a-chart" >}})).
Values from the events | A field that is in the events but not indexed, added with a [search extraction]({{< relref "search-extraction" >}}).
Names and settings | Rename a pane or a column; set the query to run when the dashboard opens, or to refresh on a timer (e.g. every 10 minutes); a table's rows per page, the most rows at each group level, its detail rows, its column filters row, and its extraction pipeline.

On a StroomQL dashboard, the table's results come from the query itself, so changes to the table don't apply to it.
Its settings (running when opened, refreshing) can be changed, and a chart is added as a `show` clause at the end of its StroomQL.

The agent names panes and columns as you see them on the dashboard, so you can refer to them that way, e.g. _"Sort the Failures column in the second table"_.


## A Query Instead

If you want to run a search yourself rather than have a dashboard, ask for a query, e.g. _"Create a query for DNS lookups of new domains"_.
The agent offers a _Create query…_ button, which opens Stroom's New Query dialog, and saves the StroomQL in the new Query once you create it.
With a Query tab attached, it can propose a change to the query instead (_Apply to query_), laid out a clause a line, which you can undo.

_"Show me"_ or _"how many"_ has the agent run the search and answer from the results; _"create"_, _"make"_ or _"save"_ a query or dashboard has it offer a document to create.
If it isn't clear which you want, it asks.
