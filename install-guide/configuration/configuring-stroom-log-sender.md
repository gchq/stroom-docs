# Stroom log sender Configuration

> **Version Information:** Created with Stroom v7.0  
> **Last Updated:** 2021-06-14

Stroom log sender is a docker image used for sending application logs to stroom.
It is essentially just a combination of the [send_to_stroom.sh (external link)](https://github.com/gchq/stroom-clients/tree/master/bash) script and a set of crontab entries to call the script at intervals.

## Deploying without Docker

When deploying without docker stroom and stroom-proxy nodes will need to be configured to send their logs to stroom.
This can be done using the `./bin/send_to_stroom.sh` script in the stroom and stroom-proxy zip distributions and some crontab configuration.

The crontab file for the user account running stroom should be edited (`crontab -e`) and set to something like:

```crontab
# stroom logs
* * * * * STROOM_HOME=<path to stroom home> ${STROOM_HOME}/bin/send_to_stroom.sh ${STROOM_HOME}/logs/access STROOM-ACCESS-EVENTS <datafeed URL> --system STROOM --environment <environment> --file-regex '.*/[a-z]+-[0-9]{4}-[0-9]{2}-[0-9]{2}T.*\\.log' --max-sleep 10 --key <key file> --cert <cert file> --cacert <CA cert file> --delete-after-sending --compress >> <path to log> 2>&1
* * * * * STROOM_HOME=<path to stroom home> ${STROOM_HOME}/bin/send_to_stroom.sh ${STROOM_HOME}/logs/app    STROOM-APP-EVENTS    <datafeed URL> --system STROOM --environment <environment> --file-regex '.*/[a-z]+-[0-9]{4}-[0-9]{2}-[0-9]{2}T.*\\.log' --max-sleep 10 --key <key file> --cert <cert file> --cacert <CA cert file> --delete-after-sending --compress >> <path to log> 2>&1
* * * * * STROOM_HOME=<path to stroom home> ${STROOM_HOME}/bin/send_to_stroom.sh ${STROOM_HOME}/logs/user   STROOM-USER-EVENTS   <datafeed URL> --system STROOM --environment <environment> --file-regex '.*/[a-z]+-[0-9]{4}-[0-9]{2}-[0-9]{2}T.*\\.log' --max-sleep 10 --key <key file> --cert <cert file> --cacert <CA cert file> --delete-after-sending --compress >> <path to log> 2>&1

# stroom-proxy logs
* * * * * PROXY_HOME=<path to proxy home> ${PROXY_HOME}/bin/send_to_stroom.sh ${PROXY_HOME}/logs/access  STROOM_PROXY-ACCESS-EVENTS  <datafeed URL> --system STROOM-PROXY --environment <environment> --file-regex '.*/[a-z]+-[0-9]{4}-[0-9]{2}-[0-9]{2}T.*\\.log' --max-sleep 10 --key <key file> --cert <cert file> --cacert <CA cert file> --delete-after-sending --compress >> <path to log> 2>&1
* * * * * PROXY_HOME=<path to proxy home> ${PROXY_HOME}/bin/send_to_stroom.sh ${PROXY_HOME}/logs/app     STROOM_PROXY-APP-EVENTS     <datafeed URL> --system STROOM-PROXY --environment <environment> --file-regex '.*/[a-z]+-[0-9]{4}-[0-9]{2}-[0-9]{2}T.*\\.log' --max-sleep 10 --key <key file> --cert <cert file> --cacert <CA cert file> --delete-after-sending --compress >> <path to log> 2>&1
* * * * * PROXY_HOME=<path to proxy home> ${PROXY_HOME}/bin/send_to_stroom.sh ${PROXY_HOME}/logs/send    STROOM_PROXY-SEND-EVENTS    <datafeed URL> --system STROOM-PROXY --environment <environment> --file-regex '.*/[a-z]+-[0-9]{4}-[0-9]{2}-[0-9]{2}T.*\\.log' --max-sleep 10 --key <key file> --cert <cert file> --cacert <CA cert file> --delete-after-sending --compress >> <path to log> 2>&1
* * * * * PROXY_HOME=<path to proxy home> ${PROXY_HOME}/bin/send_to_stroom.sh ${PROXY_HOME}/logs/receive STROOM_PROXY-RECEIVE-EVENTS <datafeed URL> --system STROOM-PROXY --environment <environment> --file-regex '.*/[a-z]+-[0-9]{4}-[0-9]{2}-[0-9]{2}T.*\\.log' --max-sleep 10 --key <key file> --cert <cert file> --cacert <CA cert file> --delete-after-sending --compress >> <path to log> 2>&1
```

where the environment specific values are:

* `<path to stroom home>` - The absolute path to the stroom home, i.e. the location of the `start.sh` script.
* `<path to proxy home>` - The absolute path to the stroom-proxy home, i.e. the location of the `start.sh` script.
* `<datafeed URL>` - The URL that the logs will be sent to.
  This will typically be the nginx host or load balancer and the path will typically be `https://host/datafeeddirect` to bypass the proxy for faster access to the logs.
* `<environment>` - The environment name that the stroom/proxy is deployed in, e.g. OPS, REF, DEV, etc.
* `<key file>` - The absolute path to the SSL key file used by curl.
* `<cert file>` - The absolute path to the SSL certificate file used by curl.
* `<CA cert file>` - The absolute path to the SSL certificate authority file used by curl.
* `<path to log>` - The absolute path to a log file to log all the send_to_stroom.sh output to.


If your implementation of cron supports environment variables then you can define some of the common values at the top of the crontab file and use them in the entries.
`cronie` as used by Centos does not support environment variables in the crontab file but variables can be defined at the line level as has been shown with STROOM_HOME and PROXY_HOME.

The above crontab entries assume that stroom and stroom-proxy are running on the same host.
If there are not then the entries can be split across the hosts accordingly.

### Service host(s)

When deploying stroom/stroom-proxy without stroom you may still be deploying the service stack (nginx and stroom-log-sender) to a host.
In this case see [As part of a docker stack](#as-part-of-a-docker-stack) below for details of how to configure stroom-log-sender to send the nginx logs.


## As part of a docker stack

### Crontab

The docker stacks include the stroom-log-sender docker image for sending the logs of all the other containers to stroom.
Stroom-log-sender is configured using the crontab file `volumes/stroom-log-sender/conf/crontab.txt`.
When the container starts this file will be read.
Any variables in it will be substituted with the values from the corresponding environment variables that are present in the container.
These common values can be set in the `config/<stack name>.env` file.

As the variables are substituted on container start you will need to restart the container following any configuration change.

### Certificates

The directory `volumes/stroom-log-sender/certs` contains the default client certificates used for the stack.
These allow stroom-log-sender to send the log files over SSL which also provides stroom with details of the sender.
These will need to be replaced in a production environment.

```
volumes/stroom-log-sender/certs/ca.pem.crt
volumes/stroom-log-sender/certs/client.pem.crt
volumes/stroom-log-sender/certs/client.unencrypted.key
```

For a production deployment these will need to be changed, see [Certificates](../configuration.md#configuration)

