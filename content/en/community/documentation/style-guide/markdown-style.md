---
title: "Markdown Style Conventions"
linkTitle: "Markdown Conventions"
weight: 30
date: 2022-01-27
tags: 
description: >
  House style conventions for basic Markdown use.
---

## Line breaks


### Sentence per line

Each sentence must start on a new line, even in numbered/bulleted lists.
This makes it easier to move sentences around or to remove them and limits the scope of changes when it comes to git diffs and merges.
When the markdown is rendered into HTML/PDF, the sentences will be joined into a single paragraph.

See this {{< external-link "site" "https://asciidoctor.org/docs/asciidoc-recommended-practices/#one-sentence-per-line" >}} for more of the reasons behind sentence per line.
Though this link relates to Asciidoc, the same logic applies to markdown.

For example:

{{< cardpane >}}

  {{< card header="Do this" >}}
```markdown
This is the first sentence of the paragraph.
This is the second.
This it the third and final one.

This is the start of a new paragraph.
```

**Which renders as:**

This is the first sentence of the paragraph.
This is the second.
This it the third and final one.

This is the start of a new paragraph.
  {{< /card >}}

  {{< card header="Don't do this" >}}
```markdown
This is the first sentence of the paragraph. This is the second. This it the third and final one.

This is the start of a new paragraph.
```

**Which renders as:**

This is the first sentence of the paragraph. This is the second. This it the third and final one.

This is the start of a new paragraph.
  {{< /card >}}
{{< /cardpane >}}


### No hard line breaks.

Long lines should **not** be hard wrapped by adding line breaks.
You should instead rely on your editor to soft wrap long lines that cannot fit on the visible screen area.
The process of hard wrapping long lines will vary from editor to editor and not all editors support re-wrapping lines after the content has changed.
It also relies on each person's editor being configured to the same wrap column.
Adding hard wraps also means a slight change at the start of a paragraph will potentially cause all subsequent lines to be re-wrapped and thus appear as a substantial difference in the commit.

```markdown
## Don't do this

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu
fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in
culpa qui officia deserunt mollit anim id est laborum.


## Do this instead

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
```

{{< cardpane >}}
  {{< card header="Both examples render as:" >}}
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  {{< /card >}}
{{< /cardpane >}}


### Forced line breaks

In some circumstances, e.g. a list of items that is not bulleted, you may want to prevent the joining of adjacent lines when rendered.
You can force a line break by adding two spaces `␣␣` at the end of a line.

{{< cardpane >}}
  {{< card header="Do this" >}}
```markdown
Paragraph 1.

One␣␣
Two␣␣
Three

Paragraph 2.
```

**Which renders as:**

Paragraph 1.

One  
Two  
Three

Paragraph 2.
  {{< /card >}}
  {{< card header="Don't do this" >}}
```markdown
Paragraph 1.

One
Two
Three

Paragraph 2.
```

**Which renders as:**

Paragraph 1.

One
Two
Three

Paragraph 2.

  {{< /card >}}
{{< /cardpane >}}


## Blank lines and spacing

* A heading line should be preceded by two blank lines and followed by one blank line.
  This makes the headings clearer in the markdown source.
* A fenced code block should be surrounded by one blank line.
* Paragraphs should be separated by one blank line.
* Bulleted and numbered lists should be surrounded by one blank line.
* Additional sentences in bulleted/numbered lists should be indented for clarity in the raw markdown.

e.g:

```markdown
The text belonging to the previous heading.


## A Heading


## A sub heading

The text of this heading.
A second sentence in this paragraph.

A new paragraph.
A second sentence in this paragraph.

Here are some bullets:

* Bullet Z.
* Bullet A.
  This is an additional sentence for this bullet point.
  And so is this.
  * Sub-bullet AX.
    This is an additional sentence for this bullet point.
    And so is this.
* Bullet F.

Here are some numbered steps:

1. Step 1.
1. Step 2.
1. Step 3.

Another random line.
```


## Headings

The page title uses heading level one (`# ` in markdown) so all markdown headings should be >= 2 (`## `, `### `, `#### `, etc.).
Headings should have two blank lines above them for clarity in the raw markdown.
The `#` characters should **always** be followed by one space character

The following is an example of the heading levels.

```markdown
# Heading level 1

DON'T use this level in your documents.
Level one headings will be generated from the `title` in the document's front matter.


## Heading level 2


### Heading level 3


#### Heading level 4


##### Heading level 5


###### Heading level 6
```

