---
title: "Multi Line Example"
linkTitle: "Multi Line Example"
weight: 40
date: 2021-07-27
tags: 
description: >
  
---

Example multi line file where records are split over may lines. There are various ways this data could be treated but this example forms a record from data created when some fictitious query starts plus the subsequent query results.

## Input

```text
09/07/2016    14:49:36    User = user1
09/07/2016    14:49:36    Query = some query

09/07/2016    16:34:40    Results:
09/07/2016    16:34:40    Line 1:   result1
09/07/2016    16:34:40    Line 2:   result2
09/07/2016    16:34:40    Line 3:   result3
09/07/2016    16:34:40    Line 4:   result4

09/07/2009    16:35:21    User = user2
09/07/2009    16:35:21    Query = some other query

09/07/2009    16:45:36    Results:
09/07/2009    16:45:36    Line 1:   result1
09/07/2009    16:45:36    Line 2:   result2
09/07/2009    16:45:36    Line 3:   result3
09/07/2009    16:45:36    Line 4:   result4
```

## Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter
    xmlns="data-splitter:3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd"
    version="3.0">

  <!-- Match each record. We want to treat the query and results as a single event so match the two sets of data separated by a double new line -->
  <regex pattern="\n*((.*\n)+?\n(.*\n)+?\n)|\n*(.*\n?)+">
    <group>

      <!-- Split the record into query and results -->
      <regex pattern="(.*?)\n\n(.*)" dotAll="true">

        <!-- Create a data element to output query data -->
        <data name="query">
          <group value="$1">

            <!-- We only want to output the date and time from the first line. -->
            <regex pattern="([^\t]*)\t([^\t]*)[\t]*([^=:]*)[=:]*(.*)" maxMatch="1">
              <data name="date" value="$1" />
              <data name="time" value="$2" />
              <data name="$3" value="$4" />
            </regex>
            
            <!-- Output all other values -->
            <regex pattern="([^\t]*)\t([^\t]*)[\t]*([^=:]*)[=:]*(.*)">
              <data name="$3" value="$4" />
            </regex>
          </group>
        </data>

        <!-- Create a data element to output result data -->
        <data name="results">
          <group value="$2">

            <!-- We only want to output the date and time from the first line. -->
            <regex pattern="([^\t]*)\t([^\t]*)[\t]*([^=:]*)[=:]*(.*)" maxMatch="1">
              <data name="date" value="$1" />
              <data name="time" value="$2" />
              <data name="$3" value="$4" />
            </regex>
            
            <!-- Output all other values -->
            <regex pattern="([^\t]*)\t([^\t]*)[\t]*([^=:]*)[=:]*(.*)">
              <data name="$3" value="$4" />
            </regex>
          </group>
        </data>
      </regex>
    </group>
  </regex>
</dataSplitter>
```

## Output

```xml
<?xml version="1.0" encoding="UTF-8"?>
<records
    xmlns="records:2"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="records:2 file://records-v2.0.xsd"
                version="2.0">
  <record>
    <data name="query">
      <data name="date" value="09/07/2016" />
      <data name="time" value="14:49:36" />
      <data name="User" value="user1" />
      <data name="Query" value="some query" />
    </data>
    <data name="results">
      <data name="date" value="09/07/2016" />
      <data name="time" value="16:34:40" />
      <data name="Results" />
      <data name="Line 1" value="result1" />
      <data name="Line 2" value="result2" />
      <data name="Line 3" value="result3" />
      <data name="Line 4" value="result4" />
    </data>
  </record>
  <record>
    <data name="query">
      <data name="date" value="09/07/2016" />
      <data name="time" value="16:35:21" />
      <data name="User" value="user2" />
      <data name="Query" value="some other query" />
    </data>
    <data name="results">
      <data name="date" value="09/07/2016" />
      <data name="time" value="16:45:36" />
      <data name="Results" />
      <data name="Line 1" value="result1" />
      <data name="Line 2" value="result2" />
      <data name="Line 3" value="result3" />
      <data name="Line 4" value="result4" />
    </data>
  </record>
</records>
```
