## Removing Docs from an Index

There are two scripts which can be used to clear documents from indexes.  One is for solr, the other is for elasticsearch.

```
ruby scripts/ruby/solr_clear_index.rb [project] -[options]...
ruby scripts/ruby/es_clear_index.rb [project] -[options]...
```

Both of the scripts have the same usage and behavior.

```
Usage: ruby [type]_clear_index.rb [project] -[options]...
    -h, --help                       Computer, display script options.
    -e, --environment [input]        Environment (test, production)
    -f, --field [input]              The specific field regex is run on
    -r, --regex [input]              Used as criteria for removing item (books.*, etc)
```

By default, the scripts will run on the "development" environment unless otherwise directed.  **Be very careful when running these scripts -- if you are clearing the production API site, you may be bringing down dozens of sites across the CDRH at once!!**

In general, you can clear the entire development index like this:

```
ruby scripts/ruby/[type]_clear_index.rb whitman
```

Specify a different environment:

```
ruby scripts/ruby/[type]_clear_index.rb whitman -e production
ruby scripts/ruby/[type]_clear_index.rb whitman -e api_dev
```

You can also search for a specific or group of ids to remove

```
ruby scripts/ruby/[type]_clear_index.rb cody -r txt\.001
```

You can remove entries by field + regex

```
ruby scripts/ruby/[type]_clear_index.rb transmississippi -f category -r memorabilia
```

In order for these scripts to execute correctly, you will need to make sure that the configuration files are set up correctly.
