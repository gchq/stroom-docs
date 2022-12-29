---
title: "Exploring Data in Kibana"
linkTitle: "Kibana"
weight: 4
date: 2022-12-15
tags:
  - search
  - elastic
  - elasticsearch
  - kibana
description: >
  Using Kibana to search, aggregate and explore data indexed in Stroom
---

{{< external-link "Kibana" "https://www.elastic.co/kibana/" >}} is part of the Elastic Stack and provides users with an interactive, visual way to query, visualise and explore data in Elasticsearch.

It is highly customisable and provides users and teams with tools to create and share dashboards, searches, reports and other content.

Once data has been indexed by Stroom into Elasticsearch, it can be explored in Kibana. You will first need to {{< external-link "create a *data view*" "https://www.elastic.co/guide/en/kibana/current/data-views.html" >}} in order to query your indices.


## Why use Kibana?

There are several use cases that benefit from Kibana:

1. Convenient and powerful drag-and-drop charts and other visualisation types using Kibana Lens. Much more performant and easier to customise than built-in Stroom dashboard visualisations.
2. Field statistics and value summaries with Kibana Discover. Great for doing initial audit data survey.
3. Geospatial analysis and visualisation.
4. Search field auto-completion.
5. {{< external-link "Runtime fields" "https://www.elastic.co/guide/en/elasticsearch/reference/current/runtime.html" >}}. Good for data exploration, at the cost of performance.
