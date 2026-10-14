---
title: "todo"
linkTitle: "todo"
weight: 50
date: 2026-10-14
tags:
description: >
  Test using the `todo` shortcode.
---

{{< todo >}}
* This is bold **1**
* This is italic _2_
{{< /todo >}}

{{< todo >}}
{{< glossary "idp" >}}
{{< /todo >}}

{{< todo >}}
{{< xslt-func-link "cosine-similarity" >}}
{{< /todo >}}

{{< todo >}}
* This is bold **1001**
* {{< xslt-func-link "cosine-similarity" >}}
* This is italic _2_
{{< /todo >}}

{{< todo >}}
* This is bold **1003**
* xxx {{< xslt-func-link "cosine-similarity" >}} yyy
* This is italic _2_
{{< /todo >}}

{{< todo >}}
* This is bold **1005**
* {{< glossary "idp" >}}
* This is italic _2_
{{< /todo >}}

{{< todo >}}
* This is bold **1007**
* xxx {{< glossary "idp" >}} yyy
* This is italic _2_
{{< /todo >}}

{{< todo >}}
This is bold **1009**

{{< xslt-func-link "cosine-similarity" >}}

{{< glossary "idp" >}}
{{< /todo >}}

{{< todo >}}
* This is bold **1011**
* {{< xslt-func-link "cosine-similarity" >}}
* {{< glossary "idp" >}}
{{< /todo >}}

{{< todo >}}
* This is bold **1013**
* {{< glossary "idp" >}}
* {{< xslt-func-link "cosine-similarity" >}}
{{< /todo >}}

{{< todo >}}
This is an external **link** {{< external-link "github.com/gchq/stroom" "https://github.com/gchq/stroom" >}}
{{< /todo >}}

{{< todo >}}
This is an internal link [Shortcode Tests]({{< relref "./" >}}).
{{< /todo >}}
