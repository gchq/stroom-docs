---
title: "Deleting Content"
linkTitle: "Deleting Content"
weight: 80
date: 2026-08-13
tags:
  - content
description: >
  Deleting documents safely, and seeing what depends on what.
---

Content in Stroom is heavily interlinked.
A pipeline refers to translations and schemas, a feed is referred to by processor filters, a dashboard queries an index.
Deleting something that other content relies on will break that content, so Stroom tracks these relationships and warns you before a delete goes ahead.


## Dependencies and Dependants

Stroom records the links between documents as you create and edit them, in both directions.

* A document's **Dependencies** are the documents it needs.
* A document's **Dependants** are the documents that need it.

Both are available from the context menu of a document in the explorer tree.

{{< stroom-menu "Dependencies" >}}

{{< stroom-menu "Dependants" >}}

The whole set can be browsed from

{{< stroom-menu "Tools" "Dependencies" >}}

which lists every link as a _from_ document and a _to_ document, with a _Status_ of `OK`, or `Missing` where the document being depended on no longer exists.
Filtering this list for `Missing` is a quick way to find content that has already been broken.


## Deleting a Document

When you delete something that nothing else depends on, Stroom simply asks you to confirm.

When it does have dependants, the confirmation becomes a warning telling you that the item is used by other items and that deleting it may break them.
The dependants are listed so that you can see what would be affected before deciding.

{{% note %}}
The list only names the dependants you have permission to see.
If others exist that you cannot see, you are told that they exist without being told what they are, so the warning is never misleadingly short.
{{% /note %}}

If Stroom cannot work out what would be affected, it says so rather than implying that nothing would be, and leaves the decision with you.


## Deleting a Folder

Deleting a folder deletes everything inside it.

The confirmation lists how many contained items would go, broken down by document type, and warns separately if any of them have dependants of their own.
As with dependants, only the contained items you have permission to see are listed and counted, and the existence of any others is disclosed without naming them.

For a folder with a large number of items the list is capped, and you are told that there are more than those shown.


## What Happens to Deleted Documents

Deleting a document does not immediately remove it from the database.
It is marked as deleted, and physically removed later by the _Doc Store - Physical Delete_ job once it has been in that state for longer than `stroom.docstore.physicalDeleteAge`, which defaults to 30 days.


{{% see-also %}}
* [Document History]({{< relref "document-history" >}})
* [Import and Export]({{< relref "import-export" >}})
{{% /see-also %}}
