---
title: "Data Feed Identities"
linkTitle: "Data Feed Identities"
weight: 50
date: 2026-02-05
tags: 
description: >
  Data Feed Identities is an authentication mechanism designed specifically for the `/datafeed` API.
---

Data Feed Identities are a new authentication mechanism for data receipt into both Stroom-Proxy and Stroom.
It combines a set of authentication identities with a pre-defined set of static meta entries.



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
Files added to this directory while Stroom-Proxy/Stroom is running will be read and added to the in-memory store of hashed keys.
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


