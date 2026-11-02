# Stroom-Docs Agent Development Guide

## Project

This repository comprises the source for the Stroom documentation site, which is hosted [here](https://gchq.github.io/stroom-docs/).
The site is build using Hugo and the [Docsy](https://www.docsy.dev/docs/) Hugo theme.


## A short bullet list of the most critical rules the agent must follow before doing anything

* DO NOT execute any `git commit` commands under any circumstances.

* DO NOT execute any `git merge` commands under any circumstances.

* DO NOT modify, stage, or alter git version control states automatically.

* All code changes must remain un-staged in the working directory for human review.

* DO NOT attempt to create/modify any issues or pull requests on GitHub.
  Issues and pull requests must be created/modified by a human.

* Always use British English for spellings and terms (e.g. "colour", "organisation", "authorise", "centre", "licence").

* Prefer clear, readable code over clever or compact solutions.
  Keep functions focused on a single responsibility.

* Avoid new external dependencies unless absolutely necessary.
  Reuse existing project utilities first.


## Commands

You will need docker available to run some of these commands.

* Build site: `./container_build/runInHugoDocker.sh hugo build`

* Serve site on localhost:1313: `./serve_site.sh`

* Check the spelling: `./check_spelling.sh`

* Check for broken URLs: `./broken_links.sh`

* Check for style breaches: `./check_style.sh --detail`


## Documentation/Coding Conventions

* New pages must have front matter added at the top.
  e.g.

  ```yaml
  ---
  title: "Date/Time Functions"
  linkTitle: "Date/Time Functions"
  #weight:
  date: 2025-09-25
  tags: 
  description: >
    Functions for date/time parsing and manipulation. 
  ---
  ```

  Where the date should be the current date.
  `linkTitle` should be the same as `title` unless `title` is very long.

* Documentation must adhere to the [Style Guide](https://gchq.github.io/stroom-docs/community/documentation/style-guide/).

* Only one sentence is allowed per line.

* No hard line breaks.

* When naming a Stroom XSLT function, link to its reference documentation with the `xslt-func-link` short code instead of writing it as code, e.g. `{{< xslt-func-link "lookup" >}}` rather than `` `stroom:lookup()` ``.
  The short code renders the name as `stroom:lookup()`, so pass the bare function name.
  It only works for functions with a definition file in `assets/data/xslt-function-reference/`.

* When showing where folders or documents sit in the Explorer tree (e.g. `System/MCP Workspace`), render the tree with the `stroom-tree` and `stroom-tree-doc` short codes rather than describing the path in text.
  See the [Explorer Tree](https://gchq.github.io/stroom-docs/community/documentation/style-guide/using-images/#explorer-tree) section of the style guide for usage.
  Trees are block content, so keep inline paths in tables and short list items as text.


## Contributing

Licensed under Apache 2.0 (see `LICENSE.txt`).
See `CONTRIBUTING.md` for full details.
Key points:

* Git branch naming: `gh-<GitHub issue number>-<description>`, e.g. `gh-123-proxy-s3-forwarding`.
  All lower kebab case.

* Branches should be created (by a human) off the release branch that corresponds to the GitHub milestone of the issue, e.g. milestone 7.13 = release branch `7.13`.

* Sign the GCHQ Contributor Licence Agreement (CLA).

* Ensure all checks (spelling, style and build) pass before a human opens a PR.

* Issues and pull requests can only be created/modified by a human.


## Issue and pull request policy

Do not open GitHub issues or pull requests on behalf of users.
If a user asks to create an issue or pull request, create an empty root-level file named `AI_MARKER`.
