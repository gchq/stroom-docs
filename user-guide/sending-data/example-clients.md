# Example Clients
The following article provides examples to help data providers send data to Stroom via the HTTPS interface. The code for the clients is in the `stroom-clients` repository (TODO link).

## UNIX (using curl)
Curl is a standard unix tool to send data to or from a server. In the following examples -H is used to specify the header arguments required by Stroom, see [Header Arguments](header-arguments.html).

Notes:

* The @ character must be used in front of the file being posted. If it is not then curl will post the file name instead of it's contents.
* The --data-binary argument must always be used even for text formats, in order to prevent data corruption by curl stripping out newlines.

### Example HTTPS post without authentication:

```bash
curl -k --data-binary @file.dat "https://<Stroom_HOST>/stroom/datafeed"
        -H "Feed:EXAMPLE_FEED"
        -H "System:EXAMPLE_SYSTEM"
        -H "Environment:EXAMPLE_ENVIRONMENT"
```

In the above example -k is required to stop curl from authenticating the server. The next example must be used to supply the necessary CA to authenticate the server if this is required.

### Example HTTPS With 1 way SSL authentication:

```bash
curl --cacert root_ca.crt --data-binary @file.dat "https://<Stroom_HOST>/stroom/datafeed"
        -H "Feed:EXAMPLE_FEED"
        -H "System:EXAMPLE_SYSTEM"
        -H "Environment:EXAMPLE_ENVIRONMENT"
```

The above example verifies that the certificate presented by Stroom is signed by the CA. The CA is provided to curl using the '--cacert root_ca.crt' parameter.

For step by step instructions for creating, configuring and testing the PKI authentication, see the [SSL Guide](ssl.html)

### Example HTTPS With 2 way SSL authentication:

```bash
curl --cert example.pem --cacert root_ca.crt --data-binary @file.dat "https://<Stroom_HOST>/stroom/datafeed"
        -H "Feed:EXAMPLE_FEED"
        -H "System:EXAMPLE_SYSTEM"
        -H "Environment:EXAMPLE_ENVIRONMENT"
```

The above example both verifies that the certificate presented by Stroom is signed by the CA and also provides a certificate to authenticate itself with Stroom. The data provider provides a certificate using the '--cert example.pem' parameter.

If your input file is not compressed you should compress it as follows:

```bash
gzip -c uncompressedfile.dat | curl --cert example.pem --cacert root_ca.crt --data-binary @- "https://<Stroom_HOST>/stroom/datafeed"
	        -H "Feed:EXAMPLE_FEED"
	        -H "System:EXAMPLE_SYSTEM"
	        -H "Environment:EXAMPLE_ENVIRONMENT"
	        -H "Compression:Gzip"
```

When delivering data from a RHEL4 host, an additional header argument must be added to specify the FQDN of the host:

```bash
-H "Hostname:host.being.audited"
```

The hostname being sent as a header argument may be resolved upon execution using the command **hostname -f**.

### SSL Notes

To create a .pem format key simply append the private key and certifcate.

```bash
cat <NAME>.key >> <NAME>.pem
cat <NAME>.crt >> <NAME>.pem
```

To remove the pass phrase from a openssl private key use.

```bash
openssl rsa -in server.key -out server-clear.key
```

The `send-logs.sh` script assumes the period start and end times are embedded in the file name (e.g. log_2010-01-01T12:00:00.000Z_2010-01-02T12:00:00.000Z.log).  The certificates will need to be added to the script as above.

## Windows
### Using wget
There is a version of wget for windows

* Use --post-file argument to supply the data
* Use --certificate and --certificate-type arguments to specify your client certificate
* Use --header argument to inform Stroom which feed and environment your data relates to

### Using curl
There is a version of curl for Windows

*Note: We haven't tried using this so if anybody would like to have a go and provide documentation for this section please do.*

### Using VBScript
`extract-data.vbs` uses wevtutil.exe to extract **Security** event information from the windows event log.  This script has been tested on Windows 2008.

This script is designed to run periodically (say every 10 minutes).  The first time the script is run it stores the current time in UTC format in the registry.  Subsequent calls then extract event information from the last run time to the new current time.  The events are stored in a zip file with the period dates embedded.

The script requires a working directory used as a buffer for the zip files.  This can be set at the start of the script otherwise it will default to the working directory.

The `send-data.vbs` script is designed to run periodically (say every 10 minutes). The script will scan for zip files and send them to Stroom.

The script details several parameters that require setting per environment. Among these are the working directory that the zip files are stored in, the feed name and the URL of Stroom.

#### SSL
To send data over SSL (https) you must import a client certificate in p12 format into windows.  
To convert a certificate (.crt) and private key (.key) into a p12 format use the following command:

```bash
openssl pkcs12 -export -in <NAME>.crt -inkey <NAME>.key -out <NAME>.p12 -name "<NAME>"
```

Once in p12 format use the windows certificate wizard to import the public private key.

The `send-data-tree.vbs` script works through a directory for different feed types.  

### Using Java
The `stroom-java-client` provides an example Java client that can:

* Read a zip, gzip or uncompressed an input file.
* Perform a HTTP post of data with zip, gzip or uncompressed compression.
* Pass down arguments on the command line as HTTP request arguments.
* Supports HTTP and HTTPS with 1 or 2 way authentication.

*(N.B. arguments must be in lower case).*

To use the example client first compile the Java code:

```bash
javac DataFeedClient.java
```

#### Example HTTP Post:

```bash
java -classpath . DataFeedClient inputfile=datafeed url=http://<Stroom_HOST>/stroom/datafeed system=EXAMPLE-SYSTEM environment=DEV feed=EXAMPLE-FEED
```

#### Example HTTPS With 1 way SSL authentication:

```bash
java -classpath . -Djavax.net.ssl.trustStore=ca.jks -Djavax.net.ssl.trustStorePassword=capass DataFeedClient inputfile=datafeed url=https://<Stroom_HOST>/stroom/datafeed system=EXAMPLE-SYSTEM environment=DEV feed=EXAMPLE-FEED
```

#### Example HTTPS With 2 way SSL authentication:

```bash
java -classpath . -Djavax.net.ssl.trustStore=ca.jks -Djavax.net.ssl.trustStorePassword=capass -Djavax.net.ssl.keyStore=example.jks -Djavax.net.ssl.keyStorePassword=<PASSWORD> DataFeedClient inputfile=datafeed url=https://<Stroom_HOST>/stroom/datafeed system=EXAMPLE-SYSTEM environment=DEV feed=EXAMPLE-FEED
```

### Using C*#*

The `StroomCSharpClient` is a C# port of the Java client and behaves in the same way. Note that this is just an example, not a fully functional client.
