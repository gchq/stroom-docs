<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xpath-default-namespace="records:2" xmlns="event-logging:3" xmlns:stroom="stroom" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">

  <!-- Bluecoat Proxy logs in W2C Extended Log File Format (ELF) -->

  <!-- Ingest the record key value pair elements -->
  <xsl:template match="records">
    <Events xsi:schemaLocation="event-logging:3 file://event-logging-v3.2.4.xsd" Version="3.2.4">
      <xsl:apply-templates />
    </Events>
  </xsl:template>

  <!-- Main record template for single event -->
  <xsl:template match="record">
    <xsl:choose>

      <!-- Store the Software and Version information of the Bluecoat log file for use in the Event Source elements which are processed later -->
      <xsl:when test="data[@name='_bc_software']">
        <xsl:value-of select="stroom:put('_bc_software', data[@name='_bc_software']/@value)" />
      </xsl:when>
      <xsl:when test="data[@name='_bc_version']">
        <xsl:value-of select="stroom:put('_bc_version', data[@name='_bc_version']/@value)" />
      </xsl:when>

      <!-- Process the event logs -->
      <xsl:otherwise>
        <Event>
          <xsl:call-template name="event_time" />
          <xsl:call-template name="event_source" />
          <xsl:call-template name="event_detail" />
        </Event>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Time -->
  <xsl:template name="event_time">
    <EventTime>
      <TimeCreated>
        <xsl:value-of select="concat(data[@name = 'date']/@value,'T',data[@name='time']/@value,'.000Z')" />
      </TimeCreated>
    </EventTime>
  </xsl:template>

  <!-- Template for event source-->
  <xsl:template name="event_source">

    <!--
             We extract some situational awareness information that the posting script includes when posting the event data 
    -->
    <xsl:variable name="_mymeta" select="translate(stroom:meta('MyMeta'),'&quot;', '')" />

    <!-- Form the EventSource node -->
    <EventSource>
      <System>
        <Name>
          <xsl:value-of select="stroom:meta('System')" />
        </Name>
        <Environment>
          <xsl:value-of select="stroom:meta('Environment')" />
        </Environment>
      </System>
      <Generator>
        <xsl:variable name="gen">
          <xsl:if test="stroom:get('_bc_software')">
            <xsl:value-of select="concat(' Software: ', stroom:get('_bc_software'))" />
          </xsl:if>
          <xsl:if test="stroom:get('_bc_version')">
            <xsl:value-of select="concat(' Version: ', stroom:get('_bc_version'))" />
          </xsl:if>
        </xsl:variable>
        <xsl:value-of select="concat('Bluecoat', $gen)" />
      </Generator>
      <xsl:if test="data[@name='s-computername'] or data[@name='s-ip']">
        <Device>
          <xsl:if test="data[@name='s-computername']">
            <Name>
              <xsl:value-of select="data[@name='s-computername']/@value" />
            </Name>
          </xsl:if>
          <xsl:if test="data[@name='s-ip']">
            <IPAddress>
              <xsl:value-of select=" data[@name='s-ip']/@value" />
            </IPAddress>
          </xsl:if>
          <xsl:if test="data[@name='s-sitename']">
            <Data Name="ServiceType" Value="{data[@name='s-sitename']/@value}" />
          </xsl:if>
        </Device>
      </xsl:if>

      <!-- -->
      <Client>
        <xsl:if test="data[@name='c-ip']/@value != '-'">
          <IPAddress>
            <xsl:value-of select="data[@name='c-ip']/@value" />
          </IPAddress>
        </xsl:if>

        <!-- Remote Port Number -->
        <xsl:if test="data[@name='c-port']/@value !='-'">
          <Port>
            <xsl:value-of select="data[@name='c-port']/@value" />
          </Port>
        </xsl:if>
      </Client>

      <!-- -->
      <Server>
        <HostName>
          <xsl:value-of select="data[@name='cs-host']/@value" />
        </HostName>
      </Server>

      <!-- -->
      <xsl:variable name="user">
        <xsl:value-of select="data[@name='cs-user']/@value" />
        <xsl:value-of select="data[@name='cs-username']/@value" />
        <xsl:value-of select="data[@name='cs-userdn']/@value" />
      </xsl:variable>
      <xsl:if test="$user !='-'">
        <User>
          <Id>
            <xsl:value-of select="$user" />
          </Id>
        </User>
      </xsl:if>
      <Data Name="MyMeta">
        <xsl:attribute name="Value" select="$_mymeta" />
      </Data>
    </EventSource>
  </xsl:template>

  <!-- Event detail -->
  <xsl:template name="event_detail">
    <EventDetail>

      <!--
                 We model Proxy events as either Receive or Send events depending on the method.
      
      We make use of the Receive/Send sub-elements Source/Destination to map the Client/Destination Proxy values
      and the Payload sub-element to map the URL and other details of the activity. If we have a query, we model it
      as a Criteria
      
      -->
      <TypeId>
        <xsl:value-of select="concat('Bluecoat-', data[@name='cs-method']/@value, '-', data[@name='cs-uri-scheme']/@value)" />
        <xsl:if test="data[@name='cs-uri-query']/@value != '-'">-Query</xsl:if>
      </TypeId>
      <xsl:choose>
        <xsl:when test="matches(data[@name='cs-method']/@value, 'GET|OPTIONS|HEAD')">
          <Description>Receipt of information from a Resource via Proxy</Description>
          <Receive>
            <xsl:call-template name="setupParticipants" />
            <xsl:call-template name="setPayload" />
            <xsl:call-template name="setOutcome" />
          </Receive>
        </xsl:when>
        <xsl:otherwise>
          <Description>Transmission of information to a Resource via Proxy</Description>
          <Send>
            <xsl:call-template name="setupParticipants" />
            <xsl:call-template name="setPayload" />
            <xsl:call-template name="setOutcome" />
          </Send>
        </xsl:otherwise>
      </xsl:choose>
    </EventDetail>
  </xsl:template>

  <!-- Establish the Source and Destination nodes -->
  <xsl:template name="setupParticipants">
    <Source>
      <Device>
        <xsl:if test="data[@name='c-ip']/@value != '-'">
          <IPAddress>
            <xsl:value-of select="data[@name='c-ip']/@value" />
          </IPAddress>
        </xsl:if>

        <!-- Remote Port Number -->
        <xsl:if test="data[@name='c-port']/@value !='-'">
          <Port>
            <xsl:value-of select="data[@name='c-port']/@value" />
          </Port>
        </xsl:if>
      </Device>
    </Source>
    <Destination>
      <Device>
        <HostName>
          <xsl:value-of select="data[@name='cs-host']/@value" />
        </HostName>
      </Device>
    </Destination>
  </xsl:template>

  <!-- Define the Payload node -->
  <xsl:template name="setPayload">
    <Payload>
      <xsl:if test="data[@name='cs-uri-query']/@value != '-'">
        <Criteria>
          <DataSources>
            <DataSource>
              <xsl:value-of select="concat(data[@name='cs-uri-scheme']/@value, '://', data[@name='cs-host']/@value)" />
              <xsl:if test="data[@name='cs-uri-path']/@value != '/'">
                <xsl:value-of select="data[@name='cs-uri-path']/@value" />
              </xsl:if>
            </DataSource>
          </DataSources>
          <Query>
            <Raw>
              <xsl:value-of select="data[@name='cs-uri-query']/@value" />
            </Raw>
          </Query>
        </Criteria>
      </xsl:if>
      <Resource>

        <!-- Check for auth groups the URL belongs to -->
        <xsl:variable name="authgroups">
          <xsl:value-of select="data[@name='cs-auth-group']/@value" />
          <xsl:if test="exists(data[@name='cs-auth-group']) and exists(data[@name='cs-auth-groups'])">,</xsl:if>
          <xsl:value-of select="data[@name='cs-auth-groups']/@value" />
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains($authgroups, ',')">
            <Groups>
              <xsl:for-each select="tokenize($authgroups, ',')">
                <Group>
                  <Id>
                    <xsl:value-of select="." />
                  </Id>
                </Group>
              </xsl:for-each>
            </Groups>
          </xsl:when>
          <xsl:when test="$authgroups != '-' and $authgroups != ''">
            <Groups>
              <Group>
                <Id>
                  <xsl:value-of select="$authgroups" />
                </Id>
              </Group>
            </Groups>
          </xsl:when>
        </xsl:choose>

        <!-- Re-form the URL -->
        <URL>
          <xsl:value-of select="concat(data[@name='cs-uri-scheme']/@value, '://', data[@name='cs-host']/@value)" />
          <xsl:if test="data[@name='cs-uri-path']/@value != '/'">
            <xsl:value-of select="data[@name='cs-uri-path']/@value" />
          </xsl:if>
        </URL>
        <HTTPMethod>
          <xsl:value-of select="data[@name='cs-method']/@value" />
        </HTTPMethod>
        <xsl:if test="data[@name='cs(User-Agent)']/@value !='-'">
          <UserAgent>
            <xsl:value-of select="data[@name='cs(User-Agent)']/@value" />
          </UserAgent>
        </xsl:if>

        <!-- Inbound activity -->
        <xsl:if test="data[@name='sc-bytes']/@value !='-'">
          <InboundSize>
            <xsl:value-of select="data[@name='sc-bytes']/@value" />
          </InboundSize>
        </xsl:if>
        <xsl:if test="data[@name='sc-bodylength']/@value !='-'">
          <InboundContentSize>
            <xsl:value-of select="data[@name='sc-bodylength']/@value" />
          </InboundContentSize>
        </xsl:if>

        <!-- Outbound activity -->
        <xsl:if test="data[@name='cs-bytes']/@value !='-'">
          <OutboundSize>
            <xsl:value-of select="data[@name='cs-bytes']/@value" />
          </OutboundSize>
        </xsl:if>
        <xsl:if test="data[@name='cs-bodylength']/@value !='-'">
          <OutboundContentSize>
            <xsl:value-of select="data[@name='cs-bodylength']/@value" />
          </OutboundContentSize>
        </xsl:if>

        <!-- Miscellaneous -->
        <RequestTime>
          <xsl:value-of select="data[@name='time-taken']/@value" />
        </RequestTime>
        <ResponseCode>
          <xsl:value-of select="data[@name='sc-status']/@value" />
        </ResponseCode>
        <xsl:if test="data[@name='rs(Content-Type)']/@value != '-'">
          <MimeType>
            <xsl:value-of select="data[@name='rs(Content-Type)']/@value" />
          </MimeType>
        </xsl:if>
        <xsl:if test="data[@name='cs-categories']/@value != 'none' or data[@name='sc-filter-category']/@value != 'none'">
          <Category>
            <xsl:value-of select="data[@name='cs-categories']/@value" />
            <xsl:value-of select="data[@name='sc-filter-category']/@value" />
          </Category>
        </xsl:if>

        <!-- Take up other items as data elements -->
        <xsl:apply-templates select="data[@name='s-action']" />
        <xsl:apply-templates select="data[@name='cs-uri-scheme']" />
        <xsl:apply-templates select="data[@name='s-hierarchy']" />
        <xsl:apply-templates select="data[@name='sc-filter-result']" />
        <xsl:apply-templates select="data[@name='x-virus-id']" />
        <xsl:apply-templates select="data[@name='x-virus-details']" />
        <xsl:apply-templates select="data[@name='x-icap-error-code']" />
        <xsl:apply-templates select="data[@name='x-icap-error-details']" />
      </Resource>
    </Payload>
  </xsl:template>

  <!-- Generic Data capture template so we capture all other Bluecoat objects not already consumed -->
  <xsl:template match="data">
    <xsl:if test="@value != '-'">
      <Data Name="{@name}" Value="{@value}" />
    </xsl:if>
  </xsl:template>

  <!-- 
         Set up the Outcome node.
  
  We only set an Outcome for an error state. The absence of an Outcome infers success
  -->
  <xsl:template name="setOutcome">
    <xsl:choose>

      <!-- Favour squid specific errors first -->
      <xsl:when test="data[@name='sc-status']/@value > 500">
        <Outcome>
          <Success>false</Success>
          <Description>
            <xsl:call-template name="responseCodeDesc">
              <xsl:with-param name="code" select="data[@name='sc-status']/@value" />
            </xsl:call-template>
          </Description>
        </Outcome>
      </xsl:when>

      <!-- Now check for 'normal' errors -->
      <xsl:when test="tCliStatus > 400">
        <Outcome>
          <Success>false</Success>
          <Description>
            <xsl:call-template name="responseCodeDesc">
              <xsl:with-param name="code" select="data[@name='sc-status']/@value" />
            </xsl:call-template>
          </Description>
        </Outcome>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Response Code map to Descriptions -->
  <xsl:template name="responseCodeDesc">
    <xsl:param name="code" />
    <xsl:choose>

      <!-- Informational -->
      <xsl:when test="$code = 100">Continue</xsl:when>
      <xsl:when test="$code = 101">Switching Protocols</xsl:when>
      <xsl:when test="$code = 102">Processing</xsl:when>

      <!-- Successful Transaction -->
      <xsl:when test="$code = 200">OK</xsl:when>
      <xsl:when test="$code = 201">Created</xsl:when>
      <xsl:when test="$code = 202">Accepted</xsl:when>
      <xsl:when test="$code = 203">Non-Authoritative Information</xsl:when>
      <xsl:when test="$code = 204">No Content</xsl:when>
      <xsl:when test="$code = 205">Reset Content</xsl:when>
      <xsl:when test="$code = 206">Partial Content</xsl:when>
      <xsl:when test="$code = 207">Multi Status</xsl:when>

      <!-- Redirection -->
      <xsl:when test="$code = 300">Multiple Choices</xsl:when>
      <xsl:when test="$code = 301">Moved Permanently</xsl:when>
      <xsl:when test="$code = 302">Moved Temporarily</xsl:when>
      <xsl:when test="$code = 303">See Other</xsl:when>
      <xsl:when test="$code = 304">Not Modified</xsl:when>
      <xsl:when test="$code = 305">Use Proxy</xsl:when>
      <xsl:when test="$code = 307">Temporary Redirect</xsl:when>

      <!-- Client Error -->
      <xsl:when test="$code = 400">Bad Request</xsl:when>
      <xsl:when test="$code = 401">Unauthorized</xsl:when>
      <xsl:when test="$code = 402">Payment Required</xsl:when>
      <xsl:when test="$code = 403">Forbidden</xsl:when>
      <xsl:when test="$code = 404">Not Found</xsl:when>
      <xsl:when test="$code = 405">Method Not Allowed</xsl:when>
      <xsl:when test="$code = 406">Not Acceptable</xsl:when>
      <xsl:when test="$code = 407">Proxy Authentication Required</xsl:when>
      <xsl:when test="$code = 408">Request Timeout</xsl:when>
      <xsl:when test="$code = 409">Conflict</xsl:when>
      <xsl:when test="$code = 410">Gone</xsl:when>
      <xsl:when test="$code = 411">Length Required</xsl:when>
      <xsl:when test="$code = 412">Precondition Failed</xsl:when>
      <xsl:when test="$code = 413">Request Entity Too Large</xsl:when>
      <xsl:when test="$code = 414">Request URI Too Large</xsl:when>
      <xsl:when test="$code = 415">Unsupported Media Type</xsl:when>
      <xsl:when test="$code = 416">Request Range Not Satisfiable</xsl:when>
      <xsl:when test="$code = 417">Expectation Failed</xsl:when>
      <xsl:when test="$code = 422">Unprocessable Entity</xsl:when>
      <xsl:when test="$code = 424">Locked/Failed Dependency</xsl:when>
      <xsl:when test="$code = 433">Unprocessable Entity</xsl:when>

      <!-- Server Error -->
      <xsl:when test="$code = 500">Internal Server Error</xsl:when>
      <xsl:when test="$code = 501">Not Implemented</xsl:when>
      <xsl:when test="$code = 502">Bad Gateway</xsl:when>
      <xsl:when test="$code = 503">Service Unavailable</xsl:when>
      <xsl:when test="$code = 504">Gateway Timeout</xsl:when>
      <xsl:when test="$code = 505">HTTP Version Not Supported</xsl:when>
      <xsl:when test="$code = 507">Insufficient Storage</xsl:when>
      <xsl:when test="$code = 600">Squid: header parsing error</xsl:when>
      <xsl:when test="$code = 601">Squid: header size overflow detected while parsing/roundcube: software configuration error</xsl:when>
      <xsl:when test="$code = 603">roundcube: invalid authorization</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('Unknown Code:', $code)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
