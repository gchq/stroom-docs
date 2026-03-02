---
title: "Analytic Rules"
linkTitle: "Analytic Rules"
weight: 40
date: 2024-04-30
tags: 
 - analytic
description: >
  Analytic Rules are queries that can be run against the data either as it is ingested or on a scheduled basis.
---

Analytic Rules allow you to run [{{% glossary "StroomQL" %}}]({{< relref "../queries/stroom-query-language" >}}) queries either:

* **Streaming** — evaluated as data is ingested through a pipeline, enabling near real-time alerting.
* **Table Builder** — builds up a working dataset over time for use in scheduled queries.
* **Scheduled Query** — runs periodically against existing indexed data.

When an Analytic Rule fires it can create an [Annotation]({{< relref "/docs/reference-section/documents#annotation" >}}) or send a notification.

{{% todo %}}
Complete this section.
{{% /todo %}}
