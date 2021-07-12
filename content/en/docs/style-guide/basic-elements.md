---
title: "Basic Page Elements"
linkTitle: "Basic Page Elements"
weight: 10
description: >
tags:
  - style

---

## Markdown style conventions


### Sentence per line

Each sentence should start on a new line, even in numbered/bulleted lists.
This makes it easier to move sentences around or to remove them.
e.g.:

```markdown
This is the first sentence of the paragraph.
This is the second.
This it the third and final one.

This is the start of a new paragraph.
```

### No hard line breaks.

Long lines should not be hard wrapped by adding line breaks.
You should instead rely on your editor to soft wrap long lines that cannot fit on the visible screen area.
The process of hard wrapping long lines will vary from editor to editor and not all editors support re-wrapping lines after the content has changed.

### Blank lines and spacing

* A heading line should be preceded by two blank lines and followed by one blank line.
  This makes the headings clearer in the markdown source.
* A fenced code block should be surrounded by one blank line.
* Paragraphs should be separated by one blank line.
* Bulleted and numbered lists should be surrounded by one blank line.

e.g:

```markdown
The text belonging to the previous heading.


## A Heading

The text of this heading.
Another line.

A new paragraph.
Another line.

Here are some bullets:

* Bullet 1
* Bullet 2
* Bullet 3

Here are some numbered steps:

1. Step 1
1. Step 2
1. Step 3

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

> This is a single line block quote.
> This is the second line.

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

Tables should ideally have its columns aligned in the markdown for clarity in the source.

| Artist          | Album          | Year |
|-----------------|----------------|------|
| Michael Jackson | Thriller       | 1982 |
| Prince          | Purple Rain    | 1984 |
| Beastie Boys    | License to Ill | 1986 |

However this will produce the same result.

| Artist | Album | Year |
|-|-|-|
| Michael Jackson | Thriller | 1982 |
| Prince | Purple Rain | 1984 |
| Beastie Boys | License to Ill | 1986 |


## Links

A [link](#alerts) to an anchor on this page.

A [link]({{< ref "using-images#captions" >}}) link to an anchor on page that is a sibling of this one.

A [link]({{< ref "../proxy/install.md#prerequisites" >}}) link to an anchor on page above this one, using a relative path.

A [link]({{< relref "/docs/proxy/install.md#prerequisites" >}}) link to an anchor on page above this one, using an absolute path, that will be converted to a relative one.


## Code highlighting


### Inline code

Inline code `looks like this`.


### Code blocks

Code blocks should be surrounded with fences and the language type **always** specified to ensure correct syntax highlighting.
If the language type is not supplied then styling will be different to fenced blocks with a language.
The list of supported languages can be found [here (external)](https://prismjs.com/index.html#supported-languages).
If the content of the fenced block has no supported language or is just plain text then use language `none` or `text`.
This ensures the correct default styling is used and makes it explicitly clear to anyone editing the markdown what the content of the block is.

The following are some example of code blocks:

**Plain text**

```none
id,date,time,guid,from_ip,to_ip,application
1,6/2/2018,10:18,10990cde-1084-4006-aaf3-7fe52b62ce06,159.161.108.105,217.151.32.69,Tres-Zap
2,12/6/2017,5:58,633aa1a8-04ff-442d-ad9a-03ce9166a63a,210.14.34.58,133.136.48.23,Sub-Ex
3,6/7/2018,11:58,fabdeb8a-936f-4e1e-a410-3ca5f2ac3ed6,153.216.143.195,152.3.51.83,Otcom
```

**YAML**

```yaml
---
root:
  someKey: "value"
```

**Bash**

```bash
echo "${VAR}"
```

**XML**

```xml
<root>
  <child attr="xxx">some val</child>
</root>
```


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

