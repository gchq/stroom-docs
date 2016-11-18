# Running Stroom in a docker

This is how to run Stroom in a Docker container.

These instructions show how to build MySQL from DockerHub and Stroom from source code. In the future a Stroom image will be available on DockerHub, and this guide will be a lot simpler.

## MySQL 
```bash
# Clean up if necessary
docker stop stroom-db
docker rm stroom-db

# Run the MySQL docker image
docker run --name stroom-db -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_USER=stroomuser -e MYSQL_PASSWORD=stroompassword1 -e MYSQL_DATABASE=stroom -d mysql:5.6
```

### If you want to...
#### Log on to MySQL as stroomuser
`docker run -it --link stroom-db:mysql --rm mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -u"stroomuser" -p"stroompassword1" stroom'`

#### Log on to MySQL as root
`docker run -it --link stroom-db:mysql --rm mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -u"root" -p"my-secret-pw" stroom'`



## Stroom

### Create configuration file
Stroom will look for configuration in `~/.stroom.conf.d/stroom.conf`. You can create a basic configuration file like this:

```bash
mkdir ~/.stroom.conf.d
cd ~/.stroom.conf.d
wget https://raw.githubusercontent.com/gchq/stroom-docs/master/dev-guide/resources/stroom.conf
```

### Clone and build `event-logging`

```bash
git clone https://github.com/gchq/event-logging.git
cd event-logging
mvn clean install
cd ..
```

### Clone and build `stroom`

```bash
git clone https://github.com/gchq.git
mvn clean install
```

###  Unpack the Stroom distribution in preparation for building the docker image

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
docker run -p 8080:8080 --link stroom-db -v ~/.stroom.conf.d:/root/.stroom.conf.d --name=stroom -e STROOM_JDBC_DRIVER_URL="jdbc:mysql://stroom-db/stroom?useUnicode=yes&characterEncoding=UTF-8" -e STROOM_JDBC_DRIVER_USERNAME="stroomuser" -e STROOM_JDBC_DRIVER_PASSWORD="stroompassword1" stroom
```

Navigate to [http://localhost:8080/stroom/stroom.jsp](http://localhost:8080/stroom/stroom.jsp) to see Stroom running.
