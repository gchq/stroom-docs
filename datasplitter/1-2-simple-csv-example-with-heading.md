# Simple CSV example with heading

In addition to referencing content produced by a parent element it is often desirable to store content and reference it later. The following example of a CSV with a heading demonstrates how content can be stored in a variable and then referenced later on.

## <a name="sec_1_2_1"></a>Input

This example will use a similar input to the one in the previous CSV example but also adds a heading line.

```
Date,Time,IPAddress,HostName,User,EventType,Detail
01/01/2010,00:00:00,192.168.1.100,SOMEHOST.SOMEWHERE.COM,user1,logon,
01/01/2010,00:01:00,192.168.1.100,SOMEHOST.SOMEWHERE.COM,user1,create,c:\test.txt
01/01/2010,00:02:00,192.168.1.100,SOMEHOST.SOMEWHERE.COM,user1,logoff,
```

## <a name="sec_1_2_2"></a>Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dataSplitter xmlns="data-splitter:3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="data-splitter:3 file://data-splitter-v3.0.xsd" version="3.0">

  <!-- Match heading line (note that maxMatch="1" means that only the
  first line will be matched by this splitter) -->
  <split delimiter="\n" maxMatch="1">

    <!-- Store each heading in a named list -->
    <group>
      <split delimiter=",">
        <var id="heading" />
      </split>
    </group>
  </split>

  <!-- Match each record -->
  <split delimiter="\n">

    <!-- Take the matched line -->
    <group value="$1">

      <!-- Split the line up -->
      <split delimiter=",">

        <!-- Output the stored heading for each iteration and the value
        from group 1 -->
        <data name="$heading$1" value="$1" />
      </split>
    </group>
  </split>
</dataSplitter>
```

## <a name="sec_1_2_3"></a>Output

```xml
<?xml version="1.0" encoding="UTF-8"?>
<records xmlns="records:2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="records:2 file://records-v2.0.xsd" version="3.0">
  <record>
    <data name="Date" value="01/01/2010" />
    <data name="Time" value="00:00:00" />
    <data name="IPAddress" value="192.168.1.100" />
    <data name="HostName" value="SOMEHOST.SOMEWHERE.COM" />
    <data name="User" value="user1" />
    <data name="EventType" value="logon" />
  </record>
  <record>
    <data name="Date" value="01/01/2010" />
    <data name="Time" value="00:01:00" />
    <data name="IPAddress" value="192.168.1.100" />
    <data name="HostName" value="SOMEHOST.SOMEWHERE.COM" />
    <data name="User" value="user1" />
    <data name="EventType" value="create" />
    <data name="Detail" value="c:\test.txt" />
  </record>
  <record>
    <data name="Date" value="01/01/2010" />
    <data name="Time" value="00:02:00" />
    <data name="IPAdress" value="192.168.1.100" />
    <data name="HostName" value="SOMEHOST.SOMEWHERE.COM" />
    <data name="User" value="user1" />
    <data name="EventType" value="logoff" />
  </record>
</records>
```
