---
title: "Running Stroom in an IDE"
linkTitle: "Running Stroom in an IDE"
weight: 20
date: 2022-01-25
tags: 
description: >
  How to run Stroom in an Integrated Development Environment, e.g. IntelliJ

---

We tend to use IntelliJ as our Java IDE of choice.
This is a guide for running Stroom in IntelliJ for the purposes of developing/debugging Stroom.


## Prerequisites

In order to build/run/debug Stroom you will need the following:

 * OpenJDK 15
 * Git
 * Gradle
 * IntelliJ
 * Docker CE
 * Docker Compose

These instructions assume that all servcies will either run in the IDE or in Docker containers.

We develop on Linux so if you are running on a Mac you may experience issues with some of our shell scripts.
For running the various shell scripts in our repositories you are advised to install

* bash 4+
* jq
* GNU grep
* GNU sed


## Stroom git repositories

To develop Stroom you will need to clone/fork multiple git repositories.
To quickly clone all of the Stroom repositories you can use the helper script described in {{< external-link "stroom-resource" "https://github.com/gchq/stroom-resources/blob/master/README.md" >}}.


## Database setup

Stroom requires a MySQL database to run.
You can either point stroom at a local MySQL server or use the MySQL Docker container from _stroom-resources_.


### MySQL in a Docker container

