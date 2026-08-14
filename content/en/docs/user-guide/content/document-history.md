---
title: "Document History"
linkTitle: "Document History"
weight: 70
date: 2026-08-13
tags:
  - content
description: >
  Seeing who changed a document and when.
---

Stroom keeps an audit trail for every document, recording each change that is made to it and who made it.


## Viewing the History of a Document

Select a document in the explorer tree, then choose

{{< stroom-menu "Info" >}}

from its context menu.

The _Info_ dialog shows the document's UUID, type, name and any tags, followed by an _Audit Info_ table with a row per recorded action.

Each row gives:

| Column | Meaning |
| --- | --- |
| Time | When the action happened. |
| User | The user that performed it. |
| Action | What was done. |

The actions that are recorded are _Created_, _Updated_, _Deleted_, _Imported_, _Exported_, _Copied_, _Moved_ and _Renamed_.

The dialog is not modal, so it can be left open while selecting another document in the tree, and it will update to show that document instead.


## What is Recorded

Alongside the audit trail, Stroom stores a snapshot of the document's data each time it changes.
Snapshots are held so that the content of a document at a point in the past is not lost when it is edited, and are deduplicated so that repeated saves of unchanged content do not each cost a copy.

Documents that existed before upgrading to v7.13 have their audit trail seeded from the create and update details already held against them, giving them a _Created_ entry and, where the document had been changed, an _Updated_ entry.
Changes made before the upgrade other than the most recent one were never recorded, so they cannot appear.


{{% see-also %}}
* [Deleting Content]({{< relref "deleting-content" >}})
* [Import and Export]({{< relref "import-export" >}})
{{% /see-also %}}
