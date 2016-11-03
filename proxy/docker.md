# Stroom Proxy

## Clone and build 'stroom-proxy'

```bash
git clone http://<HOST>/scm/ace/stroom-proxy.git
mvn clean install
```

##  Unpack the `stroom-proxy` distribution in preparation for building the docker iamge

```bash
cd stroom-proxy-distribution
unzip target/stroom-proxy-distribution-<version>-bin.zip -d target
```

## Building and running the docker image
Here you need to say where you want data to be sent by `stroom-proxy`. This is done using a [`--build-arg`](https://docs.docker.com/engine/reference/commandline/build/#/set-build-time-variables-build-arg) parameter of `STROOM_PROXY_TYPE`. These values can be `forward`, `store`, or `store_nodb`. See the `stroom-proxy` (TODO:link) documentation for more details about these options.

```bash
docker stop stroom-proxy
docker rm stroom-proxy
docker rmi stroom-proxy

docker build --build-arg STROOM_PROXY_TYPE=store_nodb --tag=stroom-proxy:latest target/stroom-proxy
docker run -p 8080:8080 --name=stroom-proxy stroom-proxy
```