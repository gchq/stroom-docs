---
title: "Dictionaries"
linkTitle: "Dictionaries"
weight: 60
date: 2021-07-27
tags:
  - TODO
  - dictionary
description: >
  
---

## Creating
Right click on a folder in the explorer tree that you want to create a dictionary in.
Choose ‘New/Dictionary’ from the popup menu:

{{< stroom-menu "New" "Configuration" "Dictionary" >}}

Call the dictionary something like ‘My Dictionary’ and click {{< stroom-btn "OK" >}}.

Now just add any search terms you want to the newly created dictionary and click {{< stroom-icon "save.svg" >}}.

You can add multiple terms.

* Terms on separate lines act as if they are part of an 'OR' expression when used in a search.
  ```text
  apple
  banana
  orange
  ```
* Terms on a single line separated by spaces act as if they are part of an 'AND' expression when used in a search.
  ```text
  apple,banana,orange
  ```


## Using the Dictionary

To perform a search using your dictionary, just choose the newly created dictionary as part of your search expression:

> **TODO**: Fix image
