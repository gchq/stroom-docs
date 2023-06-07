---
title: "Documenting content"
linkTitle: "Documenting content"
#weight:
date: 2023-06-07
tags: 
  - content
description: >
  The ability to document each entity created in Stroom.
---

The screen for each {{< glossary "Entity" >}} in Stroom has a *Documentation* sub-tab.
The purpose of this sub-tab is to allow the user to provide any documentation about the {{< glossary "entity" >}} that is relevant.
For example a user might want to provide information about the system that a {{< glossary "Feed" >}} receives data from, or document the purpose of a complex XSLT translation.

In previous versions this documentation was a small and simple *Description* text field, however now it is a full screen of rich text.
This screen defaults to its read-only preview mode, but the user can toggle it to the edit mode to edit the content.
In the edit mode, the documentation can be created/edited using plain text, or {{< glossary "Markdown" >}}.
Markdown is a fairly simple markup language for producing richly formatted text from plain text.

Stroom uses the {{< external-link "Showdown" "https://github.com/showdownjs/showdown/wiki/Showdown's-Markdown-syntax" >}} markdown converter to render users' markdown content into formatted text.
This link is the definitive source for supported markdown syntax.

{{% note %}}
The _Showdown_ markdown processor used in stroom is not the same as the markdown processor used within this *stroom-docs* documentation site, so there may be some differences in syntax.
{{% /note %}}


The following is a brief guide to the most common formatting that can be done with markdown and that is supported in Stroom.

````text
# Markdown Example

This is an example of a markdown document.


## Headings Example

This is at level 2.


### Heading Level 3

This is at level 3.


#### Heading Level 4

This is at level 4.


## Text Styles

**bold**, __bold__, *italic*, _italic_, ***bold and italic***, ~~strike-through~~


## Bullets and Numbered Lists

Use four spaces to indent a sub-item.

* Bullet 1
    * Bullet 1a
* Bullet 2
    * Bullet 2a

1. Item 1
    1. Item 1a
    1. Item 1b
1. Item 2
    1. Item 2a
    1. Item 2b

## Quoted Text

> This is a quote.

Text

> This is another quote.  
> And it has multiple lines...
>
> ...and gaps and bullets
> * Item 1
> * Item 2


## Tables

Note `---:` to right align a column, `:---:` to center align it.

| Syntax      | Description | Value | Fruit  |
| ----------- | ----------- | -----:| :----: |
| Row 1       | Title       | 1     | Pear   |
| Row 2       | Text        | 10    | Apple  |
| Row 3       | Text        | 100   | Kiwi   |
| Row 4       | Text        | 1000  | Orange |

Table using `<br>` for multi-line cells.

| Name      | Description                                                                                                                  |
|-----------|-----------------|
| Row 1     | Line 1<br>Line2 |
| Row 2     | Line 1<br>Line2 |


## Links

Line: [title](https://www.example.com)


## Simple Lists

One  
Two  
Three  

## Paragraphs

Lines not separated by a blank line will be joined together with a space between them.
Stroom will wrap long lines when rendered.

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

## Task Lists

The `X` indicates a task has been completed.

* [x] Write the press release
* [ ] Update the website
* [ ] Contact the media


## Images

A non-standard syntax is supported to render images at a set size in the form of `<width>x<height>`.
Use a `*` for one of the dimensions to scale it proportionately.

![This is my alt text](images/logo.svg =200x* "This is my tooltip title")

## Separator

This is a horizontal rule separator

---

## Code

Code can be represented in-line like this `echo "hello world"` by surround it with back-ticks.

Blocks of code can rendered with the appropriate syntax highlighting using a fenced block comprising three back-ticks.
Specify the language after the first set of three back ticks, or `text` for plain text.
Only certain languages are supported in Stroom.

**JSON**
```json
{
  "key1": "some text",
  "key2": 123
}
```

**XML**
```xml
  <record>
    <data name="dateTime" value="2020-09-28T14:30:33.476" />
    <data name="machineIp" value="19.141.201.14" />
  </record>
```

**bash**
```bash
#!/bin/bash
now="$(date)"
computer_name="$(hostname)"
echo "Current date and time : $now"
echo "Computer name : $computer_name"
```
````

## Code Syntax Highlighting

Stroom supports the following languages for fenced blocks.
If you require additional languages then please raised a ticket {{< external-link "here" "https://github.com/gchq/stroom/issues" >}}.

* text
* sh
* bash
* xml
* css
* javascript
* csv
* regex
* powershell
* sql
* json
* yaml
* properties
* toml

## Escaping Characters

It is common to use `_` characters in {{< glossary "Feed" >}} names, however if there are two of these in a word then the markdown processor will interpret them as _italic_ markup.
To prevent this, either surround the word with back ticks to be rendered as code or escape each underscore with a `\`, i.e. `THIS\_IS\_MY\_FEED`. THIS_IS_MY_FEED.

