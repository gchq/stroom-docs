# Running Stroom in a Docker Container

This is how to run Stroom in a Docker container (assuming you have already installed Docker). There are two options for running Stroom within a Docker container.

* [Using a pre-built Docker Hub image](#using-a-pre-built-docker-hub-image)
* [Building a Docker image from a Stroom distribution](#building-a-docker-image-from-a-stroom-distribution)

The first option of using a pre-built _Docker Hub_ image is the quickest and easiest way to get Stroom up and running.

## Using a pre-built _Docker Hub_ image for Stroom 5.0

```bash
# If you have already run stroom/stroom-db in Docker then clean up any old images
docker stop stroom
docker stop stroom-db
docker stop stroom-stats-db
docker rm stroom
docker rm stroom-db
docker rm stroom-stats-db
docker rmi stroom

# Run up the databases
docker run --name stroom-db -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_USER=stroomuser -e MYSQL_PASSWORD=stroompassword1 -e MYSQL_DATABASE=stroom -d mysql:5.6
docker run --name stroom-stats-db -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_USER=stroomuser -e MYSQL_PASSWORD=stroompassword1 -e MYSQL_DATABASE=statistics -d mysql:5.6

# Grab the IP addresses of the databases
stroomDbIp=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' stroom-db`
stroomStatsDbIp=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' stroom-stats-db`

# Run up Stroom 5.0
docker run -p 8080:8080 -v ~/.stroom:/root/.stroom --name=stroom -e STROOM_JDBC_DRIVER_URL="jdbc:mysql://$stroomDbIp/stroom?useUnicode=yes&characterEncoding=UTF-8" -e STROOM_JDBC_DRIVER_USERNAME="stroomuser" -e STROOM_JDBC_DRIVER_PASSWORD="stroompassword1" -e STROOM_STATISTICS_SQL_JDBC_DRIVER_URL="jdbc:mysql://$stroomStatsDbIp/statistics?useUnicode=yes&characterEncoding=UTF-8" -e STROOM_STATISTICS_SQL_JDBC_DRIVER_USERNAME="stroomuser" -e STROOM_STATISTICS_SQL_JDBC_DRIVER_PASSWORD="stroompassword1" gchq/stroom:5.0-beta.21
```

Now open a browser (preferably Chrome) at [localhost:8080/stroom](http://localhost:8080/stroom) to get started with Stroom.

## Building a Docker image from a Stroom distribution

These instructions show how to build MySQL from Docker Hub and Stroom from source code. 

### MySQL 
Build as above.

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
docker run -p 8080:8080 --link stroom-db -v ~/.stroom:/root/.stroom --name=stroom -e STROOM_JDBC_DRIVER_URL="jdbc:mysql://stroom-db/stroom?useUnicode=yes&characterEncoding=UTF-8" -e STROOM_JDBC_DRIVER_USERNAME="stroomuser" -e STROOM_JDBC_DRIVER_PASSWORD="stroompassword1" -e STROOM_STATISTICS_SQL_JDBC_DRIVER_URL="jdbc:mysql://stroom-stats-db:3308/statistics?useUnicode=yes&characterEncoding=UTF-8" -e STROOM_STATISTICS_SQL_JDBC_DRIVER_USERNAME="stroomuser" -e STROOM_STATISTICS_SQL_JDBC_DRIVER_PASSWORD="stroompassword1" stroom
```

Navigate to [http://localhost:8080/stroom/stroom.jsp](http://localhost:8080/stroom/stroom.jsp) to see Stroom running.

## Releasing the Docker image to Docker Hub (or any other Docker registry)

1. Build an image using the method above, and then test it.

2. Check that the image name is correct. For Docker Hub the Stroom image needs to be called `gchq/stroom` so that it gets pushed to the GCHQ Docker Hub organisation. You can rename it like this: `docker tag stroom:latest gchq/stroom:latest`.

3. Log in to the registry using `docker login` followed by your credentials when prompted. 

4. Push the image up using `docker push gchq/stroom`.

### Docker Hub links
[The Stroom image](https://hub.docker.com/r/gchq/stroom/)

[The GCHQ organisation](https://hub.docker.com/u/gchq/)
