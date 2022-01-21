---
title: "VBScript (Windows)"
linkTitle: "VBScript (Windows)"
#weight:
date: 2022-01-13
tags: 
description: >
  Using VBScript to send data to Stroom.

---
`extract-data.vbs` uses wevtutil.exe to extract **Security** event information from the windows event log.
This script has been tested on Windows 2008.

This script is designed to run periodically (say every 10 minutes).
The first time the script is run it stores the current time in UTC format in the registry.
Subsequent calls then extract event information from the last run time to the new current time.
The events are stored in a zip file with the period dates embedded.

The script requires a working directory used as a buffer for the zip files.
This can be set at the start of the script otherwise it will default to the working directory.

The `send-data.vbs` script is designed to run periodically (say every 10 minutes). The script will scan for zip files and send them to Stroom.

The script details several parameters that require setting per environment. Among these are the working directory that the zip files are stored in, the feed name and the URL of Stroom.

## SSL

To send data over SSL (https) you must import a client certificate in p12 format into windows.
To convert a certificate (.crt) and private key (.key) into a p12 format use the following command:

```text
openssl pkcs12 -export -in <NAME>.crt -inkey <NAME>.key -out <NAME>.p12 -name "<NAME>"
```

Once in p12 format use the windows certificate wizard to import the public private key.

The `send-data-tree.vbs` script works through a directory for different feed types.
