---
title: "Elasticsearch"
linkTitle: "Elasticsearch"
weight: 30
date: 2024-05-03
tags: 
  - data-source
  - search
  - elastic
description: >
  Using Elasticsearch as a data source.
---

Stroom can integrate with external Elasticsearch indexes to allow querying using Stroom's various mechanisms for querying data sources.
These indexes may have been populated using a Stroom pipeline (See [here]({{< relref "docs/user-guide/indexing/elasticsearch" >}})).


## Searching Using a Stroom Dashboard

Searching an Elasticsearch index (or data stream) using a Stroom dashboard is conceptually similar to the process described in [Dashboards]({{< relref "docs/quick-start-guide/dashboard" >}}).

Before you set the dashboard's data source, you must first create an Elastic Index document to tell Stroom which index (or indices) you wish to query.


### Create an Elastic Index Document

1. Right-click a folder in the Stroom Explorer pane ({{< stroom-icon "folder-tree.svg" "Explorer" >}}).
1. Select:  
   {{< stroom-menu "New" "Elastic Index" >}}
1. Enter a name for the index document and click {{< stroom-btn "OK" >}}.
1. On the **Settings** tab, select the `Elastic Cluster` document for the cluster where the index exists in `Cluster configuration`.
1. Enter the name of an index or data stream in `Index name or pattern`.
   Data view (formerly known as *index pattern*) {{< external-link "syntax" "https://www.elastic.co/guide/en/kibana/current/data-views.html#settings-create-pattern" >}} is supported, which enables you to query multiple indices or data streams at once.
   For example: `stroom-events-v1`.
1. (Optional) Enter the name of the index's main date field in `Main date field`, which is the field a query's time range applies to.
   This is usually `@timestamp`, especially for data streams.
1. (Optional) Set `Number of slices`, which is the number of parallel workers that will query the index.
   For very large indices, increasing this value up to and including the number of shards can increase scroll performance, which will allow you to download results faster.
1. (Optional) Set `Scroll size`, which specifies the number of documents to return in each search response.
   Greater values generally increase efficiency.
   By default, Elasticsearch limits this number to `10,000`.
1. (Optional) Select a `Default extraction pipeline`.
   Dashboard tables set to use the data source's default extraction pipeline use it to extract fields from the source events of search results.
1. (Optional) Set the `Vector search` fields, as explained in [Vector Search]({{< relref "#vector-search" >}}).
1. Click {{< stroom-btn "Test Connection" >}}.
   A dialog will appear with the result, which will state `Connection Success` if the connection was successful and the index pattern matched one or more indices.
1. Click {{< stroom-icon "save.svg" "Save" >}}.


### Set the Elastic Index Document as the Dashboard Data Source

1. Open or create a dashboard.
1. Click {{< stroom-icon "settings.svg" "Settings" >}} in the `Query` panel.
1. Click {{< stroom-icon "ellipses-horizontal.svg" "Ellipsis" >}} next to the `Data Source` field label.
1. Select the Elastic Index document you created and click {{< stroom-btn "OK" >}}.
1. Configure the query expression as explained in [Dashboards]({{< relref "docs/quick-start-guide/dashboard#configuring-the-query-expression" >}}).
   Note the [tips]({{< relref "#query-expression-tips" >}}) for particular Elasticsearch field mapping data types.
1. [Configure the table]({{< relref "docs/quick-start-guide/dashboard#configuring-the-table" >}}).


## Query Expression Tips

Certain Elasticsearch field mapping types support special syntax when used in a Stroom dashboard query expression.

To identify the field mapping type for a particular field:

1. Click {{< stroom-icon "add.svg" "Add" >}} in the `Query` panel to add a new expression item.
1. Select the Elasticsearch field name in the drop-down list.
1. Note the blue data type indicator to the far right of the row.
   Common examples are: `keyword`, `text` and `number`.

After you identify the field mapping type, move the mouse cursor over the mapping type indicator.
A tooltip appears, explaining various types of queries you can perform against that particular field's type.


## Searching Multiple Indices

Using data view (index pattern) syntax, you can create powerful dashboards that query multiple indices at a time.
An example of this is where you have multiple indices covering different types of email systems.
Let's assume these indices are named: `stroom-exchange-v1`, `stroom-domino-v1` and `stroom-mailu-v1`.

There is a common set of fields across all three indices: `@timestamp`, `Subject`, `Sender` and `Recipient`.
You want to allow search across all indices at once, in effect creating a unified *email* dashboard.

