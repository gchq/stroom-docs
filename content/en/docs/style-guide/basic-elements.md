---
title: "Basic Page Elements"
linkTitle: "Basic Page Elements"
weight: 10
date: 2021-07-20
description: >
  Examples of various markdown and Hugo page elements.
tags:
  - style
---

## Markdown style conventions

### Line breaks

#### Sentence per line

Each sentence should start on a new line, even in numbered/bulleted lists.
This makes it easier to move sentences around or to remove them.
When the mrkdown is rendered into HTML/PDF, the sentences will be joined into a single paragraph.

See this [link (external linnk)](https://asciidoctor.org/docs/asciidoc-recommended-practices/#one-sentence-per-line) for more of the reasons behind sentence per line.
Though this link relates to Asciidoc, the same applies to markdown.

For example:

{{< cardpane >}}

  {{< card header="Don't do this" >}}
```markdown
This is the first sentence of the paragraph. This is the second. This it the third and final one.

This is the start of a new paragraph.
```

**Which renders as:**

This is the first sentence of the paragraph. This is the second. This it the third and final one.

This is the start of a new paragraph.
  {{< /card >}}

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

{{< /cardpane >}}


#### No hard line breaks.

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

**Which both render as:**

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.


#### Forced line breaks

In some circumstances, e.g. a list of items that is not bulleted, you may want to prevent the joining of adjecent lines when rendered.
You can force a line break by adding two spaces `  ` at the end of a line.

{{< cardpane >}}

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

  {{< card header="Do this (highlight the text to see the spaces)" >}}
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



### Blank lines and spacing

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

The following is an exmaple of the heading levels.

```markdown

# Heading level 1


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

A simple paragraph block quote.

> This is a simple block quote.
> This is the second sentence.

A pair of spaces at the end of a line can be used to force line breaks, e.g.:

> This is a multi line block quote.  
> This is the second line.  
> This is the third line.

## Lists


### Bulleted list

* Item 1.
  This is some extra content for item 1.
* Item 2.
    * Item 2a.
    * Item 2b.
* Item 3.


### Numbered List

1. Item 1.
   This is some extra content for step 1.
1. Item 2.
    1. Item 2a.
    1. Item 2b.
1. Item 3.


### Check List

* [ ] Item 1.
      This is some extra content for item 1.
* [ ] Item 2.
    * [x] Item 2a.
    * [ ] Item 2b.
* [x] Item 3.


### Definition list

Name
: Godzilla

Birthplace
: Japan

Color
: Green


## Tables

Tables should ideally have its columns aligned in the markdown for clarity in the raw markdown.

```markdown
## Don't do this

| Artist | Album | Year |
|-|-|-|
| Michael Jackson | Thriller | 1982 |
| Prince | Purple Rain | 1984 |
| Beastie Boys | License to Ill | 1986 |

## Do this

| Artist          | Album          | Year |
|-----------------|----------------|------|
| Michael Jackson | Thriller       | 1982 |
| Prince          | Purple Rain    | 1984 |
| Beastie Boys    | License to Ill | 1986 |
```

However both will produce the same result.

| Artist          | Album          | Year |
|-----------------|----------------|------|
| Michael Jackson | Thriller       | 1982 |
| Prince          | Purple Rain    | 1984 |
| Beastie Boys    | License to Ill | 1986 |


## Links

A [link](#alerts) to an anchor on this page.

A [link]({{< ref "using-images#captions" >}}) link to an anchor on page that is a sibling of this one.

A [link]({{< ref "../proxy/install.md#prerequisites" >}}) link to an anchor on page above this one, using a relative path.

A [link]({{< relref "/docs/proxy/install.md#prerequisites" >}}) link to an anchor on page above this one, using an absolute path, that will be converted to a relative one.


## Code highlighting


### Inline code

Inline code `looks like this`.


### Code blocks

Code blocks should be surrounded with fences `` ```language-type `` and `` ``` `` with the language type **always** specified to ensure correct syntax highlighting.
If the language type is not supplied then styling will be different to fenced blocks with a language.

This is a markdown example of a fenced code block containing XML content.

````markdown
```xml
<root>
  <child attr="xxx">some val</child>
</root>
```
````

Some language types commonly used in this documentation are:

* `bash`
* `java`
* `json`
* `text`
* `xml`
* `yaml`

The list of supported languages can be found [here (external)](https://prismjs.com/index.html#supported-languages).
If the content of the fenced block has no supported language or is just plain text then use language `text`.
This ensures the correct default styling is used and makes it explicitly clear to anyone editing the markdown what the content of the block is.

The following are some example of rendered code blocks:

{{< cardpane >}}

  {{< card header="Plain Text" >}}
```text
id,date,time
1,6/2/2018,10:18
2,12/6/2017,5:58
3,6/7/2018,11:58
```
  {{< /card >}}

  {{< card header="YAML" >}}
```yaml
---
root:
  someKey: "value"
```
  {{< /card >}}

  {{< card header="XML" >}}
```xml
<root>
  <child attr="xxx">
    some val
  </child>
</root>
```
  {{< /card >}}

  {{< card header="bash" >}}
```bash
echo "${VAR}"
```
  {{< /card >}}

{{< /cardpane >}}


## Alerts


### Warning block Quote

{{% warning %}}
This is a warning that can contain _markdown_.
{{% /warning %}}


### Page level warning

{{% page-warning %}}
This is a warning that can contain _markdown_.
{{% /page-warning %}}


### Note block Quote

{{% note %}}
This is a note that can contain **markdown**.
{{% /note %}}


### Page level info

{{% pageinfo %}}
This is some info that can contain **markdown**.
{{% /pageinfo %}}


### TODO block Quote

{{% todo %}}
This is a TODO that can contain `markdown`.
{{% /todo %}}

## Cards

Cards can be used to display related conent side by side.
Each card can contain markdown and/or Hugo short codes.
The cards will be displayed horizopntally across the page.

{{< cardpane >}}

  {{< card header="YAML" >}}
```yaml
---
root:
  someKey: "value"
```
  {{< /card >}}

  {{< card header="XML" >}}
```xml
<root>
  <child attr="xxx">some val</child>
</root>
```
  {{< /card >}}

{{< /cardpane >}}

