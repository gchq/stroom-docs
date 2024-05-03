---
title: "New Features"
linkTitle: "New Features"
weight: 10
date: 2024-02-29
tags: 
description: >
  New features in Stroom version 7.4.
---

## Scheduler

The scheduler in Stroom that is used to schedule all the background jobs {{< stroom-icon name="jobs.svg" title="Jobs" colour="grey" >}} and Analytic Rules {{< stroom-icon "document/AnalyticRule.svg" >}} has been changed.
The existing {{< glossary "cron" >}}/frequency scheduler was quite simplistic and only supported a limited set of features of a cron schedule.

The cron format has changed from a three value cron expression (e.g. `* * *` to run every minute) to six value one.
Existing three value cron expressions will be migrated to the new syntax when deploying Stroom v7.4.

For full details of the new scheduler see [Scheduler]({{< relref "docs/user-guide/jobs/scheduler" >}})

{{< image "releases/07.04/schedule-icon.png" "700x" >}}New cron schedule format.{{< /image >}}
{{< cardpane >}}
  {{< image "releases/07.04/schedule-cron.png" "300x" >}}The edit dialog for a cron schedule.{{< /image >}}
  {{< image "releases/07.04/schedule-freq.png" "300x" >}}The edit dialog for a frequency schedule.{{< /image >}}
{{< /cardpane >}}


## General User Interface Changes

### Keyboard Shortcuts

Various new keyboard shortcuts for performing actions in Stroom.
See [Keyboard Shortcuts]({{< relref "/docs/reference-section/keyboard-shortcuts" >}}) for details.

* Add the keyboard shortcut {{< key-bind "ctrl+enter" >}} to the code pane of the stepper to perform a _step refresh_ {{< stroom-icon name="refresh.svg" colour="green">}}.
* Add the keyboard shortcut {{< key-bind "ctrl+enter" >}} to the Dashboards to execute all queries.
* Add multiple _Goto_ type shortcuts to jump directly to a screen.
  See [Direct Access to Screens]({{< relref "/docs/reference-section/keyboard-shortcuts#direct-access-to-screens" >}}) for details.


### Documentation

The Documentation {{< stroom-icon "document/Documentation.svg">}} entity will now default to edit mode if there is no documentation, e.g. on a newly created Documentation entity.


### Copy As

A _Copy As_ group has been added to the explorer tree context menu.
This replaces, but includes the _Copy Link to Clipboard_ menu item.

* Copy Name to Clipboard - Copies the name of the entity to the clipboard.
* Copy UUID to Clipboard - Copies the {{< glossary "UUID" >}} of the entity to the clipboard.
* Copy link to Clipboard - Copies a URL to the clipboard that will link directly to the selected entity.

{{< image "releases/07.04/copy-as.png" "300x" >}}Copy explorer tree entities as name/UUID/link{{< /image >}}


### API Specification Link

Previous versions of Stroom have included an interactive user interface for navigating Stroom's {{< glossary "API" >}} specification.
A link to this has been added to the Help menu.

{{< cardpane >}}
  {{< image "releases/07.04/api-link.png" "300x" >}}Help menu item to the API specification.{{< /image >}}
  {{< image "releases/07.04/swagger.png" "300x" >}}Swagger user interface.{{< /image >}}
{{< /cardpane >}}


### Dashboard Conditional Formatting

* Make the _Enabled_ and _Hide Row_ checkboxes clickable in the table without having open the rule edit dialog.
* Dim disabled rules in the table.
* Add colour swatches for the background and text colours.

{{< image "releases/07.04/conditional-formatting.png" "400x" >}}Clickable checkboxes and colour swatches.{{< /image >}}


### Help Icons on Dialogs

Functionality has been added to included help icons {{< stroom-icon "help.svg" >}} on dialogs.
Clicking the {{< stroom-icon "help.svg" >}} icon will display a popup containing help text relating to the thing the icon is next to.

Currently help icons have only been added to a few dialogs, but more will follow.

{{< image "releases/07.04/help-icons.png" "400x" >}}Help icons on dialogs.{{< /image >}}


### Stepping Location

The way you change the step location in the stepper {{< stroom-icon name="step.svg" title="Stepper" colour="green">}} has changed.
Previously you could click and then directly edit each of the three numbers.
Now the location label is a clickable link that opens an edit dialog.

{{< image "releases/07.04/step-location-link.png" "200x" >}}Modified step location label.{{< /image >}}
{{< image "releases/07.04/step-location-dialog.png" "200x" >}}Step location edit dialog.{{< /image >}}

