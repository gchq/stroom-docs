# Complex example with regex and user defined names

The following example uses a real world Apache log and demonstrates the use of regular expressions rather than simple 'split' tokenizers. The usage and structure of regular expressions is outside of the scope of this document but Data Splitter uses Java's standard regular expression library that is POSIX compliant and documented in numerous places.

This example also demonstrates that the names and values that are output can be hard coded in the absence of field name information to make XSLT conversion easier later on. Also shown is that any match can be divided into further fields with additional expressions and the ability to nest data elements to provide structure if needed.

## <a name="sec_1_3_1"></a>Input

```
192.168.1.100 - "-" [12/Jul/2012:11:57:07 +0000] "GET /doc.htm HTTP/1.1" 200 4235 "-" "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET4.0C; .NET4.0E; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)"
192.168.1.100 - "-" [12/Jul/2012:11:57:07 +0000] "GET /default.css HTTP/1.1" 200 3494 "http://some.server:8080/doc.htm" "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET4.0C; .NET4.0E; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)"
```

## <a name="sec_1_3_2"></a>Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd" version="3.0">

  <!--
  Standard Apache Format

  %h - host name should be ok without quotes
  %l - Remote logname (from identd, if supplied). This will return a dash unless IdentityCheck is set On.
  \"%u\" - user name should be quoted to deal with DNs
  %t - time is added in square brackets so is contained for parsing purposes
  \"%r\" - URL is quoted
  %>s - Response code doesn't need to be quoted as it is a single number
  %b - The size in bytes of the response sent to the client
  \"%{Referer}i\" - Referrer is quoted so that’s ok
  \"%{User-Agent}i\" - User agent is quoted so also ok

  LogFormat "%h %l \"%u\" %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
  -->

  <!-- Match line -->
  <split delimiter="\n">
    <group value="$1">

      <!-- Provide a regular expression for the whole line with match
      groups for each field we want to split out -->
      <regex pattern="^([^ ]+) ([^ ]+) &#34;([^&#34;]+)&#34; \[([^\]]+)] &#34;([^&#34;]+)&#34; ([^ ]+) ([^ ]+) &#34;([^&#34;]+)&#34; &#34;([^&#34;]+)&#34;">
        <data name="host" value="$1" />
        <data name="log" value="$2" />
        <data name="user" value="$3" />
        <data name="time" value="$4" />
        <data name="url" value="$5">

          <!-- Take the 5th regular expression group and pass it to
          another expression to divide into smaller components -->
          <group value="$5">
            <regex pattern="^([^ ]+) ([^ ]+) ([^ /]*)/([^ ]*)">
              <data name="httpMethod" value="$1" />
              <data name="url" value="$2" />
              <data name="protocol" value="$3" />
              <data name="version" value="$4" />
            </regex>
          </group>
        </data>
        <data name="response" value="$6" />
        <data name="size" value="$7" />
        <data name="referrer" value="$8" />
        <data name="userAgent" value="$9" />
      </regex>
    </group>
  </split>
</dataSplitter>
```

## <a name="sec_1_3_3"></a>Output

```xml
<?xml version="1.0" encoding="UTF-8"?>
<records xmlns="records:2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="records:2 file://records-v2.0.xsd" version="3.0">
  <record>
    <data name="host" value="192.168.1.100" />
    <data name="log" value="-" />
    <data name="user" value="-" />
    <data name="time" value="12/Jul/2012:11:57:07 +0000" />
    <data name="url" value="GET /doc.htm HTTP/1.1">
      <data name="httpMethod" value="GET" />
      <data name="url" value="/doc.htm" />
      <data name="protocol" value="HTTP" />
      <data name="version" value="1.1" />
    </data>
    <data name="response" value="200" />
    <data name="size" value="4235" />
    <data name="referrer" value="-" />
    <data name="userAgent" value="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET4.0C; .NET4.0E; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" />
  </record>
  <record>
    <data name="host" value="192.168.1.100" />
    <data name="log" value="-" />
    <data name="user" value="-" />
    <data name="time" value="12/Jul/2012:11:57:07 +0000" />
    <data name="url" value="GET /default.css HTTP/1.1">
      <data name="httpMethod" value="GET" />
      <data name="url" value="/default.css" />
      <data name="protocol" value="HTTP" />
      <data name="version" value="1.1" />
    </data>
    <data name="response" value="200" />
    <data name="size" value="3494" />
    <data name="referrer" value="http://some.server:8080/doc.htm" />
    <data name="userAgent" value="Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET4.0C; .NET4.0E; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)" />
  </record>
</records>
```
