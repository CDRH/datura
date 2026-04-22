## Posting

The `post.rb` script can be used for any format -> any backend and HTML generation.  To view all the available options for the script, run:

```bash
post -h
```

Make sure you run `post` at the root of the collection directory (i.e. `/var/local/www/collections/stories_humanity`), not from any of its subfolders (i.e. `/var/local/www/collections/stories_humanity/source/tei`), otherwise it will not be able to locate the proper files.

### Basic Example

Generally, the script is expecting a collection (the directory name) to be passed in, with options following if desired:

```bash
post [options]
```

The above does the following:

- transforms the source files for Elasticsearch
- posts resulting transformations to Elasticsearch
- assumes an environment of "development" since no environment specified

### Options

```bash
-h, --help
```

Displays usage and list of options

```bash
-e, --environment [input]
```

*Default setting: "development"*

Specifies the environment's settings that should be used.  Typically the environments are "development" and "production" but environments of nearly any name can be added to a collection to override default settings.

```bash
-f, --format [input]
```

*Default setting: all formats*

Format options include:

- csv
- html
- tei
- vra
- webs

If you do not select any, all the formats found will be executed.

```bash
-n, --no-commit
```

*Default setting: commit*

Solr specific, this will post documents but will not "commit" them to the index.

```bash
-o, --output
```

*Default setting: false*

Outputs transformed files to a collection's `output/[environment]/[type]`. This is useful for debugging and inspection purposes.

```bash
-r, --regex [input]
```

Transforms / posts only files matching a specific regular expression.  DO NOT include the file extension.

Example: `post -r let0001`

```bash
-t, --transform-only
```

*Default setting: false*

Transform the documents but do not post them to Solr or Elasticsearch.  This is often useful in combination with the `-o` flag for output.

```bash
-u, --update [YYYY-MM-DDTHH:MM]
```

Post only the documents that have been updated since a given time.  Follow the format above, hours and minutes optional.

```bash
-v, --verbose
```

*Default setting: false*

Outputs more information about the script running.  Can be useful for debugging.

```bash
-x, --type [input]
```

*Default setting: es*

Specifies the search index or format you are posting to (the html format will create local files)

- es
- solr
- html

You may chain these together with a comma:

```bash
post -x es,html
```

Note that when updating local files with the `-t -o` options or the `-x html` option, it may be necessary to delete files before posting again, in order for changes to take effect.

### Troubleshooting

If `post` does not work, try running `bundle install` and if you get `can't find gem datura (>= 0.a) with executable post` try prefixing the command with `bundle exec`, i.e. `bundle exec post`.
If you get an error when you run `bundle install`, try running the suggested commands, or contact a server adminsitration, especially for permission errors. (For server admins: Common reasons are permission problems with the gemset, or users not being in the proper. See documentation on server permissions).

### Posting to Omeka

For posting to Omeka, see [post_omeka.md] and [post_omeka_html.md]
