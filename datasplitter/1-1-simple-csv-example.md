# Simple CSV example

The following CSV data will be split up into separate fields using Data Splitter.

```
01/01/2010,00:00:00,192.168.1.100,SOMEHOST.SOMEWHERE.COM,user1,logon,
01/01/2010,00:01:00,192.168.1.100,SOMEHOST.SOMEWHERE.COM,user1,create,c:\test.txt
01/01/2010,00:02:00,192.168.1.100,SOMEHOST.SOMEWHERE.COM,user1,logoff,
```

The first thing we need to do is match each record. Each record in a CSV file is delimited by a new line character. The following configuration will split the data into records using ‘\n’ as a delimiter:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd" version="3.0">
  
  <!-- Match each line using a new line character as the delimiter -->
  <split delimiter="\n"/>

</dataSplitter>
```

In the above example the ‘split’ tokenizer matches all of the supplied content up to the end of each line ready to pass each line of content on for further treatment.

We can now add a `<group>` element within `<split>` to take content matched by the tokenizer.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd" version="3.0">

  <!-- Match each line using a new line character as the delimiter -->
  <split delimiter="\n">

    <!-- Take the matched line (using group 1 ignores the delimiters, 
    without this each match would include the new line character) -->
    <group value="$1">

    </group>
  </split>
</dataSplitter>
```

The `<group>` within the `<split>` chooses to take the content from the `<split>` without including the new line '\n' delimiter by using match group 1, see [expression match references](3-1-expression-match-references.md#sec_3_1_1) for details.

```
01/01/2010,00:00:00,192.168.1.100,SOMEHOST.SOMEWHERE.COM,user1,logon,
```

The content selected by the `<group>` from its parent match can then be passed onto sub expressions for further matching:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd" version="3.0">

  <!-- Match each line using a new line character as the delimiter -->
  <split delimiter="\n">

    <!-- Take the matched line (using group 1 ignores the delimiters, 
    without this each match would include the new line character) -->
    <group value="$1">

      <!-- Match each value separated by a comma as the delimiter -->
      <split delimiter=",">

      </split>
    </group>
  </split>
</dataSplitter>
```

In the above example the additional `<split>` element within the `<group>` will match the content provided by the group repeatedly until it has used all of the group content.

The content matched by the inner `<split>` element can be passed to a `<data>` element to emit XML content.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd" version="3.0">

  <!-- Match each line using a new line character as the delimiter -->
  <split delimiter="\n">

    <!-- Take the matched line (using group 1 ignores the delimiters, 
    without this each match would include the new line character) -->
    <group value="$1">

      <!-- Match each value separated by a comma as the delimiter -->
      <split delimiter=",">

        <!-- Output the value from group 1 (as above using group 1
        ignores the delimiters, without this each value would include
        the comma) -->
        <data value="$1" />
      </split>
    </group>
  </split>
</dataSplitter>
```

In the above example each match from the inner `<split>` is made available to the inner `<data>` element that chooses to output content from match group 1, see [expression match references](3-1-expression-match-references.md#sec_3_1_1) for details.

The above configuration results in the following XML output for the whole input:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<records xmlns="records:2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="records:2 file://records-v2.0.xsd" version="3.0">
  <record>
    <data value="01/01/2010" />
    <data value="00:00:00" />
    <data value="192.168.1.100" />
    <data value="SOMEHOST.SOMEWHERE.COM" />
    <data value="user1" />
    <data value="logon" />
  </record>
  <record>
    <data value="01/01/2010" />
    <data value="00:01:00" />
    <data value="192.168.1.100" />
    <data value="SOMEHOST.SOMEWHERE.COM" />
    <data value="user1" />
    <data value="create" />
    <data value="c:\test.txt" />
  </record>
  <record>
    <data value="01/01/2010" />
    <data value="00:02:00" />
    <data value="192.168.1.100" />
    <data value="SOMEHOST.SOMEWHERE.COM" />
    <data value="user1" />
    <data value="logoff" />
  </record>
</records>
```