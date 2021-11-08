[Back to documentation page for entire system](../../README.md)

Datura
======

[Datura Collection Management Scripts](https://github.com/CDRH/data)

This collection supports the population of an API storing data extracted from XML, CSV, YML, and other file types.

## The Process

Collections are added as sub repositories. They may contain data in the following formats: HTML, TEI P5, VRA, and CSV.  The following output formats are supported: HTML, IIIF Presentation Manifest JSON, Solr XML, Elasticsearch (ES) JSON.

The files are parsed and formatted into documents appropriate for Solr, IIIF, Elasticsearch, and HTML snippets, and then these resulting documents are posted to the appropriate locations. There are also several management scripts for creating indexes, managing the schemas, and deleting indexes.

## Documentation

### Basics

- Start a new collection
  - [Create collection and add files](1_setup/collection_setup.md)
  - [Configuration](1_setup/config.md)
  - [Add index and schema](1_setup/prepare_index.md)
- Customize collection
  - [TEI to Elasticsearch](2_customization/xml_to_es.md)
  - [CSV to Solr](2_customization/csv_to_solr.md)
  - [IIIF Manifest Customization](2_customization/iiif.md)
  - HTML customization
  - Solr customization
  - [Collection Tests](2_customization/test.md)
- Manage collection
  - [Post to index](3_manage/post.md)
  - [Clear index](3_manage/clear_index.md)
  - [Whitelisting](2_customization/whitelisting.md)
  - Remove / destroy index
- Developers
  - [Installation](4_developers/installation.md)
  - [Saxon setup](4_developers/saxon.md)
  - [Ruby / Gems](4_developers/ruby_gems.md)
  - Class organization
  - [Tests](4_developers/test.md)
  - [Add new formats to Datura](4_developers/new_formats.md)
- More
  - [Troubleshooting](troubleshooting.md)
  - [XSLT to Ruby reference](xslt_to_ruby_reference.md)

## The Basics

If this is a brand new collection, please refer to [Create collection and add files](1_setup/collection_setup.md)

View all available commands:

```
about
```

To post to elasticsearch with a basic development environment, give the following a try:

```
post
```

Check out all the options by running the "help" flag:

```
post -h
```
