---
title: "SSL Configuration"
linkTitle: "SSL Configuration"
weight: 50
date: 2021-07-27
tags: 
description: >
  Configuring SSL with cURL.
---

This page provides a step by step guide to getting PKI authentication working correctly for Unix hosts so as to be able to sign deliveries from cURL.

First make sure you have a copy of your organisation's CA certificate.

Check that the CA certificate works by running the following command:

{{< command-line >}}
echo "Test" | curl --cacert CA.crt --data-binary @- "https://<Stroom_HOST>/stroom/datafeed"
{{< /command-line >}}

If the response starts with the line:

{{< command-line >}}
(out) (60) SSL certificate problem, verify that the CA cert is OK.
{{< /command-line >}}

then you do not have the correct CA certificate.

If the response contains the line

{{< command-line >}}
(out) HTTP Status 406 - Stroom Status 100 - Feed must be specified
{{< /command-line >}}

then one-way SSL authentication using the CA certificate is successful.

The VBScript file to check windows certificates is `check-certs.vbs` (TODO link).

## Final Testing

Once one-way authentication has been tested, two-way authentication should be configured:

The server certificate and private key should be concatenated to create a PEM file:

{{< command-line >}}
cat hostname.cert hostname.key > hostname.pem
{{< /command-line >}}

Finally, test for 2-way authentication:

{{< command-line >}}
echo "Test" | curl --cacert CA.crt --cert hostname.pem --data-binary @- "https://<Stroom_HOST>/stroom/datafeed"
{{< /command-line >}}

If the response contains the line

{{< command-line >}}
(out) HTTP Status 406 - Stroom Status 100 - Feed must be specified
{{< /command-line >}}

then two-way SSL authentication is successful.

## Final Tidy Up

The files `ca.crt` and `hostname.pem` are the only files required for two-way authentication and should be stored permanently on the server; all other remaining files may be deleted or backed up if required.

## Certificate Expiry

PKI certificates expire after 2 years. To check the expiry date of a certificate, run the following command:

{{< command-line >}}
openssl x509 -in /path/to/certificate.pem -noout -enddate
{{< /command-line >}}

This will give a response looking similar to:

{{< command-line >}}
(out) notAfter=Aug 15 10:01:42 2013 GMT
{{< /command-line >}}
