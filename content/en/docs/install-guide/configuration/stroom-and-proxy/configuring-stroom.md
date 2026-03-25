---
title: "Stroom Configuration"
linkTitle: "Stroom Configuration"
#weight:
date: 2021-06-23
tags:
description: >
  Describes how the Stroom application is configured.
---

{{% see-also %}}
[Stroom and Stroom-Proxy Common Configuration]({{< relref "common-configuration" >}})  
[Stroom Properties]({{< relref "/docs/user-guide/properties.md" >}})
{{% /see-also %}}


## General configuration

The Stroom application is essentially just an executable {{< external-link "JAR" "https://en.wikipedia.org/wiki/JAR_%28file_format%29" >}} file that can be run when provided with a configuration file, `config.yml`.
This config file is common to all forms of deployment.


### config.yml

Stroom operates on a configuration by exception basis so all configuration properties will have a sensible default value and a property only needs to be explicitly configured if the default value is not appropriate, e.g. for tuning a large scale production deployment or where values are environment specific.
As a result `config.yml` only contains a minimal set of properties.
The full tree of properties can be seen in `./config/config-defaults.yml` and a schema for the configuration tree (along with descriptions for each property) can be found in `./config/config-schema.yml`.
These two files can be used as a reference when configuring stroom.


#### Key Configuration Properties

The following are key properties that would typically be changed for a production deployment.
All configuration branches are relative to the `appConfig` root.

The database name(s), hostname(s), port(s), usernames(s) and password(s) should be configured using these properties.
Typically stroom is configured to keep it statistics data in a separate database to the main stroom database, as is configured below.

```yaml
  commonDbDetails:
    connection:
      jdbcDriverUrl: "jdbc:mysql://localhost:3307/stroom?useUnicode=yes&characterEncoding=UTF-8"
      jdbcDriverUsername: "stroomuser"
      jdbcDriverPassword: "stroompassword1"
  statistics:
    sql:
      db:
        connection:
          jdbcDriverUrl: "jdbc:mysql://localhost:3307/stats?useUnicode=yes&characterEncoding=UTF-8"
          jdbcDriverUsername: "statsuser"
          jdbcDriverPassword: "stroompassword1"
```

In a clustered deployment each node must be given a node name that is unique within the cluster.
This is used to identify nodes in the Nodes screen.
It could be the hostname of the node or follow some other naming convention.

```yaml
  node:
    name: "node1a"
```

Each node should have its identity on the network configured so that it uses the appropriate FQDNs.
The `nodeUri` hostname is the FQDN of each node and used by nodes to communicate with each other, therefore it can be private to the cluster of nodes.
The `publicUri` hostname is the public facing FQDN for stroom, i.e. the address of a load balancer or Nginx.
This is the address that users will use in their browser.

```yaml
  nodeUri:
    hostname: "localhost" # e.g. node5.stroomnodes.somedomain
  publicUri:
    hostname: "localhost" # e.g. stroom.somedomain
```


## Deploying without Docker

Stroom running without docker has two files to configure it.
The following locations are relative to the stroom home directory, i.e. the root of the distribution zip.

* `./config/config.yml` - Stroom configuration YAML file
* `./config/scripts.env` - Stroom scripts configuration env file

The distribution also includes these files which are helpful when it comes to configuring stroom.

* `./config/config-defaults.yml` - Full version of the config.yml file containing all branches/leaves with default values set.
                                   Useful as a reference for the structure and the default values.
* `./config/config-schema.yml` - The schema defining the structure of the `config.yml` file.


### scripts.env

This file is used by the various shell scripts like `start.sh`, `stop.sh`, etc.
This file should not need to be changed unless you want to change the locations where certain log files are written to or need to change the java memory settings.

In a production system it is highly likely that you will need to increase the java heap size as the default is only 2G.
The heap size settings and any other java command line options can be set by changing:

```sh
JAVA_OPTS="-Xms512m -Xmx2048m"
```


## As part of a docker stack

When stroom is run as part of one of our docker stacks, e.g. _stroom_core_ there are some additional layers of configuration to take into account, but the configuration is still primarily done using the `config.yml` file.

Stroom's `config.yml` file is found in the stack in `./volumes/stroom/config/` and this is the primary means of configuring Stroom.

The stack also ships with a default `config.yml` file baked into the docker image.
This minimal fallback file (located in `/stroom/config-fallback/` inside the container) will be used in the absence of one provided in the docker stack configuration (`./volumes/stroom/config/`).

The default `config.yml` file uses [environment variable substitution]({{< relref "./#environment-variables" >}}) so some configuration items will be set by environment variables set into the container by the stack _env_ file and the docker-compose YAML.
This approach is useful for configuration values that need to be used by multiple containers, e.g. the public FQDN of Nginx, so it can be configured in one place.

If you need to further customise the stroom configuration then it is recommended to edit the `./volumes/stroom/config/config.yml` file.
This can either be a simple file with hard coded values or one that uses environment variables for some of its
configuration items.

The configuration works as follows:

```text
env file (stroom<stack name>.env)
                |
                |
                | environment variable substitution
                |
                v
docker compose YAML (01_stroom.yml)
                |
                |
                | environment variable substitution
                |
                v
Stroom configuration file (config.yml)
```


