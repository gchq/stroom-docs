---
title: "note"
linkTitle: "note"
weight: 30
date: 2026-10-13
tags:
description: >
  Test using the `note` shortcode.
---

{{< note >}}
* This is bold **1**
* This is italic _2_
{{< /note >}}

{{< note >}}
{{< glossary "idp" >}}
{{< /note >}}

{{< note >}}
{{< xslt-func-link "cosine-similarity" >}}
{{< /note >}}

{{< note >}}
* This is bold **1001**
* {{< xslt-func-link "cosine-similarity" >}}
* This is italic _2_
{{< /note >}}

{{< note >}}
* This is bold **1003**
* xxx {{< xslt-func-link "cosine-similarity" >}} yyy
* This is italic _2_
{{< /note >}}

{{< note >}}
* This is bold **1005**
* {{< glossary "idp" >}}
* This is italic _2_
{{< /note >}}

{{< note >}}
* This is bold **1007**
* xxx {{< glossary "idp" >}} yyy
* This is italic _2_
{{< /note >}}

{{< note >}}
This is bold **1009**

{{< xslt-func-link "cosine-similarity" >}}

{{< glossary "idp" >}}
{{< /note >}}

{{< note >}}
* This is bold **1011**
* {{< xslt-func-link "cosine-similarity" >}}
* {{< glossary "idp" >}}
{{< /note >}}

{{< note >}}
* This is bold **1013**
* {{< glossary "idp" >}}
* {{< xslt-func-link "cosine-similarity" >}}
{{< /note >}}

{{< note >}}
This is an external **link** {{< external-link "github.com/gchq/stroom" "https://github.com/gchq/stroom" >}}
{{< /note >}}

{{< note >}}
This is an internal link [Shortcode Tests]({{< relref "./" >}}).
{{< /note >}}
