---
title: "Site Structure"
linkTitle: "Site Structure"
weight: 10
date: 2022-01-25
tags:
description: >
  Describes the file and directory structure for the site.
---

## File names

Ideally files and directories should be named using _lower-kebab-case_, e.g. `site-structure.md`.


## Directory structure

All page content, i.e. markdown, is located underneath `content/en`.
This directory has one sub-directory for each of the top nav bar items.

### Stroom-Docs top level sections

Each of the following sections can have a different styling that is appropriate to its content, e.g. documentation vs blog.


#### Landing Page

The landing page is located at `content/en/_index.html`.
This is the page that users will initially see, unless visiting via a direct link.


#### About (`about`)

A single page describing what stroom is.


#### Documentation (`docs`)

This is where all the documentation for installing, administering and using stroom is located.


#### News/Releases (`news`)

This is a `blog` type section that contains a page for each new Stroom release and a set of blog posts for Stroom news items.
The pages in the two sub-sections (`news` and `releases`) are displayed in chronalogical order based on the `date` key in the page's front matter.


##### News (`news/news`)

This sub section has a flat structure with one `.md` file per news item.
Each file should be named in the form `YYYYMMDD-<name>.md`.
The `date` key should be set in the front matter to match the date of the file.
Hugo will use this `date` key to order the files in the menu.
The date should be set in ISO 8601 date format, i.e.

```yaml
date: 2021-07-09
```

##### Releases (`news/releases`)

Each new minor version release of Stroom should have a file in this directory.
They should be named in the form `vXX.YY.md` where `XX` is the zero padded major version and `YY` is the zero padded minor version, e.g. `v07.01`.
The zero padding is to ensure correct ordering by default withouth having to resort to using `weight` in the front matter.

The front matter should be set along these lines:

```yaml
---
title: "Version 7.0"
linkTitle: "7.0"
date: 2021-07-07
description: >
  Key new features and changes present in v7.0 of Stroom and Stroom-Proxy.
---
```


#### Community (`community`)

This section provides information for people wanting to contribute to the development of Stroom and its peripheral repositories.
This can include developer documentation for building and developing Stroom.
This has the same structure as `docs`.


### Documentation content

The `docs` and `community` top level sections have a tree structure for their content.
Each of these directories will contain three different types of entities:

* Section directories
* Section index files (`_index.md`)
* Pages (e.g. `building.md`)

The following is an example of part of the structure of the `community` section.

```text
├── documentation/                 Documentation section directory
│   ├── building.md                Page
│   ├── _index.md                  Documentation section index page
│   ├── style-guide/               Style guide section directory
│   │   ├── basic-elements.md      Page
│   │   ├── icon-gallery.md        Page     
│   │   ├── _index.md              Style guide section index page
│   │   ├── site-structure.md      Page
│   │   └── using-images.md        Page
│   └── versions.md                Page
└── roadmap.md                     Page
```

A section can essentially contain branches (sections) and leaves (pages).
A branch (i.e. a section) is defined by a directory that contains an `_index.md` file.
The front matter in this index file defines the meta data for that section, e.g. the title, date, tags, description, etc.
A leaf (i.e. a page with no children) is just a markdown file with front matter.
The front matter for branches and leaves works in the same way.
