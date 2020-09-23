# Streams

Data received into Stroom is stored in units called _streams_.
A stream is essentially a bounded stream or batch of data.

Streams can either be created when data is directly POSTed in to Stroom or during the proxy aggregation process.
When data is directly POSTed to Stroom the content of the POST will be stored as one Stream.
With proxy aggregation multiple files in the proxy repository will/can be aggregated together into a single Stream.

## Anatomy of a Stream

A Stream is made up of a number of parts of which the raw or cooked data is just one.
In addition to the data the Stream can contain a number of other child stream types, e.g. Context and Meta Data.

The hierarchy of a stream is as follows:

* Stream nnn
  * Part [1 to *]
    * Data [1-1]
    * Context [0-1]
    * Meta Data [0-1]

Although all streams conform to the above hierarchy there are three main types of Stream that are used in Stroom:

* Non-segmented Stream - Raw events, Raw Reference
* Segmented Stream - Events, Reference
* Segmented Error Stream - Error

Segmented means that the data has been demarcated into segments or records.

### Child Stream Types

#### Data

This is the actual data of the stream, e.g. the XML events, raw CSV, JSON, etc.

#### Context

This is additional contextual data that can be sent with the data.
Context data can be used for reference data lookups.

#### Meta Data

This is the data about the Stream (e.g. the feed name, receipt time, user agent, etc.).
This meta data either comes from the HTTP headers when the data was POSTed to Stroom or is added by Stroom or Stroom-Proxy on receipt/processing.

### Non-Segmented Stream

The following is a representation of a non-segmented stream with three parts, each with Meta Data and Context child streams.

![Non-Segmented Stream](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/gchq/stroom-docs/master/user-guide/concepts/non-segmented-stream.puml&random=2)

Raw Events and Raw Reference streams contain non-segmented data, e.g. a large batch of CSV, JSON, XML, etc. data.
There is no notion of a record/event/segment in the data, it is simply data in any form (including malformed data) that is yet to be processed and demarcated into records/events, for example using a Data Splitter or an XML parser.

The Stream may be single-part or multi-part depending on how it is received.
If it is the product of proxy aggregation then it is likely to be multi-part.
Each part will have its own context and meta data child streams, if applicable.

### Segmented Stream

The following is a representation of a segmented stream that contains three records (i.e events) and has Meta Data and Context child streams.

![Segmented Stream](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/gchq/stroom-docs/master/user-guide/concepts/segmented-stream.puml&random=2)

Cooked Events and Reference data are forms of segmented data.
The raw data has been parsed and split into records/events and the resulting data is stored in a way that allows Stroom to know where each record/event starts/ends.
These streams only have a single part.

### Error Stream

![Error Stream](http://www.plantuml.com/plantuml/proxy?src=https://raw.githubusercontent.com/gchq/stroom-docs/master/user-guide/concepts/error-stream.puml&random=2)

Error streams are similar to segmented Event/Reference streams in that they are single-part and have demarcated records (where each error/warning/info message is a record).
Error streams do not have any Meta Data or Context child streams.



