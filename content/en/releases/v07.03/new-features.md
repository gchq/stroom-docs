---
title: "New Features"
linkTitle: "New Features"
weight: 10
date: 2024-02-23
tags: 
description: >
  New features in Stroom version 7.3.
---

## User Interface

* Add a Copy {{< stroom-icon "copy.svg" >}} button to the Processors sub-tab on the Pipeline screen.
  This will create a duplicate of an existing filter.

* Add a Line Wrapping {{< stroom-icon "text-wrap.svg">}} toggle button to the Server Tasks screen.
  This will enable/disable line wrapping on the Name and Info cells.

* Allow pane resizing in dashboards without needing to be in design mode.

* Add Copy {{< stroom-icon "copy.svg" >}} and Jump to {{< stroom-icon "open.svg" >}} hover buttons to the Stream Browser screen to copy the value of the cell or (if it is a document) jump to that document.

  {{< image "releases/07.03/meta-links.png" "400x" >}}Copy and jump to links in the Data Browser screen{{< /image >}}

* Tagging of individual explorer nodes was introduced in [v7.2]({{< relref "../v07.02/new-features#document-tagging" >}}).
  v7.3 however adds support for adding/removing tags to/from multiple explorer tree nodes via the explorer context menu.

  {{< cardpane >}}
  {{< image "releases/07.03/add-remove-tags.png" "400x" >}}Add/Remove tags on multiple items.{{< /image >}}
  {{< image "releases/07.03/add-tags.png" "400x" >}}Add tags to multiple nodes.{{< /image >}}
  {{< image "releases/07.03/remove-tags.png" "400x" >}}Remove tags from multiple nodes.{{< /image >}}
  {{< /cardpane >}}


### Explorer Tree

* Additional buttons on the top of the explorer tree pane.

  {{< image "releases/07.03/explorer-pane.png" "300x" >}}Explorer Tree Pane{{< /image >}}

  * Add Expand All {{< stroom-icon "expand-all.svg">}} and Collapse All {{< stroom-icon "collapse-all.svg">}} buttons to the explorer pane to open or close all items in the tree respectively.

  * Add a Locate Current Item {{< stroom-icon "locate.svg" "Locate Current Item">}} button to the explorer pane to locate the currently open document in the explorer tree.


### Finding Things

#### Find

New screen for finding documents by name.
Accessed using `alt-shift-f` or

{{< stroom-menu "Navigation" "Find" >}}

{{< image "releases/07.03/find.png" "400x" >}}Find{{< /image >}}


#### Find In Content

Improvements to the Find In Content screen so that it now shows the content of the document and highlights the matched terms.
Now accessible using `ctrl-shift-f` or 

{{< stroom-menu "Navigation" "Find In Content" >}}


{{< image "releases/07.03/find-in-content.png" "400x" >}}Find In Content{{< /image >}}


#### Recent Items

New screen for finding recently used documents.
Accessed using `ctrl-e` or

{{< stroom-menu "Navigation" "Recent Items" >}}

{{< image "releases/07.03/recent-items.png" "400x" >}}Recent Items{{< /image >}}


### Editor Snippets

[Snippets]({{< relref "docs/user-guide/content/editing-text/editing-text#auto-completion-and-snippets" >}}) are a way of quickly adding snippets of pre-defined text into the text editors in Stroom.
Snippets have been available in previous versions of Stroom however there have been various additions to the library of snippets available which makes creating/editing content a lot easier.

* Add snippets for [Data Splitter]({{< relref "docs/user-guide/data-splitter" >}}).
  For the list of available snippets see [here]({{< relref "docs/user-guide/content/editing-text/snippet-reference#data-splitter-snippets" >}}).

* Add snippets for [XMLFragmentParser]({{< relref "docs/user-guide/pipelines/element-reference#xmlfragmentparser" >}}).
  For the list of available snippets see [here]({{< relref "docs/user-guide/content/editing-text/snippet-reference#xmlfragmentparser-snippets" >}}).

* Add new XSLT snippets for `<xsl:element>` and `<xsl:message>`.
  For the list of available snippets see [here]({{< relref "docs/user-guide/content/editing-text/snippet-reference#xmlxslt-snippets" >}}).

* Add snippets for {{< glossary "StroomQL" >}}.
  For the list of available snippets see [here]({{< relref "docs/user-guide/content/editing-text/snippet-reference#stroom-query-language-snippets" >}}).


### API Keys

API Keys are a means for client systems to authenticate with Stroom.
In v7.2 of Stroom, the ability to use API Keys was removed if you were using an {{< glossary "idp" "external identity provider">}} as client systems could get tokens from the IDP themselves.
In v7.3 the ability to use API Keys with an external IDP has returned as we felt it offered client systems a choice and removed the complexity of dealing with the IDP.

The API Keys screen has undergone various improvements:

* Look/feel brought in line with other screens in Stroom.
* Ability to temporarily enable/disable API Keys.
  A key that is disabled in Stroom cannot be authenticated against.
* Deletion of an API Key prevents any future authentication against that key.
* Named API Keys to indicate purpose, e.g. naming a key with the client system's name.
* Comments for keys to add additional context/information for a key.
* API Key prefix to aid with identifying an API Key.
* The full API key string is no longer stored in Stroom and cannot be viewed after creation.

{{< image "releases/07.03/api-keys.png" "800x" >}}API Keys screen{{< /image >}}


#### Key Creation

The screens for creating a new API Key are as follows:

{{< cardpane >}}
  {{< image "releases/07.03/create-api-key-1.png" "400x" >}}Create API Key (part 1){{< /image >}}
  {{< image "releases/07.03/create-api-key-2.png" "400x" >}}Create API Key (part 2){{< /image >}}
{{< /cardpane >}}

