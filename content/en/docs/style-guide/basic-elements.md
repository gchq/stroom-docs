
---
title: "Basic Page Elements"
linkTitle: "Basic Page Elements"
description: >
tags:
  - style

---

## Heading A (level 2)

The page title uses heading level one (`# ` in markdown) so all markdown headings should be >= 2 (`## `, `### `, `#### `, etc.).

Page table of contents (right hand pane) is controlled by this in `config.toml`.

```toml
[markup]
  [markup.tableOfContents]
    endLevel = 4
    ordered = false
    startLevel = 2
```


### Heading AA (level 3)

Some text at level 3


### Heading AB (level 3)

Some text at level 3


## Heading B (level 2)

Some text at level 2


### Heading BA (level 3)

Some text at level 3


### Heading BB (level 3)

Some text at level 3


## Block quotes

> This is a multi line block quote.  
> This is the second line.


## Bulleted list

* Item 1
* Item 2
    * Item 2a
    * Item 2b
* Item 3


## Numbered List

1. Item 1
1. Item 2
    1. Item 2a
    1. Item 2b
1. Item 3


## Check List

* [ ] Item 1
* [ ] Item 2
    * [x] Item 2a
    * [ ] Item 2b
* [x] Item 3

## Definition list

Name
: Godzilla

Birthplace
: Japan

Color
: Green

## Tables

| Artist            | Album           | Year |
|-------------------|-----------------|------|
| Michael Jackson   | Thriller        | 1982 |
| Prince            | Purple Rain     | 1984 |
| Beastie Boys      | License to Ill  | 1986 |



## Links

A [link](#alerts) to an anchor on this page.

A [link]({{< ref "using-images#captions" >}}) link to an anchor on page below this one.

A [link]({{< ref "../proxy/install.md#prerequisites" >}}) link to an anchor on page above this one, using a relative path.

A [link]({{< relref "/docs/proxy/install.md#prerequisites" >}}) link to an anchor on page above this one, using an absolute path, that will be converted to a relative one.


## Code highlighting


### Inline code

Inline code `looks like this`


### YAML

```yaml
---
root:
  someKey: "value"
```

### Bash

```bash
echo "${VAR}"
```

### XML

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
