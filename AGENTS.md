# Stroom-Docs Agent Development Guide

## Project

This repository comprises the source for the Stroom documentation site, which is hosted [here](https://gchq.github.io/stroom-docs/).
The site is build using Hugo and the [Docsy](https://www.docsy.dev/docs/) Hugo theme.


## A short bullet list of the most critical rules the agent must follow before doing anything

* Changes may be staged and committed.
  Commit messages are a single short line in the imperative mood, in the form `#NNNN Message` where `NNNN` is the GitHub issue number, e.g. `#151 Add a filter section to the StroomQL grammar reference`.
  When there is no issue, use the message alone.

* DO NOT add a `Co-Authored-By` trailer, or any other AI attribution, to commit messages.

* DO NOT execute any `git merge` commands under any circumstances.

* DO NOT push, rebase, reset or otherwise rewrite git history.

* DO NOT attempt to create/modify any issues or pull requests on GitHub.
  Issues and pull requests must be created/modified by a human.

* Always use British English for spellings and terms (e.g. "colour", "organisation", "authorise", "centre", "licence").

* Prefer clear, readable code over clever or compact solutions.
  Keep functions focused on a single responsibility.

* Avoid new external dependencies unless absolutely necessary.
  Reuse existing project utilities first.


## Protected branches

* DO NOT commit directly to `master`, or to a version branch, i.e. one whose whole name matches the regular expression `[0-9]+\.[0-9]+` (e.g. `7.14`).

* Check the current branch with `git branch --show-current` before committing.
  If it is protected, stop and ask the human to create a branch to commit to.

* Branches named after a version but with more to the name, such as `7.11_wip` or `7.10-add-xslt-funcs`, are not protected.


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
