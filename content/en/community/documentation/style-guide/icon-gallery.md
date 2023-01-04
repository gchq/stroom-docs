---
title: "Icon Gallery"
linkTitle: "Icon Gallery"
weight: 60
date: 2021-07-12
tags: 
description: >
  A gallery of all the icons in use in stroom for reference.
---

This page can be used as a reference for finding icons and their filenames to use them in the documentation.

See [here]({{< ref "using-images#stroom-icons" >}}) for how to add icons to pages.


## General icons

General icons used in Stroom.

**Example**: {{< stroom-icon "edit.svg">}} `{{</* stroom-icon "edit.svg" */>}}`

{{< stroom-icons-gallery "images/stroom-ui/" >}}


## Pipeline element icons

Icons used for the different pipeline elements.

**Base path**: `pipeline`  
**Example**: {{< stroom-icon "pipeline/stream.svg">}} `{{</* stroom-icon "pipeline/stream.svg" */>}}`

{{< stroom-icons-gallery "images/stroom-ui/pipeline/" >}}


## Document type icons

Icons used for the different _document_ entity types, i.e. those seen in the explorer tree.

**Base path**: `document`  
**Example**: {{< stroom-icon "document/Index.svg">}} `{{</* stroom-icon "document/Index.svg" */>}}`

{{< stroom-icons-gallery "images/stroom-ui/document/" >}}


## Dashboard icons

Icons used on the Dashboard

**Base path**: `dashboard`.

{{< stroom-icons-gallery "images/stroom-ui/dashboard/" >}}


## Menu items

Menu items with icons that are available for use with the [`stroom-menu` shortcode]({{< relref "using-images#stroom-selected-menu-items" >}}).

{{< stroom-menu "menu_demo" >}}


## Pipeline elements

Pipeline elements that are available for use with the [`pipe-elm` shortcode]({{< relref "using-images#pipeline-elements" >}}).

{{< pipe-elm "pipe_elm_demo" >}}


## Updating this gallery

### Icons

This gallery of icons can be updated by running the following script which will copy all the icons from the stroom repository.
You should ensure your local stroom repository is up to date and on the correct branch before running this.

{{< command-line >}}
./update_stroom_icons.sh <stroom repo root>
{{</ command-line >}}

e.g. 

{{< command-line >}}
./update_stroom_icons.sh ../v7stroom/
{{</ command-line >}}


### Menu Items

To update the available [menu items]({{< relref "#menu-items" >}}) edit the shortcode file `layouts/shortcodes/stroom-menu.html` and modify the `icon_map` variable.


### Pipeline elements

To update the available [pipeline elements]({{< relref "#pipeline-elements" >}}) edit the shortcode file `layouts/shortcodes/pipe-elm.html` and modify the `element_map` variable.
