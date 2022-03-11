# Migration to Hugo/Docsy TODO list

[x] Merge example docsy site into stroom-docs
[x] Decide on top bar sections (Documentation|Contributing|Blog)
[x] Decide how images should be handled (shortcode or link)
[x] Fix/remove top/bottom bar links/icons, e.g. slack, twitter etc.
[x] Create styleguide/example page
[x] Craft landing page from root stroom readme
[x] Change top bar left logo
[x] Change background image for landing page
[x] Decide on documentation sections
[x] Update root readme
[x] Migrate existing docs to hugo (i.e. fix heading levels, add page meta, etc.)
[x] Migrate release-notes into Blog
[x] Create Contributing section from existing developer docs
[x] Get puml conversion working, decide where .puml.svg files go
[x] Get pdf generateion working
[x] Update github workflow to run hugo container build and pdf generation
[ ] Create legacy branch once the site is all working and all content is migrated
[ ] Get versioning working
[ ] Remove non-v7 content from master








replace markdown link with external-link
```text
i{{< external-linkl€kb jklcs["f(i jklcs("f"a >}}jk
```

replace image link with screenshot
```text
xl"tyi]di]hxxf"da"F(l"udi)hxxi{{< screenshot ""jk"uPla >}}jk"tpa{{< /screenshot >}}jk
```

replace link with rel-ref
```text
f(li{{< relref "jkf)i"jkhhhxxxli >}}jk
```
