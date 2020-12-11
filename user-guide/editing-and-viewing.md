# Editing and Viewing Data

> * Version Information: Created with Stroom v7.0  
* Last Updated: 10 December 2020  

## Viewing Data

The data viewer is shown on the _Data_ tab when you open (by double clicking) one of these items in the explorer tree:

* Feed - to show all data for that feed.
* Folder - to show all data for all feeds that are descendants of the folder.
* System Root Folder - to show all data for all feeds that are ancestors of the folder. 

In all cases the data shown is dependant on the permissions of the user performing the action and any permissions set on the feeds/folders being viewed.

The Data Viewer screen is made up of the following three parts which are shown as three panes split horizontally.

### Stream List

This shows all streams within the opened entity (feed or folder).
The streams are shown in reverse chronological order.
By default _Deleted_ and _Locked_ streams are filtered out.
The filtering can be changed by clicking on the <img src="../resources/v7/icons/filter.svg" height="18" title="Filter"> icon.
This will show all stream types by default so may be a mixture of _Raw events_, _Events_, _Errors_, etc. depending on the feed/folder in question.

### Related Stream List

This list only shows data when a stream is selected in the streams list above it.
It shows all streams related to the currently selected stream.
It may show streams that are 'ancestors' of the selected stream, e.g. showing the _Raw Events_ stream for an _Events_ stream, or show descendants, e.g. showing the _Errors_ stream which resulted from processing the selected _Raw Events_ stream.

### Content Viewer Pane

This pane shows the contents of the stream selected in the Related Streams List.
The content of a stream will differ depending on the type of stream selected and the child stream types in that stream.
For more information on the anatomy of streams, see [Streams](./concepts/streams.md).
This pane is split into multiple sub tabs depending on the different types of content available. 

#### Info Tab

This sub-tab shows the information for the stream, such as creation times, size, physical file location, state, etc.

#### Error Tab

This sub-tab is only visible for an Error stream.
It shows a table of errors and warnings with associated messages and locations in the stream that it relates to.

#### Data Preview Tab
This sub-tab shows the content of the data child stream, formatted if it is XML.
It will only show a limited amount of data so if the data child stream is large then it will only show the first n characters.

If the stream is multi-part then you will see Part navigation controls to switch between parts.
For each part you will be shown the first n character of that part (formatted if applicable).

