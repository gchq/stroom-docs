---
title: "Stroom Pipeline Functions"
linkTitle: "Pipeline Functions"
#weight:
date: 2025-09-25
tags: 
description: >
  Functions for obtaining information about the current pipeline process. 
---

<!-- 
The xslt-func shortcode outputs all the XsltFunctionDef annotation content for the function.
You can add any additional content for the function (e.g. examples) underneath the shortcode call.
-->


## add-meta

{{< xslt-func "add-meta" >}}


## bitmap-lookup

{{< xslt-func "bitmap-lookup" >}}

### Examples

For the purposes of these examples, the reference data store map contains:

| Key (Bit position) | Value          |
|--------------------|----------------|
| 0                  | Administrator  |
| 1                  | Manage_Users   |
| 2                  | Perform_Export |
| 3                  | View_Data      |
| 4                  | Manage_Jobs    |
| 5                  | Delete_Data    |
| 6                  | Manage_Volumes |

The following are example lookups using the above reference data:

| Lookup Key (decimal) | Lookup Key (Hex) | Bitmap    | Result                                  |
|----------------------|------------------|-----------|-----------------------------------------|
| `0`                  | `0x0`            | `0000000` | -                                       |
| `1`                  | `0x1`            | `0000001` | `Administrator`                         |
| `74`                 | `0x4A`           | `1001010` | `Manage_Users View_Data Manage_Volumes` |
| `2`                  | `0x2`            | `0000010` | `Manage_Users`                          |
| `96`                 | `0x60`           | `1100000` | `Delete_Data Manage_Volumes`            |


## classification

{{< xslt-func "classification" >}}


## col-from

{{< xslt-func "col-from" >}}


## col-to

{{< xslt-func "col-to" >}}


## dictionary

{{< xslt-func "dictionary" >}}


## feed-name

{{< xslt-func "feed-name" >}}


## get

{{< xslt-func "get" >}}


## line-from

{{< xslt-func "line-from" >}}


## line-to

{{< xslt-func "line-to" >}}


## log

{{< xslt-func "log" >}}

### Example

Heading

This call will warn if a SID is not the correct length.

```xml
<xsl:if test="string-length($sid) != 7">
  <xsl:value-of select="stroom:log('WARN', concat($sid, ' is not the correct length'))"/>
</xsl:if>
```

The same functionality can also be achieved using the standard `xsl:message` element, see [`<xsl:message>`]({{< relref "xslt-basics#xslmessage" >}}).


## lookup

{{< xslt-func "lookup" >}}


### Example

By testing the result, a default value may be output if no result is returned.

The following example uses `lookup` to convert a staff number into an employee ID, assuming the `STAFF_NO_TO_EMP_ID` reference data map has been loaded with the staff number to employee ID mappings.

```xml
<xsl:variable name="staffNo" select="StaffNumber"/>
<xsl:if test="$staffNo">
   <xsl:variable name="sid" select="stroom:lookup('STAFF_NO_TO_EMP_ID', $staffNo, $formattedDateTime)"/>

   <xsl:choose>
      <xsl:when test="$empId">
         <User>
             <Id><xsl:value-of select="$empId"/></Id>
         </User>
      </xsl:when>
      <xsl:otherwise>
         <data name="StaffNumber">
            <xsl:attribute name="Value"><xsl:value-of select="$staffNo"/></xsl:attribute>
         </data>
      </xsl:otherwise>
   </xsl:choose>
</xsl:if>
```


### Range Lookups

Reference data entries can either be stored with single string key or a key range that defines a numeric range, e.g. 1-100.
When a lookup is preformed the passed key is looked up as if it were a normal string key.
If that lookup fails Stroom will try to convert the key to an integer (long) value.
If it can be converted to an integer than a second lookup will be performed against entries with key ranges to see if there is a key range that includes the requested key.

Range lookups can be used for looking up an IP address where the reference data values are associated with ranges of IP addresses.
In this use case, the IP address must first be converted into a numeric value using `numeric-ip()`, e.g.:

```xml
<xsl:value-of select="stroom:lookup('IP_TO_LOCATION', numeric-ip($ipAddress))"/>
```

Similarly the reference data must be stored with key ranges whose bounds were created using this function.


### Nested Maps

The lookup function allows you to perform chained lookups using nested maps.
For example you may have a reference data map called _USER_ID_TO_LOCATION_ that maps user IDs to some location information for that user and a map called _USER_ID_TO_MANAGER_ that maps user IDs to the user ID of their manager.
If you wanted to decorate a user's event with the location of their manager you could use a nested map to achieve the lookup chain.
To perform the lookup set the `map` argument to the list of maps in the lookup chain, separated by a `/`, e.g. `USER_ID_TO_MANAGER/USER_ID_TO_LOCATION`.

This will perform a lookup against the first map in the list using the requested key.
If a value is found the value will be used as the key in a lookup against the next map.
The value from each map lookup is used as the key in the next map all the way down the chain.
The value from the last lookup is then returned as the result of the `lookup()` call.
If no value is found at any point in the chain then that results in no value being returned from the function.

In order to use nested map lookups each intermediate map must contain simple string values.
The last map in the chain can either contain string values or XML fragment values.


## manifest

{{< xslt-func "manifest" >}}


## meta

{{< xslt-func "meta" >}}

{{% note %}}
This is not the same as `meta-attribute()`.

`meta-attribute()` - reads the manifest of the whole stream from the data store, so it will open the stream's source.  
`meta()` - reads the meta data of the part currently being processed, and is what most translations want.
{{% /note %}}


## meta-attribute

{{< xslt-func "meta-attribute" >}}

{{% note %}}
This is not the same as `meta()`.

`meta()` - reads the meta data of the part currently being processed, and is what most translations want.  
`meta-attribute()` - reads the manifest of the whole stream from the data store, so it will open the stream's source.
{{% /note %}}


## meta-keys

{{< xslt-func "meta-keys" >}}

{{% warning %}}
When calling this function and assigning the result to a variable, you must specify the variable data type of `xs:string*` (array of strings).
{{% /warning %}}


### Example

The following fragment is an example of using `meta-keys()` to emit all meta values for a given stream, into an `Event/Meta` element:

```xml
<Event>
  <xsl:variable name="metaKeys" select="stroom:meta-keys()" as="xs:string*" />
  <Meta>
    <xsl:for-each select="$metaKeys">
      <string key="{.}"><xsl:value-of select="stroom:meta(.)" /></string>
    </xsl:for-each>
  </Meta>
</Event>
```


## meta-stream

{{< xslt-func "meta-stream" >}}


## parent-for-id

{{< xslt-func "parent-for-id" >}}


## parent-id

{{< xslt-func "parent-id" >}}


## part-no

{{< xslt-func "part-no" >}}


## pipeline-name

{{< xslt-func "pipeline-name" >}}


## put

{{< xslt-func "put" >}}


## record-no

{{< xslt-func "record-no" >}}


## search-id

{{< xslt-func "search-id" >}}


## source

{{< xslt-func "source" >}}


## source-id

{{< xslt-func "source-id" >}}

