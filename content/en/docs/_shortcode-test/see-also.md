---
title: "see-also"
linkTitle: "see-also"
weight: 40
date: 2026-10-12
tags: 
description: >
  Test using the `see-also` shortcode.  
---

{{< see-also >}}
* This is bold **1**
* This is italic _2_
{{< /see-also >}}

{{< see-also >}}
{{< glossary "idp" >}}
{{< /see-also >}}

{{< see-also >}}
{{< xslt-func-link "cosine-similarity" >}}
{{< /see-also >}}

{{< see-also >}}
* This is bold **1001**
* {{< xslt-func-link "cosine-similarity" >}}
* This is italic _2_
{{< /see-also >}}

{{< see-also >}}
* Some text.
* This is a glossary link {{< glossary "idp" >}}.
* This is an xslt func link {{< xslt-func-link "lookup" >}}.
* This is a doc link {{< doc-link "Feed" >}} 
* This is a doc link {{< doc-link "Feed" >}} 
* This is a pipe element link {{< pipe-elm "IndexingFilter" >}}
* Some more text.
{{< /see-also >}}

{{< see-also >}}
{{< pipe-elm "StandardKafkaProducer" >}}
{{< /see-also >}}

{{< see-also >}}
* This is bold **1001**
* {{< pipe-elm "StandardKafkaProducer" >}}
* This is italic _2_
{{< /see-also >}}

{{< see-also >}}
* This is bold **1003**
* xxx {{< xslt-func-link "cosine-similarity" >}} yyy
* This is italic _2_
{{< /see-also >}}

{{< see-also >}}
* This is bold **1005**
* {{< glossary "idp" >}}
* This is italic _2_
{{< /see-also >}}

{{< see-also >}}
* This is bold **1007**
* xxx {{< glossary "idp" >}} yyy
* This is italic _2_
{{< /see-also >}}

{{< see-also >}}
This is bold **1009**

{{< xslt-func-link "cosine-similarity" >}}

{{< glossary "idp" >}}
{{< /see-also >}}

{{< see-also >}}
* This is bold **1011**
* {{< xslt-func-link "cosine-similarity" >}}
* {{< glossary "idp" >}}
{{< /see-also >}}

{{< see-also >}}
* This is bold **1013**
* {{< glossary "idp" >}}
* {{< xslt-func-link "cosine-similarity" >}}
{{< /see-also >}}

{{< see-also >}}
This is an external **link** {{< external-link "github.com/gchq/stroom" "https://github.com/gchq/stroom" >}}
{{< /see-also >}}

{{< see-also >}}
This is an internal link [Shortcode Tests]({{< relref "./" >}}).
{{< /see-also >}}
