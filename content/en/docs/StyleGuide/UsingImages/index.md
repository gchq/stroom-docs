
---
title: "Images"
linkTitle: "Images"
weight: 1
description: >
# Set draft: true to stop the page appearing in the published/released version.
tags:
  - style
exclude_search: true

---

## Using page resources

Use the `image` short code to display an image file that is located in the same directory as the page.
For the short code to work the page must be a leaf bundle (`index.md`) or a branch bundle (`_index.md`), i.e:

```
/docs
   /MyPage
      index.md - #image shortcode used in here
      example.svg
```

or 

```
/docs
   /MySection
      /Page1
         index.md
      /Page2
         index.md
      _index.md - #image shortcode used in here
      example.svg
```

{{< image puml-example.svg "300x" />}}

### Captions

The image can be displayed with a caption:

{{< image stroom-oo.svg "200x" >}}
This is some optional caption text for the image.
And this is another line.
{{< /image >}}

### Size

The image can be defined with a maximum width (`nnnx`) or a maximum height (`xnnn`).

{{< image puml-example.svg "120x" />}}


## Using global `/assets/` resources

For images that are shared by multiple page bundles, e.g. stroom icons, place them in `/assets/images/`.
The image path is relative to `/assets/images/`, e.g. file  `/assets/images/StyleGuide/svg-example.svg` becomes:

```
{{</* image "StyleGuide/svg-example.svg" "200x" */>}}
```

{{< image "StyleGuide/svg-example.svg" "200x" >}}
This is some optional caption text for the image.
And this is another line.
{{< /image >}}


