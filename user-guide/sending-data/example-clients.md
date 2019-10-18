# Example Clients
The following article provides examples to help data providers send data to Stroom via the HTTPS interface. The code for the clients is in the _stroom-clients_ repository [stroom-clients](https://github.com/gchq/stroom-clients).

## Using Docker
[stroom-log-sender](https://hub.docker.com/r/gchq/stroom-log-sender/) is a small Docker image for sending data to _stroom_. 
This is the simplest way to get data into stroom if the data provider is itself running in docker. 
It can also be used for sending data to _stroom_ from data providers that are not running in Docker.
_stroom-log-sender_ makes use of the _send_to_stroom.sh_ bash script that is described below.
For details on how to use _stroom-log-sender_, see the Dockerhub link above.

## UNIX (using send_to_stroom.sh)
[send_to_stroom.sh](https://github.com/gchq/stroom-clients/releases) is a small bash script to make it easier to send data to _stroom_. To use it download the following files using wget or similar, replacing `SEND_TO_STROOM_VER` with the latest released version from [here](https://github.com/gchq/stroom-clients/releases):

``` bash
SEND_TO_STROOM_VER="send-to-stroom-v2.0" && \
    wget "https://raw.githubusercontent.com/gchq/stroom-clients/${SEND_TO_STROOM_VER}/bash/send_to_stroom.sh" && \
    wget "https://raw.githubusercontent.com/gchq/stroom-clients/${SEND_TO_STROOM_VER}/bash/send_to_stroom_args.sh" && \
    chmod u+x send_to_stroom*.sh
```

To see the help for _send_to_stroom.sh_, enter `./send_to_stroom.sh --help`

The following is an example of using _send_to_stroom.sh_ to send all logs in a directory:

``` bash
./send_to_stroom.sh \
    --delete-after-sending \
    --file-regex ".*/access-[0-9]+.*\.log(\.gz)?$" \
    --key ./client..key \
    --cert ./client.pem.crt \
    --cacert ./ca.pem.crt \
    /some_directory/logs \
    MY_FEED \
    MY_SYSTEM \
    DEV \
    https://stroom-host/stroom/datafeed
```

## UNIX (using curl)
Curl is a standard unix tool to send data to or from a server. In the following examples -H is used to specify the header arguments required by Stroom, see [Header Arguments](header-arguments.md).

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

For step by step instructions for creating, configuring and testing the PKI authentication, see the [SSL Guide](ssl.md)

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

Windows 10 is the latest desktop OS offering from Microsoft.
From Windows 10 build 17063 and later, curl is now natively included - you can execute it directly from Cmd.exe or PowerShell.exe.
Curl.exe is located at c:\windows\system32 (which is included in the standard PATH environment variable) - all you need to do is run Command Prompt with administrative rights and you can use Curl. You can execute it directly from Cmd.exe or PowerShell.exe.
For older versions of Windows, the cURL project has Windows binaries.

```bash
curl -s -k --data-binary @file.dat "https://stroomp.strmdev00.org/stroom/datafeed" -H"Feed:TEST-FEED-V1_0" -H"System:EXAMPLE_SYSTEM" -H"Environment:EXAMPLE_ENVIRONMENT"
```
![New dashboard](images/curl_windows.png)

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
