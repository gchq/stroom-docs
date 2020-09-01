# Reference Data

> * Version Information: Created with Stroom v7.0  
* Last Updated: 28 August 2020  
* See also: [HOWTO - Creating a Simple Reference Feed](../HOWTOs/ReferenceFeeds/CreateSimpleReferenceFeed.md)

In Stroom reference data is primarily used to decorate events using `stroom:lookup()` calls in XSLTs.
For example you may have reference data feed that associates the FQDN of a device to the physical location.
You can then perform a `stroom:lookup()` in the XSLT to decorate an event with the physical location of a device by looking up the FQDN found in the event.

Reference data is time sensitive and each stream of reference data has an Effective Date set against it.
This allows reference data lookups to be performed using the date of the event to ensure the reference data that was actually effective at the time of the event is used.

Using reference data involves the following steps/processes:

* Ingesting the raw reference data into Stroom.
* Creating (and processing) a pipeline to transform the raw reference into `reference-data:2` format XML.
* Creating a reference loader pipeline with a Reference Data Filter element to load _cooked_ reference data into the reference data store.
* Adding reference pipeline/feeds to an XSLT Filter in your event pipeline.
* Adding the lookup call to the XSLT.
* Processing the raw events through the event pipeline.

The process of creating a reference data pipeline is described in the HOWTO linked at the top of this document.

## Reference Data Structure

A reference data entry essentially consists of the following:

* **Effective time** - The data/time that the entry was effective from, i.e the time the raw reference data was received.
* **Map name** - A unique name for the key/value map that the entry will be stored in.
  The name only needs to be unique within all map names that me be loaded within an XSLT Filter.
  In practice it makes sense to keep map names globally unique.
* **Key** - The text that will be used to lookup the value in the reference data map.
* **Value** - The value can either be simple text, e.g. an IP address, or an XML fragment that can be inserted into another XML document.
  XML values must be correctly namespaced.

The following is an example of some reference data that has been converted from its raw form into `reference-data:2` XML.
In this example the reference data contains three entries that each belong to a different map.
Two of the entries are simple text values and the last has an XML value.

``` xml
<?xml version="1.1" encoding="UTF-8"?>
<referenceData 
    xmlns="reference-data:2" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:stroom="stroom" 
    xmlns:evt="event-logging:3" 
    xsi:schemaLocation="reference-data:2 file://reference-data-v2.0.xsd" 
    version="2.0.1">

  <!-- A simple string value -->
  <reference>
    <map>FQDN_TO_IP</map>
    <key>stroomnode00.strmdev00.org</key>
    <value>
      <IPAddress>192.168.2.245</IPAddress>
    </value>
  </reference>

  <!-- A simple string value -->
  <reference>
    <map>IP_TO_FQDN</map>
    <key>192.168.2.245</key>
    <value>
      <HostName>stroomnode00.strmdev00.org</HostName>
    </value>
  </reference>

  <!-- An XML value -->
  <reference>
    <map>FQDN_TO_LOC</map>
    <key>stroomnode00.strmdev00.org</key>
    <value>
      <evt:Location>
        <evt:Country>GBR</evt:Country>
        <evt:Site>Bristol-S00</evt:Site>
        <evt:Building>GZero</evt:Building>
        <evt:Room>R00</evt:Room>
        <evt:TimeZone>+00:00/+01:00</evt:TimeZone>
      </evt:Location>
    </value>
  </reference>
</referenceData>
```

### Reference Data Namespaces

When XML reference data values are created, as in the example XML above, the XML values must be qualified with a namespace to distinguish them from the `reference-data:2` XML that surrounds them.
In the above example the XML fragment will become as follows when injected into an event:

``` xml
      <evt:Location xmlns:evt="event-logging:3" >
        <evt:Country>GBR</evt:Country>
        <evt:Site>Bristol-S00</evt:Site>
        <evt:Building>GZero</evt:Building>
        <evt:Room>R00</evt:Room>
        <evt:TimeZone>+00:00/+01:00</evt:TimeZone>
      </evt:Location>
```

Even if `evt` is already declared in the XML being injected into it, if it has been declared for the reference fragment then it will be explicitly declared in the destination.
While duplicate namespacing may appear odd it is valid XML.

The namespacing can also be achieved like this:

``` xml
<?xml version="1.1" encoding="UTF-8"?>
<referenceData 
    xmlns="reference-data:2" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:stroom="stroom" 
    xsi:schemaLocation="reference-data:2 file://reference-data-v2.0.xsd" 
    version="2.0.1">

  <!-- An XML value -->
  <reference>
    <map>FQDN_TO_LOC</map>
    <key>stroomnode00.strmdev00.org</key>
    <value>
      <Location xmlns="event-logging:3">
        <Country>GBR</Country>
        <Site>Bristol-S00</Site>
        <Building>GZero</Building>
        <Room>R00</Room>
        <TimeZone>+00:00/+01:00</TimeZone>
      </Location>
    </value>
  </reference>
</referenceData>
```

This reference data will be injected into event XML exactly as it, i.e.:

``` xml
      <Location xmlns="event-logging:3">
        <Country>GBR</Country>
        <Site>Bristol-S00</Site>
        <Building>GZero</Building>
        <Room>R00</Room>
        <TimeZone>+00:00/+01:00</TimeZone>
      </Location>
```

## Reference Data Storage

