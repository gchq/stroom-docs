---
title: "Output"
linkTitle: "Output"
#weight:
date: 2021-07-27
tags: 
description: >
  
---

As with all other aspects of Data Splitter, output XML is determined by adding certain elements to the Data Splitter configuration.

## <a name="sec_2_4_1"></a>The &lt;data&gt; element

Output is created by Data Splitter using one or more `<data>` elements in the configuration. The first `<data>` element that is encountered within a matched expression will result in parent `<record>` elements being produced in the output.

### <a name="sec_2_4_1_1"></a>Attributes

The `<data>` element has the following attributes:

* [id](#sec-2-4-1-1-1)
* [name](#sec-2-4-1-1-2)
* [value](#sec-2-4-1-1-3)

#### <a name="sec-2-4-1-1-1"></a>id

Optional attribute used to debug the location of expressions causing errors, see [id](2-1-content-providers.md#sec-2-1-2-1-1).

#### <a name="sec-2-4-1-1-2"></a>name

Both the name and value attributes of the `<data>` element can be specified using [match references](3-0-match-references.md).

#### <a name="sec-2-4-1-1-3"></a>value

Both the name and value attributes of the `<data>` element can be specified using [match references](3-0-match-references.md).

#### <a name="sec_2_4_1_2"></a>Single &lt;data&gt; element example

The simplest example that can be provided uses a single `<data>` element within a `<split>` expression.

Given the following input:

```
This is line 1
This is line 2
This is line 3
```

… and the following configuration:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd" version="3.0">
  <split delimiter="\n" >
    <data value="$1"/>
  </split>
</dataSplitter>
```

… you would get the following output:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<records xmlns="records:2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="records:2 file://records-v2.0.xsd" version="3.0">
  <record>
    <data value="This is line 1" />
  </record>
  <record>
    <data value="This is line 2" />
  </record>
  <record>
    <data value="This is line 3" />
  </record>
</records>
```

#### <a name="sec_2_4_1_3"></a>Multiple &lt;data&gt; element example

You could also output multiple `<data>` elements for the same `<record>` by adding multiple elements within the same expression:

Given the following input:

```
ip=1.1.1.1 user=user1
ip=2.2.2.2 user=user2
ip=3.3.3.3 user=user3
```

… and the following configuration:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd" version="3.0">
  <regex pattern="ip=([^ ]+) user=([^ ]+)\s*">
    <data name="ip" value="$1"/>
    <data name="user" value="$2"/>
  </split>
</dataSplitter>
```

… you would get the following output:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<records xmlns="records:2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="records:2 file://records-v2.0.xsd" version="3.0">
  <record>
    <data name="ip" value="1.1.1.1" />
    <data name="user" value="user1" />
  </record>
  <record>
    <data name="ip" value="2.2.2.2" />
    <data name="user" value="user2" />
  </record>
  <record>
    <data name="ip" value="3.3.3.3" />
    <data name="user" value="user3" />
  </record>
</records>
```

### <a name="sec_2_4_1_4"></a>Multi level &lt;data&gt; elements

As long as all data elements occur within the same parent/ancestor expression, all data elements will be output within the same record.

Given the following input:

```
ip=1.1.1.1 user=user1
ip=2.2.2.2 user=user2
ip=3.3.3.3 user=user3
```

… and the following configuration:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd" version="3.0">
  <split delimiter="\n" >
    <data name="line" value="$1"/>

    <group value="$1">
      <regex pattern="ip=([^ ]+) user=([^ ]+)">
        <data name="ip" value="$1"/>
        <data name="user" value="$2"/>
      </regex>
    </group>
  </split>
</dataSplitter>
```

… you would get the following output:

```
<?xml version="1.0" encoding="UTF-8"?>
<records xmlns="records:2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="records:2 file://records-v2.0.xsd" version="3.0">
  <record>
    <data name="line" value="ip=1.1.1.1 user=user1" />
    <data name="ip" value="1.1.1.1" />
    <data name="user" value="user1" />
  </record>
  <record>
    <data name="line" value="ip=2.2.2.2 user=user2" />
    <data name="ip" value="2.2.2.2" />
    <data name="user" value="user2" />
  </record>
  <record>
    <data name="line" value="ip=3.3.3.3 user=user3" />
    <data name="ip" value="3.3.3.3" />
    <data name="user" value="user3" />
  </record>
</records>
```

### <a name="sec_2_4_1_5"></a>Nesting &lt;data&gt; elements

Rather than having `<data>` elements all appear as children of `<record>` it is possible to nest them either as direct children or within child groups.

#### <a name="sec-2-4-1-5-1"></a>Direct children

Given the following input:

```
ip=1.1.1.1 user=user1
ip=2.2.2.2 user=user2
ip=3.3.3.3 user=user3
```

… and the following configuration:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd" version="3.0">
  <regex pattern="ip=([^ ]+) user=([^ ]+)\s*">
    <data name="line" value="$">
      <data name="ip" value="$1"/>
      <data name="user" value="$2"/>
    </data>
  </split>
</dataSplitter>
```

… you would get the following output:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<records xmlns="records:2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="records:2 file://records-v2.0.xsd" version="3.0">
  <record>
    <data name="line" value="ip=1.1.1.1 user=user1">
      <data name="ip" value="1.1.1.1" />
      <data name="user" value="user1" />
    </data>
  </record>
  <record>
    <data name="line" value="ip=2.2.2.2 user=user2">
      <data name="ip" value="2.2.2.2" />
      <data name="user" value="user2" />
    </data>
  </record>
  <record>
    <data name="line" value="ip=3.3.3.3 user=user3">
      <data name="ip" value="3.3.3.3" />
      <data name="user" value="user3" />
    </data>
  </record>
</records>
```

#### <a name="sec-2-4-1-5-2"></a>Within child groups

Given the following input:

```
ip=1.1.1.1 user=user1
ip=2.2.2.2 user=user2
ip=3.3.3.3 user=user3
```

… and the following configuration:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd" version="3.0">
  <split delimiter="\n" >
    <data name="line" value="$1">
      <group value="$1">
        <regex pattern="ip=([^ ]+) user=([^ ]+)">
          <data name="ip" value="$1"/>
          <data name="user" value="$2"/>
        </regex>
      </group>
    </data>
  </split>
</dataSplitter>
```

… you would get the following output:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<records xmlns="records:2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="records:2 file://records-v2.0.xsd" version="3.0">
  <record>
    <data name="line" value="ip=1.1.1.1 user=user1">
      <data name="ip" value="1.1.1.1" />
      <data name="user" value="user1" />
    </data>
  </record>
  <record>
    <data name="line" value="ip=2.2.2.2 user=user2">
      <data name="ip" value="2.2.2.2" />
      <data name="user" value="user2" />
    </data>
  </record>
  <record>
    <data name="line" value="ip=3.3.3.3 user=user3">
      <data name="ip" value="3.3.3.3" />
      <data name="user" value="user3" />
    </data>
  </record>
</records>
```

The above example produces the same output as the previous but could be used to apply much more complex expression logic to produce the child `<data>` elements, e.g. the inclusion of multiple child expressions to deal with different types of lines.
