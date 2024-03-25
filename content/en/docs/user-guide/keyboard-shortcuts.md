---
title: "Keyboard Shortcuts"
linkTitle: "Keyboard Shortcuts"
weight: 90
date: 2024-03-18
tags: 
description: >
  Keyboard shortcuts for actions in Stroom.
---

This section describes all the keyboard shortcuts that are available to use in Stroom.
Some shortcuts apply everywhere and some are specific to the screen that you are in or the user interface component that has focus.

Keyboard shortcuts can take two forms:

* Combination - Multiple keys pressed at the same time, e.g. {{< key-bind "ctrl+ enter" >}}.
* Sequence - Multiple keys pressed in sequence with only one key pressed at a time, e.g. {{< key-bind "g" "t" >}}.

{{% warning %}}
Currently these keyboard shortcuts will not work if a visualisation or documentation preview pane has focus.
This is a known issue that will be addressed in the future.
{{% /warning %}}



## General Shortcuts

* **Cancel** - {{< key-bind "esc" >}} - Closes/cancels an open popup or dialog discarding any changes.
  Equivalent to clicking {{< stroom-btn "Cancel" >}} on a dialog.
* **Select / toggle** - {{< key-bind "space" >}} - Selects a row/item in a table, list, selection box or tab bar.
 Toggles a focused checkbox.
 Selects a radio button.
* **Execute** - {{< key-bind "enter" >}} - Selects a row/item in a table, list, selection box or tab bar.
  Opens a Document/Date picker dialog on a Document/Date field.
* **OK** - {{< key-bind "ctrl,enter" >}}. Equivalent to clicking {{< stroom-btn "OK" >}} on a dialog, closes the dialog accepting any changes.
* **Context Menu** - {{< key-bind "menu" >}} - Shows the context menu for the selected item, e.g. the selected item in the explorer tree.
* **Select all** - {{< key-bind "ctrl,a" >}}.
* **Save** - {{< key-bind "ctrl,s" >}} - Save the current tab.
* **Save all** - {{< key-bind "shift,ctrl,s" >}} - Saves all open and un-saved tabs.
* **Close** - {{< key-bind "alt,w" >}} - Close the current tab.
* **Close all** - {{< key-bind "shift,alt,w" >}} - Closes all open tabs.


### Movement

Movement within lists, selection boxes or tab bars you can use the cursor keys, `hjkl` or `wasd` to move between items.

* **Up** - {{< key-bind "up" >}} or {{< key-bind "k" >}} or {{< key-bind "w" >}}
* **Down** - {{< key-bind "down" >}} or {{< key-bind "j" >}} or {{< key-bind "s" >}}
* **Left** - {{< key-bind "left" >}} or {{< key-bind "h" >}} or {{< key-bind "a" >}}
* **Right** - {{< key-bind "right" >}} or {{< key-bind "l" >}} or {{< key-bind "d" >}}

You can also move up or down by _page_ using:

* **Page Up** - {{< key-bind "pgup" >}}
* **Page Down** - {{< key-bind "pgdn" >}}
* **Home / Start** - {{< key-bind "home" >}}
* **End** - {{< key-bind "end" >}}


### Finding Things

* **Find documents by name** - {{< key-bind "shift,alt,f" >}} or {{< key-bind "shift" "shift" >}} - Find {{< glossary "document" "documents" >}} by name, type, {{< glossary "UUID">}}.
* **Find in content** - {{< key-bind "shift,ctrl,f" >}} - Find {{< glossary "document" "documents" >}} whose content contains the search term.
  This is the same as clicking the {{< stroom-icon "find.svg" "Find In Content" >}} icon on the explorer tree.
* **Recent items** - {{< key-bind "ctrl,e" >}} - Find a {{< glossary "document" >}} in a list of the most recently opened items.
* **Locate document** - {{< key-bind "alt,l" >}} - Locate the currently open document in the explorer tree.
  This is the same as clicking the {{< stroom-icon "locate.svg" >}} icon on the explorer tree.
* **Help** - {{< key-bind "f1" >}} - Show the help popup for the currently focused screen control, e.g. a text box.
  This shortcut will only work if there is a help {{< stroom-icon "help.svg" >}} next to the control.
* **Focus the Explorer Tree filter** - {{< key-bind "ctrl+/" >}} - Changes focus to the Quick Filter in the Explorer Tree pane.
* **Focus the current tab Quick Filter** - {{< key-bind "/" >}} - If the currently open tab has a Quick Filter bar it will chante focus to that so a filter term can be entered.


