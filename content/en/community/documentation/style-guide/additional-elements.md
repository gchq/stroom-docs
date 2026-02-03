---
title: "Additional Page Elements"
linkTitle: "Additional Page Elements"
weight: 40
date: 2021-07-20
description: >
  Examples of various markdown and Hugo page elements.
tags:
  - style
---

## Links

While links can be added using standard markdown link syntax you should use Hugo shortcodes to add them.
The advantage of the shortcode is that Hugo will check for broken links when building the site.


### External links

As this site is deployed to environments with no internet connect and is also released in PDF form it is important that any links to locations outside of the this site (i.e. on the internet) are clearly marked.
To include an external link do the following:

* This is a link to {{< external-link "Stroom on Github" "https://github.com/gchq/stroom" >}} with a title.

  ```markdown
  This is a link to {{</* external-link "Stroom on Github" "https://github.com/gchq/stroom" */>}} with a title.
  ```

* This is the same link with no title, {{< external-link "https://github.com/gchq/stroom" >}}.

  ```markdown
  This is the same link with no title, {{</* external-link "https://github.com/gchq/stroom" */>}}.
  ```


#### Versioned URLs

Some external links are to other Stroom URLs are versioned.
If you need to link to a site external to this one that has the Stroom version in the URL then you can use the tag `@@VERSION@@` in the URL.
This will be translated into the Stroom version of this site, as seen in the _Stroom Version (...)_ drop down at the top of the page.
This saves you from having to update the URL on each release of Stroom.

* This is a versioned URL {{< external-link "https://gchq.github.io/stroom/v@@VERSION@@" >}} 

  ```markdown
  This is a versioned URL {{</* external-link "https://gchq.github.io/stroom/v@@VERSION@@" */>}} 
  ```

{{% warning %}}
This will not work for version `legacy` as that is not an actual Stroom version.
{{% /warning %}}



### Anchors

You can link to headings on a page using its anchor.
The anchor for a heading is the heading text with:

* All non-alphanumeric characters removed
* Spaces replaced with a `-`
* All characters made lower case
* Multiple consecutive `-` characters, e.g. `---` are replaced with a single `-`

For example the heading `Mr O'Neil's 1st Event (something)` becomes as an anchor `#mr-oneils-1st-event-something`.

See The link examples below that use anchors.


#### Duplicate anchors

If you have two headings on the same page then Hugo will suffix the anchors with a sequential number to ensure uniqueness of the anchor.
For example, with the following markdown:

```markdown
## Apples

### Example

## Oranges

### Example
```

Hugo will create the following anchors:

`apples`  
`example`  
`oranges`  
`example-1`

If you want to avoid confusion and removed the risk of anchors breaking if new headings are added in the middle, then you can explicitly name anchors:

```markdown
## Apples

### Example {#apples-example}

## Oranges

### Example {#oranges-example}
```

This is only worth doing if you want to link to these heading.


### Shortcode internal page link examples

Shortcode links are slightly more verbose to type but are preferable to markdown style links as the link target will be checked at site build time so you know all the links are correct.

Hugo has `ref` and `relref` link shortcodes.
Use only `relref` as this will be translated into a relative path when the site it built ensuring that the site can be run from any base path.

The following are some example of different links to internal content.


#### Heading anchor

* A [link]({{< relref "#alerts" >}}) to a heading anchor on this page.

  ```markdown
  [link]({{</* relref "#alerts" */>}})
  ```


#### Absolute path

* A [link]({{< relref "community/documentation/style-guide/using-images#captions" >}}) to a heading anchor on another page, using an absolute path.

  ```markdown
  [link]({{</* relref "community/documentation/style-guide/using-images#captions" */>}})
  ```


#### Relative path

* A [link]({{< relref "../versions" >}}) to a heading anchor on page above this one, using a relative path.

  ```markdown
  [link]({{</* relref "../versions" */>}})
  ```


#### Unique page name

* A [link]({{< relref "running#basic-configuration" >}}) to a heading anchor on another page, using only the unique page name.
  This is quicker to type and won't break if pages are moved but will not work if the page name is not unique.

  ```markdown
  [link]({{</* relref "running#basic-configuration" */>}})
  ```


#### Section link

* A [link]({{< relref "docs/HOWTOs" >}}) to a branch/section in the document tree, i.e. to the `\_index.md`.

  ```markdown
  [link]({{</* relref "docs/HOWTOs" */>}})
  ```


