---
title: "Search Extraction"
linkTitle: "Search Extraction"
#weight:
date: 2022-02-18
tags:
  - extraction
description: >
  The process of combining data extracted from events with the data stored in an index.

---

When indexing data it is possible to store (see [Stored Fields]({{< relref "/docs/user-guide/indexing/lucene" >}}) all data in the index.
This comes with a storage cost as the data is then held in two places; the event; and the index document.

Stroom has the capability of doing Search Extraction at query time.
This involves combining the data stored in the index document with data extracted using a search extraction pipeline.
Extracting data in this way is slower but reduces the data stored in the index, so it is a trade off between performance and storage space consumed.

Search Extraction relies on the StreamId and EventId being stored in the Index.
Stroom can then used these two fields to locate the event in the stream store and process it with the search extraction pipeline.

{{% todo %}}
Add more detail
{{% /todo %}}