Reference data is stored in two different places on a Stroom node.
All reference data is only visible to the node where it is located.
Each node that is performing reference data lookups will need to load and store its own reference data.
While this will result in duplicate data being held by nodes it makes the storage of reference data and its subsequent lookup very performant.

### On-Heap Store

The On-Heap store is the reference data store that is held in memory in the Java Heap.
This store is volatile and will be lost on shut down of the node.
The On-Heap store is only used for storage of context data.

### Off-Heap Store

The Off-Heap store is the reference data store that is held in memory outside of the Java Heap and is persisted to to local disk.
As the store is also persisted to local disk it means the reference data will survive the shutdown of the stroom instance.
Storing the data off-heap means Stroom can run with a much smaller Java Heap size.

The Off-Heap store is based on the Lightning Memory-Mapped Database (LMDB).
LMDB makes use of the linux page cache to ensure that hot portions of the reference data are held in the page cache (making use of all available free memory).
Infrequently used portions of the reference data will be evicted from the page cache by the Operating System.
Given that LMDB utilises the page cache for holding reference data in memory the more free memory the host has the better as there will be less shifting of pages in/out of the OS page cache.
When storing large amounts of data you may experience the OS reporting very little free memory as a large amount will be in use by the page cache.
This is not an issue as the OS will evict pages when memory is needed for other applications, e.g. the Java Heap.

#### Local Disk

The Off-Heap store is intended to be located on local disk on the Stroom node.
The location of the store is set using the property `stroom.pipeline.referenceData.localDir`.
Using LMDB on remote storage is NOT advised, see http://www.lmdb.tech/doc.

If you are running stroom on AWS EC2 instances then you will need to attach some local instance storage to the host, e.g. SSD, to use for the reference data store.
In tests EBS storage was found to be VERY slow.
It should be noted that AWS instance storage is not persistent between instance stops, terminations and hardware failure.
However any loss of the reference data store will mean that the next time Stroom boots a new store will be created and reference data will be loaded on demand as normal.

#### Transactions

LMDB is a transactional database with ACID semantics.
All interaction with LMDB is done within a read or write transaction.
There can only be one write transaction at a time so if there are a number of concurrent reference data loads then they will have to wait in line.
Read transactions, i.e. lookups, are not blocked by each other or by write transactions so once the data is loaded and is in memory lookups can be performed very quickly.

#### Read-Ahead Mode

When data is read from the store, if the data is not already in the page cache then it will be read from disk and added to the page cache by the OS.
Read-ahead is the process of speculatively reading ahead to load more pages into the page cache then were requested.
This is on the basis that future requests for data may need the pages speculatively read into memory.
If the reference data store is very large or is larger than the available memory then it is recommended to turn read-ahead off as the result will be to evict hot reference data from the page cache to make room for speculative pages that may not be needed.
It can be tuned off with the system property `stroom.pipeline.referenceData.readAheadEnabled`.

#### Key Size

When reference data is created care must be taken to ensure that the _Key_ used for each entry is less than 507 bytes.
For simple ASCII characters then this means less than 507 characters.
If non-ASCII characters are in the key then these will take up more than one byte per character so the length of the key in characters will be less.
This is a limitation inherent to LMDB.

## The Loading Process

Reference data is loaded into the store on demand during the processing of a `stroom:lookup()` method call.
Reference data will only be loaded if it does not already exist in the store, however it is always loaded as a complete stream, rather than entry by entry.

The test for existence in the store is based on the following criteria:

* The UUID of the reference loader pipeline.
* The version of the reference loader pipeline.
* The Stream ID for the stream of reference data that has been deemed effective for the lookup.
* The Stream Number (in the case of multi part streams).

If a reference stream has already been loaded matching the above criteria then no additional load is required.
It should be noted that as the version of the reference data pipeline forms part of the criteria, if the reference loader pipeline is changed then this will invalidate ALL existing reference data.
Typically the reference loader pipeline is very static so this should not be an issue.

### De-Duplication

Only unique values held in the store to reduce the storage footprint.
This is useful given that typically, reference data updates may be received daily and each one is a full snapshot of the whole reference data.
As a result this can mean many copies of the same value being loaded into the store.
The store will only hold the first instance of duplicate values.

## Querying the Reference Data Store

The reference data store can be queried within a Dashboard in Stroom by selecting `Reference Data Store` in the data source selection popup.
Querying the store is currently an experimental feature and is mostly intended for use in fault finding.
Given the localised nature of the reference data store the dashboard can currently only query the store on the node that the user interface is being served from.
In a multi-node environment where some nodes are UI only and most are processing only, the UI nodes will have no reference data in their store.

## Purging Old Reference Data

Reference data loading and purging is done at the level of a reference stream.
Whenever a reference lookup is performed the last accessed time of the reference stream in the store is checked.
If it is older than one hour then it will be update to the current time.
This last access time is used to determine reference streams that are no longer in active use and thus can be purged.

The Stroom job _Ref Data Off-heap Store Purge_ is used to perform the purge operation on the Off-Heap reference data store.
No purge is required for the On-Heap store as that only holds transient data.
When the purge job is run it checks the time since each reference stream was accessed against the purge cut-off age.
The purge age is configured via the property `stroom.pipeline.referenceData.purgeAge`.
It is advised to schedule this job for quiet times when it is unlikely to conflict with reference loading operations as they will fight for access to the single write transaction.





TODO
Range lookups
Commit intervals
Context data lookups
