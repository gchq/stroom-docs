---
title: "CSV and Excel Data Connections"
linkTitle: "CSV and Excel"
weight: 40
date: 2026-11-12
tags:
  - data-source
  - search
  - data-connection
description: >
  Querying CSV text or an Excel workbook held in the Data Connection itself.
---

A CSV or Excel {{< stroom-doc "DataConnection" >}} holds its data in the document itself, so it needs no connection and no credential.
It suits small lookup tables and reference lists, such as teams, sites or holidays, that queries and dashboards can use alongside Stroom's own data.
Bulk data belongs in a {{< glossary "Feed" >}}.

The data is queried with Stroom's own clauses alone, so a query has no `sql` clause, e.g.

```stroomql
from "Bank Holidays"
where region = "All" or region = "Scotland"
sort by date
select date, holiday
```

The data is held, exported and imported with the document.
An export keeps it in a file of its own beside the document's JSON: the CSV as text, in a `.csv` file, and the workbook as the original `.xlsx` file.

An administrator sets the most data a Data Connection may hold with the `stroom.dataConnection.maxStoredDataSize` property, `5M` (5 MiB) by default.
Saving more is refused.


## Columns

The fields of a query are the columns in the document's _Columns_ table, in the order their values appear in each row.
Each column has a name, which becomes the field name, and a type, which its values are read as:

| Type | Values |
|------|--------|
| Text | Anything, kept as it is. |
| Long | Whole numbers. |
| Double | Numbers that may have a fraction. |
| Date | Dates and times in ISO 8601 with a four-digit year, e.g. `2026-11-12` or `2026-11-12T09:30:00Z`. A space may stand for the `T`. A time with no zone is taken as UTC; a zone is `Z` or an offset such as `+01:00`, `+0100` or `+01`. |
| Boolean | `true` or `false`, in any case. |

A value that is not of its column's type is empty, and the query warns about it, giving the number of such values and an example.

{{< stroom-btn "Detect Columns" >}} reads the first 1,000 rows and fills in the table:

* Each column is named from the header row, if there is one.
  A column with no name in the header, or with no header row, is named `column1`, `column2` and so on, and a repeated name has a suffix added, as each column needs a field name of its own.
* Each column's type is guessed from its values: the narrowest of Long, Double, Date and Boolean that all of them are, or else Text.
  Numbers that would lose something as a number stay Text, such as codes with leading zeros, e.g. `0123`, and whole numbers too big for a Long, such as long identifiers.
* A column already in the table keeps the type you chose for it, so you can detect the columns again after changing the data.

If the header row no longer matches the columns in the table, because the data changed after they were detected, a query warns that values may be under the wrong fields.
Detect the columns again.


## CSV

_Delimiter_
: The character between the values of each row: comma, semicolon, tab or pipe.
  Default: comma.

_First Row Is A Header_
: Whether the first row holds the column names.
  Default: on.

_CSV_
: The data.
  Paste it in, or click {{< stroom-btn "Load From File" >}} to read a file from your computer, which then detects the columns.
  Values are read as CSV, so a value holding the delimiter, a quote or a line break is quoted in `"` double quotes, with any `"` inside written twice.

Changing the delimiter or the header setting detects the columns again.

{{< stroom-btn "Check CSV" >}} reads all of the CSV and reports how many rows and columns it has, and any values that are not of their column's type.


## Excel

_Workbook_
: The Excel workbook.
  Choose an `.xlsx` file: it is uploaded straight away, which detects the columns, and stored with the document when you save.
  Older `.xls` workbooks cannot be read; save them as `.xlsx` in Excel first.
  {{< stroom-btn "Download" >}} downloads the stored workbook, e.g. to edit it in Excel and upload it again.
  {{< stroom-btn "Remove" >}} removes it when you save.

_Sheet (optional)_
: The name of the sheet to read.
  Leave it empty to read the first sheet.

_First Row Is A Header_
: Whether the first row with values holds the column names.
  Default: on.

Excel values are read as Excel worked them out:

* Numbers are read as plain numbers, whatever their format in Excel, e.g. `1234.5` for a cell shown as `£1,234.50`.
* Dates are read as dates, including in workbooks that count dates from 1904, as older Mac versions of Excel did.
* Formulas are read as the value Excel last worked out for them; Stroom does not work them out again.

{{< stroom-btn "Check Workbook" >}} reads all of the sheet and reports how many rows and columns it has, and any values that are not of their column's type.

The browser never holds the workbook: it is uploaded to Stroom, and downloaded only when you ask.


## Time Range and Other Settings

If the document names a _Time Column_, which must be a Date column, a query's time range filters the rows on it.
With none, the time range is ignored, and the query warns that it was.

The data only changes when the document does, so CSV and Excel Data Connections have no query timeout and no minimum refresh.
The rows read are cached for each version of the document, so a dashboard that refreshes does not read the data again.
