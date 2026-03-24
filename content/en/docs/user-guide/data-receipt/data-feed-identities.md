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

There are currently two types of Data Feed Identities:

* Data Feed Keys - Similar to an API Key.
* Certificate Identities - Uses an X509 Distinguished Name for authentication.

Both types of identity are written to one or more files that are placed on the Stroom or Stroom Proxy Host in a directory configured by `.receive.dataFeedIdentitiesDir`.

The following is an example of a file containing one of each type:

```json
{
  "dataFeedIdentities" : [ {
    "type" : "DATA_FEED_KEY",
    "expiryDateEpochMs" : 1775237109581,
    "hash" : "$2a$10$JdngdVGxg6RGBeerku.JNusZdyyh4rNHYN5UeNKXRVdNUSNbg3NP6",
    "hashAlgorithm" : "BCRYPT_2A",
    "salt" : "$2a$10$JdngdVGxg6RGBeerku.JNu",
    "streamMetaData" : {
      "AccountId" : "1000",
      "MetaKey2" : "MetaKey2Val-1000",
      "MetaKey1" : "MetaKey1Val-1000"
    }
  }, {
    "type" : "CERTIFICATE_DN",
    "certificateDn" : "/DC=com/DC=example/DC=corp/OU=Users/CN=John Doe 2/emailAddress=john_doe@example.com",
    "expiryDateEpochMs" : 1775237109581,
    "streamMetaData" : {
      "AccountId" : "2002",
      "MetaKey2" : "MetaKey2Val-2002",
      "MetaKey1" : "MetaKey1Val-2002"
    }
  } ]
}
```

The file can contain zero-many of either type and the directory can contain zero-many of these files.
This allows for generating Data Feed Keys with a life of say 26hrs, adding a new file every day and deleting files older than 2 days.

The file(s) will be read on boot and all hashed keys will be stored in memory for receipt authentication.
Files added to this directory while Stroom-Proxy/Stroom is running will be read and added to the in-memory store of hashed keys.
Files deleted from this directory will result in all entries associated with the file path being removed from the in-memory store of hashed keys.


### Common properties

The following JSON properties are common to both types:

* `type` - The type of the identity, one of (`DATA_FEED_KEY`|`CERTIFICATE_DN`).

* `expiryDateEpochMs` - The time the identity expires expressed as milliseconds since the epoch.

* `streamMetaData` - A map of Meta key/value pairs to set on the Stream's Meta Data on receipt.
  The attributes in `streamMetaData` will overwrite any matching attribute keys in the received data.

The property `.receive.dataFeedOwnerMetaKey` defines the Meta key that will be used to extract the owner of the Data Feed Identity.
By default this key is set to `accountId`.
It is typically an identifier for a client team that may have one or more systems that require one or more Feeds in Stroom.
An `accountID` can have many active Data Feed Identities.


## Data Feed Keys

They allow for a set of hashed short life keys to be placed in a directory accessible to Stroom-Proxy/Stroom for receipt requests to be authenticated against.

```json
{
  "type" : "DATA_FEED_KEY",
  "expiryDateEpochMs" : 1775237109581,
  "hash" : "$2a$10$JdngdVGxg6RGBeerku.JNusZdyyh4rNHYN5UeNKXRVdNUSNbg3NP6",
  "hashAlgorithm" : "BCRYPT_2A",
  "salt" : "$2a$10$JdngdVGxg6RGBeerku.JNu",
  "streamMetaData" : {
    "AccountId" : "1000",
    "MetaKey2" : "MetaKey2Val-1000",
    "MetaKey1" : "MetaKey1Val-1000"
  }
}
```

`type` must always be `DATA_FEED_KEY` for a Data Feed Key.

Data Feed Identities have an expiry date after which they will no longer work.
Multiple files can be placed in the directory and all valid keys will be loaded.

The `hashAlgorithmId` is the identifier for the hash algorithm used to hash the key.
The system creating the hashed data feed keys must use the same hash algorithm and parameters when hashing the key as Stroom will use when it hashes the key used in data receipt to validate them.

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

Data Feed Identities are used in the same way as API Keys or OAuth2 tokens, i.e. using the Header `Authorization: Bearer <data feed key>`.


### Certificate Identities

These identities allow client systems to authenticate with an X509 certificate.
Typically the TLS will be terminated by an Nginx or load balancer sitting in front of Stroom/Stroom-Proxy, and it will pass the DN as a header (configured by `.receive.x509CertificateDnHeader`).

```json
{
  "type" : "CERTIFICATE_DN",
  "certificateDn" : "/DC=com/DC=example/DC=corp/OU=Users/CN=John Doe 2/emailAddress=john_doe@example.com",
  "expiryDateEpochMs" : 1775237109581,
  "streamMetaData" : {
    "AccountId" : "2002",
    "MetaKey2" : "MetaKey2Val-2002",
    "MetaKey1" : "MetaKey1Val-2002"
  }
}
```

`type` must always be `CERTIFICATE_DN` for a Certificate Identity.

`certificateDn` is the certificate's DN (Distinguished Name) in the format defined by `.receive.x509CertificateDnFormat`.

When a client sends data, the DN extracted from the header will be checked against all the DNs in the Certificate Identities.
If one matches and is not expired, it will authenticate using the owner and set the Meta entries using `streamMetaData`.

