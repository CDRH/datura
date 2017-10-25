## Posting

The `post.rb` script can be used for any format -> any backend and HTML generation.  To view all the available options for the script, run:

```
ruby scripts/ruby/post.rb -h
```

### Basic Example

Generally, the script is expecting a collection (the directory name) to be passed in:

```
ruby scripts/ruby/post.rb example
```

The above does the following:

- transforms the example data files for Elasticsearch
- posts resulting transformations to Elasticsearch
- assumes an environment of "development"

### Options

```
-h, --help
```

Displays usage and list of options

```
-e, --environment [input]
```

*Default setting: "development"*

Specifies the environment's settings that should be used.  Typically the environments are "development" and "production" but environments of nearly any name can be added to a collection to override default settings.

```
-f, --format [input]
```

*Default setting: all formats*

Format options include:

- csv
- dublin_core
- tei
- vra

If you do not select any, all the formats found will be executed.

```
-n, --no-commit
```

*Default setting: commit*

Solr specific, this will post documents but will not "commit" them to the index.

```
-o, --output
```

*Default setting: false*

Outputs transformed files to a collection's `output/[environment]/[type]`. This is useful for debugging and inspection purposes.

```
-r, --regex [input]
```

Transforms / posts only files matching a specific regular expression.  DO NOT include the file extension.

Example: `post.rb example -r cat.let0001`

```
-t, --transform-only
```

*Default setting: false*

Transform the documents but do not post them to Solr or Elasticsearch.  This is often useful in combination with the `-o` flag for output.

```
-u, --update [YYYY-MM-DDTHH:MM]
```

Post only the documents that have been updated since a given time.  Follow the format above, hours and minutes optional.

```
-v, --verbose
```

*Default setting: false*

Outputs more information about the script running.  Can be useful for debugging.

```
-x, --type [input]
```

*Default setting: es*

- es
- solr
- html

You may chain these together with a comma:

`post.rb example -x es,html`
