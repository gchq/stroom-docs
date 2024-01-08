---
title: "Lucene Indexes"
linkTitle: "Lucene Indexes"
#weight:
date: 2022-02-15
tags:
  - TODO
description: >
  Stroom's built in Apache Lucene based indexing.

---

Stroom uses {{< external-link "Apache Lucene" "https://lucene.apache.org" >}} for its built-in indexing solution.
Index documents are stored in a {{< glossary "Volume" >}}.

{{% todo %}}
Complete this page.
{{% /todo %}}


## Field configuration

### Field Types

* `Id` - Treated as a `Long`.
* `Boolean` - True/False values.
* `Integer` - Whole numbers from -2,147,483,648 to 2,147,483,647.
* `Long` - Whole numbers from -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807.
* `Float` - Fractional numbers.
   Sufficient for storing 6 to 7 decimal digits.
* `Double` - Fractional numbers.
   Sufficient for storing 15 decimal digits.
* `Date` - Date and time values.
* `Text` - Text data.
* `Number` - An alias for `Long`.


### Stored fields

If a field is _Stored_ then it means the complete field value will be stored in the index.
This means the value can be retrieved from the index when building search results rather than using the slower [Search Extraction]({{< relref "extraction.md" >}}) process.
Storing field values comes at the cost of hight storage requirements for the index.
If storage space is not an issue then storing all fields that you want to return in search results is the optimum.


### Indexed fields

An _Indexed_ field is one that will be processed by Lucene so that the field can be queried.
How the field is indexed will depend on the Field type and the Analyser used.

If you have fields that you do not want to be able to filter (i.e. that you won't use as a query term) then you can include them as non-Indexed fields.
Including a non-indexed field means it will be available for the user to select in the {{< glossary "Dashboard" >}} table.
A non-indexed field would either need to be _Stored_ in the index or added via Search Extraction to be available in the search results.


### Positions

If _Positions_ is selected then Lucene will store the positions of all the field terms in the document.


### Analyser types

The Analyser determines how Lucene reads the fields value and extracts tokens from it.
The choice of Analyser will depend on the date in the field and how you want to search it.

* `Keyword` - Treats the whole field value as one token.
  Useful for things like IDs and post codes.
  Supports the _Case Sensitivity setting_.
* `Alpha` - Tokenises on any non-letter characters, e.g. `one1 two2 three 3` => `one` `two` `three`.
  Strips non-letter characters.
  Supports the _Case Sensitivity setting_.
* `Numeric` - 
* `Alpha numeric` - Tokenises on any non-letter/digit characters, e.g. `one1 two2 three 3` => `one1` `two2` `three` `3`.
  Supports the _Case Sensitivity setting_.
* `Whitespace` - Tokenises only on white space.
  Not affected by the _Case Sensitivity setting_, case sensitive.
* `Stop words` - Tokenises bases on non-letter characters and removes [Stop Words]({{< relref "#stop-words" >}}), e.g. `and`.
  Not affected by the _Case Sensitivity setting_.
  Case insensitive.
* `Standard` - The most common analyser.
  Tokenises the value on spaces and punctuation but recognises URLs and email addresses.
  Removes [Stop Words]({{< relref "#stop-words" >}}), e.g. `and`.
  Not affected by the _Case Sensitivity setting_.
  Case insensitive.
  e.g. `Find Stroom at github.com/stroom` => `Find` `Stroom` `at` `github.com/stroom`.


#### Stop words

Some of the Analysers use a set of stop words for the tokenisers.
This is the list of stop words that will not be indexed.

`a`, `an`, `and`, `are`, `as`, `at`, `be`, `but`, `by`, `for`, `if`, `in`, `into`, `is`, `it`, `no`, `not`, `of`, `on`, `or`, `such`, `that`, `the`, `their`, `then`, `there`, `these`, `they`, `this`, `to`, `was`, `will`, `with`


### Case sensitivity

Some of the Analyser types support case (in)sensitivity.
For example if the Analyser supports it the value `TWO two` would either be tokenised as `TWO` `two` or `two` `two`.