You can achieve this by creating an Elastic Index document called (for example) `Elastic-Email-Combined` and setting the property `Index name or pattern` to: `stroom-exchange-v1,stroom-domino-v1,stroom-mailu-v1`.
Click {{< stroom-icon "save.svg" "Save" >}} and re-open the dashboard.
You'll notice that the available fields are a union of the fields across all three indices.
You can now search by any of these - in particular, the fields common to all three.


## Vector Search

Vector search finds documents whose meaning is similar to the search term, rather than documents containing the same words.
It works on Elasticsearch fields of type {{< external-link "dense_vector" "https://www.elastic.co/guide/en/elasticsearch/reference/current/dense-vector.html" >}}, each of which holds an embedding of a text field, i.e. a list of numbers generated by an embedding model to represent the text's meaning.

When a query expression term uses a `dense_vector` field, Stroom asks the index's embedding model for an embedding of the term, and sends Elasticsearch a {{< external-link "kNN query" "https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-knn-query.html" >}} for the documents whose vectors are nearest to it.
A `dense_vector` field supports the `=`, `!=`, `in` and `in dictionary` conditions.

Optionally, Stroom can then rerank the results: a rerank model scores how relevant each result's original text is to the search term, and results scoring below a minimum are left out.
This matters because a kNN query always finds the nearest documents, even when none of them is relevant.


### Preparing the Index

Stroom does not generate embeddings when it indexes into Elasticsearch, so the index must hold them already.
For example, an Elasticsearch {{< external-link "ingest pipeline" "https://www.elastic.co/guide/en/elasticsearch/reference/current/ingest.html" >}} with an inference processor can generate them as documents are indexed, set in the {{< pipe-elm "ElasticIndexingFilter" >}} `ingestPipeline` property.

{{< warning >}}
The embeddings in the index and those Stroom generates for search terms must come from the same embedding model, with the same number of dimensions.
Otherwise the vectors can't be compared, and a search either fails or finds unrelated documents.
{{< /warning >}}

Name each vector field and the text it was generated from as siblings, differing only in the last part of the name, e.g. `Content.vector` and `Content.text`.
Reranking finds a vector field's text by this naming convention.
For example, the mappings in an index template could include:

```json
"mappings": {
  "properties": {
    "Content": {
      "properties": {
        "text": {
          "type": "text"
        },
        "vector": {
          "type": "dense_vector",
          "dims": 1024,
          "similarity": "cosine"
        }
      }
    }
  }
}
```


### Vector Search Settings

The `Vector search` section of the Elastic Index document's **Settings** tab holds:

Setting | Default | Description
-- | -- | --
`Vector generation model` | None | The **OpenAI Model** document for the embedding model that generates embeddings for search terms. It is needed to search on a `dense_vector` field.
`Rerank model` | None | The **OpenAI Model** document for the rerank model. Without one, results are not reranked.
`Rerank text field suffix` | `.text` | The suffix of the text field a vector field was generated from. With the defaults, the text of `Content.vector` is in `Content.text`.
`Rerank score field suffix` | `.score` | The suffix of the field holding a result's rerank score. With the defaults, the score for a search on `Content.vector` is in `Content.score`.
`Minimum rerank score` | `0.8` | The lowest rerank score, from `0.0` to `1.0`, a result can have and still be included.

Both models are set up as **OpenAI Model** documents, as described in [Setting Up Ask Stroom AI]({{< relref "docs/user-guide/ai/ask-stroom-ai/setting-up#setting-up-a-model" >}}):

* The embedding model must be served with an OpenAI-compatible embeddings API.
  Set the model document's _Embedding model dimensions_ to the number of dimensions of the index's vectors, e.g. `1024`, or to `0` for the model's default.
* The rerank model must be served with a Jina-compatible rerank API, which Stroom calls at the model's _Base URL_ followed by `/rerank`.
  If the model's _Maximum context window tokens_ is set, each text sent to it is cut to that many characters.


### Using Rerank Scores

A rerank score field such as `Content.score` is not in the index, so it is not in the data source's list of fields.
To show the score in a dashboard table, add a column with the expression `${Content.score}`, and sort on it to see the most relevant results first.

If `Minimum rerank score` is above `0`, the table must include the score field of each vector field the query searches, or the search fails with an error saying the score field is missing.
Set `Minimum rerank score` to `0` to rerank without leaving any results out.

Results are reranked in batches of the index's `Scroll size`, with one request to the rerank model for each vector field searched in each batch.
A search with many results therefore makes many requests to the rerank model, so consider narrowing the query with other terms, e.g. a time range.
