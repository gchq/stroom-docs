---
title: "SSL Configuration"
linkTitle: "SSL Configuration"
weight: 60
date: 2021-07-27
tags: 
description: >
  Configuring SSL with cURL.
---

This page provides a step by step guide to getting PKI authentication working correctly for Unix hosts so as to be able to sign deliveries from cURL.

First make sure you have a copy of your organisations CA certificate.

Check that the CA certificate works by running the following command:

```bash
echo "Test" | curl --cacert CA.crt --data-binary @- "https://<Stroom_HOST>/stroom/datafeed"
```

If the response starts with the line:

```bash
curl: (60) SSL certificate problem, verify that the CA cert is OK.
```

then you do not have the correct CA certificate.

If the response contains the line

```bash
HTTP Status 406 - Stroom Status 100 - Feed must be specified
```

then one-way SSL authentication using the CA certificate is successful.

The VBScript file to check windows certificates is `check-certs.vbs` (TODO link).

#Final Testing

Once one-way authentication has been tested, two-way authentication should be configured:

The server certificate and private key should be concatenated to create a PEM file:

```bash
cat hostname.cert hostname.key > hostname.pem
```

Finally, test for 2-way authentication:

```bash
echo "Test" | curl --cacert CA.crt --cert hostname.pem --data-binary @- "https://<Stroom_HOST>/stroom/datafeed"
```

If the response contains the line

```bash
HTTP Status 406 - Stroom Status 100 - Feed must be specified
```

then two-way SSL authentication is successful.

#Final Tidy Up

The files `ca.crt` and `hostname.pem` are the only files required for two-way authentication and should be stored permanently on the server; all other remaining files may be deleted or backed up if required.

#Certificate Expiry

PKI certificates expire after 2 years.  To check the expiry date of a certificate, run the following command:

```bash
openssl x509 -in /path/to/certificate.pem -noout -enddate
```

This will give a response looking similar to:

```bash
notAfter=Aug 15 10:01:42 2013 GMT
```
