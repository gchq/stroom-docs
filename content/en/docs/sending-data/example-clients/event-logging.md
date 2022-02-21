---
title: "event-logging (Java library)"
linkTitle: "event-logging (Java library)"
#weight:
date: 2022-01-13
tags: 
description: >
  A Java library for logging events in Java applications.

---

{{< external-link "event-logging" "https://github.com/gchq/event-logging" >}} is a Java API for logging audit events conforming to the {{< external-link "Event Logging XML Schema" "https://github.com/gchq/event-logging-schema" >}}.
The API uses a generated Java JAXB model of the _Event Logging XML Schema_.
_Event Logging_ can be incorporated into your Java application to provide a means of recording and outputting audit events or user actions for compliance, security or monitoring.

This library only generates the events.
By default XML events are written to a file using a logging appender.
In order to send the events to Stroom either the logged files will need to be sent to stroom using one of the other [clients]({{< ref "." >}}).


