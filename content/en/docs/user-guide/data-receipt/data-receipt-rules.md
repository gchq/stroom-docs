---
title: "Data Receipt Rules"
linkTitle: "Data Receipt Rules"
weight: 10
date: 2026-02-05
tags: 
description: >
  Describes the process of creating Data Receipt Rules to control whether data received by Stroom or Stroom Proxy is Accepted, Rejected or Dropped.
---

Data Receipt Rules serves as an alternative to the legacy feed status checking performed by Stroom Proxy and Stroom.
It provides a much richer mechanism for controlling which received data streams are Received, Rejected or Dropped.
It allows anyone with the _Manage Data Receipt Rules_ Application Permission to create one or more rules to controls the receipt of data.

Data Receipt Rules can be accessed as follows:

{{< stroom-menu "Administration" "Data Receipt Rules" >}}

Each rule is defined by a boolean expression (as used in Dashboards and Stream filtering) and the _Action_ (Receive, Reject, Drop_ that will be performed if the data matches the rule.
Rules are evaluated in ascending order by Rule Number.
The action is taken from the first rule to match.

If no rules match then the data will be rejected by default, i.e. the rules are include rather than exclude filters.
If you want data to be received if no rules match then you can create a rule at the end of the list with an _Action_ of `Receive` and no expression terms.

If a stream matches a rule that has an `Accept` action, it will still be subject to a check to see if the _Feed_ actually exists.
This means that the rules do not need to contain an `Accept` rule to cover all of the Feeds in the system.
They only need to cover 
The client will receive a `101` `Feed is not defined` error if it does not exist.

{{< image "user-guide/data-receipt/ReceiptRules.png" "700x" />}}

The screen operates in a similar way to Data Retention Rules in that rules can be moved up/down to change their importance, or enabled/disabled.


## Fields

The fields available to use in the expression terms can be defined in the _Fields_ tab.
The terms will be evaluated against the stream's meta data, i.e. a combination of the HTTP headers sent by the client and any that have been populated by Stroom Proxy or Stroom.
This allows for the use of custom headers to aid in the filtering of data into Stroom.

{{< image "user-guide/data-receipt/ReceiptRuleFields.png" "300x" />}}

Dictionaries are supported for use with the `in dictionary` condition.
The contents of the dictionary and any of the dictionaries that it inherits will be included in the data fetched by Stroom Proxy.

{{% note %}}
You cannot use the same dictionary for multiple fields if any one of those fields is obfuscated.

Should you need to use the same dictionary for an obfuscated and a non-obfuscated field, you can create one empty dictionary for each and make them both import from the same source dictionary.
{{% /note %}}


## Stroom Configuration

Data Receipt Rules are controlled by the following configuration:

```yaml
appConfig:
  receiptPolicy:
    # List of fields whose values will be obfuscated when the rules
    # are fetched by Stroom Proxy
    obfuscatedFields:
    - "AccountId"
    - "AccountName"
    - "Component"
      # ... truncated
    - "UploadUserId"
    - "UploadUsername"
    - "X-Forwarded-For"
    # The hash algorithm used to hash obfuscated values, one of:
    # * SHA3_256
    # * SHA2_256
    # * BCRYPT
    # * ARGON_2
    # * SHA2_512
    obfuscationHashAlgorithm: "SHA2_512"
    # The initial list of fields to bootstrap a Stroom environment.
    # Changing this has no effect one an environment has been started up.
    receiptRulesInitialFields:
      AccountId: "Text"
      Component: "Text"
      Compression: "Text"
      content-length: "Text"
      # ... truncated
      Type: "Text"
      UploadUsername: "Text"
      UploadUserId: "Text"
      user-agent: "Text"
      X-Forwarded-For: "Text"
  receive:
    # The action to take if there is a problem with the data receipt rules, e.g.
    # Stroom Proxy has been unable to contact Stroom to fetch the rules.
    fallbackReceiveAction: "RECEIVE"
    # The data receipt checking mode, one of:
    # * FEED_STATUS - Use the legacy Feed Status Check method
    # * RECEIPT_POLICY - Use the new Data Receipt Rules
    # * RECEIVE_ALL - Receive ALL data with no checks
    # * DROP_ALL - Drop ALL data with no checks
    # * REJECT_ALL - Reject ALL data with no checks
    receiptCheckMode: "RECEIPT_POLICY"
```


## Stroom Proxy Configuration

```yaml
appConfig:
  receiptPolicy:
    # Only set this if you need to supply a non-standard full url
    # By default Proxy will used the known path for the Data Receipt Rules resource
    # combined with the host/port/scheme from the `downstreamHost` config property.
    receiveDataRulesUrl: null
    # The frequency that the rules will be fetched from the downstream Stroom instance.
    syncFrequency: "PT1M"

  # Identical configuration to Stroom as described above.
  # Stroom and Stroom Proxy can use different `receiptCheckMode` values, but typically
  # they will be the same.
  receiptPolicy:
```


## Stroom Proxy Rule Synchronisation

If Stroom Proxy is configured with `receiptCheckMode` set to `RECEIPT_POLICY` and has `downstreamHost` configured, then it will periodically send a request to Stroom to fetch the latest copy of the Data Receipt Rules.
If Stroom Proxy is unable to contact Stroom it will use the latest copy of the rules that it has.

Given that Stroom Proxy will only synchronise periodically, once a change is made to the rule set, there will be a delay before the new rules take effect.


### Term Value Obfuscation

As a Stroom administrator you may not want the values used in the Data Receipt Rule expression terms to be visible when they are fetched by a remote Stroom Proxy (that may be maintained by another team).
It is therefore possible to obfuscate the values used for the expression terms for certain configured fields.
The fields that are obfuscated are controlled by the property `stroom.receiptPolicy.obfuscatedFields`.

For example, in the default configuration, `Feed` is an obfuscated field.
Thus a term like `Feed != FEED_XYZ` would have its value obfuscated when fetched by Stroom Proxy.
Stroom Proxy is able to similarly obfuscated meta data values for obfuscated fields in the same way to allow it to test the rule expression.

{{% warning %}}
Due to the way obfuscation works, you are limited by the expression conditions that can be used, e.g. `contains`, `>`, `<` etc. are not allowed, but `==` and `!=` are.
Stroom will tell you if you are using an unsupported condition for the field.
{{% /warning %}}

This prevents the Stroom Proxy administrator from being able to see the values used in the rules as they are not in plain text.
Each value is salted with its own unique salt then hashed.
The hash algorithm can be configured using `stroom.receiptPolicy.obfuscationHashAlgorithm`.

{{% note %}}
Obfuscation is not encryption.
The fetched data includes the salt values and given enough compute/time it would be possible to brute force the reversal of the hashing.
Strong hashing algorithms such as BCrypt or Argon2 can mitigate against this but not remove the risk.
If the rule values are too sensitive then you will have to let the Stroom Proxy accept the data and have Stroom do the full rule based checking.
{{% /note %}}
