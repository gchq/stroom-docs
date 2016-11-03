#Payloads

Stroom can support multiple payload formats with different compression applied. However all data once uncompressed must be text and not binary.

Stroom can receive data in the following formats:

* Uncompressed - Text data is sent to Stroom and no compression flag is set in the header arguments.
* GZIP - Text data is GZIP compressed and the compression flag is set to GZIP.
* ZIP - A text file is compressed into a ZIP archive and sent to Stroom with the compression flag set to ZIP. The ZIP file must contain one data file and an optional context file, see below.

##Context Files

ZIP files sent to Stroom are expected to contain the data file and an optional context file *.ctx. If provided a context file can be used to provide reference data that is specific to the data file that has been sent. Context data is supplimentary information that is not contained within logged events, e.g. the machine name, ip address etc may be delivered in a context file if it is not written by an application in each logged event.

##Character Encodings

Although Stroom only supports data in text format, text can be encoded using multiple character encodings. Supported encodings include:

* ISO-8859-1 (understood by default)
* Windows-1252 - ANSI (understood by default)
* ASCII (understood by default)
* UTF-8 (with or without BOM)
* UTF-16LE (little endian with or without BOM)
* UTF-16BE (big endian with or without BOM)
* UTF-32LE (little endian with or without BOM)
* UTF-32BE (big endian with or without BOM)

In order to tell Stroom what character encoding to use the feed that the data belongs to can be configured within the Stroom application to use a specific character encoding. Separate character encodings can be specified for logged event and context data.
