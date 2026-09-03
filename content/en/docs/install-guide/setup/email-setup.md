---
title: "Email Setup"
linkTitle: "Email Setup"
weight: 60
date: 2026-09-02
tags:
  - analytic
  - report
description: >
  Configuring the SMTP server that Stroom uses to send Analytic Rule and Report emails.
---

Stroom sends email for two things, [Analytic Rule]({{< relref "docs/user-guide/search/analytics" >}}) {{< stroom-icon "document/AnalyticRule.svg" >}} notifications and [Report]({{< relref "docs/user-guide/search/reports" >}}) {{< stroom-icon "document/Report.svg" >}} delivery.
Neither will work until an SMTP server has been configured.

This step is only needed if you intend to use email notifications.
An installation whose rules only write detections to a {{< glossary "Feed" >}} does not need it.

{{% note %}}
There is no email configuration in the user interface.
It is set in `config.yml` and applies to the whole installation, so rule authors cannot configure it themselves.
{{% /note %}}


## Configuration

Email is configured under the `appConfig.analytics.emailConfig` branch.

```yaml
appConfig:
  analytics:
    emailConfig:
      fromAddress: "noreply@stroom"
      fromName: "Stroom Analytics"
      smtp:
        host: "localhost"
        port: 2525
        transport: "plain"
        username: null
        password: null
```

Property      | Description
------------- | ------------
`fromAddress` | The address that Stroom sends from, and that replies will go to.
`fromName`    | The display name shown against the from address.
`host`        | The {{< glossary "FQDN" >}} of the SMTP server.
`port`        | The port of the SMTP server.
`transport`   | How Stroom talks to the SMTP server, see below.
`username`    | The user to authenticate as, or `null` for an unauthenticated server.
`password`    | The password to authenticate with, or `null` for an unauthenticated server.

The from address and name are set here rather than on each rule, so every email Stroom sends comes from the same place.
It is worth choosing an address that is monitored, or one that makes clear that replies will not be read.


### Transport

Value   | Meaning
------- | --------
`plain` | Plain SMTP with no transport security. This is the default.
`TLS`   | SMTP over TLS.
`SSL`   | SMTP over TLS. Treated identically to `TLS`.

{{% warning %}}
Any value other than `TLS` or `SSL` is treated as `plain`, including a misspelling.
A typo here will silently send mail unencrypted rather than failing, so it is worth confirming the setting took effect by checking the traffic or the mail server's logs.
{{% /warning %}}


## Testing

The quickest way to confirm the configuration works is from a rule rather than from the server.

1. Open or create an Analytic Rule {{< stroom-icon "document/AnalyticRule.svg" >}}.
1. On the _Notifications_ tab, add a notification with a _Destination Type_ of `Email` and put your own address in the _To_ field.
1. Click _Send Test Email_.

This sends an example detection through the whole path, so a message arriving proves the SMTP settings, the from address and the templates all work.

Where it fails, the error is reported in the user interface.
Errors from real rule executions go to the rule's error feed instead.

{{% see-also %}}
[Rule Notifications]({{< relref "docs/user-guide/search/analytics/notifications" >}})
[Report Delivery]({{< relref "docs/user-guide/search/reports/delivery" >}})
[Stroom Configuration]({{< relref "docs/install-guide/configuration/stroom-and-proxy/configuring-stroom#analytics" >}})
{{% /see-also %}}