If the stream is a [Segmented stream](./concepts/streams.md#segmented-stream) stream then you will see the Record navigation controls to switch between records.
Only one record is shown at once.
If a record is very large then only the first n characters of the record will be shown.

This sub-tab is intended for seeing a quick preview of the data in a form that is easy to read, i.e. formatted.
If you want to see the full data in its original form then click on the _View Source_ link at the top right of the sub-tab.

The Data Preview tab shows a '[progress](#data-progress-bar)' bar to indicate what portion of the content is visible in the editor.

#### Context Tab

This sub-tab is only shown for non-segmented streams, e.g. _Raw Events_ and _Raw_Reference_ that have an associated context data child stream.
For more details of context streams, see [Context](./concepts/streams.md#context)
This sub-tab works in exactly the same way as the Data Preview sub-tab except that it shows a different child stream.

#### Meta Tab

This sub-tab is only shown for non-segmented streams, e.g. _Raw Events_ and _Raw_Reference_ that have an associated meta data child stream.
For more details of meta streams, see [Meta](./concepts/streams.md#meta-data)
This sub-tab works in exactly the same way as the Data Preview sub-tab except that it shows a different child stream.

### Source View

The source view is accessed by clicking the _View Source_ link on the _Data Preview_ sub-tab or from the `data()` dashboard column function.
Its purpose is to display the selected child stream (data, context, meta, etc) or record in the form in which it was received, i.e un-formatted.

The Data Preview tab shows a '[progress](#data-progress-bar)' bar to indicate what portion of the content is visible in the editor.

In order to navigate through the data you have three options

* Click on the 'progress bar' to show a porting of the data starting from the position clicked on.
* Page through the data using the navigation controls.
* Select a source range to display using the Set Source Range dialog which is accessed by clicking on the _Lines_ or _Chars_ links.
  This allows you to precisely select the range to display.
  You can either specify a range with a just start point or a start point and some form of size/position limit.
  If no limit is specified then Stroom will limit the data shown to the configured maximum (`stroom.ui.source.maxCharactersPerFetch`).
  If a range is entered that is too big to display Stroom will limit the data to its maximum.

#### A Note About Characters

Stroom does not know the size of a stream in terms of character lines/cols, it only knows the size in bytes.
Due to the way character data is encoded into bytes it is not possible to say how many characters are in a stream based on its size in bytes.
Stroom can only provide an estimate based on the ratio of characters to bytes seen so far in the stream.

### Data Progress Bar

Stroom often handles very large streams of data and it is not feasible to show all of this data in the editor at once.
Therefore Stroom will show a limited amount of the data in the editor at a time.
The 'progress' bar at the top of the Data Preview and Source View screens shows what percentage of the data is visible in the editor and where in the stream the visible portion is located.
If all of the data is visible in the editor (which includes scrolling down to see it) the bar will be green and will occupy the full width.
If only some of the data is visible then the bar will be blue and the coloured part will only occupy part of the width.

## Editor

Stroom uses the _Ace_ editor for editing and viewing text, such as XSLTs, raw data, cooked events, stepping, etc.

### Keyboard shortcuts

The following are some useful keyboard shortcuts in the editor:

* `ctrl-z` - Undo last action.
* `ctrl-shift-z` - Redo previously undone action.
* `ctrl-/` - Toggle commenting of current line/selection. Applies when editing XML, XSLT or Javascript.
* `alt-up`/`alt-down` - Move line/selection up/down respectively
* `ctrl-d` - Delete current line.
* `ctrl-f` - Open find dialog.
* `ctrl-h` - Open find/replace dialog.
* `ctrl-k` - Find next match.
* `ctrl-shift-k` - Find previous match.
* `tab` - Indent selection.
* `shift-tab` - Outdent selection.
* `ctrl-u` - Make selection upper-case.

See [here](https://github.com/ajaxorg/ace/wiki/Default-Keyboard-Shortcuts) for more.

#### Vim key bindings

If you are familiar with the Vi/Vim text editors then it is possible to enable Vim key bindings in Stroom.
This is currently done by enabling Vim bindings in the editor context menu in each editor screen.
In future versions of Stroom it will be possible to store these preferences on a per user basis.

The _Ace_ editor does not support all features of Vim however the core navigation/editing key bindings are present.
The key supported features of Vim are:

* Visual mode and visual block mode.
* Searching with `/` (javascript flavour regex)
* Search/replace with commands like `:%s/foo/bar/g`
* Incrementing/decrementing numbers with `ctrl-a`/`ctrl-x`
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

For a list of useful Vim key bindings see this [cheat sheet](https://vim.rtorr.com), though not all bindings will be available in Stroom's _Ace_ editor.

### Auto-Completion And Snippets

The editor supports a number of different types of auto-completion of text.
Completion suggestions are triggered by the following mechanisms:

* `ctrl-space` - when live auto-complete is disabled.
* Typing - when live auto-complete is enabled.

When completion suggestions are triggered the follow types of completion may be available depending on the text being edited.

* _Local_ - any word/token found in the existing text.
  Useful if you have typed a long word and need to type it again.
* _Keyword_ - A word/token that has been defined in the syntax highlighting rules for the text type, i.e. `function` is a keyword when editing Javascript.
* _Snippet_ - A block of text that has been defined as a snippet for the editor mode (XML, Javascript, etc.).

#### Snippets

Snippets allow you to quickly entry pre-defined blocks of common text.
For example when editing an XSLT you may want to insert a call-template with parameters.
To do this using snippets you can do the following:

* Type `call` then hit `ctrl-space`.
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
