---
# This section is the hugo front matter containing the meta data for the page
# See https://gohugo.io/content-management/front-matter/

# The top of page title.
# Each word capitalised.
title: "Documentation Style Guide"

# The link title in the left menu. Often the same as the title but if the title
# is long then it is better to shorten/abbreviate the link title
# Each word capitalised.
linkTitle: "Style Guide"

# Optional priority in the left menu bar, lower number = higher position
# Use this if you want to control over the positions
weight: 20

# An optional  list of tags applicable to this page. Allows searching by tags.
# Style names in lower-kebab-case.
tags:
  - style

# Cascade properties to all sub pages
# cascade:

# Prevent this page from being included in 'Search this site...'
#exclude_search: true

# Description section that goes between the page title and the list of tags for the page
# It is also shown on the parent page, beneath the link, so it is useful for eah page to have at least a sentence summarising the page.
# Must have a 2 char indent as it is a multi-line yaml string.
description: >
  A guide on the house style, structure and content for this site.
  It should be viewed both in its rendered form and as source to understand how the page elements are formed.
  You should read this section before contributing to the documentation.

---

## Overview

Stroom's documentation is created using the static site generator {{< external-link "Hugo" "https://gohugo.io/" >}}.
This converts markdown content into a rich HTML site.
The markdown content in _stroom-docs_ is not intended to be read as-is in GitHub, it needs to be rendered first.

The full documentation for _Hugo_ can be found {{< external-link "here" "https://gohugo.io/documentation/" >}}.
The site also uses the {{< external-link "Docsy" "https://www.docsy.dev" >}} theme for Hugo.
The documentation for _Docsy_ can be found {{< external-link "here" "https://www.docsy.dev/docs/" >}}.
The _Docsy_ theme provides a lot of the styling but also adds other features and shortcodes.
You should consult the _Docsy_ documentation in the first instance.

To maintain a degree of consistency in the documentation you should use this section as a reference for how to layout your content.


## Shortcodes

The documentation makes heavy use of Hugo _shortcodes_ for adding page elements such as links, icons, images, etc.
Shortcodes are a compact way of inserting reusable content into a page and make it easy to change how a page element is styled by just changing the shortcode in one place.

There are numerous shortcodes available to use:

* {{< external-link "Hugo built in shortcodes" "https://gohugo.io/content-management/shortcodes/" >}}
* {{< external-link "Docsy theme shortcodes" "https://www.docsy.dev/docs/adding-content/shortcodes/" >}}
* [Bespoke _stroom-docs_ shortcodes]({{< relref "./using-images/#stroom-user-interface-components" >}}).
  These can be found in `layouts/shortcodes/`.

An example of using a short code in your markdown is:

```text
Click the {{</* stroom-icon "save.svg" "Save Document" */>}} icon.
```

This calls the shortcode _stroom-icon_ with the positional arguments `save.svg` and `Save Document`.
Shortcodes can either use positional arguments or named arguments depending on how they have been written.

This is an example of calling a shortcode with named arguments:

```text
Click the {{</* stroom-icon name="settings.svg" colour="red" */>}} icon.
```

Check the documentation for specific shortcode to see how to call it.


### Editor snippets and shortcodes

To make your life easier when editing the documentation it is highly recommended to use a text editor that supports text snippets.
Snippets make it very quick to add shortcodes into the documentation.

For example the following {{< external-link "UltiSnips (for Vim)" "https://github.com/SirVer/ultisnips" >}} and {{< external-link "VS Code" "https://code.visualstudio.com/docs/editor/userdefinedsnippets" >}} snippets adds a skeleton front matter to a page.

{{< cardpane >}}
  {{< card header="UltiSnips (for Vim)" >}}
```snippets
snippet hfront "Hugo markdown metadata front matter" b
---
title: "${1:Title}"
linkTitle: "$1"
#weight:
date: `date "+%Y-%m-%d"`
tags: $2
description: >
  $3
---

$0
endsnippet
```
  {{< /card >}}
  {{< card header="JSON (VS Code)" >}}

```json
{
  "hugo-front-matter": {
    "prefix": "hfront",
    "body": [
      "---",
      "title: \"${1:Title}\"",
      "linkTitle: \"$1\"",
      "#weight:",
      "date: `date \"+%Y-%m-%d\"`",
      "tags: $2",
      "description: >",
      "  $3",
      "---",
      "",
      "$0"
    ],
    "description": "Hugo markdown metadata front matter"
  }
}
```
  {{< /card >}}
{{< /cardpane >}}



{{% todo %}}
Add section on naming, i.e. what names we use for things, e.g. data/meta/stream, config/properties, job/task, etc.
{{% /todo %}}