### Ansible

If you are using Ansible to deploy a stack then it is recommended that all of stroom's configuration properties are set directly in the `config.yml` file using a templated version of the file and to NOT use any environment variable substitution.
When using Ansible, the Ansible inventory is the single source of truth for your configuration so not using environment variable substitution for stroom simplifies the configuration and makes it clearer when looking at deployed configuration files.

[Stroom-ansible](https://github.com/gchq/stroom-ansible) has an example inventory for a single node stroom stack deployment.
The [group_vars/all](https://github.com/gchq/stroom-ansible/blob/master/config/single_node_stroom_core_stack/example_inventory/group_vars/all) file shows how values can be set into the _env_ file.


## Configuration Reference

```yaml
appConfig:
  haltBootOnConfigValidationFailure: true
  ...
```

The following sections document each level one branch of `appConfig`, e.g. `appConfig.receive`.

A common structure within the configuration is the [Cache Configuration]({{< relref "common-configuration#cache-configuration" >}}).
Typically any property name that ends `....Cache` has this structure.

Each functional area/module in Stroom has its own logical database connection.
Any property with the name `db` is a standard structure for configuring a database connection.
See [Common Database Configuration]({{< relref "#common-database-configuration" >}}).

This allows each module to, in theory, connect to a separate database, be they on one host or multiple.
In practice most Stroom deployments will use one database connection for all modules.
See [`commonDbDetails`]({{< relref "#commondbdetails" >}}) for details on how to use one shared database configuration.


### `activity`

```yaml
appConfig:
  activity:
    db: # Common database configuration branch
```


### `analytics`

```yaml
appConfig:
  analytics:
    db: # Common database configuration branch
    duplicateCheckStore:
      lmdb: # Common LMDB structure
        localDir: "lmdb/duplicate_check"
    emailConfig:
      fromAddress: "noreply@stroom"
      fromName: "Stroom Analytics"
      smtp:
        host: "localhost"
        password: null
        port: 2525
        transport: "plain"
        username: null
    executionHistoryRetention: "P10D"
    resultStore:
      lmdb: # Common LMDB structure
        localDir: "lmdb/analytic_store"
      maxPayloadSize: "1G"
      maxPutsBeforeCommit: 10000
      maxSortedItems: 500000
      maxStringFieldLength: 1000
      minPayloadSize: "1M"
      offHeapResults: true
      valueQueueSize: 10000
    streamingAnalyticCache: # Common cache structure
    timezone: "UTC"
```


### `annotation`

```yaml
appConfig:
  annotation:
    annotationFeedCache:
    annotationTagCache:
    createText: "Create Annotation"
    db:
    defaultRetentionPeriod: "5y"
    physicalDeleteAge: "P7D"
    standardComments: []
```


### `askStroomAi`

```yaml
appConfig:
  askStroomAi:
    chatMemory:
      timeToLive:
        time: 1
        timeUnit: "HOURS"
      tokenLimit: 30000
    tableSummary:
      maximumBatchSize: 16384
      maximumTableInputRows: 100
```


### `autoContentCreation`

```yaml
appConfig:
  autoContentCreation:

    #An optional group to add the group defined by groupTemplate to.
    #The value of this property is the name of a group. It can be the same 
    #as groupParentGroupName if required. 
    #It allows all the templated groups to belong to a common group for easier 
    #permission management.
    additionalGroupParentGroupName: "Data Feed Developer"

    #If set, when Stroom auto-creates a feed, it will create an additional user group with a 
    #name derived from this template. This is in addition to the user group defined by 'groupTemplate'.
    #If not set, only the latter user group will be created. Default value is 'grp-${accountid}-sandbox'. 
    #If this property is set in the YAML file, use single quotes to prevent the 
    #variables being expanded when the config file is loaded.
    additionalGroupTemplate: "grp-${accountid}-sandbox"

    #The subjectId of the user/group who the auto-created content will be created by, 
    #typically a group with administrator privileges. 
    #This user/group must have the permission to create all content required. It will also be the 
    #'run as' user for created pipeline processor filters.
    createAsSubjectId: "Administrators"

    #The type of the entity represented by createAsSubjectId, i.g. 'USER' or 'GROUP'. 
    #It is possible for content to be owned by a group rather than individual users.
    createAsType: "GROUP"

    #The templated path to a folder in the Stroom explorer tree where Stroom will auto-create 
    #content. If it doesn't exist it will be created. Content will be created in a sub-folder of this 
    #folder with a name derived from the system name of the received data. By default this is 
    #'Feeds/${accountid}'.
    #If this property is set in the YAML file, use single quotes to prevent the 
    #variables being expanded when the config file is loaded.
    destinationExplorerPathTemplate: "/Feeds/${accountid}"

    #An optional templated sub-path of 'destinationExplorerPathTemplate'. If set, copied dependencies (e.g.
    #XSLT filters, Test Converters, etc.) will be created in the sub-directory defined by this template. 
    #If not set, that content will be created in the directory 
    destinationExplorerSubPathTemplate: "sandbox"

    #Whether the auto-creation of content on data receipt is enabled or not. 
    #If enabled, Stroom will automatically create content such as Feeds/XSLTs/Pipelines on receipt of 
    #a data stream. The property 'templatesPath' will contain content to be used as templates for 
    #auto-creation. Content will only be created if a Content Template rule matches the attributes 
    #on the incoming data.
    enabled: false

    #An optional group to add the group defined by groupTemplate to.
    #The value of this property is the name of a group. 
    #It allows all the templated groups to belong to a common group for easier 
    #permission management.
    groupParentGroupName: "Data Feed Reader"

    #When Stroom auto-creates a feed, it will create a user group with a 
    #name derived from this template. Default value is 'grp-${accountid}'. 
    #If this property is set in the YAML file, use single quotes to prevent the 
    #variables being expanded when the config file is loaded.
    groupTemplate: "grp-${accountid}"

    #The header keys available for use when matching a request to a content template. 
    #Must be in lower case.
    templateMatchFields:
    - "accountid"
    - "accountname"
    - "component"
    - "feed"
    - "format"
    - "schema"
    - "schemaversion"
```


### `byteBufferPool`

```yaml
appConfig:
  byteBufferPool:
    blockOnExhaustedPool: false
    pooledByteBufferCounts:
      1: 50
      10: 50
      100: 50
      1000: 50
      10000: 50
      100000: 10
      1000000: 3
    warningThresholdPercentage: 90
```


### `cluster`

```yaml
appConfig:
  cluster:
    clusterCallIgnoreSSLHostnameVerifier: true
    clusterCallReadTimeout: "PT30S"
    clusterCallUseLocal: true
    clusterResponseTimeout: "PT30S"
```


### `clusterLock`

```yaml
appConfig:
  clusterLock:
    db:
    lockTimeout: "PT10M"
```


### `commonDbDetails`

```yaml
appConfig:
  commonDbDetails:
```

`commonDbDetails` has the same structure as all the `db` branches.
It is used for defining a database connection configuration that will be used for all stroom functional areas/modules unless the module has explicitly configured its `db` configuration branch.



### `contentPackImport`

```yaml
appConfig:
  contentPackImport:
    enabled: false
    importAsSubjectId: "Administrators"
    importAsType: "GROUP"
    importDirectory: "content_pack_import"
```


### `contentStore`

```yaml
appConfig:
  contentStore:
    urls:
    - "https://raw.githubusercontent.com/gchq/stroom-content/refs/heads/master/source/content-store.yml"
```


### `credentials`

```yaml
appConfig:
  credentials:
    db:
    keyStoreCachePath: "${stroom.home}/keystores"
```


### `crossModule`

```yaml
appConfig:
  crossModule:
    db:
```


### `dashboard`

```yaml
appConfig:
  dashboard:
    visualisationDocCache:
      expireAfterAccess: null
      expireAfterWrite: "PT10M"
      maximumSize: 100
      refreshAfterWrite: null
      statisticsMode: "INTERNAL"
```


### `data`

```yaml
appConfig:
  data:
    filesystemVolume:
      createDefaultStreamVolumesOnStart: true
      defaultStreamVolumeFilesystemUtilisation: 0.9
      defaultStreamVolumeGroupName: "Default Volume Group"
      defaultStreamVolumePaths:
      - "volumes/default_stream_volume"
      feedPathCache:
      findOrphanedMetaBatchSize: 7000
      maxVolumeStateAge: "PT30S"
      metaTypeExtensions:
        Detections: "dtxn"
        Error: "err"
        Events: "evt"
        Raw Events: "revt"
        Raw Reference: "rref"
        Records: "rec"
        Reference: "ref"
        Test Events: "tevt"
        Test Reference: "tref"
      typePathCache:
      volumeCache:
      volumeSelector: "RoundRobin"
    meta:
      dataFormats:
      - "FIXED_WIDTH_NO_HEADER"
      - "INI"
      - "CSV"
      - "JSON"
      - "TEXT"
      - "XML_FRAGMENT"
      - "YAML"
      - "PSV_NO_HEADER"
      - "PSV"
      - "CSV_NO_HEADER"
      - "XML"
      - "TSV"
      - "SYSLOG"
      - "TSV_NO_HEADER"
      - "FIXED_WIDTH"
      - "TOML"
      db:
      metaFeedCache:
      metaProcessorCache:
      metaStatusUpdateBatchSize: 0
      metaTypeCache:
      metaTypes:
      - "Context"
      - "Raw Reference"
      - "Events"
      - "Raw Events"
      - "Reference"
      - "Error"
      - "Test Events"
      - "Test Reference"
      - "Detections"
      - "Meta Data"
      - "Records"
      metaValue:
        addAsync: true
        deleteAge: "P30D"
        deleteBatchSize: 500
        flushBatchSize: 500
      rawMetaTypes:
      - "Raw Reference"
      - "Raw Events"
    retention:
      deleteBatchSize: 1000
      useQueryOptimisation: true
    store:
      db:
      deleteBatchSize: 1000
      deleteFailureThreshold: 100
      deletePurgeAge: "P7D"
      fileSystemCleanBatchSize: 20
      fileSystemCleanDeleteOut: false
      fileSystemCleanOldAge: "P1D"
```


### `docstore`

```yaml
appConfig:
  docstore:
    db:
```


### `elastic`

```yaml
appConfig:
  elastic:
    client:
      maxConnections: 30
      maxConnectionsPerRoute: 10
    indexCache:
    indexClientCache:
    indexing:
      initialRetryBackoffPeriodMs: 1000
      maxNestedElementDepth: 10
      retryCount: 5
    search:
      highlight: true
      scrollDuration: "PT1M"
      storeSize: "1000000,100,10,1"
      suggestions:
        enabled: true
```


### `explorer`

```yaml
appConfig:
  explorer:
    db:
    dependencyWarningsEnabled: false
    docRefInfoCache:
    suggestedTags:
    - "reference-loader"
    - "dynamic"
    - "extraction"
```


### `export`

```yaml
appConfig:
  export:
    enabled: false
```


### `feed`

```yaml
appConfig:
  feed:
    feedDocCache:
    feedNamePattern: "^[A-Z0-9_-]{3,}$"
    unknownClassification: "UNKNOWN CLASSIFICATION"
```


### `gitRepo`

```yaml
appConfig:
  gitRepo:
    db:
    localDir: "git_repo"
```


### `index`

```yaml
appConfig:
  index:
    db:
    indexCache:
    indexFieldCache:
    ramBufferSizeMB: 1024
    writer:
      activeShardCache:
      cache:
        coreItems: 50
        maxItems: 100
        minItems: 0
        timeToIdle: "PT0S"
        timeToLive: "PT0S"
      indexShardWriterCache:
      slowIndexWriteWarningThreshold: "PT1S"
```


### `job`

```yaml
appConfig:
  job:
    db:
    enableJobsOnBootstrap: false
    enabled: true
    executionInterval: "10s"
```


### `kafka`

```yaml
appConfig:
  kafka:
    kafkaConfigDocCache:
      expireAfterAccess: "PT10S"
      expireAfterWrite: null
      maximumSize: 1000
      refreshAfterWrite: null
      statisticsMode: "INTERNAL"
    skeletonConfigContent: ".........TRUNCATED..........."
```


### `lifecycle`

```yaml
appConfig:
  lifecycle:
    enabled: true
```


### `lmdbLibrary`

```yaml
appConfig:
  lmdbLibrary:
    providedSystemLibraryPath: null
    systemLibraryExtractDir: "lmdb_library"
```


### `logging`

```yaml
appConfig:
  logging:
    deviceCache:
    logEveryRestCallEnabled: false
    maxDataElementStringLength: 500
    maxListElements: 5
    omitRecordDetailsLoggingEnabled: true
```


### `node`

```yaml
appConfig:
  node:
    db:
    name: "tba"
    status:
      heapHistogram:
        classNameMatchRegex: "^stroom\\..*$"
        classNameReplacementRegex: "((?<=\\$Proxy)[0-9]+|(?<=\\$\\$)[0-9a-f]+|(?<=\\\
          $\\$Lambda\\$)[0-9]+\\/[0-9]+)"
```


### `nodeUri`

```yaml
appConfig:
  nodeUri:
    hostname: null
    pathPrefix: null
    port: null
    scheme: null
```


### `path`

```yaml
appConfig:
  path:
    home: null
    temp: null
```


### `pipeline`

```yaml
appConfig:
  pipeline:
    appender:
      maxActiveDestinations: 100
    documentPermissionCache:
    httpClientCache:
    parser:
      cache:
      secureProcessing: true
    pipelineDataCache:
    referenceData:
      effectiveStreamCache:
      lmdb:
        localDir: "reference_data"
        readerBlockedByWriter: true
      loadingLockStripes: 2048
      maxPurgeDeletesBeforeCommit: 200000
      maxPutsBeforeCommit: 200000
      metaIdToRefStoreCache:
        expireAfterAccess: "PT1H"
        expireAfterWrite: null
        maximumSize: 1000
        refreshAfterWrite: null
        statisticsMode: "INTERNAL"
      purgeAge: "P30D"
      stagingLmdb:
        localDir: "reference_staging_data"
        maxReaders: 5
        maxStoreSize: "10G"
        readAheadEnabled: true
        readerBlockedByWriter: false
    xmlSchema:
      cache:
        expireAfterAccess: "PT10M"
        expireAfterWrite: null
        maximumSize: 1000
        refreshAfterWrite: null
        statisticsMode: "INTERNAL"
    xslt:
      cache:
        expireAfterAccess: "PT10M"
        expireAfterWrite: null
        maximumSize: 1000
        refreshAfterWrite: null
        statisticsMode: "INTERNAL"
      maxElements: 1000000
```


### `planb`

```yaml
appConfig:
  planb:
    minTimeToKeepEnvOpen: "PT1M"
    minTimeToKeepSnapshots: "PT10M"
    nodeList: []
    path: "${stroom.home}/planb"
    snapshotRetryFetchInterval: "PT1M"
    stateDocCache:
```


### `processor`

```yaml
appConfig:
  processor:
    assignTasks: true
    createTasksBeyondProcessLimit: true
    databaseMultiInsertMaxBatchSize: 500
    db:
    deleteAge: "P1D"
    disownDeadTasksAfter: "PT10M"
    fillTaskQueue: true
    processorCache:
    processorFeedCache:
    processorFilterCache:
    processorNodeCache:
    queueSize: 1000
    skipNonProducingFiltersDuration: "PT10S"
    taskCreationThreadCount: 5
    tasksToCreate: 1000
    waitToQueueTasksDuration: "PT10S"
```


### `properties`

```yaml
appConfig:
  properties:
    db:
```


### `publicUri`

```yaml
appConfig:
  publicUri:
    hostname: null
    pathPrefix: null
    port: null
    scheme: "https"
```


### `queryDataSource`

```yaml
appConfig:
  queryDataSource:
    db:
```


### `queryHistory`

```yaml
appConfig:
  queryHistory:
    daysRetention: 365
    db:
    itemsRetention: 100
```


### `receiptPolicy`

```yaml
appConfig:
  receiptPolicy:
    obfuscatedFields:
    - "AccountId"
    - "AccountName"
    - "Component"
    - "Feed"
    - "ReceivedPath"
    - "RemoteDN"
    - "RemoteHost"
    - "System"
    - "UploadUserId"
    - "UploadUsername"
    - "X-Forwarded-For"
    obfuscationHashAlgorithm: "SHA2_512"
    receiptRulesInitialFields:
      AccountId: "Text"
      Component: "Text"
      Compression: "Text"
      content-length: "Text"
      ContextEncoding: "Text"
      ContextFormat: "Text"
      EffectiveTime: "Date"
      Encoding: "Text"
      Environment: "Text"
      Feed: "Text"
      Format: "Text"
      ReceiptId: "Text"
      ReceiptIdPath: "Text"
      ReceivedPath: "Text"
      ReceivedTime: "Date"
      ReceivedTimeHistory: "Text"
      RemoteCertExpiry: "Date"
      RemoteDN: "Text"
      RemoteHost: "Text"
      RemoteAddress: "Text"
      Schema: "Text"
      SchemaVersion: "Text"
      System: "Text"
      Type: "Text"
      UploadUsername: "Text"
      UploadUserId: "Text"
      user-agent: "Text"
      X-Forwarded-For: "Text"
```


### `receive`

```yaml
appConfig:
  receive:
```

The `receive` configuration branch is common to both Stroom and Stroom Proxy.
See [Receive Configuration]({{< relref "common-configuration#receive-configuration" >}}) for more details.


### `s3`

```yaml
appConfig:
  s3:
    s3ConfigDocCache:
    skeletonConfigContent: "{\n  \"credentialsProviderType\" : \"DEFAULT\",\n  \"\
      region\" : \"eu-west-2\",\n  \"bucketName\" : \"XXXX-eu-west-2\",\n  \"keyPattern\"\
      \ : \"${type}/${year}/${month}/${day}/${idPath}/${feed}/${idPadded}.zip\"\n\
      }\n"
```


### `search`

```yaml
appConfig:
  search:
    extraction:
      extractionDelayMs: 100
      maxStoredDataQueueSize: 1000
      maxStreamEventMapSize: 1000000
      maxThreadsPerTask: 5
    maxBooleanClauseCount: 1024
    maxStoredDataQueueSize: 1000
    resultStore:
      lmdb:
        localDir: "search_results"
        maxReaders: 10
        maxStoreSize: "10G"
        readAheadEnabled: true
      map:
        minUntrimmedSize: 100000
        trimmedSizeLimit: 500000
      maxPayloadSize: "1G"
      maxPutsBeforeCommit: 10000
      maxSortedItems: 500000
      maxStringFieldLength: 1000
      minPayloadSize: "1M"
      offHeapResults: true
      valueQueueSize: 10000
    shard:
      indexShardSearcherCache:
      maxDocIdQueueSize: 1000000
      maxThreadsPerTask: 5
      remoteSearchResultCache:
```


### `security`

```yaml
appConfig:
  security:
    authentication:
      apiKeyCache:
      authenticationStateCache:
      maxApiKeyExpiryAge: "P365D"
      openId:
        allowedAudiences: []
        audienceClaimRequired: false
        authEndpoint: null
        clientCredentialsScopes:
        - "openid"
        clientId: null
        clientSecret: null
        expectedSignerPrefixes: []
        formTokenRequest: true
        fullNameClaimTemplate: "${name}"
        identityProviderType: "INTERNAL_IDP"
        issuer: null
        jwksUri: null
        logoutEndpoint: null
        logoutRedirectParamName: "post_logout_redirect_uri"
        openIdConfigurationEndpoint: null
        publicKeyUriPattern: "https://public-keys.auth.elb.${awsRegion}.amazonaws.com/${keyId}"
        requestScopes:
        - "openid"
        - "email"
        tokenEndpoint: null
        uniqueIdentityClaim: "sub"
        userDisplayNameClaim: "preferred_username"
        validIssuers: []
      preventLogin: false
    authorisation:
      appPermissionIdCache:
      db:
      docTypeIdCache:
      userAppPermissionsCache:
      userByUuidCache:
      userCache:
      userDocumentPermissionsCache:
      userGroupsCache:
      userInfoByUuidCache:
    crypto:
      secretEncryptionKey: ""
    identity:
      allowCertificateAuthentication: false
      autoCreateAdminAccountOnBoot: false
      certificateCnCaptureGroupIndex: 1
      certificateCnPattern: ".*\\((.*)\\)"
      db:
      email:
        allowPasswordResets: false
        fromAddress: "noreply@stroom"
        fromName: "Stroom User Accounts"
        passwordResetSubject: "Password reset for Stroom"
        passwordResetText: "A password reset has been requested for this email address.\
          \ Please visit the following URL to reset your password: %s."
        passwordResetUrl: "/s/resetPassword/?user=%s&token=%s"
        smtp:
          host: "localhost"
          password: null
          port: 2525
          transport: "plain"
          username: null
      failedLoginLockThreshold: 3
      openid:
        accessCodeCache:
        refreshTokenCache:
      passwordPolicy:
        allowPasswordResets: true
        forcePasswordChangeOnFirstLogin: true
        mandatoryPasswordChangeDuration: "P90D"
        minimumPasswordLength: 8
        minimumPasswordStrength: 3
        neverUsedAccountDeactivationThreshold: "P30D"
        passwordComplexityRegex: ".*"
        passwordPolicyMessage: "To conform with our Strong Password policy, you are\
          \ required to use a sufficiently strong password. Password must be more\
          \ than 8 characters."
        unusedAccountDeactivationThreshold: "P90D"
      token:
        accessTokenExpiration: "PT1H"
        algorithm: "RS256"
        defaultApiKeyExpiration: "P365D"
        emailResetTokenExpiration: "PT10M"
        idTokenExpiration: "PT1H"
        jwsIssuer: "stroom"
        refreshTokenExpiration: "P30D"
    webContent:
      contentSecurityPolicy: "default-src 'self'; script-src 'self' 'unsafe-eval'\
        \ 'unsafe-inline'; img-src 'self' data:; style-src 'self' 'unsafe-inline';\
        \ frame-ancestors 'self';"
      contentTypeOptions: "nosniff"
      frameOptions: "sameorigin"
      strictTransportSecurity: "max-age=31536000; includeSubDomains; preload"
      xssProtection: "1; mode=block"
```


### `session`

```yaml
appConfig:
  session:
    maxInactiveInterval: "P7D"
```


### `sessionCookie`

```yaml
appConfig:
  sessionCookie:
    httpOnly: true
    sameSite: "STRICT"
    secure: true
```


### `solr`

```yaml
appConfig:
  solr:
    indexCache:
    indexClientCache:
    search:
      maxBooleanClauseCount: 1024
      maxStoredDataQueueSize: 1000
```


### `state`

```yaml
appConfig:
  state:
    scyllaDbDocCache:
    sessionCache:
    stateDocCache:
```


### `statistics`

```yaml
appConfig:
  statistics:
    hbase:
      docRefType: "StroomStatsStore"
      eventsPerMessage: 100
      kafkaConfigUuid: null
      kafkaTopics:
        count: "statisticEvents-Count"
        value: "statisticEvents-Value"
    internal:
      benchmarkCluster:
      - type: "StatisticStore"
        uuid: "946a88c6-a59a-11e6-bdc4-0242ac110002"
        name: "Benchmark-Cluster Test"
      - type: "StroomStatsStore"
        uuid: "2503f703-5ce0-4432-b9d4-e3272178f47e"
        name: "Benchmark-Cluster Test"
      cpu:
      - type: "StatisticStore"
        uuid: "af08c4a7-ee7c-44e4-8f5e-e9c6be280434"
        name: "CPU"
      - type: "StroomStatsStore"
        uuid: "1edfd582-5e60-413a-b91c-151bd544da47"
        name: "CPU"
      enabledStoreTypes:
      - "StatisticStore"
      eventsPerSecond:
      - type: "StatisticStore"
        uuid: "a9936548-2572-448b-9d5b-8543052c4d92"
        name: "EPS"
      - type: "StroomStatsStore"
        uuid: "cde67df0-0f77-45d3-b2c0-ee8bb7b3c9c6"
        name: "EPS"
      heapHistogramBytes:
      - type: "StatisticStore"
        uuid: "934a1600-b456-49bf-9aea-f1e84025febd"
        name: "Heap Histogram Bytes"
      - type: "StroomStatsStore"
        uuid: "b0110ab4-ac25-4b73-b4f6-96f2b50b456a"
        name: "Heap Histogram Bytes"
      heapHistogramInstances:
      - type: "StatisticStore"
        uuid: "e4f243b8-2c70-4d6e-9d5a-16466bf8764f"
        name: "Heap Histogram Instances"
      - type: "StroomStatsStore"
        uuid: "bdd933a4-4309-47fd-98f6-1bc2eb555f20"
        name: "Heap Histogram Instances"
      memory:
      - type: "StatisticStore"
        uuid: "77c09ccb-e251-4ca5-bca0-56a842654397"
        name: "Memory"
      - type: "StroomStatsStore"
        uuid: "d8a7da4f-ef6d-47e0-b16a-af26367a2798"
        name: "Memory"
      metaDataStreamSize:
      - type: "StatisticStore"
        uuid: "946a8814-a59a-11e6-bdc4-0242ac110002"
        name: "Meta Data-Stream Size"
      - type: "StroomStatsStore"
        uuid: "3b25d63b-5472-44d0-80e8-8eea94f40f14"
        name: "Meta Data-Stream Size"
      metaDataStreamsReceived:
      - type: "StatisticStore"
        uuid: "946a87bc-a59a-11e6-bdc4-0242ac110002"
        name: "Meta Data-Streams Received"
      - type: "StroomStatsStore"
        uuid: "5535f493-29ae-4ee6-bba6-735aa3104136"
        name: "Meta Data-Streams Received"
      pipelineStreamProcessor:
      - type: "StatisticStore"
        uuid: "946a80fc-a59a-11e6-bdc4-0242ac110002"
        name: "PipelineStreamProcessor"
      - type: "StroomStatsStore"
        uuid: "efd9bad4-0bab-460f-ae98-79e9717deeaf"
        name: "PipelineStreamProcessor"
      refDataStoreEntryCount:
      - type: "StatisticStore"
        uuid: "f1587262-9cbc-46b4-80eb-51deb011b2c1"
        name: "Reference Data Store Entry Count"
      - type: "StroomStatsStore"
        uuid: "TODO"
        name: "Reference Data Store Entry Count"
      refDataStoreSize:
      - type: "StatisticStore"
        uuid: "e57959bf-0b2d-4008-98a7-ffcae4bbc4bb"
        name: "Reference Data Store Size"
      - type: "StroomStatsStore"
        uuid: "TODO"
        name: "Reference Data Store Size"
      refDataStoreStreamCount:
      - type: "StatisticStore"
        uuid: "0dfd4e00-e068-4667-9c60-d3f6163a6c04"
        name: "Reference Data Store Stream Count"
      - type: "StroomStatsStore"
        uuid: "TODO"
        name: "Reference Data Store Stream Count"
      searchResultsStoreCount:
      - type: "StatisticStore"
        uuid: "35d60e7d-f11a-45c9-981d-16d8ddda081e"
        name: "Search Results Store Count"
      - type: "StroomStatsStore"
        uuid: "TODO"
        name: "Search Results Store Count"
      searchResultsStoreSize:
      - type: "StatisticStore"
        uuid: "de5b831d-3b7e-4bb5-836f-2f438ec30568"
        name: "Search Results Store Size"
      - type: "StroomStatsStore"
        uuid: "TODO"
        name: "Search Results Store Size"
      streamTaskQueueSize:
      - type: "StatisticStore"
        uuid: "946a7f0f-a59a-11e6-bdc4-0242ac110002"
        name: "Stream Task Queue Size"
      - type: "StroomStatsStore"
        uuid: "4ce8d6e7-94be-40e1-8294-bf29dd089962"
        name: "Stream Task Queue Size"
      volumes:
      - type: "StatisticStore"
        uuid: "ac4d8d10-6f75-4946-9708-18b8cb42a5a3"
        name: "Volumes"
      - type: "StroomStatsStore"
        uuid: "60f4f5f0-4cc3-42d6-8fe7-21a7cec30f8e"
        name: "Volumes"
    sql:
      dataSourceCache:
      db:
      docRefType: "StatisticStore"
      inMemAggregatorPoolSize: 10
      inMemFinalAggregatorSizeThreshold: 1000000
      inMemPooledAggregatorAgeThreshold: "PT5M"
      inMemPooledAggregatorSizeThreshold: 1000000
      maxProcessingAge: null
      search:
        fetchSize: 5000
        maxResults: 100000
      slowQueryWarningThreshold: "PT1S"
      statisticAggregationBatchSize: 1000000
      statisticAggregationStageTwoBatchSize: 200000
      statisticFlushBatchSize: 8000
```


### `ui`

```yaml
appConfig:
  ui:
    aboutHtml: "<h1>About Stroom</h1><p>Stroom is designed to receive data from multiple\
      \ systems.</p>"
    activity:
      chooseOnStartup: false
      editorBody: "Activity Code:</br><input type=\"text\" name=\"code\"></input></br></br>Activity\
        \ Description:</br><textarea rows=\"4\" style=\"width:100%;height:80px\" name=\"\
        description\" validation=\".{80,}\" validationMessage=\"The activity description\
        \ must be at least 80 characters long.\" ></textarea>Explain what the activity\
        \ is"
      editorTitle: "Edit Activity"
      enabled: false
      managerTitle: "Choose Activity"
    analyticUiDefaultConfig:
      defaultBodyTemplate: "<!DOCTYPE html>\n<html lang=\"en\">\n<meta charset=\"\
        UTF-8\" />\n<title>Detector '{{ detectorName | escape }}' Alert</title>\n\
        <body>\n  <p>Detector <em>{{ detectorName | escape }}</em> {{ detectorVersion\
        \ | escape }} fired at {{ detectTime | escape }}</p>\n\n  {%- if (values |\
        \ length) > 0 -%}\n  <p>Detail: {{ headline | escape }}</p>\n  <ul>\n    {%\
        \ for key, val in values | dictsort -%}\n      <li><strong>{{ key | escape\
        \ }}</strong>: {{ val | escape }}</li>\n    {% endfor %}\n  </ul>\n  {% endif\
        \ -%}\n\n  {%- if (linkedEvents | length) > 0 -%}\n  <p>Linked Events:</p>\n\
        \  <ul>\n    {% for linkedEvent in linkedEvents -%}\n      <li>Environment:\
        \ {{ linkedEvent.stroom | escape }}, Stream ID: {{ linkedEvent.streamId |\
        \ escape }}, Event ID: {{ linkedEvent.eventId | escape }}</li>\n    {% endfor\
        \ %}\n  </ul>\n  {% endif %}\n</body>\n"
      defaultSubjectTemplate: "Detector '{{ detectorName | escape }}' Alert"
    defaultApiKeyHashAlgorithm: "SHA3_256"
    defaultMaxResults: "1000000,100,10,1"
    helpSubPathDocumentation: "/user-guide/content/documentation/"
    helpSubPathExpressions: "/user-guide/dashboards/expressions/"
    helpSubPathJobs: "/reference-section/jobs/"
    helpSubPathProperties: "/user-guide/properties/"
    helpSubPathQuickFilter: "/user-guide/finding-things/"
    helpSubPathStroomQueryLanguage: "/user-guide/dashboards/stroom-query-language/"
    helpUrl: "https://gchq.github.io/stroom-docs/7.5/docs"
    htmlTitle: "Stroom"
    maxEditorCompletionEntries: 1000
    namePattern: "^[a-zA-Z0-9_\\- \\.\\(\\)]{1,}$"
    nestedIndexFieldsDelimiterPattern: "[.:]"
    nodeMonitoring:
      pingMaxThreshold: 500
      pingWarnThreshold: 100
    oncontextmenu: "return false;"
    process:
      defaultRecordLimit: 1000000
      defaultTimeLimit: 30
    query:
      dashboardPipelineSelectorIncludedTags:
      - "extraction"
      indexPipelineSelectorIncludedTags:
      - "extraction"
      infoPopup:
        enabled: false
        title: "Please Provide Query Info"
        validationRegex: "^[\\s\\S]{3,}$"
      viewPipelineSelectorIncludedTags:
      - "extraction"
    referencePipelineSelectorIncludedTags:
    - "reference-loader"
    reportUiDefaultConfig:
      defaultBodyTemplate: "<!DOCTYPE html>\n<html lang=\"en\">\n<meta charset=\"\
        UTF-8\" />\n<title>Report '{{ reportName | escape }}'</title>\n<body>\n <p><em>Report:\
        \ {{ reportName | escape }}</em>  executed for {{ effectiveExecutionTime |\
        \ escape }} on {{ executionTime | escape }}</p>\n <p><em>Description:</em>\
        \  {{ description | escape }}</p>\n</body>\n"
      defaultSubjectTemplate: "Report '{{ reportName | escape }}'"
    source:
      maxCharactersInPreviewFetch: 30000
      maxCharactersPerFetch: 80000
      maxCharactersToCompleteLine: 10000
      maxHexDumpLines: 1000
    splash:
      body: "<h1>About Stroom</h1><p>Stroom is designed to receive data from multiple\
        \ systems.</p>"
      enabled: false
      title: "Splash Screen"
      version: "v0.1"
    theme:
      labelColours: "TEST1=#FF0000,TEST2=#FF9900"
    welcomeHtml: "<h1>About Stroom</h1><p>Stroom is designed to receive data from\
      \ multiple systems.</p>"
```


### `uiUri`

```yaml
appConfig:
  uiUri:
    hostname: null
    pathPrefix: null
    port: null
    scheme: "https"
```


### `volumes`

```yaml
appConfig:
  volumes:
    createDefaultIndexVolumesOnStart: true
    defaultIndexVolumeFilesystemUtilisation: 0.9
    defaultIndexVolumeGroupName: "Default Volume Group"
    defaultIndexVolumeGroupPaths:
    - "volumes/default_index_volume"
    volumeSelector: "RoundRobin"
    volumeSelectorCache:
```


### Common Configuration Structures

The following are configuration branch structures that are used in multiple places in Stroom's configuration.


#### Common Database Configuration

The following shows the structure of the common database configuration that features in many of the above configuration branches.
Any property with the name `db` will follow this structure.

```yaml
    db:
      connection:
        jdbcDriverClassName: null
        jdbcDriverPassword: null
        jdbcDriverUrl: null
        jdbcDriverUsername: null
      connectionPool:
        cachePrepStmts: false
        connectionTimeout: "PT30S"
        idleTimeout: "PT10M"
        leakDetectionThreshold: "PT0S"
        maxLifetime: "PT30M"
        maxPoolSize: 30
        minimumIdle: 10
        prepStmtCacheSize: 25
        prepStmtCacheSqlLimit: 256
```


#### Common LMDB Configuration

```yaml
lmdb:
  # The directory where the LMDB files will be persisted
  localDir: "lmdb/xxxxxx"
  # The maximum number of concurrent readers
  maxReaders: 10
  # The maximum size the store can grow to
  maxStoreSize: "10G"
  # If true LMDB with read additional pages of data to optimistically hold
  # in the page cache.
  readAheadEnabled: true
  # If true readers will be blocked when other threads are writing.
  # This can prevent excessive store size growth if reading and writing happens concurrently.
  readerBlockedByWriter: true
```

