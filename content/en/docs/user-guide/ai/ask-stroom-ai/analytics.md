---
title: "Analysing tables and charts"
linkTitle: "Analysing tables and charts"
weight: 23
date: 2026-10-27
tags:
  - ai
  - dashboard
  - search
description: >
  The analysis the agent can do on the rows of a dashboard or query table, the events behind them, and the charts drawn from them.
---

The agent can answer questions about the results you are looking at, e.g. _"Which users had the most failed logins this week?"_, _"What kinds of error message are there?"_ or _"What's this spike?"_.
It works out figures in code, with its tools, rather than by reading rows, so its counts and totals are exact.
It can then make what it found part of the dashboard: a column, a grouping, a highlight, a new table or a chart.


## What You Can Ask

Kind of analysis | For example | How the agent does it
-- | -- | --
Counting and ranking | _"Top 10 users by failed logins"_, _"How many distinct hosts are there?"_ | Groups the table's rows and counts, sums, averages or finds the smallest and largest, then sorts and limits.
Rates, ratios and percentages | _"What share of each host's requests failed?"_, _"Bytes per second for each transfer"_ | Works the value out for each row or each group, with an expression.
Time | _"Events per hour yesterday"_, _"Which weekday is busiest?"_ | Rounds times into buckets (minute, hour, day, week, month), or takes their parts (hour of day, weekday).
Filtering and comparing | _"Only the rows from node-2"_, _"Which users logged in from more than three countries?"_ | Filters rows by comparisons, text matches and regular expressions, before or after grouping.
Free text | _"What kinds of error message are there?"_ | Counts messages as patterns, with the varying parts masked, and summarises them.
The events behind the rows | _"Which of these logins used a proxy?"_, _"What usernames are in these JSON payloads?"_ | Fetches the events behind the rows, and takes values out of them by XPath or jq, as a new column.
Data beyond the table | _"How does that compare with last month?"_ | Runs a StroomQL query of its own into a further table.
A chart | _"What's this spike?"_, _"Is this rising?"_, _"Who links these groups?"_ | Reads the chart's render report: what it draws, what you have selected or zoomed in on, its trends and clusters.
Which charts fit | _"Which charts could I make from this table?"_ | Sorts the chart kinds into those the table can make now, those it could make after a change, and those that don't suit it.
Why a chart is empty | _"Why does this chart show nothing?"_ | Checks the chart's rows, its table's filters and grouping, and the selections filtering it.

Each answer says what it covers, e.g. the rows of the snapshot it was worked out from, or _"of the first 500 of 12,000 events"_.


## Attaching a Table

A table gets to the chat in one of these ways:

* A table's or a chart's {{< stroom-icon "ai.svg" "Ask Stroom AI" >}} _Ask Stroom AI_ button, which attaches the table's rows (for a chart, the rows it draws).
* Attaching a dashboard or query tab, after which the agent takes a snapshot of the results it shows when it needs them.
* The agent's own StroomQL queries, whose results it saves as tables.

An attached table is downloaded into the chat's workspace, up to 50,000 rows by default.
The model isn't given the rows themselves, but the table's profile: its row and column counts, and for each column its type, how many values are empty, roughly how many distinct values it has, its smallest and largest values and its most common values, with a few sample rows.
From that it decides what to ask of the data.


### Snapshots of a Tab

A snapshot of a dashboard's or query's results is taken once, and reused for later questions.
The agent tells you before it gives figures from a snapshot that is:

* **Stale**: The tab's query, expression, parameters or time range have changed since it was taken.
* **Incomplete**: The search hadn't finished, the table's row limit cut it short, or it holds fewer rows than asked for while more exist.

It then offers to run the search again, which can be slow, and does so only if you say yes, for that question.
If you say no, it answers from the old snapshot, saying which query it is from.
Ask about _"the first 100 rows"_ and only those are taken.


## How the Agent Works Out Figures

The agent is told to work out every figure (a sum, average, ratio, percentage, difference, rate, age, time bucket, or a value taken out of text) with a tool, never in its head, even from a few rows it can see.
Its table tool queries a table exactly, in Stroom's expression language, the language of dashboard column expressions:

