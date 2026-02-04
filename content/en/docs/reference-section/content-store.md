---
title: "Content Store"
linkTitle: "Content Store"
weight: 0
date: 2026-01-19
tags:
description: >
  Import packages of content to extend Stroom.
---


## Motivation

Setting up Stroom is complex.
Reusing other people's work is much easier.
The Content Store allows you to import packages of tested, consistent content.

## How to find it

The Content Store can be accessed via the Stroom Menu {{< stroom-icon "menu.svg" >}} Tools > Content Store.


## What is a Content Store?

A Content Store is a YAML text file that references a number of sources of content. The content needs to be available via Git.

The default Content Store can be found here: {{< external-link "https://github.com/gchq/stroom-content/blob/master/source/content-store.yml" "https://github.com/gchq/stroom-content/blob/master/source/content-store.yml" >}}.
You can add extra or completely different Content Stores for your instance of Stroom by defining them within your `local.yml` configuration file. See below for details.


## Security Considerations

The content within a Content Pack has full access to your Stroom system. You should examine the content carefully before trusting it.


## Managing Content Packs


### Importing

Open the Content Store via the Stroom Menu {{< stroom-icon "menu.svg" >}} Tools > Content Store.

Select the Content Pack you are interested in and click the `Install` button. A new {{< stroom-icon "document/GitRepo.svg" >}} Git Repo document will be created in the Explorer Tree and content pulled from Git.

Some Content Packs might be marked as requiring authentication. In this case you will need to contact the provider of the Content Pack for credentials.


### Deleting

Select the {{< stroom-icon "document/GitRepo.svg" >}} Git Repo document in the Explorer Tree.
Right click the document and select {{< stroom-icon "delete.svg" >}} Delete.
Confirm the deletion and the Content Pack will be removed.


### Updating

There are two types of update that may be available:

1. The content within Git may have been updated
2. The values within the Content Store may be referencing new content; for example a new Git URL or a new Git commit.


### Updating via the Content Store

Both of these update routes are managed within the Content Store.

Open the Content Store via the Stroom Menu {{< stroom-icon "menu.svg" >}} Tools > Content Store.

The Content Store will check whether updates are available in the background. This may take a few minutes.
If an update is available the Upgrade button will be enabled.
Clicking that button will immediately start the upgrade process.
Once the upgrade is complete a summary is shown.


### Updating via the Git Repo Document

You can also update the content within the Git Repo document, although this won't update any changes to the Content Store such as a new Git URL or Commit Hash.
Double-click the {{< stroom-icon "document/GitRepo.svg" >}} Git Repo document in the Explorer Tree to open a tab showing the details.

On the `Settings` tab, click `Check for updates`. Any available changes to the content within the Git Repository will be shown in {{< external-link "diff format" "https://en.wikipedia.org/wiki/Diff#Context_format" >}}.

To update click `Pull from Git`. Any updates will immediately be imported into Stroom.


### The difference between a Content Pack and a Git Repo

You will notice that the settings tab of {{< stroom-icon "document/GitRepo.svg" >}} Git Repo documents created manually looks slightly different to those created via the Content Store.
This is because some of the fields should be controlled by the Content Store, otherwise upgrades might do unexpected things.
It isn't possible to push changes to content packs back into Git.

If you need to push content back into Git then it is recommended that you create a {{< stroom-icon "document/GitRepo.svg" >}}Git Repo document [manually]({{< relref "git-repo" >}}).


## Defining a Content Store

A Content Store is a {{< external-link "YAML formatted" "https://yaml.org/" >}}  text file. The {{< external-link "default Content Store" "https://raw.githubusercontent.com/gchq/stroom-content/refs/heads/master/source/content-store.yml" >}} is annotated so see that file for full definitions of all the fields.

The overall format is:

- meta section at the start, with information about the person or organisation that created and manages the Content Store.
- contentPacks section, listing all the Content Packs.

Each content pack has the following fields:

id
: Unique ID for the Content Pack within the Content Store.

uiName
: The name for the Content Pack, as shown in the Content Store user-interface.

iconUrl
: URL to get the icon. Any image format is supported.

licenseName
: Short form for the license.
For example; Apache 2.0.

stroomPath
: Where the {{< stroom-icon "document/GitRepo.svg" >}}Git Repo will be created within the Explorer Tree.

gitRepoName
: The name of the {{< stroom-icon "document/GitRepo.svg" >}}Git Repo. If not specified then the value of the `uiName` is used.

details
: Description of the Content Pack, formatted in {{< external-link "Markdown" "https://www.markdownguide.org/" >}}.

gitUrl
: The URL of the Git repository; for example {{< external-link "https://github.com/gchq/stroom-content.git" "https://github.com/gchq/stroom-content.git" >}} or `git@github.com:gchq/stroom-content.git`

gitBranch
: The name of the Git branch within the repository. For example `master` or `main`.

gitPath
: The relative path to the root of the content to import or export.

gitCommit
: Optional Git commit hash for the content to import. If this is specified the Git repository is effectively locked to that version. Thus any updates will require an updated version of the Content Store file.

gitNeedsAuth
: `true`, if the user needs to enter credentials to access the Content Pack, or `false` if the content is freely downloadable.


## Adding extra Content Stores

Content Stores are listed in the local.yaml configuration file, under `appConfig/contentStore/urls`.
If nothing is specified in the configuration file then the {{< external-link "default Content Store URL" "https://raw.githubusercontent.com/gchq/stroom-content/refs/heads/master/source/content-store.yml" >}} is used.

Extra URLs can be added to the YAML array of URLs; for example:
```yaml
...
  contentStore:
    urls:
    - "https://raw.githubusercontent.com/gchq/stroom-content/refs/heads/master/source/content-store.yml"
    - "https://intranet.local/stroom/myorg-content-store.yml" 
...
```
