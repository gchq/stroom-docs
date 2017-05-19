
## Building a Docker image from a Stroom distribution

These instructions show how to build MySQL from Docker Hub and Stroom from source code. 

### MySQL 
Build as when [running a docker](docker-running.md).

### Stroom

#### Create configuration file
Stroom will look for configuration in `~/.stroom/stroom.conf`. You can create a basic configuration file like this:

```bash
mkdir ~/.stroom
cd ~/.stroom
wget https://raw.githubusercontent.com/gchq/stroom-docs/master/dev-guide/resources/stroom.conf
```

#### Clone and build `event-logging`

```bash
git clone https://github.com/gchq/event-logging.git
cd event-logging
mvn clean install
cd ..
```

#### Clone and build `stroom`

```bash
git clone https://github.com/gchq/stroom.git
gradle clean build
```

####  Unpack the Stroom distribution in preparation for building the docker image

```bash
cd stroom-app-distribution
unzip target/stroom-app-distribution-<version>-bin.zip -d target
```

### Building and running the docker image

```bash
docker stop stroom
docker rm stroom
docker rmi stroom

docker build --tag=stroom:latest target/stroom-app
docker run -p 8080:8080 --link stroom-db --link stroom-stats-db -v ~/.stroom:/root/.stroom --name=stroom -e STROOM_JDBC_DRIVER_URL="jdbc:mysql://stroom-db/stroom?useUnicode=yes&characterEncoding=UTF-8" -e STROOM_JDBC_DRIVER_USERNAME="stroomuser" -e STROOM_JDBC_DRIVER_PASSWORD="stroompassword1" -e STROOM_STATISTICS_SQL_JDBC_DRIVER_URL="jdbc:mysql://stroom-stats-db/statistics?useUnicode=yes&characterEncoding=UTF-8" -e STROOM_STATISTICS_SQL_JDBC_DRIVER_USERNAME="stroomuser" -e STROOM_STATISTICS_SQL_JDBC_DRIVER_PASSWORD="stroompassword1" stroom
```

Navigate to [http://localhost:8080/stroom/stroom.jsp](http://localhost:8080/stroom/stroom.jsp) to see Stroom running.

## Releasing the Docker image to Docker Hub (or any other Docker registry)

1. Build an image using the method above, and then test it.

2. Check that the image name is correct. For Docker Hub the Stroom image needs to be called `gchq/stroom` so that it gets pushed to the GCHQ Docker Hub organisation. You can rename it like this: `docker tag stroom:latest gchq/stroom:latest`.

3. Log in to the registry using `docker login` followed by your credentials when prompted. 

4. Push the image up using `docker push gchq/stroom`.

### Docker Hub links
[The Stroom image](https://hub.docker.com/r/gchq/stroom/docker-running.md)

[The GCHQ organisation](https://hub.docker.com/u/gchq/docker-running.md)
