---
title: "Creating charts"
linkTitle: "Creating charts"
weight: 22
date: 2026-10-27
tags:
  - ai
  - dashboard
  - visualisation
description: >
  Charting a dashboard table or a StroomQL query with the agent, and filtering, reading and changing the charts it makes.
---

The agent can chart the results of a dashboard table, or of a StroomQL query, from a request in plain words, e.g. _"Chart failed logins per user as a bar chart"_ or _"Show who messages whom as a network"_.
It chooses the kind of chart, which of the table's columns it draws and its style, and checks that the table's rows can make the chart.
Stroom then builds the {{< glossary "Visualisation" >}} from a fixed template, drawn by Stroom's own adapter script, so no code written by the model ever runs in your browser.

Attach the dashboard or query tab to the chat first (see [Using the chat]({{< relref "using-the-chat#attaching-a-tab" >}})).


## Before You Start

An administrator must install a charting library, as a {{< stroom-icon "document/Script.svg" >}} Script document:

* **ECharts**: A Script document holding `echarts.min.js` from an {{< external-link "Apache ECharts" "https://echarts.apache.org" >}} release, version 6 or later.
* **D3**: A Script document holding a D3 build, version 3 or later (e.g. `d3.min.js` from D3 7).
  The visualisations content pack includes D3 3.

Stroom recognises a library by its content, so upgrading one is a matter of putting a newer release's build in its Script document.
Where several versions are installed, the newest is used.
The first time a chart is created, Stroom adds its own adapter Script document beside the library.

With both libraries installed, the agent asks which to use, recommending ECharts.
Both draw every kind of chart and setting, and look and work alike.
The agent can also wire one of the visualisations content pack's own D3 Visualisations to a table.


## Making a Chart

1. Ask for the chart.
   If you ask the agent to suggest one, it looks at the table's columns and the charts already on the dashboard, and offers two to four kinds that suit the data for you to choose from.
   Ask _"Which charts could I make from this table?"_ for the kinds it can make now, those it could make after a change to the table, and those that don't suit it (see [Which Charts a Table Can Make]({{< relref "analytics#which-charts-a-table-can-make" >}})).
