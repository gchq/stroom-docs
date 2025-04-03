---
title: "Preview Features (experimental)"
linkTitle: "Preview Features"
weight: 20
date: 2025-04-01
tags: 
description: >
  Preview features in Stroom version 7.9.
  Preview features are somewhat experimental in nature and are therefore subject to breaking changes in future releases.
---

## Data Feed Keys

Data Feed Keys are a new authentication mechanism for data receipt into both Stroom-Proxy and Stroom.
They allow for a set of hashed short life keys to be placed in a directory accessible to Stroom-Proxy/Stroom for receipt requests to be authenticated against.

The following is an example of a Data Feed Key file:

```json
{
  "dataFeedKeys" : [ {
    "expiryDateEpochMs" : 1744279266584,
    "hash" : "4KP8qRFigfKHAMQgWVHCvgXtf293wsETMwWbaUJcgC2JSqP6qF1YHacyUe8C7CrAAa",
    "hashAlgorithmId" : "000",
    "streamMetaData" : {
      "AccountId" : "1000",
      "MetaKey2" : "MetaKey2Val-1000",
      "MetaKey1" : "MetaKey1Val-1000"
    }
  }, {
    "expiryDateEpochMs" : 1744279266584,
    "hash" : "8U7roYFWcj3Ht8cGbAavemQPm2P93xEC9QnvdUCuth4EKmbvEjVM2NWje1bPkKWx7s",
    "hashAlgorithmId" : "000",
    "streamMetaData" : {
      "AccountId" : "1001",
      "MetaKey2" : "MetaKey2Val-1001",
      "MetaKey1" : "MetaKey1Val-1001"
    }
  }
}
```

A file can contain many hashed keys.
One or more files of this format are placed in the directory defined by the Stroom-Proxy/Stroom config property `.receive.dataFeedKeysDir`.
This allows for generating Data Feed Keys with a life of say 26hrs, adding a new file every day and deleting files older than 2 days.

The file(s) will be read on boot and all hashed keys will be stored in memory for receipt authentication.
Files added to this directory while Stoom-Proxy/Stroom is running will be read and added to the in-memory store of hashed keys.
Files deleted from this directory will result in all entries associated with the file path being removed from the in-memory store of hashed keys.

The `accountId` is typically an identifier for a client team that may have one or more systems that require one or more Feeds in Stroom.
This JSON key, which identifies the ownership of the Data Feed Key, is configured via the property `.receive.dataFeedKeyOwnerMetaKey`.

Data Feed Keys have an expiry date after which they will no longer work.
An `accountID` can have many active Data Feed Keys.
Multiple files can be placed in the directory and all valid keys will be loaded.

The `hashAlgorithmId` is the identifier for the hash algorithm used to hash the key.
The system creating the hashed data feed keys must use the same hash algorithm and parameters when hashing the key as Stroom will use when it hashes the key used in data receipt to validate them.

`streamMetaData` provides a means to add meta attributes to data received with a Data Feed Key.
The attributes in `streamMetaData` will overwrite any matching attribute keys in the received data.

Currently the only hash algorithm available for use is Argon2 with an ID of `000` and the following parameters:

* Hash length: 48
* Iterations: 2
* Memory KB: 65536

A Data Feed Key takes the following form:

```text
sdk_<3 char hash algorithm ID>_<128 char random Base58 string>
```

The regular expression pattern for a Data Feed Key is

```regex
^sdk_[0-9]{3}_[A-HJ-NP-Za-km-z1-9]{128}$
```

Data Feed Keys are used in the same way as API Keys or OAuth2 tokens, i.e. using the Header `Authorization: Bearer <data feed key>`.


## Content Auto-Generation

In an effort to streamline the process of getting client systems to send data to Stroom we have added auto-generation of content and removed the need to supply a feed name.
The aim is that client systems can provide a number of mandatory headers with their data that will then be used to auto-generate a feed name, create the feed and create content from a template to process that feed's data.

