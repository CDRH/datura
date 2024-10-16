# Datura Changelog

All notable changes to Datura will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic
Versioning](https://semver.org/spec/v2.0.0.html).

<!-- Template - Please preserve this order of sections
## [Unreleased] - Brief description TBD before next release
[Unreleased]: https://github.com/CDRH/datura/compare/v#.#.#...dev

### Fixed

### Added

### Changed

### Removed

### Migration

### Deprecated

### Security
-->

## [Unreleased] - Brief description TBD before next release
[Unreleased]: https://github.com/CDRH/datura/compare/v0.2.0...dev

### Fixed

### Added

### Changed

### Removed

### Migration

### Deprecated

### Security

## [v0.2.0] - Ingest documentation, text spacing, and date_standardize
[v0.2.0]: https://github.com/CDRH/datura/compare/v0.2.0-beta...v0.2.0

### Added
- minor test for Datura::Helpers.date_standardize
- documentation for web scraping
- documentation for CsvToEs (transforming CSV files and posting to elasticsearch)
- documentation for adding new ingest formats to Datura
- byebug gem for debugging
- instructions for installing Javascript Runtime files for Saxon
- API schema can either be the original 1.0 or the newly updated 2.0 (which includes new fields including nested fields); 1.0 will be run by default unless 2.0 is specified. Add the following to `public.yml` or `private.yml` in the data repo:
```
api_version: '2.0'
```
See new schema (2.0) documentation [here](https://github.com/CDRH/datura/blob/main/docs/schema_v2.md)
- schema validation with API version 2.0: invalidly constructed documents will not post
- authentication with Elasticesarch 8.5
- field overrides for new fields in the new API schema
- functionality to transform EAD files and post them to elasticsearch
- functionality to transform PDF files (including text and metadata) and post them to elasticsearch
- limiting `text` field to a specific limit: `text_limit` in `public.yml` or `private.yml`
- configuration options related to Elasticsearch, including `es_schema_override` and `es_schema_path` to change the location of the Elasticsearch schema
- more detailed errors including a stack trace

### Changed
- update ruby to 3.1.2
- date_standardize now relies on strftime instead of manual zero padding for month, day
- minor corrections to documentation
- XPath: "text" is now ingested as an array and will be displayed delimitted by spaces
- "text" field now includes "notes" XPath
- refactored posting script (`Datura.run`)
- refactored command line methods into elasticsearch library
- refactored and moved date_standardize and date_display helper methods
- Nokogiri methods `get_text` and `get_list` on TEI now return nil rather than empty strings or arrays if there are no matches. fields have been changed to check for these nil values

### Migration
- check to make sure "text" xpath is doing desired behavior
- use Elasticsearch 8.5 or higher and add authentication if security is enabled. Add the following to `public.yml` or `private.yml` in the data repo:
```
  es_user: username
  es_password: ********
```
- upgrade data repos to Ruby 3.1.2
- 
- add api version to config as described above
- make sure fields are consistent with the api schema, many have been renamed or changed in format
- add nil checks with get_text and get_list methods as needed
- add EadToES overrides if ingesting EAD files
- add `byebug` and `pdf-reader` to Gemfile in repos based on Datura
- if overriding the `read_csv` method in `lib/datura/file_type.rb`, the hash must be prefixed with ** (`**{}`).

## [v0.2.0-beta](https://github.com/CDRH/datura/compare/v0.1.6...v0.2.0-beta) - 2020-08-17 - Altering field and xpath behavior, adds get_elements

### Added
- Fields (and therefore methods) for ES JSON, such as extent, alternative, spatial, etc
- Methods to xToES format fields to accommodate default behavior
- ES JSON `uri` now populated using default Orchid item path
- Tests and fixtures for all supported formats except CustomToEs
- `get_elements` returns nodeset given xpath arguments
- `spatial` nested fields `spatial.type` and `spatial.title`
- Versioning system to support multiple elasticsearch schemas
- Validator to check against the elasticsearch copy

### Changed
- Arguments for `get_text`, `get_list`, and `get_xpaths`
- XPaths for VRA and TEI to Elasticsearch
- Default behavior for CsvToEs for some fields
- Documentation updated
- Changed Install instructions to include RVM and gemset naming conventions
- API field `coverage_spatial` is now just `spatial`
- refactored executables into modules and classes

### Migration
- Change `coverage_spatial` nested field to `spatial`
- `get_text`, `get_list`, and `get_xpaths` require changing arguments to keyword (like `xml` and `keep_tags`)
- Recommend checking xpaths and behavior of fields after updating to this version, as some defaults have changed
- Possible to refactor previous FileCsv overrides to use new CsvToEs abilities, but not necessary
- Config files should specify `api_version` as 1.0 or 2.0

## [v0.1.6](https://github.com/CDRH/datura/compare/v0.1.5...v0.1.6) - 2020-04-24 - Improvements to CSV, WEBS transformers and adds Custom transformer

### Added
- CsvToEs class added which imitates style of other XToEs classes for easier overriding / maintenance
- Custom formats now supported, although no functionality provided since the type of format cannot be predicted
- Adds documentation for custom format setup

### Changed
- CSV to ES transformation no longer accepts default column names, but instead looks for columns matching ES fields to use
- FileType elasticsearch transform now has swappable component when reading
XML-type files. Webscraping script altered to manipulate HTML instead of
XML object type

### Removed
- CSV to ES transformation used to automatically assume columns as ES fields, this functionality has been removed

## [v0.1.5](https://github.com/CDRH/datura/compare/v0.1.4...v0.1.5) - 2020-02-03 - VRA to Solr

### Added
- VRA to Solr field "topic" set up with basic functionality

### Changed
- Upgraded Ruby version to 2.7.0, updated gems
- VRA to Solr field "text" fixed to post correctly
- VRA to Solr field "people" and "language" made overridable
- Updated URL to Saxon HE software

## [v0.1.4](https://github.com/CDRH/datura/compare/v0.1.3...v0.1.4) - 2019-09-17 - PB Update

### Changed
- Removed match on `pb/@xml:id` for tei-to-html

## [v0.1.3](https://github.com/CDRH/datura/compare/v0.1.2...v0.1.3) - 2019-08-21 - IIIF Manifests

### Added
- IIIF output format and documentation
- Changelog

### Changed
- nokogiri gem restricted to moving minor version instead of patch

### Removed
- pkg builds of gem
- outdated comment line

## [v0.1.2](https://github.com/CDRH/datura/compare/v0.1.1...v0.1.2) - 2019-05-15 - Web scraping support, post by update time fix

### Added
- `webs` format for minimal support of web scraping by specific apps
- `today` shortcut for `--update` flag

### Changed
- `--update` flag fixed

## [v0.1.1](https://github.com/CDRH/datura/compare/v0.1.0...v0.1.1) - 2019-03-01 - Pre and post file transformation hooks

### Added
- ability to manipulate files before and after transformation

### Changed
- accomodates ruby 2.6.x

## [v0.1.0](https://github.com/CDRH/datura/compare/data_old...v0.1.0) - 2018-11-21 - Datura Gem Launch

### Added
- creates the datura gem

## [data_old] - 2018-11-12 - Original Data Repository

This release contains code as the data repository used to be when it was a collection of scripts. After this point, it will be a gem named "datura."
