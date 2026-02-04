---
title: "Keyboard Shortcuts"
linkTitle: "Keyboard Shortcuts"
weight: 100
date: 2024-03-18
tags: 
description: >
  Keyboard shortcuts for actions in Stroom.
---

This section describes all the keyboard shortcuts that are available to use in Stroom.
Some shortcuts apply everywhere and some are specific to the screen that you are in or the user interface component that has focus.

Keyboard shortcuts can take two forms:

* **Combination** - Multiple keys pressed at the same time, e.g. {{< key-bind "ctrl+enter" >}}.
* **Sequence*** - Multiple keys pressed in sequence with only one key pressed at a time, e.g. {{< key-bind "g" "t" >}}, press

{{% warning %}}
Currently these keyboard shortcuts will not work if a visualisation or documentation preview pane has focus.
This is a known issue that will be addressed in the future.
{{% /warning %}}


## General Shortcuts

Action                             | Shortcut                                                           | Notes
-------                            | -------------                                                      | -------
Cancel | {{< key-bind "esc" >}} | Closes/cancels an open popup or dialog discarding any changes. Equivalent to clicking {{< stroom-btn "Cancel" >}} on a dialog.
Select / toggle | {{< key-bind "space" >}} | Selects a row/item in a table, list, selection box or tab bar. Toggles a focused checkbox. Selects a radio button.
Execute | {{< key-bind "enter" >}} | Selects a row/item in a table, list, selection box or tab bar. Opens a Document/Date picker dialog on a Document/Date field.
OK | {{< key-bind "ctrl+enter" >}} | Equivalent to clicking {{< stroom-btn "OK" >}} on a dialog, closes the dialog accepting any changes.
Context Menu | {{< key-bind "menu" >}} | Shows the context menu for the selected item, e.g. the selected item in the explorer tree.
Select all | {{< key-bind "ctrl+a" >}} | 
Save | {{< key-bind "ctrl+s" >}} | Save the current tab.
Save all | {{< key-bind "shift+ctrl+s" >}} | Saves all open and un-saved tabs.
Close | {{< key-bind "alt+w" >}} | Close the current tab.
Close all | {{< key-bind "shift+alt+w" >}} | Closes all open tabs.


### Movement

Movement within lists, selection boxes or tab bars you can use the cursor keys, `hjkl` or `wasd` to move between items.

Action                             | Shortcut
-------                            | -------------
Up | {{< key-bind "up" >}} or {{< key-bind "k" >}} or {{< key-bind "w" >}}
Down | {{< key-bind "down" >}} or {{< key-bind "j" >}} or {{< key-bind "s" >}}
Left | {{< key-bind "left" >}} or {{< key-bind "h" >}} or {{< key-bind "a" >}}
Right | {{< key-bind "right" >}} or {{< key-bind "l" >}} or {{< key-bind "d" >}}

You can also move up or down by _page_ using:

Action                             | Shortcut
-------                            | -------------
Page Up | {{< key-bind "pgup" >}}
Page Down | {{< key-bind "pgdn" >}}
Home / Start | {{< key-bind "home" >}}
End | {{< key-bind "end" >}}


### Finding Things

Action                             | Shortcut                                                           | Notes
-------                            | -------------                                                      | -------
Find documents by name             | {{< key-bind "shift+alt+f" >}} or {{< key-bind "shift" "shift" >}} | Find {{< glossary "document" "documents" >}} by name, type, {{< glossary "UUID">}}.
Find in content                    | {{< key-bind "shift+ctrl+f" >}}                                    | Find {{< glossary "document" "documents" >}} whose content contains the search term. This is the same as clicking the {{< stroom-icon "find.svg" "Find In Content" >}} icon on the explorer tree.
Recent items                       | {{< key-bind "ctrl+e" >}}                                          | Find a {{< glossary "document" >}} in a list of the most recently opened items.
Locate document                    | {{< key-bind "alt+l" >}}                                           | Locate the currently open document in the explorer tree. This is the same as clicking the {{< stroom-icon "locate.svg" >}} icon on the explorer tree.
Help                               | {{< key-bind "f1" >}}                                              | Show the help popup for the currently focused screen control, e.g. a text box. This shortcut will only work if there is a help {{< stroom-icon "help.svg" >}} next to the control.
Focus the Explorer Tree filter     | {{< key-bind "ctrl+/" >}}                                          | Changes focus to the Quick Filter in the Explorer Tree pane.
Focus the current tab Quick Filter | {{< key-bind "/" >}}                                               | If the currently open tab has a Quick Filter bar it will change focus to that so a filter term can be entered.


### Direct Access to Screens

The following shortcuts are all of the sequential type with the mnemonic _Goto X_.
These shortcuts may not do anything if you do not have the required permissions for the screen in question.

Action                       | Shortcut                 | Notes
-------                      | -------------            | -------
Goto Application Permissions | {{< key-bind "g" "a" >}} |
Goto Caches                  | {{< key-bind "g" "c" >}} |
Goto Dependencies            | {{< key-bind "g" "d" >}} |
Goto Explorer Tree           | {{< key-bind "g" "e" >}} | Changes focus to the Explorer Tree so the user can use the [Movement]({{< relref "#movement" >}}) shortcuts to move around the tree to select different documents.
Goto Index Volumes           | {{< key-bind "g" "i" >}} |
Goto Jobs                    | {{< key-bind "g" "j" >}} |
Goto API Keys                | {{< key-bind "g" "k" >}} |
Goto Nodes                   | {{< key-bind "g" "n" >}} |
Goto Properties              | {{< key-bind "g" "p" >}} |
Goto Data Retention          | {{< key-bind "g" "r" >}} |
Goto Search Results          | {{< key-bind "g" "s" >}} |
Goto Server Tasks            | {{< key-bind "g" "t" >}} |
Goto User Preferences        | {{< key-bind "g" "u" >}} |
Goto Data Volumes            | {{< key-bind "g" "v" >}} |
Goto User Accounts           | {{< key-bind "g" "x" >}} |


