---
title: "Variables"
linkTitle: "Variables"
weight: 30
date: 2021-07-27
tags: 
description: >
  
---

A variable is added to Data Splitter using the `<var>` element. A variable is used to store matches from a parent expression for use in a reference elsewhere in the configuration, see [variable reference]({{< relref "variable-reference.md" >}}).

The most recent matches are stored for use in local references, i.e. references that are in the same match scope as the variable. Multiple matches are stored for use in references that are in a separate match scope. The concept of different variable scopes is described in [scopes]({{< relref "variable-reference.md#scopes" >}}).

## The `<var>` element

The `<var>` element is used to tell Data Splitter to store matches from a parent expression for use in a reference.

### Attributes

The `<var>` element has the following attributes:

* [`id`]({{< relref "#id" >}})

#### `id`

Mandatory attribute used to uniquely identify it within the configuration (see [`id`]({{< relref "content-providers.md#id" >}})) and is the means by which a variable is referenced, e.g. `$VAR_ID$`.
