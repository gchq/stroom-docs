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

* A [link]({{< relref "../../../docs/proxy/install.md#prerequisites" >}}) to a heading anchor on page above this one, using a relative path.

  ```markdown
  [link]({{</* relref "../../../docs/proxy/install.md#prerequisites" */>}})
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

To create a link to download a file, {{< file-link "quick-start-guide/mock_stroom_data.csv" >}}like this{{< /file-link >}}, that is served by this site you need to do:

```markdown
{{</* file-link "quick-start-guide/mock_stroom_data.csv" */>}}Link Title{{</* /file-link */>}}
```

Paths are relative to `/assets/files/`.

### Glossary links

If you need to create a link to an item in the [Glossary]({{< relref "docs/glossary" >}}) you can use the `glossary` shortcode.
E.g.

A {{< glossary "feed" >}} is something you should know about.

```markdown
A {{</* glossary "feed" */>}} is something you should know about.
```

The argument to the shortcode is the glossary term.
This should match the heading text on the Glossary page exactly.
It will be converted to an HTML anchor so that you can link direct to the heading for the term in question.


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


### Code blocks

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


### Command line blocks

To demostrate commands being run on the command line you can use the `command-line` shortcode.
This results in a code block with the shell prompt displayed on the left of each line.
It also means the prompt part is not selectable when the user selects the text for copy/pasting.

The shortcode takes the following arguments:

* **username** - The username to appear in the prompt, defaults to `user`.
* **hostname** - The hostname to appear in the prompt, defaults to `localhost`.
* **language** - The language of the content (a valid and installed prism [language name]({{< relref "#supported-languages" >}}) language name), defaults to `bash`.

If you want to display shell output then prefix each output line with `(out)`.
It will then be displayed without a prompt.

{{< cardpane >}}
  {{< card header="Rendered" >}}
{{< command-line "david" "wopr" >}}
echo "hello world"
(out)hello world
id
(out)uid=1000(david) gid=1000(david)
{{</ command-line >}}
  {{< /card >}}
  {{< card header="Markdown" >}}
```markdown
{{</* command-line "david" "wopr" */>}}
echo "hello world"
(out)class
id
(out)uid=1000(david) gid=1000(david)
{{</* command-line */>}}
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
When creating new versions of these file you must included the languages and plugins already included else you may break this site.
The generated files are then copied over the top of `/static/css/prism.css` and `/static/js/prism.js`.
Both files include a comment at the top with the link to the PrismJs download page with the currently included items selected.
Use this link then add any additional items, bearing in mind the size of the download and its impact on page load times.

An example of the download link is {{< external-link "https://prismjs.com/download.html#themes=prism&languages=markup+css+clike+javascript+bash+csv+groovy+java+jq+json+markdown+python+regex+scss+sql+toml+yaml&plugins=command-line+toolbar+copy-to-clipboard+treeview" >}}


## Alerts


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

Hugo/Docsy have shortcodes for {{< external-link "tabbed panes" "https://www.docsy.dev/docs/adding-content/shortcodes/#tabbed-panes" >}} however these mean only one tab will be printed or visible in the generated PDF so there use should be avoided.