#### Next page in section link

* A link to the next page in the current section.
  If the current page is the last page in the section then no link will be displayed.
  What the next page is is defined by the [page weights]({{< relref "front-matter#weight" >}}) or the default ordering of pages in the section.

  This is useful when you have a set of pages in a section that have a natural flow, e.g. where the pages in a section are the sequential steps in an installation guide.

  The link looks like this(with the page title in the link text and the hover tip showing both the page title and the description):

  {{< next-page >}}

  ```markdown
  {{</* next-page */>}}
  ```


#### Previous page in section link

* A link to the previous page in the current section.
  If the current page is the last page in the section then no link will be displayed.
  What the previous page is is defined by the [page weights]({{< relref "front-matter#weight" >}}) or the default ordering of pages in the section.

  This is useful when you have a set of pages in a section that have a natural flow, e.g. where the pages in a section are the sequential steps in an installation guide.

  The link looks like this(with the page title in the link text and the hover tip showing both the page title and the description):

  {{< prev-page >}}

  ```markdown
  {{</* prev-page */>}}
  ```


### Markdown page link examples

{{% warning %}}
Don't use markdown style links for internal page links as they can't be verified at site build time like the short code links can.
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

You can create a link to download a file, like these:

* Download a {{< file-link "quick-start-guide/mock_stroom_data.csv" >}}file{{< /file-link >}}.

* Download {{< file-link "quick-start-guide/mock_stroom_data.csv" />}}

```markdown
{{</* file-link "quick-start-guide/mock_stroom_data.csv" */>}}Link Title{{</* /file-link */>}}

{{</* file-link "quick-start-guide/mock_stroom_data.csv" /*/>}}
```

All paths are relative to `/assets/files/`.


### Glossary links

If you need to create a link to an item in the [Glossary]({{< relref "docs/glossary" >}}) you can use the `glossary` shortcode.
E.g.

* A {{< glossary "feed" >}} is something you should know about, and so are {{< glossary "stream" "streams" >}}.

  ```markdown
  A {{</* glossary "feed" */>}} is something you should know about, and so are {{</* glossary "stream" "streams" */>}}.
  ```

The argument to the shortcode is the glossary term.
This should match the heading text on the Glossary page exactly, ignoring case.
It will be converted to an HTML anchor so that you can link directly to the heading for the term in question.


## Code


### Inline code

{{< cardpane >}}
  {{< card header="Rendered" >}}
Inline code `looks like this`.
  {{< /card >}}
  {{< card header="Markdown" >}}
```markdown
Inline code `looks like this`.
```
  {{< /card >}}
{{< /cardpane >}}


### Code blocks (simple)

Code blocks should be surrounded with fences `` ```language-type `` and `` ``` `` with the [language]({{< relref "#supported-languages" >}}) type **always** specified to ensure correct syntax highlighting.
If the language type is not supplied then styling will be different to fenced blocks with a language.

This is a markdown example of a fenced code block containing XML content.

{{< cardpane >}}
  {{< card header="Rendered" >}}
```xml
<root>
  <child attr="xxx">some val</child>
</root>
```
  {{< /card >}}
  {{< card header="Markdown" >}}
````markdown
```xml
<root>
  <child attr="xxx">some val</child>
</root>
```
````
  {{< /card >}}
{{< /cardpane >}}

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


### code blocks (advanced)

If you need to show line numbers or to highlight sections of a code block then you can use the `code-block` shortcode.
This shortcode takes the following named arguments:

* **language** - The [language]({{< relref "#supported-languages" >}}) for syntax highlighting.
  Defaults to `text`.
* **lines** - Whether to display line numbers or not (`true`|`false`).
  Defaults to `true`.
* **highlight** - A comma separate list of lines to highlight.
  Ranges of line numbers can be specified, e.g. `2-8,13,25-30`.
  Defaults to no line highlighting.
* **start** - The line number to start at.
  Defaults to 1.

The following is an example of how to use the shortcode.

```markdown
{{</* code-block language="xml" highlight="2-5,8" */>}}
<root>
  <child attr="xxx">
    some val
  </child>
  <child attr="xxx">
    some val
  </child>
  <child attr="xxx">
    some val
  </child>
</root>
{{</* /code-block */>}}
```


**Default behaviour**

```markdown
{{</* code-block */>}}
...
{{</* /code-block */>}}
```

