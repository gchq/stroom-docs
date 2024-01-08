---
title: "File Output"
linkTitle: "File Output"
weight: 40
date: 2021-07-27
tags: 
  - file
description: >
  Substitution variables for use in output file names and paths.

---
When outputting files with Stroom, the output file names and paths can include various substitution variables to form the file and path names.

## Context Variables
The following replacement variables are specific to the current processing context.

* `${feed}` - The name of the feed that the stream being processed belongs to
* `${pipeline}` - The name of the pipeline that is producing output
* `${sourceId}` - The id of the input data being processed
* `${partNo}` - The part number of the input data being processed where data is in aggregated batches
* `${searchId}` - The id of the batch search being performed. This is only available during a batch search
* `${node}` - The name of the node producing the output

## Time Variables
The following replacement variables can be used to include aspects of the current time in UTC.

* `${year}` - Year in 4 digit form, e.g. 2000
* `${month}` - Month of the year padded to 2 digits
* `${day}` - Day of the month padded to 2 digits
* `${hour}` - Hour padded to 2 digits using 24 hour clock, e.g. 22
* `${minute}` - Minute padded to 2 digits
* `${second}` - Second padded to 2 digits
* `${millis}` - Milliseconds padded to 3 digits
* `${ms}` - Milliseconds since the epoch

## System (Environment) Variables
System variables (environment variables) can also be used, e.g. `${TMP}`.

## File Name References
rolledFileName in RollingFileAppender can use references to the fileName to incorporate parts of the non rolled file name.

* `${fileName}` - The complete file name
* `${fileStem}` - Part of the file name before the file extension, i.e. everything before the last '.'
* `${fileExtension}` - The extension part of the file name, i.e. everything after the last '.'

## Other Variables

* `${uuid}` - A randomly generated UUID to guarantee unique file names
