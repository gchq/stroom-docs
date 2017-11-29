# Release process

## Performing a named release

This is a general guide for performing a release of a named version of one of the stroom family of products.

1. Ensure the CHANGELOG has been updated for the new x.y.z version, i.e. ensure there is a section for vx.y.z and the links to git diffs at the bottom are up to date. e.g. 

    ```
    ## [v3.1.1_schema-v3.1.2] - 2017-11-14

    ### Added

    * Add sources and javadoc jars

    ### Changed

    * Uplift schema to v3.1.2

    * Change build to Gradle
    ```

    and

    ```
    [v3.1.2_schema-v3.1.2]: https://github.com/gchq/event-logging/compare/v3.1.1_schema-v3.1.2...v3.1.2_schema-v3.1.2
    ```


1. Test the named release build locally by adding the argument `-Pversion=vx.y.z` to the gradle build command.

1. Ensure all code is committed to the _master_ branch, or a release branch, such as _v5.0_. 

1. To perform the release create an annotated git tag as follows:

    `git tag -a vx.y.z`

1. Complete the tag's commit message using the following format

    ```
    stroom-something-vx.y.z


    @@@
    ```

    Where _@@@_ is the content of the x.y.z section from the CHANGELOG. GitHub takes the top line as the title for the release. Git will ignore any lines starting with a `#` so remove them from the markdown headings. Keep the `*` bullets.  E.g.

    ```
    event-logging-v3.1.1_schema-v3.1.2

    Added 

    * Add sources and javadoc jars

    Changed

    * Uplift schema to v3.1.2

    * Change build to Gradle
    ```

1. Push the tag. Travis will run a build and on detecting the tag, will release any build artefacts to GitHUb Releases. If the project has any published Maven artefacts these will be releases to Bintray.

## SNAPSHOT releases

SNAPSHOT releases should not and cannot be released to Bintray. If a development version of a library needs to be shared between projects then you can either use the Gradle task `publishToMavenLocal` to publish a `SNAPSHOT` version to your local Maven repository and change your dependency version to `SNAPSHOT`, or perform a named release along the lines of `vx.y.z-alpha.n`.

## Release Versioning conventions

Semantic versioning is used, and this should be adhered to, see [SemVer](https://semver.org/). The following are examples of valid version names

* `SNAPSHOT` - Used only for local development, never to be published publicly.

* `v3.3.0` - Initial release of v3.3, with an associated `v3.3` branch.

* `v3.3.1` - A patch release to v3.3 on the `v3.3` branch.

* `v3.4.0-alpha.1` - An alpha release of v3.4, either on `master` or a `v3.4` branch

* `v3.4.0-beta.1` - An beta release of v3.4, either on `master` or a `v3.4` branch

## To Perform a Local Build

###Full build:
`./gradlew clean build`

###Build without unit tests
`./gradlew clean build -x test`

###Build without integration tests
`./gradlew clean build -x integrationTest`

###Build without any tests or GWT compilation (GWT compilation applies to stroom only)
`./gradlew clean build -x test -x integrationTest -x gwtCompile`