{{< code-block >}}
<root>
  <child attr="xxx">
    some val
  </child>
  <child attr="xxx">
    some val
  </child>
  <child attr="xxx">
    some val
  </child>
</root>
{{< /code-block >}}


**With line numbers, a language and a starting line number**

```markdown
{{</* code-block language="xml" start="5" */>}}
...
{{</* /code-block */>}}
```

{{< code-block language="xml" start="5" >}}
  <child attr="xxx">
    some val
  </child>
  <child attr="xxx">
    some val
  </child>
</root>
{{< /code-block >}}


**With line numbers, a language and highlighted lines**

```markdown
{{</* code-block language="xml" highlight="2-5,8" */>}}
...
{{</* /code-block */>}}
```

{{< code-block language="xml" highlight="2-5,8" >}}
<root>
  <child attr="xxx">
    some val
  </child>
  <child attr="xxx">
    some val
  </child>
  <child attr="xxx">
    some val
  </child>
</root>
{{< /code-block >}}


**With a language and highlighted lines, but without line numbers**

```markdown
{{</* code-block language="xml" lines="false" highlight="2-5,8" */>}}
...
{{</* /code-block */>}}
```

{{< code-block language="xml" lines="false" highlight="2-5,8" >}}
<root>
  <child attr="xxx">
    some val
  </child>
  <child attr="xxx">
    some val
  </child>
  <child attr="xxx">
    some val
  </child>
</root>
{{< /code-block >}}


### Command line blocks

To demonstrate commands being run on the command line you can use the `command-line` shortcode.
This results in a code block with the shell prompt displayed on the left of each line.
It also means the prompt part is not selectable when the user selects the text for copy/pasting.

The shortcode takes the following positional arguments:

1. **username** - The username to appear in the prompt, defaults to `user`.
1. **hostname** - The hostname to appear in the prompt, defaults to `localhost`.
1. **language** - The language of the content (a valid and installed prism [language name]({{< relref "#supported-languages" >}}) language name), defaults to `bash`.

If you want to display shell output then prefix each output line with `(out)`.
It will then be displayed without a prompt.
To display a blank line with no prompt then have a line with just `(out)` in it.

If your shell command is very long then you can split it into multiple lines using the shell line continuation character `\` which must be the last character on the line.
If this character is present then it will be rendered with a different prompt to indicate it is a continuation.
Readers can then copy/past the muli-line command into a shell and run it.

{{< cardpane >}}
  {{< card header="Rendered" >}}
{{< command-line "david" "wopr" >}}
echo hello \
world
(out)hello world
id
(out)uid=1000(david) gid=1000(david)
{{</ command-line >}}
  {{< /card >}}
  {{< card header="Markdown" >}}
```markdown
{{</* command-line "david" "wopr" */>}}
echo hello \
world
(out)hello world
id
(out)uid=1000(david) gid=1000(david)
{{</*/ command-line */>}}
```
  {{< /card >}}
{{< /cardpane >}}


### MySQL shell blocks

To demonstrate commands being run in a MySQL shell you can use the `sql-shell` shortcode.
This works in a similar way to the `command-line` shortcode but has a different prompt and no shortcode arguments.

If you want to display shell output then prefix each output line with `(out)`.
It will then be displayed without a prompt.

If your sql statement is multi-line, prefix all lines except the first with `(con)` (for continuation).
Continuation lines will be rendered with a continuation prompt (`->`).

To display a blank line with no prompt then have a line with just `(out)` in it.

{{< cardpane >}}
  {{< card header="Rendered" >}}
{{< sql-shell >}}
select *
(con)from token_type
(con)limit 2;
(out)+----+------+
(out)| id | type |
(out)+----+------+
(out)|  1 | user |
(out)|  2 | api  |
(out)+----+------+
(out)2 rows in set (0.00 sec)
(out)
select database();
(out)+------------+
(out)| database() |
(out)+------------+
(out)| stroom     |
(out)+------------+
(out)1 row in set (0.00 sec)
{{</ sql-shell >}}
  {{< /card >}}
  {{< card header="Markdown" >}}
```markdown
{{</* sql-shell */>}}
select *
(con)from token_type
(con)limit 2;
(con)+----+------+
(con)| id | type |
(con)+----+------+
(con)|  1 | user |
(con)|  2 | api  |
(con)+----+------+
(out)2 rows in set (0.00 sec)
(out)
select database();
(out)+------------+
(out)| database() |
(out)+------------+
(out)| stroom     |
(out)+------------+
(out)1 row in set (0.00 sec)
{{</*/ sql-shell */>}}
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


