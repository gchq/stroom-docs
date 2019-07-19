# Stream Dump Tool

Data within Stroom can be exported to a directory using the `StreamDumpTool`. The tool is contained within the core Stroom Java library and can be accessed via the command line, e.g.

`java -cp "apache-tomcat-7.0.53/lib/*:lib/*:instance/webapps/stroom/WEB-INF/lib/*" stroom.util.StreamDumpTool outputDir=output`

*Note the classpath may need to be altered depending on your installation.*

The above command will export all content from Stroom and output it to a directory called `output`. Data is exported to zip files in the same format as zip files in proxy repositories. The structure of the exported data is `${feed}/${pathId}/${id}` by default with a `.zip` extension.

To provide greater control over what is exported and how the following additional parameters can be used:

`feed` - Specify the name of the feed to export data for (all feeds by default).

`streamType` - The single stream type to export (all stream types by default).

`createPeriodFrom` - Exports data created after this time specified in ISO8601 UTC format, e.g. `2001-01-01T00:00:00.000Z` (exports from earliest data by default).

 `createPeriodTo` - Exports data created before this time specified in ISO8601 UTC format, e.g. `2001-01-01T00:00:00.000Z` (exports up to latest data by default).

`outputDir` - The output directory to write data to (required).

`format` - The format of the output data directory and file structure (`${feed}/${pathId}/${id}` by default).

## Format

The format parameter can include several replacement variables:

`feed` - The name of the feed for the exported data.

`streamType` - The data type of the exported data, e.g. `RAW_EVENTS`.

`streamId` - The id of the data being exported.

`pathId` - A incrementing numeric id that creates sub directories when required to ensure no directory ends up containing too many files.

`id` - A incrementing numeric id similar to `pathId` but without sub directories.