{{% note %}}
This feature is optional and controlled with configuration.
If not enabled, the Feed header will be mandatory as before.
{{% /note %}}

The default Stroom configuration for controlling Data Feed Keys, auto content creation and feed name generation is:

```yaml
appConfig:

  autoContentCreation:
    additionalGroupTemplate: "grp-${accountid}-sandbox"
    createAsSubjectId: "Administrators"
    createAsType: "GROUP"
    destinationExplorerPathTemplate: "/Feeds/${accountid}"
    enabled: false
    groupTemplate: "grp-${accountid}"
    templateMatchFields:
    - "accountid"
    - "accountname"
    - "component"
    - "feed"
    - "format"
    - "schema"
    - "schemaversion"

  receive: # applicable to both appConfig: and proxyConfig:
    allowedCertificateProviders: []
    authenticatedDataFeedKeyCache:
      #...
    authenticationRequired: true
    dataFeedKeyOwnerMetaKey: "AccountId"
    dataFeedKeysDir: "data_feed_keys"
    enabledAuthenticationTypes: # Also DATA_FEED_KEY and TOKEN
    - "CERTIFICATE"
    feedNameGenerationEnabled: false
    feedNameGenerationMandatoryHeaders:
    - "AccountId"
    - "Component"
    - "Format"
    - "Schema"
    feedNameTemplate: "${accountid}-${component}-${format}-${schema}"
    metaTypes:
      # ...
```


### Feed Name Generation

When the property `.receive.feedNameGenerationEnabled` is set to `true`, the `Feed` header is no longer required.
Instead the meta keys specified in `.receive.feedNameGenerationMandatoryHeaders` become mandatory.
The property `.receive.feedNameTemplate` is used to control the format of the generated Feed name.
The template uses values from the headers, so should be configured in tandem with `.receive.feedNameGenerationMandatoryHeaders`.
If the template parameter is not in the headers, then it will be replaced with nothing.

If enabled, Feed name generation happens on data receipt in both Stroom-Proxy and Stroom.


### Feed and Group Creation

The `.autoContentCreation.enabled` property controls whether auto-generation of content will take place on data receipt.
Content auto-generation happens as part of the feed status check, so will either be triggered when Stroom-Proxy requests a feed status check from Stroom or Stroom receives data directly.

If the generated Feed name does not exist then it will be created in the explorer path as defined by the template in `.receive.destinationExplorerPathTemplate`.
If the Feed name does exist then no further content creation will happen.

One or two user groups will be created and be granted permissions on the created content.
This is to provide user groups for users of the client system to be able to access the data.
The name of these groups is controlled by `groupTemplate` and `additionalGroupTemplate` respectively.

The former group only has `VIEW` permission, while the latter has `EDIT` permission on the created content.
The latter group is intended for clients to be able to manage the translation of their data while it is going through a take-on-work style process.

If the `/datafeed` request was authenticated (e.g. using a token, certificate, API key or Data Feed Key) then the identifier of the subject will be set in the `UploadUserId` header.
It will also ensure that a user exists in Stroom for this identity and that the user is added to the two groups created above.


### Content Templates

In Stroom a new Content Templates screen has been added, accessible from the menu.

{{< stroom-menu "Administration" "Content Templates" >}}

{{< image "releases/07.09/ContentTemplates.png" "900x" >}}The Content Templates screen{{</ image >}}

This screen allows a user with the `Manage Content Templates` application permission to create a number of content templates.
Each template has an expression that will be used to match on the headers when auto-generation of content has been triggered.
The template expressions are evaluated in order from the top.

If a template's expression matches, content will be created according to the template.
A template currently has two modes:

* `INHERIT_PIPELINE` - A new pipeline will be created that inherits from the existing pipeline specified in the template.
  The new pipeline will be created in the folder defined by `.receive.destinationExplorerPathTemplate`.
* `PROCESSOR_FILTER` - A new processor filter will be added to the existing pipeline specified in the template.


