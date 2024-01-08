---
title: "curl (Linux)"
linkTitle: "curl (Linux)"
#weight:
date: 2022-01-13
tags: 
description: >
  How to use the `curl` command to send data to Stroom.

---

Curl is a standard unix tool to send data to or from a server.
In the following examples -H is used to specify the header arguments required by Stroom, see [Header Arguments]({{< relref "header-arguments.md" >}}).

Notes:

* The `@` character must be used in front of the file being posted.
    If it is not then curl will post the file name instead of it's contents.
* The `--data-binary` argument must always be used even for text formats, in order to prevent data corruption by curl stripping out newlines.


## Example HTTPS post without authentication:

{{< command-line "user" "localhost" >}}
curl -k --data-binary @file.dat "https://<Stroom_HOST>/stroom/datafeed" \
-H "Feed:EXAMPLE_FEED" \
-H "System:EXAMPLE_SYSTEM" \
-H "Environment:EXAMPLE_ENVIRONMENT"
{{</ command-line >}}

In the above example -k is required to stop curl from authenticating the server.
The next example must be used to supply the necessary CA to authenticate the server if this is required.


## Example HTTPS With 1 way SSL authentication:

{{< command-line "user" "localhost" >}}
curl --cacert root_ca.crt --data-binary @file.dat "https://<Stroom_HOST>/stroom/datafeed" \
-H "Feed:EXAMPLE_FEED" \
-H "System:EXAMPLE_SYSTEM" \
-H "Environment:EXAMPLE_ENVIRONMENT"
{{</ command-line >}}

The above example verifies that the certificate presented by Stroom is signed by the CA.
The CA is provided to curl using the '--cacert root_ca.crt' parameter.

For step by step instructions for creating, configuring and testing the PKI authentication, see the [SSL Guide]({{< relref "ssl.md" >}})


## Example HTTPS With 2 way SSL authentication:

{{< command-line "user" "localhost" >}}
curl --cert example.pem --cacert root_ca.crt --data-binary @file.dat "https://<Stroom_HOST>/stroom/datafeed" \
-H "Feed:EXAMPLE_FEED" \
-H "System:EXAMPLE_SYSTEM" \
-H "Environment:EXAMPLE_ENVIRONMENT"
{{</ command-line >}}

The above example both verifies that the certificate presented by Stroom is signed by the CA and also provides a certificate to authenticate itself with Stroom.
The data provider provides a certificate using the '--cert example.pem' parameter.

If your input file is not compressed you should compress it as follows:

{{< command-line "user" "localhost" >}}
gzip -c uncompressedfile.dat \
| curl --cert example.pem --cacert root_ca.crt --data-binary @- "https://<Stroom_HOST>/stroom/datafeed" \
-H "Feed:EXAMPLE_FEED" \
-H "System:EXAMPLE_SYSTEM" \
-H "Environment:EXAMPLE_ENVIRONMENT" \
-H "Compression:Gzip"
{{</ command-line >}}

When delivering data from a RHEL4 host, an additional header argument must be added to specify the FQDN of the host:

```bash
-H "Hostname:host.being.audited"
```

The hostname being sent as a header argument may be resolved upon execution using the command `hostname -f`.


## SSL Notes

To create a .pem format key simply append the private key and certifcate.

{{< command-line "user" "localhost" >}}
cat <NAME>.key >> <NAME>.pem
cat <NAME>.crt >> <NAME>.pem
{{</ command-line >}}

To remove the pass phrase from a openssl private key use.

{{< command-line "user" "localhost" >}}
openssl rsa -in server.key -out server-clear.key
{{</ command-line >}}

The `send-logs.sh` script assumes the period start and end times are embedded in the file name (e.g. log_2010-01-01T12:00:00.000Z_2010-01-02T12:00:00.000Z.log).
The certificates will need to be added to the script as above.