### Supported languages

This site uses {{< external-link "Prismjs" "https://prismjs.com/index.html" >}} for syntax highlighing code blocks.
PrismJs supports a large number of different languages however only certain languages have been included with this site.
The language specified in the markdown code fence or in the `command-line` shortcode must be in the list of included languages.

The list of included language names are:

`sh`  
`bash`  
`css`  
`csv`  
`groovy`  
`http`  
`java`  
`javascript`  
`jq`  
`json`  
`python`  
`regex`  
`scss`  
`sql`  
`text`  
`toml`  
`xml`  
`yaml`  

To include extra languages in this site you need to build a new version of the `prism.js` and `prism.css` files.
This can be done {{< external-link "here" "https://prismjs.com/index.html#supported-languages" >}}.
When creating new versions of these file you must include the languages and plugins already included else you may break this site.
The generated files are then copied over the top of `/static/css/prism.css` and `/static/js/prism.js`.
Both files include a comment at the top with the link to the PrismJs download page with the currently included items selected.
Use this link then add any additional items, bearing in mind the size of the download and its impact on page load times.

An example of the download link is {{< external-link "https://prismjs.com/download.html#themes=prism&languages=markup+css+clike+javascript+bash+csv+groovy+java+jq+json+markdown+python+regex+scss+sql+toml+yaml&plugins=line-highlight+line-numbers+command-line+toolbar+copy-to-clipboard+treeview */" >}}

{{% warning %}}
The css/js downloaded from the Prism site is taken from the head of their master branch so even though the css/js mention a Prism version number this may be the same for downloads done at different times.
{{% /warning %}}


## Alerts

Various page/block level quotes for drawing attention to things.

{{% warning %}}
Using shortcodes, e.g. `{{</* pipe-elm "SplitFilter" */>}}` inside an of these alerts is currently not fully supported so may not work.
{{% /warning %}}


### Warning block Quote

{{% warning %}}
This is a warning that can contain _markdown_.
{{% /warning %}}

The markdown for this is:

```markdown
{{%/* warning */%}}
This is a warning that can contain _markdown_.
{{%/* /warning */%}}
```


### Page level warning

{{% page-warning %}}
This is a warning that can contain _markdown_.
{{% /page-warning %}}

The markdown for this is:

```markdown
{{%/* page-warning */%}}
This is a warning that can contain _markdown_.
{{%/* /page-warning */%}}
```


### Note block Quote

{{% note %}}
This is a note that can contain **markdown**.
{{% /note %}}

The markdown for this is:

```markdown
{{%/* note */%}}
This is a note that can contain **markdown**.
{{%/* /note */%}}
```


### See also block Quote

Useful for linking to other areas of the documentation or to external sites.

{{% see-also %}}
[Note block quote]({{< relref "#note-block-quote" >}})  
[Warning block quote]({{< relref "#warning-block-quote" >}})
{{% /see-also %}}

The markdown for this is:

```markdown
{{%/* see-also */%}}
[Note block quote]({{</* relref "#note-block-quote" */>}})  
[Warning block quote]({{</* relref "#warning-block-quote" */>}})
{{%/* /see-also */%}}
```


### Page level info

{{% pageinfo %}}
This is some info that can contain **markdown**.
{{% /pageinfo %}}

The markdown for this is:

```markdown
{{%/* pageinfo */%}}
This is some info that can contain **markdown**.
{{%/* /pageinfo */%}}
```


### TODO block Quote

Used to indicate areas of the documentation that are unfinished or incorrect.

{{% todo %}}
This is a TODO that can contain `markdown`.
{{% /todo %}}

The markdown for this is:

```markdown
{{%/* todo */%}}
This is a TODO that can contain `markdown`.
{{%/* /todo */%}}
```


## Cards

Cards can be used to display related content side by side.
Each card can contain markdown and/or Hugo short codes.
The cards will be displayed horizontally to fill the width of the page.


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

The markdown for this is:

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

## Tabbed panes

Hugo/Docsy have shortcodes for {{< external-link "tabbed panes" "https://www.docsy.dev/docs/content/shortcodes/#tabbed-panes" >}} however these mean only one tab will be printed or visible in the generated PDF so their use should be avoided.
