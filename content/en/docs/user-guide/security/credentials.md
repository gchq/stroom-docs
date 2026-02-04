---
title: "Credentials"
linkTitle: "Credentials"
weight: 20
date: 2026-01-16
tags:
description: >
  Authentication against other systems.
---

Sometimes Stroom needs to connect to other systems:

- Git repositories
- Stroom AI connections
- In the future, all credentials for third-party systems will be managed by this user-interface.

The Credentials module is intended to centralise the management of these
credentials within Stroom.


## Accessing Credentials Manager

The Credentials Manager can be accessed via the Stroom Menu {{< stroom-icon "menu.svg" >}} Security / Credentials Manager.


## Types of Credentials

Stroom supports different types of credentials.
Different systems can use different types of credentials.

| User          | Username / Password        | Access Token                | SSH Key                    | Key Store                  | 
|---------------|----------------------------|-----------------------------|----------------------------|----------------------------|
| GitRepo       | {{< stroom-icon ok.svg >}} | {{< stroom-icon ok.svg >}}  | {{< stroom-icon ok.svg >}} |                            |
| Content Store | {{< stroom-icon ok.svg >}} | {{< stroom-icon ok.svg >}}  | {{< stroom-icon ok.svg >}} |                            |
| Stroom AI     |                            |                             |                            | {{< stroom-icon ok.svg >}} |


### Username / Password

The username and password are passed to the server unchanged.


### Access Token

This is a variation of username / password authentication.
Stroom will pass the token in place of the password.


### SSH Key

This is used when connecting to SSH servers.
SSH authentication is not intuitive, thus the basics are explained here.

The user generates a key pair.
The public part of the key pair is given to the SSH server, via the command line `ssh-copy-id` command or via an application-specific web user-interface.
The private part is stored on the user's machine and is secured via a pass-phrase.
The pass-phrase ensures that if an attacker gains access to the user's file they cannot access the private key.

Thus Stroom needs to know the private key and the pass-phrase.

There is one more key pair involved.
It is important that the client is confident that they are connecting to the correct SSH server.
Otherwise, an attacker might trick the user into connecting to the wrong server.
This is secured by the server's key pair.
The server has a private key and allows the client to download the server's public key.

Stroom can optionally check the server's key, if the server's public key is provided.
If no key is provided then Stroom will accept any server.
This can be useful when getting things working but is not recommended for production use.
To enable this setting, check {{< stroom-icon "ok.svg" >}} the checkbox "Verify Hosts" and add the entry from your `~/.ssh/known_hosts` file.

{{% note %}}
Note that some systems hash the values in `~/.ssh/known_hosts`.
This format is not currently supported.
{{% /note %}}


### Key Store

Create a key store in {{< external-link "JKS" "https://docs.oracle.com/cd/E19509-01/820-3503/ggfen/index.html" >}} or {{< external-link "PXCS12" "https://docs.oracle.com/cd/E19509-01/820-3503/ggfhb/index.html" >}} format.


#### Key Store Type

Stroom supports these two keystore formats:

JKS
: Original Java keystore format.

PKCS12
: Standardised format, developed by RSA, which stores cryptography objects in a single file.


#### Key Store Pass Phrase

The keystore should be protected by a pass-phrase.
Stroom needs this pass-phrase to read the keystore.


#### Upload Key Store File

Select the keystore and upload it to enter it into Stroom.