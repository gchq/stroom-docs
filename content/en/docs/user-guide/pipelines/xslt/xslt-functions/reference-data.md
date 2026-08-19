---
title: "Reference Data"
linkTitle: "Reference Data"
weight: 30
date: 2026-08-14
tags:
  - xslt
description: >
  XSLT functions for reference data.
---

## bitmap-lookup()

The bitmap-lookup() function treats the key as a bitmap and, for each set bit position, looks up a value (which can be an XML node set) from reference or context data and adds it to the resultant XML.

```text
bitmap-lookup(String map, String key)
bitmap-lookup(String map, String key, String time)
bitmap-lookup(String map, String key, String time, Boolean ignoreWarnings)
bitmap-lookup(String map, String key, String time, Boolean ignoreWarnings, Boolean trace)
bitmap-lookup(String map, String key, String time, Boolean ignoreWarnings, Boolean trace, String delimiter)
```

* `map` - The name of the reference data map to perform the lookup against.
* `key` - The bitmap value to lookup.
          This can either be represented as a decimal integer (e.g. `14`) or as hexadecimal by prefixing with `0x` (e.g. `0xE`).
* `time` - Determines which set of reference data was effective at the requested time.
           If no reference data exists with an effective time before the requested time then the lookup will fail.
           Time is in the format `yyyy-MM-dd'T'HH:mm:ss.SSSXX`, e.g. `2010-01-01T00:00:00.000Z`.
* `ignoreWarnings` - If true, any lookup failures will be ignored, else they will be reported as warnings.
* `trace` - If true, additional trace information is output as INFO messages.
* `delimiter` - The string placed between the values of the matched bit positions.
                Defaults to a single space.
                An empty string concatenates the values with no delimiter.

If the look up fails no result will be returned.

The key is a bitmap expressed as either a decimal integer or a hexadecimal value, e.g. `14`/`0xE` is `1110` as a binary bitmap.
For each bit position that is set, (i.e. has a binary value of `1`) a lookup will be performed using that bit position as the key.
In this example, positions `1`, `2` & `3` are set so a lookup would be performed for these bit positions.
The result of each lookup for the bitmap are concatenated together in bit position order, separated by `delimiter` (a single space if not supplied).

If `ignoreWarnings` is true then any lookup failures will be ignored and it will return the value(s) for the bit positions it was able to lookup.

This function can be useful when you have a set of values that can be represented as a bitmap and you need them to be converted back to individual values.
For example if you have a set of additive account permissions (e.g. Admin, ManageUsers, PerformExport, etc.), each of which is associated with a bit position, then a user's permissions could be defined as a single decimal/hex bitmap value.
Thus a bitmap lookup with this value would return all the permissions held by the user.

For example the reference data store may contain:

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


## dictionary()

The dictionary() function gets the contents of the specified dictionary for use during translation.
The main use for this function is to allow users to abstract the management of a set of keywords from the XSLT so that it is easier for some users to make quick alterations to a dictionary that is used by some XSLT, without the need for the user to understand the complexities of XSLT.


## lookup()

The lookup() function looks up from reference or context data a value (which can be an XML node set) and adds it to the resultant XML.

```text
lookup(String map, String key)
lookup(String map, String key, String time)
lookup(String map, String key, String time, Boolean ignoreWarnings)
lookup(String map, String key, String time, Boolean ignoreWarnings, Boolean trace)
```

* `map` - The name of the reference data map to perform the lookup against.
* `key` - The key to lookup.
  The key can be a simple string, an integer value in a numeric range or a nested lookup key.
* `time` - Determines which set of reference data was effective at the requested time.
           If no reference data exists with an effective time before the requested time then the lookup will fail.
           Time is in the format `yyyy-MM-dd'T'HH:mm:ss.SSSXX`, e.g. `2010-01-01T00:00:00.000Z`.
* `ignoreWarnings` - If true, any lookup failures will be ignored, else they will be reported as warnings.
* `trace` - If true, additional trace information is output as INFO messages.

If the look up fails no result will be returned.
By testing the result a default value may be output if no result is returned.

E.g. Look up a SID given a PF

```xml
<xsl:variable name="pf" select="PFNumber"/>
<xsl:if test="$pf">
   <xsl:variable name="sid" select="stroom:lookup('PF_TO_SID', $pf, $formattedDateTime)"/>

   <xsl:choose>
      <xsl:when test="$sid">
         <User>
             <Id><xsl:value-of select="$sid"/></Id>
         </User>
      </xsl:when>
      <xsl:otherwise>
         <data name="PFNumber">
            <xsl:attribute name="Value"><xsl:value-of select="$pf"/></xsl:attribute>
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

``` xslt
stroom:lookup('IP_TO_LOCATION', numeric-ip($ipAddress))
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