Step | What it does
-- | --
Columns worked out for each row | e.g. `round(${bytes} / ${seconds}, 1)` for a rate, `formatDate(floorHour(${time}), 'yyyy-MM-dd HH:00')` for an hour bucket, `upperCase(substring(${host}, 0, 3))` for a site code.
Conditions | `=`, `!=`, `<`, `<=`, `>`, `>=`, contains (ignoring case), starts with, ends with, matches a regular expression, empty and not empty.
Grouping and aggregates | Count, count of distinct values, sum, minimum, maximum and average for each group, or an expression over each group, e.g. `round(sum(if(${status} = 'ERROR', 1, 0)) / count() * 100, 1)` for the percentage of errors.
Distinct values | Each distinct value, or combination of values, with how many rows have it.
Sorting and limiting | Largest or smallest first, and the top _n_.

Every function of the expression language is available, e.g. date functions, string functions, `if()`, `match()` and `decode()`.
Results can be written to CSV files in the chat's workspace, to work on further, to fetch the events behind, or to chart.

For data the table doesn't hold, the agent can run a StroomQL query of its own (e.g. last month's figures, for a comparison), with `eval` to work values out, and query its results the same way.
If more than one data source could hold what you asked for, it asks you which, judging each by its documentation.
A query on an index whose answer through Stroom would mislead (e.g. `is null` on an Elasticsearch field, which matches every document) is refused, with what to query instead.

_"Show me"_, _"how many"_ and _"find"_ run a query and answer from it; _"create"_ or _"save a query"_ offer a Query document to run yourself.
If it isn't clear which you want, the agent asks.


### Free Text

For free text, such as log messages, the agent can:

* Count the text as patterns, with numbers, IP addresses, dates and IDs masked, so that _"User 1234 logged in from 10.1.2.3"_ and _"User 5678 logged in from 10.4.5.6"_ count as one pattern.
* Summarise a column, which reduces it to its distinct patterns with their counts and, only if there are still too many, has the model summarise them in batches, looking for what you ask about, if anything (e.g. _"anything about certificates"_).


## The Events Behind the Rows

When a table isn't grouped, each row carries the stream and event it came from (from the hidden `StreamId` and `EventId` columns), so the agent can look at the events themselves, e.g. for a value the table doesn't show.
For a grouped dashboard table, it takes the rows ungrouped, one per event, by running the table's search again separately.

1. It fetches the events behind the rows (up to 500 at a time by default, which needs the _Data - View_ permission), and reads one to find where the value is.
1. It searches them: with XPath for a value from each event, for text anywhere in each event (with a snippet around the match), or with jq for values inside JSON held in an event (e.g. every `username` at any depth of a message).
1. It adds what it finds as a column of the table, for the table tool to count, group or filter.

Answers from events say how many events they cover.
For an answer over all the data, the agent offers to add the value to the table itself with a [search extraction]({{< relref "search-extraction" >}}), or suggests a query on an indexed field.

The agent can also search an index directly, as a dashboard would, for an event you describe but can't point at, and trace a hit back to its raw record.


## Keeping What You Found

Once the agent has found something, it can make it part of the dashboard or a query, proposed as a change for you to apply (_Apply to dashboard_), unsaved, for you to check and save:

* **Columns**: A column worked out with an expression (tried on the snapshot first), e.g. a domain taken from an email address, or a decoded status.
* **Grouping, sorting and filtering**: For example, group by the new column and sort by its count.
* **Highlighting**: A conditional formatting rule that colours, emboldens or hides rows, e.g. _"Highlight rows where the status is FAILED in red"_.
* **Tables by category**: A table for each category in the rows (e.g. a tab per event type), each with the columns that suit it and a filter.
* **Charts**: See [Creating charts]({{< relref "charts" >}}); a chart that needs a table change, such as a count per hour, is proposed with it, in one button.
* **A data preview**: A Text widget showing the event of the selected row (on a grouped table, its detail rows are turned on so that an event can be selected).
* **A query or a dashboard**: A new StroomQL Query document, or a change to the attached query, or a new classic or StroomQL dashboard (see [Building dashboards]({{< relref "dashboards" >}})).


## Analysing a Chart

Each chart Stroom AI generated sends Stroom a render report, which the agent reads: what it drew, any rows left out and why, and any error.
It also says what you are looking at:

* The part zoomed in on, e.g. a period of time
* What is selected, as the chart labels it
* The series hidden from the legend
* The interval an _Auto Interval_ chart groups by

