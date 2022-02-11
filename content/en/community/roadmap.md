---
title: "Roadmap"
linkTitle: "Roadmap"
weight: 10
date: 2022-01-19
tags: 
description: >
  The roadmap for new features and changes to the Stroom family of products.

---

## v7.0

### Reference data storage
Reference data uses a memory-mapped disk-based store rather than direct memory to reduce the memory overhead associated with storing reference data.


### Search result storage
Search results are stored on disk rather than in memory during creation to reduce the memory overhead incurred by search.


### Modularisation
Separation of Stroom components into discreet modules that have clear APIs and separate persistence where required to reduce coupling.


### Modernisation of libraries
Changing Stroom libraries to replace Spring with Guice and Hibernate with JOOQ.


### Annotations
Search results in dashboards can be annotated to provide status and notes relating to the result item, e.g. an event. These annotations can later be searched to see which events have annotations associated with them.


## v7.1

### Elastic search integration
Elastic search can be used for indexing data. Data can be sent to an elastic index via a pipeline element and an elastic index can be queried from a Stroom dashboard.


### Interactive Visualisations
Selecting or manipulating parts of visualisations can be used to trigger further queries to zoom in or select specific data etc.


### Improved Proxy Aggregation
Proxy aggregation can better match user defined aggregate sizes and forward to multiple destinations.


### User Preferences
The UI can be customised to meet the needs of an end user including theme (dark mode), date and time format, font, layout.


## v7.2

### XSLT 3
Add support for XSLT 3.


### Accessibility Improvements
Refactoring some elements of the UI to improve accessibility.

## v8+


### Authorisation enhancements
The Stroom authorisation system is split out into a separate service and provides integration with external authorisation mechanisms.


### Proxy processing
Stroom proxy is capable of pipeline processing in the same way as a full Stroom application. Pipeline configuration content can be pushed to proxies so that they can perform local processing prior to sending data to Stroom. 


### Multiple input sources
Stroom is capable of processing data from a Kafka topic, HDFS, the local file system, HTTP POST in addition to the included stream store.


### Multiple output destinations
Stroom has improved support for writing to various destinations such as Kafka, HDFS, etc. Improvements include compression and meta data wrapping for future import.


### Improved field extraction
Enhancements to data splitter and associated UI to make the process of extracting field data from raw content much easier.


### Kafka analytics
Stroom exposes the use of Apache Kafka Streams for performing certain complex analytics.


### Query fusion
Stroom allows multiple data sources to be queried at the same time and the results of the queries to be fused. This might be for fusing data from multiple search indexes, e.g. events and annotations, or to effectively decorate results with additional data at search time.


### Reference data deltas
 Reference data is enhanced to cope with changes (additions and removals) of state information rather than always relying on complete snapshots.

