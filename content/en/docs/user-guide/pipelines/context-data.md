---
title: "Context Data"
linkTitle: "Context Data"
weight: 60
date: 2021-07-27
tags:
  - context
description: >
  Context data is additional contextual data Stream that is sent alongside the main event data Stream.
---

{{% todo %}}
This section needs some explanation.
{{% /todo %}}


## Context File

### Input File:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<SomeData>
	<SomeEvent>
			<SomeTime>01/01/2009:12:00:01</SomeTime>
			<SomeAction>OPEN</SomeAction>
			<SomeUser>userone</SomeUser>
			<SomeFile>D:\TranslationKit\example\VerySimple\OpenFileEvents.txt</SomeFile>
	</SomeEvent>
</SomeData>
```


### Context File:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<SomeContext>
	<Machine>MyMachine</Machine>
</SomeContext>
```


### Context XSLT:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet
	xmlns="reference-data:2"
	xmlns:evt="event-logging:3"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="2.0">
		
		<xsl:template match="SomeContext">
			<referenceData 
					xsi:schemaLocation="event-logging:3 file://event-logging-v3.0.0.xsd reference-data:2 file://reference-data-v2.0.1.xsd"
					version="2.0.1">
							
					<xsl:apply-templates/>
			</referenceData>
		</xsl:template>

		<xsl:template match="Machine">
			<reference>
					<map>CONTEXT</map>
					<key>Machine</key>
					<value><xsl:value-of select="."/></value>
			</reference>
		</xsl:template>
		
</xsl:stylesheet>
```


### Context XML Translation:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<referenceData xmlns:evt="event-logging:3"
								xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
								xmlns="reference-data:2"
								xsi:schemaLocation="event-logging:3 file://event-logging-v3.0.0.xsd reference-data:2 file://reference-data-v2.0.1.xsd"
								version="2.0.1">
		<reference>
			<map>CONTEXT</map>
			<key>Machine</key>
			<value>MyMachine</value>
		</reference>
</referenceData>
```


### Input File:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<SomeData>
	<SomeEvent>
			<SomeTime>01/01/2009:12:00:01</SomeTime>
			<SomeAction>OPEN</SomeAction>
			<SomeUser>userone</SomeUser>
			<SomeFile>D:\TranslationKit\example\VerySimple\OpenFileEvents.txt</SomeFile>
	</SomeEvent>
</SomeData>
```


### Main XSLT (Note the use of the context lookup):

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet
	xmlns="event-logging:3"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	version="2.0">
	
    <xsl:template match="SomeData">
        <Events xsi:schemaLocation="event-logging:3 file://event-logging-v3.0.0.xsd" Version="3.0.0">
            <xsl:apply-templates/>
        </Events>
    </xsl:template>
    <xsl:template match="SomeEvent">
        <xsl:if test="SomeAction = 'OPEN'">
            <Event>
                <EventTime>
                        <TimeCreated>
                            <xsl:value-of select="s:format-date(SomeTime, 'dd/MM/yyyy:hh:mm:ss')"/>
                        </TimeCreated>
                </EventTime>
				<EventSource>
					<System>Example</System>
					<Environment>Example</Environment>
					<Generator>Very Simple Provider</Generator>
					<Device>
						<IPAddress>182.80.32.132</IPAddress>
						<Location>
							<Country>UK</Country>
							<Site><xsl:value-of select="s:lookup('CONTEXT', 'Machine')"/></Site>
							<Building>Main</Building>
							<Floor>1</Floor>              
							<Room>1aaa</Room>
						</Location>           
					</Device>
					<User><Id><xsl:value-of select="SomeUser"/></Id></User>
				</EventSource>
				<EventDetail>
					<View>
						<Document>
							<Title>UNKNOWN</Title>
							<File>
								<Path><xsl:value-of select="SomeFile"/></Path>
							</File>
						</Document>
					</View>
				</EventDetail>
            </Event>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
```


### Main Output XML:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Events xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns="event-logging:3"
				xsi:schemaLocation="event-logging:3 file://event-logging-v3.0.0.xsd"
				Version="3.0.0">
		<Event Id="6:1">
			<EventTime>
					<TimeCreated>2009-01-01T00:00:01.000Z</TimeCreated>
			</EventTime>
			<EventSource>
					<System>Example</System>
					<Environment>Example</Environment>
					<Generator>Very Simple Provider</Generator>
					<Device>
						<IPAddress>182.80.32.132</IPAddress>
						<Location>
								<Country>UK</Country>
								<Site>MyMachine</Site>
								<Building>Main</Building>
								<Floor>1</Floor>
								<Room>1aaa</Room>
						</Location>
					</Device>
					<User>
						<Id>userone</Id>
					</User>
			</EventSource>
			<EventDetail>
					<View>
						<Document>
								<Title>UNKNOWN</Title>
								<File>
									<Path>D:\TranslationKit\example\VerySimple\OpenFileEvents.txt</Path>
								</File>
						</Document>
					</View>
			</EventDetail>
		</Event>
</Events>
```
