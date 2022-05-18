---
title: "Data Formats"
linkTitle: "Data Formats"
weight: 10
date: 2022-05-17
tags: 
description: >
  The data formats to use when sending data to Stroom.
---

Stroom accepts data in many different forms as long as they are text data and are in one of the supported character encodings.
The following is a non-exhaustive list of formats supported by Stroom:

* Event XML fragments
* Events XML
* JSON
* Delimited data, with and without a header row (e.g CSV, TSV, etc.)
* Fixed width text data
* Multi line data (where each line can be a different format), e.g. Auditd.


## Preferred format

Where the system/application generating the logs is developed by you and the log format is under your control, the preferred format is Events XML or Event XML fragments.
The reason for this is that all data in Stroom will be normalised into a standard form.
This standard form is controlled by the {{< external-link "event-logging XML Schema" "https://gchq.github.io/event-logging-schema" >}}.
If data is sent in Events/Event XML then it will not require any additional translation.
