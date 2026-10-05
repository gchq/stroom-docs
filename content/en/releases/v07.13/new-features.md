---
title: "New Features"
linkTitle: "New Features"
weight: 10
date: 2026-08-13
tags: 
description: >
  New features in Stroom version 7.13.
---

## Node Groups and Processor Profiles

Nodes can now be placed into named _Node Groups_, and a _Processor Profile_ says which node group does the processing, during which periods of the day and week, and how many threads it may use in each period.
A processor filter can then be given a profile, so that processing can be confined to particular nodes, held back until quiet times of day, or given more of the cluster when it is free.

Both are managed from

{{< stroom-menu "Monitoring" "Node Groups" >}}

and

{{< stroom-menu "Monitoring" "Processor Profiles" >}}

Task creation now takes profiles into account, so tasks that no node is allowed to process are no longer queued, and each profile is given a share of the tasks that are created.

{{% see-also %}}
[Node Groups and Processing Profiles]({{< relref "docs/user-guide/processing-profiles" >}})
{{% /see-also %}}


## Document History and Safe Delete

Stroom now keeps a proper audit trail for every document, recording who changed it and when, along with a snapshot of the document data at each change.

Document dependencies are also now held in the database, which makes it possible to ask what a document depends on and what depends on it.
This powers the new _Safe Delete_ feature, which tells you what would break before you delete something, and shows you what a folder contains before you delete it.

{{% see-also %}}
* [Document History]({{< relref "docs/user-guide/content/document-history" >}})
* [Deleting Content]({{< relref "docs/user-guide/content/deleting-content" >}})
{{% /see-also %}}


## Data Generator

A new _DataGen_ document type sends a defined block of data into a {{< glossary "Feed" >}} on a schedule.
It is intended for generating test data, for example to exercise an analytic rule.

{{% see-also %}}
[Data Generator]({{< relref "docs/reference-section/documents#data-generator" >}})
{{% /see-also %}}


## Tab Sessions

A set of open document tabs can be saved under a name and reopened later, which is useful when you regularly work on the same group of documents, or want to put an investigation down and pick it up again.

Tab sessions are held per user and managed from the _Navigation_ menu, alongside _Find_ and _Recent Items_, using

{{< stroom-menu "Save Tab Session" >}}

{{< stroom-menu "Open Tab Session" >}}

{{< stroom-menu "Delete Tab Session" >}}

Opening a tab session closes the tabs you currently have open, then reopens the saved documents in the order they were saved in.


## Pipeline Editing Improvements

* Pipeline stepping can now step across multiple streams rather than stopping at the end of one.
* When saving a pipeline you can choose which of the changed documents it references are saved with it.
* XSLTs and text converters can be created as documents embedded in the pipeline that uses them, rather than as separate items in the explorer tree.


## Dashboard and Query Functions

Two functions have been added for pulling structured values apart in dashboard and query tables:

* `xpath` - extract a value from an XML string.
* `jq` - extract a value from a JSON string.

The `link` function now accepts a title, and a new XSLT function computes the similarity of two float vectors.


## Search Improvements

* Elasticsearch nested field types are now supported in search.
* Elasticsearch rerank search now supports multiple `dense_vector` fields, and numeric comparators work with `float` and `double` fields.
* The number of dimensions used for vector embedding is now configurable, and optional.


## Sessions and Tokens

Administrators can now see the sessions a user holds and end them, and revoke the tokens issued to that user.
Any user can end all of their own sessions other than the one they are using.

{{% see-also %}}
[Sessions and Tokens]({{< relref "docs/user-guide/security/sessions-and-tokens" >}})
{{% /see-also %}}


## Account Self Service

An account locked by repeated failed sign-ins now unlocks itself after a period rather than needing an administrator, and the 'Forgot password' flow has been rebuilt so that a user can complete a reset from an emailed link.
The three account states, _Enabled_, _Locked_ and _Inactive_, are now independent of one another, each with a single owner.

{{% see-also %}}
* [User Accounts]({{< relref "docs/user-guide/security/user-accounts" >}})
* [Signing In]({{< relref "docs/user-guide/security/signing-in" >}})
* [Breaking Changes]({{< relref "./breaking-changes" >}})
{{% /see-also %}}


## Authenticating Edge Proxies

Stroom can now sit behind a proxy that has already authenticated the user, such as an AWS Application Load Balancer with Cognito, or NGINX with `oauth2-proxy`.
In this arrangement the proxy is the OpenID Connect relying party and Stroom trusts the identity it passes on, rather than running a sign-in flow of its own.

{{% see-also %}}
[Authenticating Edge Proxy]({{< relref "docs/install-guide/setup/open-id/edge-proxy" >}})
{{% /see-also %}}


## Other Authentication Changes

* The signing keys used by the internal identity provider are now rotated automatically, controlled by `stroom.security.identity.token.jwkRotationInterval`.
* Provider specific parameters can be added to the OpenID authentication request using `authenticationRequestExtraParams`, which is how Google is asked for a refresh token.
* An optional `requiredAccessTokenType` setting refuses a token of the wrong type on the API, so that an `id_token` cannot be used in place of an access token.
* The Stroom user interface no longer needs redirects to authenticate, so it can be served from another location by a backend for frontend proxy.

{{% see-also %}}
* [Signing Keys]({{< relref "docs/user-guide/security/signing-keys" >}})
* [Stroom Configuration]({{< relref "docs/install-guide/setup/open-id/external-idp/stroom-configuration" >}})
{{% /see-also %}}


## Visualisation Assets

A Visualisation now has an _Assets_ tab holding the files it is built from, e.g. JavaScript, CSS, HTML and images, in a folder structure that can be edited and uploaded to through the user interface.

{{% see-also %}}
[Visualisation Assets]({{< relref "docs/user-guide/content/visualisation-assets" >}})
{{% /see-also %}}


## Git Repositories

Git repositories can now be given HTTP and TLS configuration, so that Stroom can reach a repository through a proxy or one that presents a private certificate.

{{% see-also %}}
[Git Repo]({{< relref "docs/user-guide/content/git-repo" >}})
{{% /see-also %}}


## Content Index

The content index is no longer rebuilt on first use after a node restarts.
It can now be held locally on each node for performance, or on shared storage, controlled by `stroom.contentIndex.storageType`.


## JSON Parsing Limits

The `JSONParser` pipeline element now streams string values to the downstream elements rather than reading each one into memory, and has new properties to protect Stroom from very large or deeply nested documents.

{{% see-also %}}
* [JSONParser]({{< relref "docs/reference-section/pipeline-elements#jsonparser" >}})
* [Breaking Changes]({{< relref "./breaking-changes" >}})
{{% /see-also %}}


## Smaller Changes

* Multiple instances of the same dashboard can be opened at once.
* A new _System Info_ admin servlet, and a menu of all admin servlets at `<admin port>/<admin path>/menu`.
* Standard annotation comments are now content rather than configuration.
* Annotation history entries are grouped and expandable, and annotation decoration of tables is faster.
* Additional properties on the `S3Appender`.
* Query table customisations can be reset.
* Node selection for node groups supports select all and inverting the selection.
* Editing a document only marks it as needing to be saved once something has actually changed.
