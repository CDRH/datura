## Removing Docs from an Index

There are two scripts which can be used to clear documents from indexes.  One is for solr, the other is for elasticsearch.

```
solr_clear_index -[options]...
es_clear_index -[options]...
```

Both of the scripts have the same usage and behavior.

```(type)_clear_index -[options]...
    -h, --help                       Computer, display script options.
    -e, --environment [input]        Environment (test, production)
    -f, --field [input]              The specific field regex is run on
    -r, --regex [input]              Used as criteria for removing item (books.*, etc)
```

By default, the scripts will run on the "development" environment unless otherwise directed.  **Be very careful when running these scripts -- if you are clearing the production API site, you may be bringing down dozens of sites across the CDRH at once!!**

In general, you can't clear the entire development index across collections particularly easily.  The following will operate only over the specific collection in the configuration environment:

```
(type)_clear_index
```

Specify a different environment:

```
(type)_clear_index -e production
(type)_clear_index -e api_dev
```

You can also search for a specific or group of ids to remove

```
(type)_clear_index -r txt\.001
```

You can remove entries by field + regex

```
(type)_clear_index -f category -r memorabilia
```

In order for these scripts to execute correctly, you will need to make sure that the configuration files are set up correctly.

## Clearing the Entier Index

If you must, you can set the collection to "all" in order to wipe everything regardless of the collection running the command.

## Deleting An Entire Index (Nuclear Option)

If you want to start from scratch and nuke an index, run the following:

```
admin_es_delete_index
```

Be careful, as the above will wipe out all types from an index.  For example, if you run it on the API's es_index, you will lose every collection ever.