So you can ask _"What's this spike?"_ or _"Explain what I've selected"_, and the agent reads the rows behind it from the chart's table.
The chart works out the figures below itself, and the agent quotes them from the report rather than reading them off the picture.


### Next Steps for a Chart

Ask what you can do with a chart (e.g. _"What can I do with this network graph?"_), and the agent offers two to four next steps that suit its kind and its data, naming the column, period or node, and recommending one, e.g. _"Find the groups among the 42 people messaging each other, and who links them"_.

Chart | Next steps the agent offers
-- | --
Network graph | Colour its [clusters](#clusters) and find the bridges between them; compare the clusters with a known grouping, such as departments; size nodes by their total links and show direction (who starts); narrow the dashboard to one person with a selection filter on their node.
Line chart, bars of dates, scatter plot | Draw a [trend](#trends); compare against a level with an average or threshold line; turn on _Auto Interval_ for detail as you zoom; read the rows behind a spike or dip.
Any chart | A better kind of chart for the data; filtering the dashboard by what is clicked (see [Filtering by a Chart]({{< relref "charts#filtering-by-a-chart" >}})).

A detail that isn't a column of the chart's table (e.g. each person's department, for a network's groups) can't be charted until it is one.
If it is in the events but not indexed, the agent offers to add it with a [search extraction]({{< relref "search-extraction" >}}), rather than inventing it.


### Trends

Line, bar (of dates) and scatter charts can draw a trend line: a straight-line fit, or a centred moving average (over about a tenth of the points, by default).
A trend needs an x it can follow (dates or numbers, not text, and bars in their own order, not sorted by value).
For each series (or the total, for a stacked chart), the report gives:

* The **direction**: Rising, falling or flat (flat meaning it changes by less than 5% of the series' average over the time shown).
* The **slope**, per a unit that suits the time shown, e.g. _+12/day_.
* **R²**, how well a straight line fits, from 0 to 1.
  Below about 0.3 the trend is weak, and drawn fainter; the agent then says the values vary too much to call it rising or falling.

With _Auto Interval_ on, the trend is of each interval's values, so it changes as zooming changes the interval, and the agent says which interval it was read at.


### Clusters

A network graph can colour its clusters: groups of nodes more linked to each other than to the rest, found with the Leiden method.
The links between clusters are greyed.
The report gives:

* How many clusters there are, and their **modularity**, how clear-cut they are (below about 0.3 they are weak, above about 0.5 clear).
* The largest clusters, each named after its most connected member (e.g. `mchen +11`), with its size.
* The **bridges**: The nodes linked to the most other clusters, often the people or hosts worth a closer look.

Mapping a known grouping, such as each person's department, to the graph's groups also gives the group most of each cluster is in.
A cluster mixing groups, or a group split across clusters, is often the finding.


### Which Charts a Table Can Make

Ask which charts suit a table, and the agent looks at the types of its columns (in a snapshot of the rows) and its grouping, and gives:

* The kinds it can make now, with the columns each would draw
* The kinds it could make after a change to the table, naming the change (e.g. a time rounded to the hour, formatted as Date Time and grouped, for a line chart)
* The kinds that don't suit it

A chart you describe in words is mapped to a kind, and the agent says which reading it chose, e.g. _"a calendar-like heatmap of activity"_ is either a calendar of counts by day, or a heatmap of weekday by hour of day.


### When a Chart Shows Nothing

Ask why, and the agent checks the render report, the rows of the chart's table, the table's filters and grouping, and the selection filters that feed it.
It says what is filtering the rows out, and offers the fix: often clearing a selection on another chart.


## Models without Tools

A model that can't call tools is given the first 10,000 rows of each table (by default), and told when there are more.
If they don't fit its context window, the tables are analysed in batches, and the partial answers are merged into one answer.
These limits, and the prompts used for batches and for merging, are set by an administrator on the **Table Analysis** tab of the chat's **Settings** (from the chat's {{< stroom-icon "ellipses-vertical.svg" "More" >}} _More_ menu).

Answers worked out this way are less exact than those of a model with tools, and the analysis above that relies on tools (expressions, the events behind rows, queries of its own) isn't available.

See [Creating charts]({{< relref "charts" >}}) for making and changing charts.
