---
title: "Event Feeds"
linkTitle: "Event Feeds"
weight: 60
date: 2021-07-27
tags:
  - feed
description: >
  Feeds provide the means to logically group data common to a data format and source system.
---

In order for Stroom to be able to handle the various data types as described in the previous section, Stroom must be told what the data is when it is received.
This is achieved using Event Feeds.
Each feed has a unique name within the system.

Events Feeds can be related to one or more Reference Feed.
Reference Feeds are used to provide look up data for a translation.
E.g. lookup a computer name by it's IP address.

Feeds can also have associated context data.
Context data used to provide look up information that is only applicable for the events file it relates to.
E.g. if the events file is missing information relating to the computer it was generated on, and you don't want to create separate feeds for each computer, an associated context file could be used to provide this information.


## Feed Identifiers

Feed identifiers must be unique within the system.
Identifiers can be in any format but an established convetnion is to use the following format

```text
<SYSTEM>-<ENVIRONMENT>-<TYPE>-<EVENTS/REFERENCE>-<VERSION>
```

If feeds in a certain site need different reference data then the site can be broken down further.

`_` may be used to represent a space.
