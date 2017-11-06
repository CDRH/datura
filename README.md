CDRH Files central repo
======

This collection supports the population of an API storing data extracted from XML, CSV, YML, and other file types.

## The Process

Collections are added as sub repositories. They may contain data in the following formats: TEI P5, VRA, Dublin Core, CSV, and YML.  The following output formats are supported: HTML, Solr XML, Elasticsearch (ES) JSON.

The files are parsed and formatted into documents appropriate for Solr, Elasticsearch, and HTML snippets, and then these resulting documents are posted to the appropriate locations. There are also several management scripts for creating indexes, managing the schemas, and deleting indexes.

## Documentation

### Basics

- Start a new collection
  - [Create collection and add files](docs/1_setup/collection_setup.md)
  - [Configuration](docs/1_setup/config.md)
  - [Add index and schema](docs/1_setup/prepare_index.md)
- Customize collection
  - [TEI to Elasticsearch](docs/2_customization/xml_to_es.md)
  - [CSV to Solr](docs/2_customization/csv_to_solr.md)
  - HTML customization
  - Solr customization
  - [Collection Tests](docs/2_customization/test.md)
- Manage collection
  - [Post to index](docs/3_manage/post.md)
  - [Clear index](docs/3_manage/clear_index.md)
  - Remove / destroy index
- Developers
  - [Installation](docs/4_developers/installation.md)
  - [Saxon setup](docs/4_developers/saxon.md)
  - [Ruby / Gems](docs/4_developers/ruby_gems.md)
  - Class organization
  - [File Structure](docs/4_developers/file_structure.md)
  - [Tests](docs/4_developers/test.md)
- More
  - [Troubleshooting](docs/troubleshooting.md)
  - [XSLT to Ruby reference](xslt_to_ruby_reference.md)

## The Basics

If this is a brand new collection, please refer to [[TODO]] these docs on how to set up a collection.

To run a basic development environment, give the following a try, subbing in your collection name.

```
ruby scripts/ruby/post.rb <collection>
```

Check out all the options by running the "help" flag:

```
ruby scripts/ruby/post.rb -h
```
