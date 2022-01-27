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

## How do I...?

### Add a child page

If you already have a section that you want to add a new child page to then you will already have a structure like this:

```text
└── my-section/
    ├── _index.md
    ├── a-page.md
    └── another-page.md
```

To add a new page simple create a `.md` file for the new page in the section directory, e.g.

```text
└── my-section/
    ├── _index.md
    ├── a-page.md
    ├── another-page.md
    └── new-page.md
```

Add the [front matter]({{< relref "front-matter" >}}) to the top of the new page file. e.g.

```yaml
---
title: "My Long Wordy Title"
linkTitle: "My Short Title"
weight: 20
date: 2022-01-27
tags: 
description: >
  A new page describing stuff.
---
```

The new page should now appear in the list of child pages on the section page and in the left hand navigation pane.

If you want to control the position of the new page relative to its siblings then adjust the [weight]({{< relref "front-matter#weight" >}}) of this page and that of its siblings to get the order that you want.

### Add a new section

If you want to add a sub-section to an existin section then you will already have a structure like this:

```text
└── my-section/
    ├── _index.md
    ├── a-page.md
    └── another-page.md
```

To add a new sub-section create a sub-directory within the existing directory (with a name that roughly matches the section name) and create an `_index.md` file within it, e.g.

```text
└── my-section/
    ├── my-new-sub-section/
    │   └── _index.md
    ├── _index.md
    ├── a-page.md
    └── another-page.md
```

In the `_index.md` file add front matter to the top, e.g.

```yaml
---
title: "My Long Wordy Section Title"
linkTitle: "My Short Section Title"
weight: 20
date: 2022-01-27
tags: 
description: >
  A new section for stuff.
---
```

As with pages, adjust the [weight]({{< relref "front-matter#weight" >}}) of the section and its siblings to get the order you require.

To add pages to this new section see [Add a new child page]({{< relref "#add-a-child-page" >}}) above.

If you are not sure if you need to add a whole new sub-section or just a child page you can just add a new sub-section and add content to the `_index.md` file as if it were a simple page.
If you later realise that you need child pages then move the content out into a child page and create other sibling pages to it.