1. The agent asks what it needs to know: the library, how clicks on the chart should filter the dashboard (see [Filtering by a Chart](#filtering-by-a-chart)), and anything unclear that changes the chart, such as the time bucket for a time axis.
1. If the table lacks something the chart needs (e.g. a count to size bars by, or a time rounded to the hour), the agent includes the change to the table, or a new table, with the chart.
1. The agent offers a _Create visualisation_ button.
   Clicking it opens Stroom's New dialog, in which you name the Visualisation and choose its folder (the dashboard's, by default).
   The chart is then added to the dashboard, with any table change and filter, unsaved, for you to check and save.

A new chart joins the dashboard's other charts as a tab, or, if it has none, goes in a new pane across the bottom of the dashboard.
Ask for it to go somewhere else (below or beside its table) if you want.
On a StroomQL query, or a dashboard's Embedded Query, the chart is a `show` clause put at the end of the query.

If the table's rows can't make the chart you asked for, the agent says why and what would fix it, rather than charting other columns.

You can ask for several charts at once (e.g. _"a gauge for each numeric column"_), up to 12.
They are created together with one _Create visualisations_ button, in one folder, and laid out side by side, one below another, in a grid or as tabs, as you choose.


## Kinds of Chart

Kind | Draws | Good for
-- | -- | --
Bar | A category and a value, with an optional series | Comparing totals across categories, e.g. events per user.
Line | An x (usually a time) and a y, with an optional series | Change over time.
Pie | A name and a value | Shares of a whole with few parts (12 or fewer; the rest become _Other_).
Scatter | An x and a y, with an optional size and series | How two measures relate, e.g. bytes against duration.
Network graph | A source and a target, with an optional weight and groups | Relationships, e.g. who messages whom.
Heatmap | An x, a y and a value | A value across two dimensions, e.g. events by hour of day and day of week.
Calendar | A date and a value | A value a day over weeks or months.
Histogram | A value, with an optional series | How a number is spread, e.g. response times; from one row per event.
Sankey | A source and a target, with an optional value | Flows from one thing to the next, e.g. source IP to destination IP to port.
Chord | A source and a target, with an optional weight | Who links to whom round a circle, for a few dozen nodes.
Sunburst | A name and up to five further levels, with an optional value | A whole split by levels, as rings.
Gauge | A value, with an optional name | A value against its range, e.g. the latest or the maximum.

Sankey, network and chord charts can follow more than two columns, e.g. source IP, then destination IP, then port.

A chart is drawn from the table's top-level rows only, so the columns it draws must all be grouped at the same level.
To put dates on a time axis, the column must be formatted as Date Time; dates held as text are drawn as categories.
A chart draws at most its _Max Rows_ (5,000 by default) of the table's rows, and a network graph at most its _Max Nodes_ (300), the most connected first.


## The Chart's Toolbar

Each chart has a toolbar under its pane's title with, where they apply:

* {{< stroom-icon "history.svg" "Select a time range" >}} _Select a time range_, then drag across the chart.
* {{< stroom-icon "clear.svg" "Clear the selection" >}} _Clear the selection_.
* {{< stroom-icon "zoom-in.svg" "Zoom in" >}} _Zoom in_, {{< stroom-icon "zoom-out.svg" "Zoom out" >}} _Zoom out_ and {{< stroom-icon "fit-width.svg" "Reset zoom" >}} _Reset zoom_.
  Bar, line and scatter charts, and network graphs, also zoom with the mouse wheel and pan by dragging.
* {{< stroom-icon "pause.svg" "Pause the layout" >}} _Pause the layout_, while a network graph settles.
* {{< stroom-icon "eye.svg" "Show all series" >}} _Show all series_, once some have been hidden from the legend.
* {{< stroom-icon "download.svg" "Download" >}} _Download_: The chart as a PNG image, or the data it draws as CSV (for users with the _Download Search Results_ permission).
* {{< stroom-icon "ai.svg" "Ask Stroom AI about this chart's data" >}} _Ask Stroom AI_: attaches the data the chart draws to the chat, with suggested questions about the chart.
* _Interval_, for a chart with _Auto Interval_ on: _Auto_, or a fixed interval.
* What is selected, and the {{< stroom-icon "refresh.svg" "Refresh" >}} refresh button.

A line chart over time, or a bar chart of dates, can have _Auto Interval_ turned on: the chart groups the table's rows into an interval that suits the time shown, coarser zoomed out and finer zoomed in.
It can't be finer than the table's own grouping, so group the table finely (e.g. `floorMinute()`) and let the chart coarsen it.

Charts follow your theme and your date and time preferences.


## Filtering by a Chart

Clicking an item on a chart (a slice, bar, point, link or node) selects it; clicking it again, or empty space, clears the selection.
Clicking with {{< key-bind "ctrl" >}} (or {{< key-bind "shift" >}}) held selects several items.
While something is selected, the chart shows a _Selected: …_ bar with a button that clears it.

A selection filter makes other parts of the dashboard follow the selection.
It filters either:

* **The query**, which runs again, so every table it feeds (and the chart itself) narrows to the selection, a drill-down.
* **One table**, e.g. listing the events behind a clicked slice, while the chart stays whole.

The agent asks which you want when it makes a chart, and adds the filter with it.
You can also ask for a filter on a chart already on the dashboard, or to remove one.
A selected time (a range dragged along a time axis, or a clicked point's day or hour) filters by time, not by an exact instant.
With nothing selected, the filter shows everything.


## Reading a Chart

Each chart sends Stroom a render report, shown in the chat and in the dashboard's description: what it drew, any rows left out and why, or its error, and what you are looking at.
The agent reads it to explain a chart, a spike or a selection, its trend lines and a network's clusters, and to find out why a chart shows nothing.
See [Analysing tables and charts]({{< relref "analytics#analysing-a-chart" >}}).


## Changing a Chart

Ask for a change to a chart's columns or style (e.g. _"make it horizontal"_, _"use a log scale"_), and the agent proposes it to apply to the dashboard, as any dashboard change (_Apply to dashboard_).
Settings include units, a log scale, threshold and average lines, breaking the axis for outliers, a zoom slider, jitter, and, for a network graph, its node colours, node sizes, physics and an overview thumbnail.

A change the chart's settings can't make, such as another kind of chart, means replacing the chart or adding a new one beside it; the agent asks which.
Replacing rewrites the chart's Visualisation for the new kind, saved at once (which needs Edit permission on it), and keeps its pane and place.
The selection filters driven by the old chart's clicks follow the new chart where it selects the same column, and the agent tells you what can't follow before you click.
Only charts Stroom AI generated can be replaced.

Every generated chart draws with the adapter of the Stroom release that is running, so a chart made with an earlier release can still be given settings added since.
Applying such a change first gives the chart's Visualisation those settings, keeping what it shows (this needs Edit permission on it).
