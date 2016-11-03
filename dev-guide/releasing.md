# Releasing

## To Perform A Release

```bash
mvn release:prepare
mvn release:perform
```

## To Perform a Local Build
`mvn -Dskip.surefire.tests=true clean install -U`

(`-U` is to force update of dependencies)

For quick GWT compilation run:

`mvn -Pgwt-dev-chrome -Dskip.surefire.tests=true clean install -U`

## To Perform a SNAPSHOT Release
`mvn deploy`

## Version Numbers
Release Builds -
 * 3.3.0
 * 3.3.0-beta-1

Snapshot Builds -
 * 3.3.0-SNAPSHOT
 * 3.3.0-beta-1-SNAPSHOT