See the section below on [stroom-resources](#stroom-resources).


### Host based MySQL server

With an instance of MySQL server 8.0 running on your local machine do the following to create the _stroom_ database:

{{< command-line "dev" "localhost" >}}
# log into your MySQL server using your root credentials
mysql --user=root --password=myrootpassword
{{</ command-line >}}

Then run the following commands in the MySQL shell:

{{< sql-shell >}}
drop database stroom;
create database stroom;
grant all privileges on stroom.* to stroomuser@localhost identified by 'stroompassword1';
quit;
{{</ sql-shell >}}


## Local configuration file

When running stroom in an IDE you need to have a local configuration file to allow you to change settings locally without affecting the repository.
The local configuration file live in the root of the _Stroom_ repository `./local.yml`.

To create a default version of this file run this script from within the root of the stroom git repository.

{{< command-line "dev" "localhost" >}}
./local.yml.sh
{{</ command-line >}}

This will create `./local.yml` using `stroom-app/dev.yml` as a template.
So that you can run a multi-node cluster it will also create `./local2.yml` and `./local3.yml` as well.
These files are not source controlled so you can make any changes you like to them, e.g. setting log levels or altering stroom property [property values]({{< relref "configuring-stroom" >}})  values.


## stroom-resources

As a minimum to develop stroom you will need clones of the `stroom` and `stroom-resources` git repositories.
`stroom-resources` provides the docker-compose configuration for running the many docker containers needed.

Having cloned `stroom-resources` navigate to the directory `stroom-resources/bin` and run the script

{{< command-line "dev" "localhost" >}}
./bounceIt.sh -y
{{</ command-line >}}

On first run this will create a default version of the git-ignored file `stroom-resources/bin/local.env` which is intended for use by developers to configure the docker stacks to run.

This file is used to set a number of environment variables that docker compose will use to configure the various containers.
The key variable in there is `SERVICE_LIST`.
This is a bash array that sets the services to run.
By default it is set to run `stroom-all-dbs` (MySQL + database init scripts) and `nginx` which are sufficient for running Stroom in an IDE.


## Verify the Gradle build

Before trying to run Stroom in an IDE it is worth performing a Gradle build to verify the code compiles and all dependencies are present.
This command will run all parts of the build except for the tests which can take 20+mins to run.
Some parts of the build are run inside docker containers (to remove the need to install additional dependencies) so on first run there will be an overhead of building the docker image layers.
These layers will be cached which will speed up future builds.

{{< command-line "dev" >}}
./gradlew clean build -x test
{{</ command-line >}}


## Local or embedded MySQL

The Junit integration tests that need a database can either be run against the local MySQL (i.e. `stroom-all-dbs`) or an embedded MySQL instance.

Configuring the database used can be done with the JVM argument `-DuseEmbeddedMySql=false`, which can be set in _Run/Debug Configurations_ => _Edit configuration templates..._ => _JUnit_ => _VM options_ in Intellij.
False will use your local MySQL instance, true with use the embedded one.
The CI build uses the embedded MySQL.

The pros/cons of using the embedded instance are:

{{< cardpane >}}
  {{< card header="Pros" >}}
* No dependency on _stroom-resources_ to run the full build.
  {{< /card >}}
  {{< card header="Cons" >}}
* Requires the MySQL binaries to be downloaded, sometimes multiple times.
* Consumes a lot of disk space if multiple instances are run.
* Harder to debug tests as the database is destroyed at the end of the test.
  {{< /card >}}
{{< /cardpane >}}


## Clearing down your environment

If you need to work from a clean slate and you are using the container based MySQL you can run the following:

{{% warning %}}
This script will delete ALL containers running/stopped whether related to Stroom or not.
It is essentially a clean slate for your docker environment.
If you are running other unrelated containers, don't run this.

It will also delete all stroom state held on the filesystem, i.e. the stream store and lucene index shards.
{{% /warning %}}

{{< command-line "dev" "localhost" >}}
pwd
(out)/home/dev/git_work/stroom-resources/bin
(out)
./clean.sh \
&& rm -rf ~/tmp/stroom \
&& rm -rf /tmp/stroom \
&& rm -rf ~/.stroom/volumes \
&& rm -rf ~/.stroom/temp \
&& rm -rf ~/.stroom/logs \
&& rm -rf ~/.stroom/v7
{{</ command-line >}}


## Sample Data

When developing Stroom it is helpful to have Stroom run with pre-loaded content and data as by default it will be completely empty.
`SetupSampleData.java` is a class that loads pre-defined content and data into the database and file system so that Stroom can begin processing data on boot.
This sample data/content is very useful for manually testing and exercising the application in development.
This class assumes that the database being used for Stroom is completely empty.

To run _SetupSampleData_ use the pre-defined Run Configuration in IntelliJ called _SetupSampleData_.
This will load content (e.g. XSLTs, Pipelines, etc.), create Feeds and load data into the Feeds.

You should now have a database and stream store populated with tables and data, providing you with some predefined feeds, data, translations, pipelines, dashboards, etc.

When Stroom is next started it will begin to process the data using the pre-defined pipelines.


## Running Stroom from the IDE

The user interface for Stroom is built using GWT (see [GWT Project](http://www.gwtproject.org/) for more information or GWT specific documentation).
As a result Stroom needs to be started up with GWT _Super Dev Mode_.
_Super Dev Mode_ handles the on-the-fly compilation of the Java user interface source into JavaScript and the source map that links client JavaScript back to Java source for client side debugging.

The following steps for running and debugging Stroom in IDEA assume you have a MySQL database running on `localhost:3307`, with a database `stroom` and user `stroomuser` already created.


### JAVA_HOME

Ensure environment variable `JAVA_HOME` is set and points to a valid JDK 15 directory

{{< command-line "dev" >}}
export JAVA_HOME=~/.jdks/openjdk-15.0.2
{{</ command-line >}}

Alternatively to simplify the process of installing and managing Java JDKs consider using {{< external-link "SDKMan" "https://sdkman.io/install" >}}.


### Build `stroom-app`

NOTE: During development, it is helpful to skip running unit and integration tests, to speed up the build process:
{{< command-line "dev" >}}
./gradlew clean build -x test
{{</ command-line >}}


### Start a single Stroom node

1. Select the IDEA run configuration named `Stroom GWT SuperDevMode`
1. Click `Debug`.
   Stroom will start, with log output displayed in the `Run` pane at the bottom of the window.

This run configuration essentially sets the JVM argument `-DgwtSuperDevMode=true` to run the application in Super Dev Mode.

Watch the log output. Once you see a log INFO message containing the text "Started", you will be able to launch the app in a browser from: https://localhost.

You will see the Stroom blue background, with a username/password prompt.
Enter the following default credentials:

* Username: `admin`
* Password: `admin`

You can now interact with Stroom and set breakpoints in Java code.
Note that setting breakpoints in any of the java code in modules suffixed with `-client` (i.e. client side GWT Java code) does not have any effect, as these components are compiled to static JavaScript.
Breakpoints in modules ending `-shared` will only have an effect **if** you are debugging server side code.

{{% note %}}
Stroom has been written with Google's Chrome browser in mind so has only been tested on Chrome.
Behaviour in other browsers may vary.
We would like to improve cross-browser support so please let us know about any browser incompatibilities that you find.
{{% /note %}}


### Starting the Super Dev Mode Compiler

With the Stroom application running you need to also run a draft GWT compile and run the Super Dev Mode compiler.

On first use it is recomended to run:

{{< command-line "dev" >}}
./gradlew gwtClean :stroom-app-gwt:gwtDraftCompile :stroom-app-gwt:gwtSuperDevMode
{{</ command-line >}}

This will ensure a clean state of the GWT compiled javascript.
It may be necessary to re-run the clean, and draft compile if there have been significant changes to the Java code or if there are problems running Stroom in Super Dev Mode.

Normally however you can just run:

{{< command-line "dev" >}}
./gradlew :stroom-app-gwt:gwtSuperDevMode
{{</ command-line >}}

When this gradle task runs it will echo some instructions for how to set up your browser.
Once the browser is all set up with the dev mode favorites you can visit Stroom at

* http://localhost:8080 (bypassing Nginx)
* https//localhost (via Nginx)

Running without Nginx is simpler but can hide problems with the Stroom/Nginx configuration/integration.


### Authentication

In development you can either run Stroom with authentication on or off.
It is a quicker development experience with authentication turned off but this can hide any problems with authentication flow.

To run Stroom with authentication turned off set the following in `local.yml`:

```yaml
stroom:
  security:
    authentication:
      authenticationRequired: false
```

If you want to run with authentication but don't want to be prompted to change the password on first boot you can set:

```yaml
stroom:
  security:
    identity:
      passwordPolicy:
        forcePasswordChangeOnFirstLogin: false
```

Alternatively you can run the IntelliJ Run Configuration _Stroom Reset Admin Password_, which will reset the password to `admin` and prevent further prompts to change it.


### Right click behaviour

Stroom overrides the default right click behaviour in the browser with its own context menu.
For UI development it is often required to have access to the browser's context menu for example to inspect elements.
To enable the browser's context menu you need to ensure this is property is set to null in `dev.yml`:

```yaml
stroom:
  ui:
    oncontextmenu: null
```

To return it to its defualt value, set it to `"return false;"`.

### Hot loading GWT UI code changes

If you make any changes to the Java code in `-client` or `-shared` modules then in order for them to be hot loaded into the Javascript code you simply need to refresh the brower.
This will trigger Super Dev Mode to recompile any changed code.

If you have make significant code changes, e.g. moving/renaming classes then GWT can get confused so you may need to run the _gwtDraftCompile_ and/or _gwtClean_ gradle tasks followed by _gwtSuperDevMode_.


### Debugging GWT UI code

To debug the GWT UI code you will need to use Chrome Dev Tools (`shift+ctrl+i`).
Setting breakpoints in the UI code in IntelliJ will have no effect.
SuperDevMode creates source maps that link the running javascript back to Java code that you can set break points in.

To find the Java source in Chrome Dev Tools open the _Sources_ tab then in the left hand navigator pane (_Page_ tab) select:

_Top_ => _ui_ => _stroom (ui)_ => _127.0.0.1:9876_ => _sourcemaps/stroom_ => _stroom_

This folder then contains all the stroom java packages.

