---
title: "Site Structure"
linkTitle: "Site Structure"
#weight:
date: 2021-07-20
tags:
description: >
  Describes the file and directory structure for the site.
---

## File names

Ideally files and directories should be named using _lower-kebab-case_, e.g. `site-structure.md`.


## Directory structure

All page content, i.e. markdown, is located underneath `content/en`.
This directory has one sub-directory for each of the top nav bar items.

### Landing Page

The landing page is located at `content/en/_index.html`.
This is the page that users will initially see, unless visiting via a direct link.


### About (`about`)

A single page describing what stroom is


### Documentation (`docs`)

This is where all the documentation for installing, administering and using stroom is located.


### News/Releases (`news`)

This is a `blog` type section that contains a page for each new Stroom release and a set of blog posts for Stroom news items.
The pages in the two sub-sections (`news` and `releases`) are displayed in chronalogical order based on the `date` key in the page's front matter.


### Community (`community`)

This section provides information for people wanting to contribute to the development of Stroom and its peripheral repositories.
This can include developer documentation for building and developing Stroom.


## Front matter

{{% note %}}
See [Hugo Front Matter (external link)](https://gohugo.io/content-management/front-matter/) for the full list of metadata keys that can be set.
{{% /note %}}

Front matter in Hugo is a set of meta data at the top of each page, e.g.

```yaml
---
title: "Site Structure"
linkTitle: "Site Structure"
#weight:
date: 2021-07-20
tags:
description: >
  Describes the file and directory structure for the site.
---
```





## Versioning

{{% note %}}
See [Docsy Versioning (external link)](https://www.docsy.dev/docs/adding-content/versioning/) for details on how to configure versioning.
{{% /note %}}

The site will be versioned and the versions will be tied to each minor release of Stroom, e.g 7.0, 7.1, 8.0 etc.
Each version will live in its own git branch, e.g. `7.0`, `7.1`, `8.0`, etc.

The site will also have a _Legacy_ version which will live on the branch `legacy`.
This will contain the documentation as it was when it was migrated to Hugo.
The legacy documentation contains content relevant to multiple versions of Stroom.
All subsequent versions will only contain content relevant to that minor version of Stroom, or will be clearly marked as being out of date, e.g.:

{{% warning %}}
This section is out of date.
{{% /warning %}}

