# Reference Data

> * Version Information: Created with Stroom v7.0  
* Last Updated: 28 August 2020  
* See also: [HOWTO - Creating a Simple Reference Feed](../HOWTOs/ReferenceFeeds/CreateSimpleReferenceFeed.md)

In Stroom reference data is primarily used to decorate events using `stroom:lookup()` calls in XSLTs.
For example you may have reference data feed that associates the FQDN of a device to the physical location.
You can then perform a `stroom:lookup()` in the XSLT to decorate an event with the physical location of a device by looking up the FQDN found in the event.

Reference data is time sensitive and each stream of reference data has an Effective Date set against it.
This allows reference data lookups to be performed using the data of the event to ensure the reference data that was effective at event time is used.

Using reference data involves the following steps/processes:

* Ingesting the raw reference data into Stroom.
* Creating a pipeline to transform the raw reference into `reference-data:2` format XML.
* Creating a reference loader pipeline with a Reference Data Filter element.
* Adding reference pipeline/feeds the an XSLT Filter in your event pipeline.
* Adding the lookup call to the XSLT.

The process of creating a reference data pipeline is described in the HOWTO linked at the top of this document.

## Reference Data Structure

A reference data entry essentially consists of the following:

* Effective time - The data/time that the entry was effective from, i.e the time the raw reference data was received.
* Map name - A unique name for the key/value map that the entry will be stored in. The name only needs to be unique within all map names that me be loaded within an XSLT Filter. In practice it makes sense to keep map names globally unique.
* Key - The text that will be used to lookup the value in the reference data map.
* Value - The value can either be simple text, e.g. an IP address, or an XML fragment that can be inserted into another XML document. XML values must be correctly namespaced.

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
  <reference>
    <map>FQDN_TO_IP</map>
    <key>stroomnode00.strmdev00.org</key>
    <value>
      <IPAddress>192.168.2.245</IPAddress>
    </value>
  </reference>
  <reference>
    <map>IP_TO_FQDN</map>
    <key>192.168.2.245</key>
    <value>
      <HostName>stroomnode00.strmdev00.org</HostName>
    </value>
  </reference>
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

## Reference Data Storage



## The Loading Process

Reference data is tr


How to namespace the ref XML.
On/Off heap stores.
Single write txn.
Local disk requirement, mention aws
Page cache & memory usage, readahead mode.
Node specific
Purging
Pipeline version change invalidates reference data.
Storage (values are de-duped)
Keys limited to 500 ish chars.
Range lookups
Commit intervals
