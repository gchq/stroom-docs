---
title: "_Style Guide"
linkTitle: "_Style Guide"
weight: 1
description: >
  A style guide page that won't be visible in production.
  It should be viewed both in its published form and as source to understand how the page elements are formed.
menu:
  main:
    weight: 20
# Set draft: true to stop the page appearing in the published/released version.
draft: true
---

## Heading A (level 2)

The page title uses heading level one so all markdown headings should be >= 2.


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

[A link to a page anchor](#heading-bb-level-3)


## Images


### Using page resources (with caption)

{{< image stroom-oo "200x" >}}
This is some optional caption text for the image.
And this is another line.
{{< /image >}}


### Using page resources (without caption)

Use the `image` short code to display an image in the same directory as the page.

{{< image puml-example "300x" />}}



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

### Note

{{% alert title="Note" %}}This is an alert with a title and **Markdown**.{{% /alert %}}

### Warning

{{% alert color="warning" title="Warning" %}}This is a warning with a title and _markdown_.{{% /alert %}}


