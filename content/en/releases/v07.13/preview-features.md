---
title: "Preview Features (experimental)"
linkTitle: "Preview Features"
weight: 20
date: 2026-08-13
tags: 
description: >
  Preview features in Stroom version 7.13.
  Preview features are somewhat experimental in nature and are therefore subject to breaking changes in future releases.
---

## Ask Stroom AI

Ask Stroom AI, introduced as a preview feature in v7.11, has been substantially improved and remains a preview feature.

* The chat can be docked as a panel rather than only opening as a dialog.
* Chat history is kept, and individual messages and attachments can be viewed, opened or deleted.
* Tables can be attached to a conversation, and are named so that the model can refer to them by source.
* Larger tables are analysed in batches and the results merged, rather than the request simply being too big.
* Answers can be copied and downloaded, and messages show when they were sent.
* Use of Ask Stroom AI is now recorded in the event log.

The chat history is held in the database, which is why a new `ai` configuration branch appears in this release.

{{% see-also %}}
[Upgrade Notes]({{< relref "./upgrade-notes" >}})
{{% /see-also %}}


## Dense Vector Search

Dense vector fields, introduced as a preview feature in v7.11, remain experimental in both the Lucene and Elasticsearch implementations.

* Search results can be reranked using a model, including across multiple `dense_vector` fields in Elasticsearch.
* The number of dimensions used for embedding is configurable, and can be left unset.
* A new XSLT function computes the similarity of two float vectors.
