# Java Key Store Setup

In order that the java process communicates over https (for example Stroom Proxy forwarding onto Stroom) the JVM requires relevant keystore's setting up.

As the processing user copy the following files to a directory stroom-jks in the processing user home directory :

- CA.crt     - Certificate Authority
- SERVER.crt - Server certificate with client authentication attributes
- SERVER.key - Server private key

As the processing user perform the following:

- First turn your keys into der format:

```bash
cd ~/stroom-jks

SERVER=<SERVER crt/key PREFIX>
AUTHORITY=CA

openssl x509 -in ${SERVER}.crt -inform PEM -out ${SERVER}.crt.der -outform DER
openssl pkcs8 -topk8 -nocrypt -in ${SERVER}.key -inform PEM -out ${SERVER}.key.der -outform DER
```

- Import Keys into the Key Stores:

```bash
Stroom_UTIL_JAR=`find ~/*app -name 'stroom-util*.jar' -print | head -1`

java -cp ${Stroom_UTIL_JAR} stroom.util.cert.ImportKey keystore=${SERVER}.jks keypass=${SERVER} alias=${SERVER} keyfile=${SERVER}.key.der certfile=${SERVER}.crt.der
keytool -import -noprompt -alias ${AUTHORITY} -file ${AUTHORITY}.crt -keystore ${AUTHORITY}.jks -storepass ${AUTHORITY}
```

- Update Processing User Global Java Settings:   
 
```bash
PWD=`pwd`
echo "export JAVA_OPTS=\"-Djavax.net.ssl.trustStore=${PWD}/${AUTHORITY}.jks -Djavax.net.ssl.trustStorePassword=${AUTHORITY} -Djavax.net.ssl.keyStore=${PWD}/${SERVER}.jks -Djavax.net.ssl.keyStorePassword=${SERVER}\"" >> ~/env.sh  
```

Any Stroom or Stroom Proxy instance will now additionally pickup the above JAVA_OPTS settings.
