---
title: "Editing Text"
linkTitle: "Editing Text"
weight: 10
date: 2023-11-08
tags:
  - content
description: >
  How to edit user defined text content within Stroom.
---

Stroom uses the {{< external-link "Ace" "https://ace.c9.io" >}} text editor for editing and viewing text, such as XSLTs, raw data, cooked events, stepping, etc.
The editor provides various useful features:

* Syntax highlighting
* [Themes]({{< relref "#themes" >}})
* Find/replace (see [Keyboard Shortcuts]({{< relref "#keyboard-shortcuts" >}}))
* [Code auto-completion]({{< relref "#auto-completion-and-snippets" >}})


## Keyboard shortcuts

The following are some useful keyboard shortcuts in the editor:

* `ctrl+z` - Undo last action.
* `ctrl+shift+z` - Redo previously undone action.
* `ctrl+/` - Toggle commenting of current line/selection. Applies when editing XML, XSLT or Javascript.
* `alt+up`/`alt+down` - Move line/selection up/down respectively
* `ctrl+d` - Delete current line.
* `ctrl+f` - Open find dialog.
* `ctrl+h` - Open find/replace dialog.
* `ctrl+k` - Find next match.
* `ctrl+shift+k` - Find previous match.
* `tab` - Indent selection.
* `shift+tab` - Outdent selection.
* `ctrl+u` - Make selection upper-case.

See {{< external-link "Default keyboard shortcuts" "https://github.com/ajaxorg/ace/wiki/Default-Keyboard-Shortcuts" >}} for more.


### Vim key bindings

If you are familiar with the Vi/Vim text editors then it is possible to enable Vim key bindings in Stroom.
This can be done in two ways.

Either globally by setting _Editor Key Bindings_ to `Vim` in your user preferences:
{{< stroom-menu "User" "Preferences" >}}

Or within an editor using the context menu.
This latter option allows you to temporarily change your bindings.

The _Ace_ editor does not support all features of _Vim_ however the core navigation/editing key bindings are present.
The key supported features of Vim are:

* Visual mode and visual block mode.
* Searching with `/` (javascript flavour regex)
* Search/replace with commands like `:%s/foo/bar/g`
* Incrementing/decrementing numbers with `ctrl+a`/`ctrl+x`
* Code (un-)folding with `zo`, `zc`, etc.
* Text objects, e.g. `>`, `)`, `]`, `'`, `"`, `p` paragraph, `w` word.
* Repetition with the `.` command.
* Jumping to a line with `:<line no>`.

Notable features not supported by the _Ace_ editor:

* The following text objects are not supported
  * `b` - Braces, i.e `{` or `[`.
  * `t` - Tags, i.e. XML tags `<value>`.
  * `s` - Sentence.
* The `g` command mode command, i.e. `:g/foo/d`
* Splits

For a list of useful Vim key bindings see this {{< external-link "cheat sheet" "https://vim.rtorr.com" >}}, though not all bindings will be available in Stroom's _Ace_ editor.


#### Use of `Esc` key in Vim mode

The `Esc` key is bound to the close action in Stroom, so pressing `Esc` will typically close a popup, dialog, selection box, etc.
Dialogs will not be closed if the Ace editor has focus but as `Esc` is used so frequently with Vim bindings it may be advisable to use an alternative key to exit insert mode to avoid accidental closure.
You can use the standard Vim binding of `ctrl+[` or the custom binding of `jk` as alternatives to `Esc`.


## Auto-Completion And Snippets

The editor supports a number of different types of auto-completion of text.
Completion suggestions are triggered by the following mechanisms:

* `ctrl+space` - when live auto-complete is disabled.
* Typing - when live auto-complete is enabled.

When completion suggestions are triggered the follow types of completion may be available depending on the text being edited.

* _Local_ - any word/token found in the existing document.
  Useful if you have typed a long word and need to type it again.
* _Keyword_ - A word/token that has been defined in the syntax highlighting rules for the text type, i.e. `function` is a keyword when editing Javascript.
* _Snippet_ - A block of text that has been defined as a snippet for the editor mode (XML, Javascript, etc.).


### Snippets

Snippets allow you to quickly enter pre-defined blocks of common text into the editor.
For example when editing an XSLT you may want to insert a `call-template` with parameters.
To do this using snippets you can do the following:

* Type `call` then hit `ctrl+space`.
* In the list of options use the cursor keys to select `call-template with-param` then hit `enter` or `tab` to insert the snippet.
  The snippet will look like 

  ``` xslt
  <xsl:call-template name="template">
    <xsl:with-param name="param"></xsl:with-param>
  </xsl:call-template>
  ```

* The cursor will be positioned on the first tab stop (the template name) with the tab stop text selected.
* At this point you can type in your template name, e.g. `MyTemplate`, then hit `tab` to advance to the next tab stop (the param name)
* Now type the name of the param, e.g. `MyParam`, then hit `tab` to advance to the last tab stop positioned within the `<with-param>` ready to enter the param value.

Snippets can be disabled from the list of suggestions by selecting the option in the editor context menu.

### Tab triggers

Some snippets can be triggered by typing an abbreviation and then hitting `tab` to insert the snippet.
This mechanism is faster than hitting `ctrl+space` and selecting the snippet, if you can remember the snippet tab trigger abbreviations.


### Available snippets

For a list of the available completion snippets see the [Completion Snippet Reference]({{< relref "./snippet-reference" >}}).


## Theme

The editor has a number of different themes that control what colours are used for the different elements in syntax highlighted text.
The theme can be set _User Preferences_, from the main menu {{< stroom-icon "menu.svg" "Main Menu">}}, select:

{{< stroom-menu "User" "Preferences" >}}

The list of themes available match the main Stroom theme, i.e. dark Ace editor themes for a dark Stroom theme.


