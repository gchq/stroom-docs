---
title: "Data Splitter"
linkTitle: "Data Splitter"
weight: 50
date: 2021-07-27
tags: 
description: >
  
---

Data Splitter was created to transform text into XML. The XML produced is basic but can be processed further with XSLT to form any desired XML output.

Data Splitter works by using regular expressions to match a region of content or tokenizers to split content. The whole match or match group can then be output or passed to other expressions to further divide the matched data.

The root `<dataSplitter>` element controls the way content is read and buffered from the source. It then passes this content on to one or more child expressions that attempt to match the content. The child expressions attempt to match content one at a time in the order they are specified until one matches. The matching expression then passes the content that it has matched to other elements that either emit XML or apply other expressions to the content matched by the parent.

This process of content supply, match, (supply, match)*, emit is best illustrated in a simple CSV example. Note that the elements and attributes used in all examples are explained in detail in the [element reference]({{< relref "element-reference" >}}).
