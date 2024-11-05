---
title: "Searching Data"
linkTitle: "Searching Data"
weight: 110
date: 2024-04-29
tags:
  - search
  - query
  - dashboard
description: >
  Searching the data held in Stroom using Dashboards, Queries, Views and Analytic Rules.
---

Data in stroom (and in external Elastic indexes) can be searched using a number of ways:

* [Dashboard]({{< relref "dashboards" >}}) {{< stroom-icon "document/Dashboard.svg">}}
  Combines multiple query expressions, result tables and visualisations in one configurable layout.

* [Query]({{< relref "queries" >}}) {{< stroom-icon "document/Query.svg">}}
  Executes a single search query written in {{< glossary "StroomQL" >}} and displays the results as a table or visualisation.

* [Analytic Rule]({{< relref "analytics" >}}) {{< stroom-icon "document/AnalyticRule.svg">}}
  Executes a {{< glossary "StroomQL" >}} search query either against data as it is ingested into Stroom or on a scheduled basis.
