<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xpath-default-namespace="records:2" xmlns="event-logging:3" xmlns:stroom="stroom" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">

  <!-- Ingest the records tree -->
  <xsl:template match="records">
    <Events xsi:schemaLocation="event-logging:3 file://event-logging-v3.2.3.xsd" Version="3.2.3">
        <xsl:apply-templates />
    </Events>
  </xsl:template>

    <!-- Only generate events if we have an url on input -->
    <xsl:template match="record[data[@name = 'url']]">
        <Event>
            <xsl:apply-templates select="." mode="eventTime" />
            <xsl:apply-templates select="." mode="eventSource" />
            <xsl:apply-templates select="." mode="eventDetail" />
        </Event>
    </xsl:template>


    <xsl:template match="node()"  mode="eventTime">
        <EventTime>
            <TimeCreated>
              <xsl:value-of select="stroom:format-date(data[@name = 'time']/@value, 'dd/MMM/yyyy:HH:mm:ss XX')" />
            </TimeCreated>
        </EventTime>
    </xsl:template>

    <xsl:template match="node()"  mode="eventSource">
      <!-- Set some variables to enable lookup functionality  -->
      <xsl:variable name="formattedDate" select="stroom:format-date(data[@name =  'time']/@value, 'dd/MMM/yyyy:HH:mm:ss XX')" />
      <!--  For Version 2.0 of Apache  audit we  have the virtual  server,  so this  will be our server -->
      <xsl:variable name="vServer" select="data[@name  =  'vserver']/@value"  />
      <xsl:variable name="vServerPort" select="data[@name =  'vserverport']/@value"  />
        <EventSource>
            <System>
              <Name>
                <xsl:value-of select="stroom:feed-attribute('System')"  />
              </Name>
              <Environment>
                <xsl:value-of select="stroom:feed-attribute('Environment')"  />
              </Environment>
            </System>
            <Generator>Apache  HTTPD</Generator>
            <Device>
              <HostName>
                <xsl:value-of select="stroom:feed-attribute('MyHost')"  />
              </HostName>
              <IPAddress>
                <xsl:value-of select="stroom:feed-attribute('MyIPAddress')"  />
              </IPAddress>
            </Device>
            <Client>
              <xsl:variable name="chost" select="stroom:lookup('IP_TO_FQDN', data[@name = 'clientip']/@value, $formattedDate, true())" />
              <xsl:if  test="$chost">
                <HostName>
                    <xsl:value-of  select="$chost" />
                </HostName>
              </xsl:if>
                <IPAddress>
                    <xsl:value-of select="data[@name =  'clientip']/@value"  />
                </IPAddress>
              <xsl:if test="data[@name =  'clientport']/@value !='-'">
                <Port>
                    <xsl:value-of select="data[@name =  'clientport']/@value"  />
                </Port>
              </xsl:if>
              <xsl:variable name="cloc" select="stroom:lookup('FQDN_TO_LOC', $chost,  $formattedDate, true())"  />
              <xsl:if  test="$chost != '' and $cloc">
                <xsl:copy-of select="$cloc"  />
              </xsl:if>
            </Client>
            <Server>
                <HostName>
                    <xsl:value-of  select="$vServer" />
                </HostName>
            <!--  See if we  can get  the  service  IPAddress -->
            <xsl:variable name="sipaddr" select="stroom:lookup('FQDN_TO_IP',$vServer, $formattedDate,  true())"  />
            <xsl:if  test="$sipaddr">
                <IPAddress>
                    <xsl:value-of  select="$sipaddr" />
                </IPAddress>
            </xsl:if>
            <!--  Server Port Number   -->
            <xsl:if test="$vServerPort !='-'">
                <Port>
                    <xsl:value-of  select="$vServerPort" />
                </Port>
            </xsl:if>
            <!--  See if we  can get the Server location -->
            <xsl:variable name="sloc"  select="stroom:lookup('FQDN_TO_LOC', $vServer, $formattedDate, true())"  />
            <xsl:if  test="$sloc">
                <xsl:copy-of select="$sloc"  />
            </xsl:if>
            </Server>
            <User>
              <Id>
                <xsl:value-of select="data[@name='user']/@value" />
              </Id>
            </User>
        </EventSource>
    </xsl:template>

    <xsl:template match="node()"  mode="eventDetail">
        <EventDetail>
          <TypeId>SendToWebService</TypeId>
          <Description>Send/Access data to Web Service</Description>
          <Classification>
            <Text>UNCLASSIFIED</Text>
          </Classification>
          <Send>
            <Source>
              <Device>
                <IPAddress>
                    <xsl:value-of select="data[@name = 'clientip']/@value"/>
                </IPAddress>
                <Port>
                    <xsl:value-of select="data[@name = 'vserverport']/@value"/>
                </Port>
              </Device>
            </Source>
            <Destination>
              <Device>
                <HostName>
                    <xsl:value-of select="data[@name = 'vserver']/@value"/>
                </HostName>
                <Port>
                    <xsl:value-of select="data[@name = 'vserverport']/@value"/>
                </Port>
              </Device>
            </Destination>
            <Payload>
              <Resource>
                <URL>
                    <xsl:value-of select="data[@name = 'url']/@value"/>
                </URL>
                <Referrer>
                    <xsl:value-of select="data[@name = 'referer']/@value"/>
                </Referrer>
                <HTTPMethod>
                    <xsl:value-of select="data[@name = 'url']/data[@name = 'httpMethod']/@value"/>
                </HTTPMethod>
                <HTTPVersion>
                    <xsl:value-of select="data[@name = 'url']/data[@name = 'version']/@value"/>
                </HTTPVersion>
                <UserAgent>
                    <xsl:value-of select="data[@name = 'userAgent']/@value"/>
                </UserAgent>
                <InboundSize>
                    <xsl:value-of select="data[@name = 'bytesIn']/@value"/>
                </InboundSize>
                <OutboundSize>
                    <xsl:value-of select="data[@name = 'bytesOut']/@value"/>
                </OutboundSize>
                <OutboundContentSize>
                    <xsl:value-of select="data[@name = 'bytesOutContent']/@value"/>
                </OutboundContentSize>
                <RequestTime>
                    <xsl:value-of select="data[@name = 'timeM']/@value"/>
                </RequestTime>
                <ConnectionStatus>
                    <xsl:value-of select="data[@name = 'constatus']/@value"/>
                </ConnectionStatus>
                <InitialResponseCode>
                    <xsl:value-of select="data[@name = 'responseB']/@value"/>
                </InitialResponseCode>
                <ResponseCode>
                    <xsl:value-of select="data[@name = 'response']/@value"/>
                </ResponseCode>
                <Data Name="Protocol">
                  <xsl:attribute select="data[@name = 'url']/data[@name = 'protocol']/@value" name="Value"/>
                </Data>
              </Resource>
            </Payload>
            <!-- Normally our translation at this point would contain an <Outcome> attribute.
            Since all our sample data includes only successful outcomes we have ommitted the <Outcome> attribute 
            in the translation to minimise complexity-->
          </Send>
        </EventDetail>
    </xsl:template>
</xsl:stylesheet>