Markdown supports an alternate style for headings, as shown below.
**Don't** use this style as it is not clear from the symbols what the heading level is.

```markddown

Heading level 1
===============

Don't use this style.


Heading level 2
---------------

Don't use this style.
```


### Table of contents

The page table of contents (right hand pane) is controlled by this in `config.toml`.

```toml
[markup]
  [markup.tableOfContents]
    endLevel = 4
    ordered = false
    startLevel = 2
```

The maximum depth of the table of contents can be controlled with `endLevel`.


## Heading example (level 2)

This is an example of a level 2 heading.


### Heading example (level 3)

This is an example of a level 3 heading.


#### Heading example (level 4)

This is an example of a level 4 heading.


##### Heading example (level 5)

This is an example of a level 5 heading.


###### Heading example (level 6)

This is an example of a level 6 heading.


## Block quotes

### Single line

A simple paragraph block quote.

```markdown
> This is a simple block quote.
> This is the second sentence on the same line.
```

> This is a simple block quote.
> This is the second sentence on the same line.

### Multi line

A pair of spaces at the end of a line can be used to force line breaks, e.g.:

```markdown
> This is a multi line block quote.␣␣
> This is the second line.␣␣
> This is the third line.
```

> This is a multi line block quote.  
> This is the second line.  
> This is the third line.


## Lists


### Bulleted list

{{< cardpane >}}
  {{< card header="Rendered" >}}
* Fruit.
  Make sure you get your five-a-day.
* Meat
    * Beef
    * Chicken
* Vegetables.
  {{< /card >}}
  {{< card header="Markdown" >}}
```markdown
* Fruit.
  Make sure you get your five-a-day.
* Meat
    * Beef
    * Chicken
* Vegetables.
```
  {{< /card >}}
{{< /cardpane >}}


### Numbered List

Numbered list items should all be numbered with number `1` so that the markdown render handles the consecutive numbering.
This makes the file easier to edit and means the addition of one item in the middle does not cause a change to all the lines after it, e.g:

{{< cardpane >}}
  {{< card header="Rendered" >}}
1. Item one.
   This is some extra content for step 1.
1. Item two.
    1. Sub-item A.
    1. Sub-item B.
1. Item three.
  {{< /card >}}
  {{< card header="Markdown" >}}
```markdown
1. Item one.
   This is some extra content for step 1.
1. Item two.
    1. Sub-item A.
    1. Sub-item B.
1. Item three.
```
  {{< /card >}}
{{< /cardpane >}}



### Check List

{{< cardpane >}}
  {{< card header="Rendered" >}}
* [ ] Item 1.
      This is some extra content for item 1.
* [ ] Item 2.
    * [x] Item 2a.
    * [ ] Item 2b.
* [x] Item 3.
  {{< /card >}}
  {{< card header="Markdown" >}}
```markdown
* [ ] Item 1.
      This is some extra content for item 1.
* [ ] Item 2.
    * [x] Item 2a.
    * [ ] Item 2b.
* [x] Item 3.
```
  {{< /card >}}
{{< /cardpane >}}


### Definition list

{{< cardpane >}}
  {{< card header="Rendered" >}}
Name
: Godzilla

Birthplace
: Japan

Color
: Green
  {{< /card >}}
  {{< card header="Markdown" >}}
```markdown
Name
: Godzilla

Birthplace
: Japan

Color
: Green
```
  {{< /card >}}
{{< /cardpane >}}


## Tables

Tables should ideally have its columns aligned in the markdown for clarity in the raw markdown.

```markdown
## Ideally do this

| Artist          | Album          | Year |
|-----------------|----------------|------|
| Michael Jackson | Thriller       | 1982 |
| Prince          | Purple Rain    | 1984 |
| Beastie Boys    | License to Ill | 1986 |

## But this is acceptable

| Artist | Album | Year |
|-|-|-|
| Michael Jackson | Thriller | 1982 |
| Prince | Purple Rain | 1984 |
| Beastie Boys | License to Ill | 1986 |
```

Both will produce the same result but the latter can be harder to read in markdown form.

| Artist          | Album          | Year |
|-----------------|----------------|------|
| Michael Jackson | Thriller       | 1982 |
| Prince          | Purple Rain    | 1984 |
| Beastie Boys    | License to Ill | 1986 |
