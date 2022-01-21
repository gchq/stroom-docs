---
title: "send_to_stroom.sh (Linux)"
linkTitle: "send_to_stroom.sh (Linux)"
#weight:
date: 2022-01-13
tags: 
description: >
  A shell script for sending logs to Stroom or one of its proxies
---

[send_to_stroom.sh (external link)](https://github.com/gchq/stroom-clients/releases) is a small bash script to make it easier to send data to _stroom_.
To use it download the following files using wget or similar, replacing `SEND_TO_STROOM_VER` with the latest released version from [here (external link)](https://github.com/gchq/stroom-clients/releases):

```bash
SEND_TO_STROOM_VER="send-to-stroom-v2.0" && \
    wget "https://raw.githubusercontent.com/gchq/stroom-clients/${SEND_TO_STROOM_VER}/bash/send_to_stroom.sh" && \
    wget "https://raw.githubusercontent.com/gchq/stroom-clients/${SEND_TO_STROOM_VER}/bash/send_to_stroom_args.sh" && \
    chmod u+x send_to_stroom*.sh
```

To see the help for _send_to_stroom.sh_, enter `./send_to_stroom.sh --help`

The following is an example of using _send_to_stroom.sh_ to send all logs in a directory:

``` bash
./send_to_stroom.sh \
    --delete-after-sending \
    --file-regex ".*/access-[0-9]+.*\.log(\.gz)?$" \
    --key ./client..key \
    --cert ./client.pem.crt \
    --cacert ./ca.pem.crt \
    /some_directory/logs \
    MY_FEED \
    MY_SYSTEM \
    DEV \
    https://stroom-host/stroom/datafeed
```
