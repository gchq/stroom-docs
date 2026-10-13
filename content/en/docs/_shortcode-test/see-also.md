---
title: "see-also"
linkTitle: "see-also"
#weight:
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