### Creating New Documents

The following shortcuts will open the dialog to create a new document in the currently selected explorer tree folder.
If a document is currently selected in the explorer tree then the new document will be created in the same folder as the selected document.
If nothing is selected or multiple items are selected then these key sequences have no effect.

Action                                                                | Shortcut
-------                                                               | -------------
Create Elastic Index {{< stroom-icon "document/ElasticIndex.svg">}}   | {{< key-bind "c" "c" >}}
Create Dashboard {{< stroom-icon "document/Dashboard.svg">}}          | {{< key-bind "c" "d" >}}
Create Feed {{< stroom-icon "document/Feed.svg">}}                    | {{< key-bind "c" "e" >}}
Create Folder {{< stroom-icon "document/Folder.svg">}}                | {{< key-bind "c" "f" >}}
Create Dictionary {{< stroom-icon "document/Dictionary.svg">}}        | {{< key-bind "c" "i" >}}
Create Lucene Index {{< stroom-icon "document/Index.svg">}}           | {{< key-bind "c" "l" >}}
Create Documentation {{< stroom-icon "document/Documentation.svg">}}  | {{< key-bind "c" "o" >}}
Create Pipeline {{< stroom-icon "document/Pipeline.svg">}}            | {{< key-bind "c" "p" >}}
Create Query {{< stroom-icon "document/Query.svg">}}                  | {{< key-bind "c" "q" >}}
Create Analytic Rule {{< stroom-icon "document/AnalyticRule.svg">}}   | {{< key-bind "c" "r" >}}
Create Text Converter {{< stroom-icon "document/TextConverter.svg">}} | {{< key-bind "c" "t" >}}
Create View {{< stroom-icon "document/View.svg">}}                    | {{< key-bind "c" "v" >}}
Create XSLT {{< stroom-icon "document/XSLT.svg">}}                    | {{< key-bind "c" "x" >}}


## Screen Specific Shortcuts

### Dashboard

The following shortcuts are available when editing a Dashboard {{< stroom-icon "document/Dashboard.svg">}}.

Action              | Shortcut                      | Notes
-------             | -------------                 | -------
Execute all queries | {{< key-bind "ctrl+enter" >}} | Executes all queries on the Dashboard. This is the same as clicking {{< stroom-icon name="play.svg" colour="green" title="Execute Queries" >}}.


### Pipeline Stepping

The following shortcuts are available when stepping {{< stroom-icon name="step.svg" colour="green" >}} a pipeline.

Action       | Shortcut                      | Notes
-------      | -------------                 | -------
Step refresh | {{< key-bind "ctrl+enter" >}} | Refresh the current step. This is the same as clicking {{< stroom-icon name="refresh.svg" colour="green" >}}.


### Query

The following shortcuts are available when editing a Query {{< stroom-icon "document/Query.svg">}}.

Action        | Shortcut                      | Notes
-------       | -------------                 | -------
Execute query | {{< key-bind "ctrl,enter" >}} | Execute the current query. This is the same as clicking {{< stroom-icon name="play.svg" colour="green" title="Execute Query" >}}.


### Text Editor

The following common shortcuts are available when [editing text]({{< relref "docs/user-guide/content/editing-text" >}}) editing text in the {{< external-link "Ace" "https://ace.c9.io" >}} text editor that is used on many screens in Stroom, e.g. when editing a Pipeline or Query.

Action               | Shortcut                        | Notes
-------              | -------------                   | -------
Undo                 | {{< key-bind "ctrl+z" >}}       | Undo last action.
Redo                 | {{< key-bind "ctrl+shift+z" >}} | Redo previously undone action.
Toggle comment       | {{< key-bind "ctrl+/" >}}       | Toggle commenting of current line/selection. Applies when editing XML, XSLT or Javascript.
Move line up         | {{< key-bind "alt+up" >}}       | Move line/selection up.
Move line down       | {{< key-bind "alt+down" >}}     | Move line/selection down.
Delete line          | {{< key-bind "ctrl+d" >}}       | Delete the current line.
Find                 | {{< key-bind "ctrl+f" >}}       | Open find dialog.
Find/replace         | {{< key-bind "ctrl+h" >}}       | Open find/replace dialog.
Find next match      | {{< key-bind "ctrl+k" >}}       | Find next match.
Find previous match  | {{< key-bind "ctrl+shift+k" >}} | Find previous match.
Indent selection     | {{< key-bind "tab" >}}          | Indent the selected text.
Outdent selection    | {{< key-bind "shift+tab" >}}    | Un-indent the selected text.
Upper-case           | {{< key-bind "ctrl+u" >}}       | Make the selected text upper-case.
Open Completion list | {{< key-bind "ctrl+space" >}}   | Open the code completion list to show suggestions based on the current word. See [Auto-Completion]({{< relref "docs/user-guide/content/editing-text#auto-completion-and-snippets" >}}).
Trigger snippet      | {{< key-bind "tab" >}}          | Trigger the insertion of a snippet for the currently entered snippet trigger text. See [Tab Triggers]({{< relref "docs/user-guide/content/editing-text#tab                              | triggers" >}}).

See {{< external-link "Ace Default keyboard shortcuts" "https://github.com/ajaxorg/ace/wiki/Default-Keyboard-Shortcuts" >}} for more.

If you know Vim key bindings then the Ace editor supports a reasonable sub-set of them, see [Vim Key Bindings]({{< relref "docs/user-guide/content/editing-text#vim-key-bindings" >}}).

