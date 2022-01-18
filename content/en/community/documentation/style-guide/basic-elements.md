---
title: "Basic Page Elements"
linkTitle: "Basic Page Elements"
weight: 20
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
When the markdown is rendered into HTML/PDF, the sentences will be joined into a single paragraph.

See this [link (external link)](https://asciidoctor.org/docs/asciidoc-recommended-practices/#one-sentence-per-line) for more of the reasons behind sentence per line.
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
You can force a line break by adding two spaces `␣␣` at the end of a line.

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
  {{< card header="Markdown" >}}
```markdown
* Fruit -
  Make sure you get your five-a-day.
* Meat
    * Beef
    * Chicken
* Vegetables.
```
  {{< /card >}}
  {{< card header="Rendered" >}}
* Fruit -
  Make sure you get your five-a-day.
* Meat
    * Beef
    * Chicken
* Vegetables.
  {{< /card >}}
{{< /cardpane >}}


### Numbered List

Numbered list items should all be numbered with number `1` so that the markdown render handles the consecutive numbering.
This makes the file easier to edit and means the addition of one item in the middle does not cause a change to all the lines after it, e.g:

{{< cardpane >}}
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
  {{< card header="Rendered" >}}
1. Item one.
   This is some extra content for step 1.
1. Item two.
    1. Sub-item A.
    1. Sub-item B.
1. Item three.
  {{< /card >}}
{{< /cardpane >}}



### Check List

{{< cardpane >}}
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
  {{< card header="Rendered" >}}
* [ ] Item 1.
      This is some extra content for item 1.
* [ ] Item 2.
    * [x] Item 2a.
    * [ ] Item 2b.
* [x] Item 3.
  {{< /card >}}
{{< /cardpane >}}


### Definition list

{{< cardpane >}}
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
  {{< card header="Rendered" >}}
Name
: Godzilla

Birthplace
: Japan

Color
: Green
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


## Links

Links can be added using either standard markdown link syntax or using a Hugo shortcode.
The advantage of the shortcode is that hugo will check for broken links when building the site so there are preferred.

Links to external sites, i.e. on the internet, should have ` (external link)` appended to the link title.
This makes it clear to readers which links are local and which are external and therefore possibly not available if there is no access to the internet.


### Anchors

You can link to headings on a page using its anchor.
The anchor for a heading is the heading text with:

* All non-alphanumeric characters removed
* Spaces replaced with a `-`
* All characters made lower case
* Multiple consecutive `-` characters, e.g. `---` are replaced with a single `-`

For example the heading `Mr O'Neil's 1st Event (something)` becomes as an anchor `#mr-oneils-1st-event-something`.


### Shortcode page link examples

* A [link]({{< ref "#alerts" >}}) to a heading anchor on this page.

  ```markdown
  [link]({{</* ref "#alerts" */>}})
  ```

* A [link]({{< ref "community/documentation/style-guide/using-images#captions" >}}) to a heading anchor on another page.

  ```markdown
  [link]({{</* ref "community/documentation/style-guide/using-images#captions" */>}})
  ```

* A [link]({{< ref "running#basic-configuration" >}}) to a heading anchor on another page, using only the page name.
  This will only work if the page name is unique

  ```markdown
  [link]({{</* ref "community/documentation/style-guide/using-images#captions" */>}})
  ```

* A [link]({{< ref "../../../docs/proxy/install.md#prerequisites" >}}) to a heading anchor on page above this one, using a relative path.

  ```markdown
  [link]({{</* ref "../../../docs/proxy/install.md#prerequisites" */>}})
  ```

* A [link]({{< relref "docs/proxy/install.md#prerequisites" >}}) to a heading anchor on page above this one, using an absolute path, that will be converted to a relative one.

  ```markdown
  [link]({{</* relref "/docs/proxy/install.md#prerequisites" */>}})
  ```

* A [link]({{< relref "docs/HOWTOs" >}}) to a branch in the document tree, i.e. to the \_index.md.

  ```markdown
  [link]({{</* relref "docs/HOWTOs" */>}})
  ```


### Markdown page link examples

{{% warning %}}
Avoid using markdown style links as they can't be verified at site build time like the short code links can.
{{% /warning %}}

Markdown style links should not contain the `.md` extension as this will be stripped when the site is generated, e.g. for the following content:

```text
/content
   /en
      /docs
         /section-x
            /sub-section-a
               _index.md
               page1.md
               page2.md
            /sub-section-b
               _index.md
               page1.md
               page2.md
```

This will become:

```text
/docs
   /section-x
      /sub-section-a
         /page1
         /page2
      /sub-section-b
         /page1
         /page2
```

in the rendered site.

* A [link](#alerts) to a heading anchor on this page.

  ```markdown
  [link](#alerts)
  ```

* A [link](../using-images#captions) to a heading anchor on another page, using a relative link.

  ```markdown
  [link](../using-images#captions)
  ```

* A [link](/docs/style-guide/using-images#captions) to a heading anchor on another page, using an absolute link.

  ```markdown
  [link](/docs/style-guide/using-images#captions)
  ```

### Download file links

To create a link to download a file, {{< file-link "quick-start-guide/mock_stroom_data.csv" >}}like this{{< /file-link >}}, that is served by this site you need to do:

```markdown
{{</* file-link "quick-start-guide/mock_stroom_data.csv" */>}}Link Title{{</* /file-link */>}}
```

Paths are relative to `/assets/files/`.


## Code highlighting


### Inline code

{{< cardpane >}}
  {{< card header="Markdown" >}}
```markdown
Inline code `looks like this`.
```
  {{< /card >}}
  {{< card header="Rendered" >}}
Inline code `looks like this`.
  {{< /card >}}
{{< /cardpane >}}



### Code blocks

Code blocks should be surrounded with fences `` ```language-type `` and `` ``` `` with the language type **always** specified to ensure correct syntax highlighting.
If the language type is not supplied then styling will be different to fenced blocks with a language.

This is a markdown example of a fenced code block containing XML content.

{{< cardpane >}}
  {{< card header="Markdown" >}}
````markdown
```xml
<root>
  <child attr="xxx">some val</child>
</root>
```
````
  {{< /card >}}
  {{< card header="Rendered" >}}
```xml
<root>
  <child attr="xxx">some val</child>
</root>
```
  {{< /card >}}
{{< /cardpane >}}


Some language types commonly used in this documentation are:

* `bash`
* `java`
* `json`
* `text`
* `xml`
* `yaml`

The list of supported languages can be found [here (external)](https://prismjs.com/index.html#supported-languages).

{{% note %}}
The fenced code block **MUST** have a language specified.
This ensures the correct default styling is used and makes it explicitly clear to anyone editing the markdown what the content of the block is.
If the content of the fenced block has no supported language or is just plain text then use language `text`.
{{% /note %}}

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


### Inline files

Some code or text examples may be too large for a fenced block so you can put the content in a separate file and include it in-line like so.

{{< textfile "style-guide/in_line_file_example.xml" "xml">}}Example in-line XML file{{< /textfile >}}

The card has a maximum height and will show scrollbars as required.

Examples of how to use in-line files are:

```markdown
{{</* textfile "style-guide/in_line_file_example.xml" "xml" */>}}My caption{{</* /textfile */>}}
{{</* textfile "style-guide/in_line_file_example.xml" */>}}My caption{{</* /textfile */>}}
{{</* textfile "style-guide/in_line_file_example.xml" /*/>}}
  ```


## Alerts


### Warning block Quote

```markdown
{{%/* warning */%}}
This is a warning that can contain _markdown_.
{{%/* /warning */%}}
```

{{% warning %}}
This is a warning that can contain _markdown_.
{{% /warning %}}


### Page level warning

```markdown
{{%/* page-warning */%}}
This is a warning that can contain _markdown_.
{{%/* /page-warning */%}}
```

{{% page-warning %}}
This is a warning that can contain _markdown_.
{{% /page-warning %}}


### Note block Quote

```markdown
{{%/* note */%}}
This is a note that can contain **markdown**.
{{%/* /note */%}}
```

{{% note %}}
This is a note that can contain **markdown**.
{{% /note %}}


### Page level info

```markdown
{{%/* pageinfo */%}}
This is some info that can contain **markdown**.
{{%/* /pageinfo */%}}
```

{{% pageinfo %}}
This is some info that can contain **markdown**.
{{% /pageinfo %}}


### TODO block Quote

```markdown
{{%/* todo */%}}
This is a TODO that can contain `markdown`.
{{%/* /todo */%}}
```

{{% todo %}}
This is a TODO that can contain `markdown`.
{{% /todo %}}


## Cards

Cards can be used to display related conent side by side.
Each card can contain markdown and/or Hugo short codes.
The cards will be displayed horizopntally across the page.

````marckdown
{{</* cardpane */>}}

  {{</* card header="YAML" */>}}
```yaml
---
root:
  someKey: "value"
```
  {{</* /card */>}}

  {{</* card header="XML" */>}}
```xml
<root>
  <child attr="xxx">some val</child>
</root>
```
  {{</* /card */>}}

{{</* /cardpane */>}}
````


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

