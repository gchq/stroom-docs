---
title: "Introduction"
linkTitle: "Introduction"
weight: 1
date: 2022-12-15
tags:
  - search
  - elastic
  - elasticsearch
  - kibana
description: >
  Concepts, assumptions and key differences to Solr and built-in Lucene indexing
---

Stroom supports using an external Elasticsearch cluster to index event data. This allows you to leverage all the features of the Elastic Stack, such as shard allocation, replication, fault tolerance and aggregations.

With Elasticsearch as an external service, your search infrastructure can scale independently of your Stroom data processing cluster, enhancing interoperability with other platforms by providing a performant and resilient time-series event data store. For instance, you can deploy {{< external-link "Kibana" "https://www.elastic.co/kibana/" >}} to search and visualise Elasticsearch data.

Stroom achieves indexing and search integration by interfacing securely with the Elasticsearch REST API using the Java high-level client.

This guide will walk you through configuring a Stroom indexing pipeline, creating an Elasticsearch index template, activating a stream processor and searching the indexed data in both Stroom and Kibana.


## Assumptions

1. You have created an Elasticsearch cluster. Elasticsearch 8.x is recommended, though the latest supported 7.x version will also work.
   For test purposes, you can quickly create a single-node cluster using Docker by following the steps in the {{< external-link "Elasticsearch Docs" "https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html#docker-cli-run-dev-mode" >}}.
2. The Elasticsearch cluster is reachable via HTTPS from all Stroom nodes participating in [stream processing]({{< relref "../../../quick-start-guide/running.md" >}}).
3. Elasticsearch security is enabled. This is mandatory and is enabled by default in Elasticsearch 8.x and above.
4. The Elasticsearch HTTPS interface presents a trusted X.509 server certificate. The Stroom node(s) connecting to Elasticsearch need to be able to verify the certificate, so for custom PKI, a Stroom truststore entry may be required.
5. You have a feed containing `Event` streams to index.


## Key differences

Indexing data with Elasticsearch differs from Solr and built-in Lucene methods in a number of ways:

1. Unlike with [Solr]({{< relref "../Solr.md" >}}) and built-in Lucene indexing, Elasticsearch field mappings are managed outside Stroom, through the use of {{< external-link "index and component templates" "https://www.elastic.co/guide/en/elasticsearch/reference/current/index-templates.html" >}}. These are normally created either via the Elasticsearch API, or interactively using Kibana.
2. Aside from creating the mandatory `StreamId` and `EventId` field mappings, explicitly defining mappings for other fields is optional. Elasticsearch will use {{< external-link "dynamic mapping" "https://www.elastic.co/guide/en/elasticsearch/reference/current/dynamic-mapping.html" >}} by default, to infer each field's type at index time. Explicitly defining mappings is recommended where consistency or greater control are required, such as for IP address fields (Elasticsearch mapping type `ip`).


## Next topic

[Getting Started]({{< relref "Getting-Started.md" >}})