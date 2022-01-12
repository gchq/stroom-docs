---
title: "Setting up releases to Sonatype & Maven Central"
linkTitle: "Setting up Sonatype"
#weight:
date: 2021-11-05
tags: 
description: >
  This is a rough guide to what was done to set it up.  Some bits may be missing.
---

## Create a Sonatype account

You need to create an account on Sonatype and you will need to raise a jira ticket on Sonatype's jira to get approved on the uk.gov.gchq group.
This will require an existing user approved for the group to approve you on the ticket.


## Setting up a GPG key

You can use the following commands for setting up a GPG2 key for signing.

```bash
# Generate the GPG2 key
gpg2 --gen-key

# To list all keys
gpg2 --list-keys

# To get the key ID
gpg2  --list-secret-keys | grep "\[SC\]" | tr -s ' ' | cut -d' ' -f2 | cut -d'/' -f2

# To send the public keys to a key server
gpg2 --keyserver hkp://pool.sks-keyservers.net --send-keys <key id>
gpg2 --keyserver hkp://keyserver.ubuntu.com --send-keys <key id>
gpg2 --keyserver hkp://pgp.mit.edu --send-keys <key id>

# To display the secret key in base64 form, for use in GH actions
key="$(gpg2 --armor --export-secret-keys <key id> | base64 -w0)"; echo -e "-------\n$key\n-------"; key=""
```

## Setting up the gradle build

The signing and release to Sonatype is done by various gradle plugins.

```groovy
id "io.github.gradle-nexus.publish-plugin" version "1.0.0"
id "signing"
id "maven-publish"
```

See the _root_ and _event-logging-api_ gradle build files (in the _event-logging_ repo) for an example of how to set up gradle.

The credentials can be passed to the gradle build using special gradle env vars [Project Properties (external)](https://docs.gradle.org/current/userguide/build_environment.html#sec:project_properties).
The credentials required are:

* `ORG_GRADLE_PROJECT_SIGNINGKEY` - The key as produced by the `gpg2 --armor` command.
* `ORG_GRADLE_PROJECT_SIGNINGPASSWORD` - The password for the GPG key.
* `ORG_GRADLE_PROJECT_SONATYPEUSERNAME` - The account username on Sonatype.
* `ORG_GRADLE_PROJECT_SONATYPEPASSWORD` - The account password on Sonatype.


## Setting up Github Actions

You will need to provide Github with the four secrets listed above by setting them as repository secrets at https://github.com/gchq/<repo>/settings/secrets/actions.
For each one create a secret with the `ORG_GRADLE_...` bit as the name.

So that the action can create the Github release you will also need to set up an SSH key pair and provide it with the public and private key.
To generate the key pair do:

```bash
ssh-keygen -t rsa -b 4096 -f <repo>_deploy_key
```

The key pair will be created in `~/.ssh/`.

Create a repo deploy key with the public key, named 'Actions Deploy Key' and with write access at https://github.com/<namespace>/<repo>/settings/keys/new.
Create a repo secret with the private key, named 'SSH_DEPLOY_KEY' at https://github.com/<namespace>/<repo>/settings/secrets/actions/new.

