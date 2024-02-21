---
title: "Viewing Data"
linkTitle: "Viewing Data"
weight: 180
date: 2021-07-27
tags: 
description: >
  How to view data in Stroom.
---

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
For more information on the anatomy of streams, see [Streams]({{< relref "./concepts/streams.md" >}}).
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

If the stream is a [Segmented stream]({{< relref "./concepts/streams.md#segmented-stream" >}}) stream then you will see the Record navigation controls to switch between records.
Only one record is shown at once.
If a record is very large then only the first n characters of the record will be shown.

This sub-tab is intended for seeing a quick preview of the data in a form that is easy to read, i.e. formatted.
If you want to see the full data in its original form then click on the _View Source_ link at the top right of the sub-tab.

The Data Preview tab shows a '[progress](#data-progress-bar)' bar to indicate what portion of the content is visible in the editor.


#### Context Tab

This sub-tab is only shown for non-segmented streams, e.g. _Raw Events_ and _Raw_Reference_ that have an associated context data child stream.
For more details of context streams, see [Context]({{< relref "./concepts/streams.md#context" >}})
This sub-tab works in exactly the same way as the Data Preview sub-tab except that it shows a different child stream.


#### Meta Tab

This sub-tab is only shown for non-segmented streams, e.g. _Raw Events_ and _Raw_Reference_ that have an associated meta data child stream.
For more details of meta streams, see [Meta]({{< relref "./concepts/streams.md#meta-data" >}})
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

