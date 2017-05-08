# Running Stroom in a Docker Container

This is how to run Stroom using Docker. You may also [build a Docker image from scratch](./docker-building.md).

## Using a pre-built _Docker Hub_ image for Stroom 5.0

```bash
# If you have already run stroom/stroom-db in Docker then clean up any old images
docker stop stroom
docker stop stroom-db
docker stop stroom-stats-db
docker rm stroom
docker rm stroom-db
docker rm stroom-stats-db

# Run up the databases
docker run --name stroom-db -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_USER=stroomuser -e MYSQL_PASSWORD=stroompassword1 -e MYSQL_DATABASE=stroom -d mysql:5.6
docker run --name stroom-stats-db -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_USER=stroomuser -e MYSQL_PASSWORD=stroompassword1 -e MYSQL_DATABASE=statistics -d mysql:5.6

# Run up Stroom 5.0
docker run -p 8080:8080 --link stroom-db --link stroom-stats-db -v ~/.stroom:/root/.stroom --name=stroom -e STROOM_JDBC_DRIVER_URL="jdbc:mysql://stroom-db/stroom?useUnicode=yes&characterEncoding=UTF-8" -e STROOM_JDBC_DRIVER_USERNAME="stroomuser" -e STROOM_JDBC_DRIVER_PASSWORD="stroompassword1" -e STROOM_STATISTICS_SQL_JDBC_DRIVER_URL="jdbc:mysql://stroom-stats-db/statistics?useUnicode=yes&characterEncoding=UTF-8" -e STROOM_STATISTICS_SQL_JDBC_DRIVER_USERNAME="stroomuser" -e STROOM_STATISTICS_SQL_JDBC_DRIVER_PASSWORD="stroompassword1" gchq/stroom:5.0-beta.21
```

Now open a browser (preferably Chrome) at [localhost:8080/stroom](http://localhost:8080/stroom) to get started with Stroom.

### Docker Hub links
[The Stroom image](https://hub.docker.com/r/gchq/stroom/docker-running.md)

[The GCHQ organisation](https://hub.docker.com/u/gchq/docker-running.md)
