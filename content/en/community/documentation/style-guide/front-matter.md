---
title: "Front Matter"
linkTitle: "Front Matter"
weight: 20
date: 2022-01-25
tags: 
description: >
  The meta data (or front matter) for pages/sections.

---

{{< note >}}
See {{< external-link "Hugo Front Matter" "https://gohugo.io/content-management/front-matter/" >}} for the full list of metadata keys that can be set.
{{</note >}}

Front matter in Hugo is a set of meta data at the top of each page that controls which menus include the page as well as providing information about the page, e.g.

```yaml
---
title: "Site Structure"
linkTitle: "Site Structure"
weight: 10
date: 2021-07-20
tags:
  - style
  - TODO
description: >
  Describes the file and directory structure for the site.
---
```

Hugo supports front matter in YAML, JSON and TOML, however for consistency all front matter in stroom-docs should be in YAML format.

## Title and link title

This is the section/page title and will become the `h1` heading (in HTML/Markdown terms) on the section/page.
The `linkTitle` is the text that is displayed in the left hand navigation sidebar.
It should be the same as `title` unless the title is quite long, in which case a shorter version should be used so it fits in the sidebar.

## Weight

The weight controls the position of the page/section within the other pages/sections of its parent.
i.e. it controls the order of the pages/sections in the left hand navigation bar and the list of child items on a section index.
If no weight is provided then Hugo will use `date`, then `linkTitle`, then the file path.

To assist with re-ordering pages you can use the script `change_weights.sh` in the root of the repo.
E.g. to change the order of the child items of the user-guide section do the following:

```bash
./change_weight.sh content/en/docs/user-guide
```


## Date

The date should be set/updated to the current date when a page/section is created or modified.
This data is show at the bottom of the page and tells the reader when the page was last updated.


## Tags

In the front matter, `tags` is a list of tags that are applicable to the document and allow documents to be searched for by tag.
Tag names should conform to the following conventions:

* Lower kebab case, i.e. `reference-data`, even for abbreviations.
* The only exception to the case rule is `TODO`, which is always upper case.
* Singular, i.e. `pipeline` rather than `pipelines`.

Avoid using too many unique tag names as it will make the list of tags in the sidebar to large to be useful.
When setting a tag on a document consult the list of existing tags to ensure consistency and to see if a more applicable tag already exists.

Add the `TODO` tag to a page when the page is incomplete.
This makes it easy to find areas of the documentation that are in need of attention.

### Cascading tags

If you want to apply a tag to all descendant pages of a section you can add this to the front matter of the section:

```yaml
cascade:
  tags:
    - install
```

This will then apply all of tags added to `tags` to each descendant page.


## Description

A short description of what the page/section covers.
This will be shown on the index page of its parent.