### Direct Access to Screens

The following shortcuts are all of the sequential type with the mnemonic _Goto X_.
These shortcuts may not do anything if you do not have the required permissions for the screen in question.

* **Goto Application Permissions** - {{< key-bind "g" "a" >}}.
* **Goto Caches** - {{< key-bind "g" "c" >}}
* **Goto Dependencies** - {{< key-bind "g" "d" >}}
* **Goto Explorer Tree** - {{< key-bind "g" "e" >}} - Changes focus to the Explorer Tree so the user can use the [Movement]({{< relref "#movement" >}}) shortcuts to move around the tree to select different documents.
* **Goto Index Volumes** - {{< key-bind "g" "i" >}}
* **Goto Jobs** - {{< key-bind "g" "j" >}}
* **Goto API Keys** - {{< key-bind "g" "k" >}}
* **Goto Nodes** - {{< key-bind "g" "n" >}}
* **Goto Properties** - {{< key-bind "g" "p" >}}
* **Goto Data Retention** - {{< key-bind "g" "r" >}}
* **Goto Search Results** - {{< key-bind "g" "s" >}}
* **Goto Server Tasks** - {{< key-bind "g" "t" >}}
* **Goto User Preferences** - {{< key-bind "g" "u" >}}
* **Goto Data Volumes** - {{< key-bind "g" "v" >}}
* **Goto User Accounts** - {{< key-bind "g" "x" >}}


## Screen Specific Shortcuts

### Dashboard

The following shortcuts are available when editing a Dashboard {{< stroom-icon "document/Dashboard.svg">}}.

* **Execute all queries** - {{< key-bind "ctrl,enter" >}} - Executes all queries on the Dashboard.
  This is the same as clicking {{< stroom-icon name="play.svg" colour="green" title="Execute Queries" >}}.


### Pipeline Stepping

The following shortcuts are available when stepping {{< stroom-icon name="step.svg" colour="green" >}} a pipeline.

* **Step refresh** - {{< key-bind "ctrl,enter" >}} - Refresh the current step.
  This is the same as clicking {{< stroom-icon name="refresh.svg" colour="green" >}}.


### Query

The following shortcuts are available when editing a Query {{< stroom-icon "document/Query.svg">}}.

* **Execute query** - {{< key-bind "ctrl,enter" >}} - Execute the current query.
  This is the same as clicking {{< stroom-icon name="play.svg" colour="green" title="Execute Query" >}}.


### Text Editor

The following common shortcuts are available when [editing text]({{< relref "content/editing-text/editing-text" >}}) editing text in the {{< external-link "Ace" "https://ace.c9.io" >}} text editor that is used on many screens in Stroom, e.g. when editing a Pipeline or Query.

* **Undo** - {{< key-bind "ctrl,z" >}} - Undo last action.
* **Redo** - {{< key-bind "ctrl,shift,z" >}} - Redo previously undone action.
* **Toggle comment** - {{< key-bind "ctrl,/" >}} - Toggle commenting of current line/selection. Applies when editing XML, XSLT or Javascript.
* **Move line** - {{< key-bind "alt,up" >}} & {{< key-bind "alt,down" >}} - Move line/selection up/down respectively
* **Delete line** - {{< key-bind "ctrl,d" >}} - Delete the current line.
* **Find** - {{< key-bind "ctrl,f" >}} - Open find dialog.
* **Find/replace** - {{< key-bind "ctrl,h" >}} - Open find/replace dialog.
* **Find next match** - {{< key-bind "ctrl,k" >}} - Find next match.
* **Find previous match** - {{< key-bind "ctrl,shift,k" >}} - Find previous match.
* **Indent selection** - {{< key-bind "tab" >}} - Indent the selected text.
* **Outdent selection** - {{< key-bind "shift,tab" >}} - Un-indent the selected text.
* **Upper-case** - {{< key-bind "ctrl,u" >}} - Make the selected text upper-case.
* **Open Completion list** - {{< key-bind "ctrl,space" >}} - Open the code completion list to show suggestions based on the current word.
  See [Auto-Completion]({{< relref "content/editing-text/editing-text#auto-completion-and-snippets" >}}).
* **Trigger snippet** - {{< key-bind "tab" >}} - Trigger the insertion of a snippet for the currently entered snippet trigger text.
  See [Tab Triggers]({{< relref "content/editing-text/editing-text#tab-triggers" >}}).

See {{< external-link "Default keyboard shortcuts" "https://github.com/ajaxorg/ace/wiki/Default-Keyboard-Shortcuts" >}} for more.

