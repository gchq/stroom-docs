---
title: "Site Structure"
linkTitle: "Site Structure"
weight: 30
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

### Stroom-Docs top level sections

Each of the following sections can have a different styling that is appropriate to its content, e.g. documentation vs blog.


#### Landing Page

The landing page is located at `content/en/_index.html`.
This is the page that users will initially see, unless visiting via a direct link.


#### About (`about`)

A single page describing what stroom is


#### Documentation (`docs`)

This is where all the documentation for installing, administering and using stroom is located.


#### News/Releases (`news`)

This is a `blog` type section that contains a page for each new Stroom release and a set of blog posts for Stroom news items.
The pages in the two sub-sections (`news` and `releases`) are displayed in chronalogical order based on the `date` key in the page's front matter.


##### News (`news/news`)

This sub section has one `.md` file per news item.
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

### Content files

The `docs` and `news` top level sections have a tree structure for the co




## Front matter

{{% note %}}
See [Hugo Front Matter (external link)](https://gohugo.io/content-management/front-matter/) for the full list of metadata keys that can be set.
{{% /note %}}

Front matter in Hugo is a set of meta data at the top of each page that controls which menus include the page as well as providing iformation about the page, e.g.

```yaml
---
title: "Site Structure"
linkTitle: "Site Structure"
#weight:
date: 2021-07-20
tags:
  - style
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

