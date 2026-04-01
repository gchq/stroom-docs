---
title: "Doc Ref"
linkTitle: "Doc Ref"
description: >
  A _Doc Ref_ (or Document Reference) is an identifier used to identify most documents/entities in Stroom, e.g. an XSLT will have a Doc Ref.
---

It is comprised of the following parts:

* {{< glossary "UUID" >}} - A Universally Unique Identifier to uniquely identify the document/entity.
* Type - The type of the document/entity, e.g. `Index`, `XSLT`, `Dashboard`, etc.
* Name - The name given to the document/entity.

Doc Refs are used heavily in the [REST API]({{< relref "docs/user-guide/api" >}}) for identifying the document/entity to be acted on.

{{% see-also %}}
{{< glossary "Document">}}
{{% /see-also %}}