{{% warning %}}
Note that the actual API Key is **ONLY** visible on the second dialog.
Once that dialog is closed Stroom cannot show you the API Key string as it does not store it.
This is for security reasons.
You must copy the created key and give it to the recipient at this point.
{{% /warning %}}


#### Key Format

We have also made changes to the format of the API Key itself.
In v7.2, the API Key was an OAuth token so had data baked into it.
In v7.3, the API Key is essentially just a _dumb_ random string, like a very long and secure password.
The following is an example of a new API Key:

```
sak_e1e78f6ee0_6CyT2Mpj2seVJzYtAXsqWwKJzyUqkYqTsammVerbJpvimtn4BpE9M5L2Sx6oeG5prhyzcA7U6fyV5EkwTxoXJPfDWLneQAq16i5P75qdQNbqJ99Wi7xzaDhryMdhVZhs
```

The structure of the key is as follows:
1. `sak` - The key type, **S**troom **A**PI **K**ey.
1. `_` - separator
1. Truncated SHA2-256 hash (truncated to 10 chars) of the whole API Key.
1. `_` - separator
1. 128 crypto random chars in the Base58 character set.
   This character set ensures no awkward characters that might need escaping and removes some ambiguous characters (`0OIl`).

Features of the new format are:

* Fixed length of 143 chars with fixed prefix (`sak_`) that make it easier to search for API Keys in config, e.g. to stop API Keys being leaked into online public repositories and the like.
* Unique prefix (e.g. `sak_e1e78f6ee0_`) to help link an API being used by a client with the API Key record stored in Stroom.
  This part of the key is stored and displayed in Stroom.
* The hash part acts as a checksum for the key to ensure it is correct.
  The following {{< external-link "CyberChef recipe" "https://gchq.github.io/CyberChef/#recipe=Register('sak_(.*)_.*$',true,false,false)Regular_expression('User%20defined','sak_.*_(.*)$',true,true,false,false,false,false,'List%20capture%20groups')SHA2('256',64,160)Regular_expression('User%20defined','%5E.%7B10%7D',true,true,false,false,false,false,'List%20matches')Regular_expression('User%20defined','%5E$R0$',true,true,false,false,false,false,'Highlight%20matches')&input=c2FrX2UxZTc4ZjZlZTBfNkN5VDJNcGoyc2VWSnpZdEFYc3FXd0tKenlVcWtZcVRzYW1tVmVyYkpwdmltdG40QnBFOU01TDJTeDZvZUc1cHJoeXpjQTdVNmZ5VjVFa3dUeG9YSlBmRFdMbmVRQXExNmk1UDc1cWRRTmJxSjk5V2k3eHphRGhyeU1kaFZaaHM" >}} shows how you can validate the hash part of a key.


## Analytics

* Add distributed processing for streaming analytics.
  This means streaming analytics can now run on all nodes in the cluster rather than just one.

* Add multiple recipients to rule notification emails.
  Previously only one recipient could be added.


## Search

* Add support for Lucene 9.8.0 and supporting multiple version of Lucene.
  Stroom now stores the Lucene version used to create an index shard against the shard so that the correct Lucene version is used when reading/writing from that shard.
  This will allow Stroom to harness new Lucene features in future while maintaining backwards compatibility with older versions.

* Add support for `field in` and `field in dictionary` to {{< glossary "StroomQL" >}}.


## Processing

* Improve the display of processor filter state.
  The columns `Tracker Ms` and `Tracker %` have been removed and the `Status` column has been improved better reflect the state of the filter tracker.

* Stroom now supports the XSLT standard element `<xsl:message>`.
  This element will be handled as follows:

  ```xml
  <!-- Log `some message` at severity `FATAL` and terminate processing of that stream part immediately.
       Note that `terminate="yes"` will trump any severity that is also set. -->
  <xsl:message terminate="yes">some message</xsl:message>

  <!-- Log `some message` at severity `ERROR`. -->
  <xsl:message>some message</xsl:message>

  <!-- Log `some message` at severity `FATAL`. -->
  <xsl:message><fatal>some message</fatal></xsl:message>

  <!-- Log `some message` at severity `ERROR`. -->
  <xsl:message><error>some message</error></xsl:message>

  <!-- Log `some message` at severity `WARNING`. -->
  <xsl:message><warn>some message</warn></xsl:message>

  <!-- Log `some message` at severity `INFO`. -->
  <xsl:message><info>some message</info></xsl:message>

  <!-- Log $msg at severity `ERROR`. -->
  <xsl:message><xsl:value-of select="$msg"></xsl:message>
  ```

  The namespace of the severity element (e.g. `<info>` is ignored.

* Add the following pipeline element properties to allow control of logged warnings for removal/replacement respectively.
  * Add property `warnOnRemoval` to {{< pipe-elm "InvalidCharFilterReader" >}}.
  * Add property `warnOnReplacement` to {{< pipe-elm "InvalidXMLCharFilterReader" >}}.


### XSLT Functions

* Add XSLT function `stroom:hex-to-string(hex, charsetName)`.
* Add XSLT function `stroom:cidr-to-numeric-ip-range` XSLT function.
* Add XSLT function `stroom:ip-in-cidr` for testing whether an IP address is within the specified CIDR range.

For details of the new functions, see [XSLT Functions]({{< relref "docs/user-guide/pipelines/xslt/xslt-functions" >}}).


## API

* Add the un-authenticated API method `/api/authproxy/v1/noauth/fetchClientCredsToken` to effectively proxy for the {{< glossary "IDP" "IDP's" >}} token endpoint to obtain an access token using the client credentials flow.
  The request contains the client credentials and looks like `{ "clientId": "a-client", "clientSecret": "BR9m.....KNQO" }`.
  The response media type is `text/plain` and contains the access token.


