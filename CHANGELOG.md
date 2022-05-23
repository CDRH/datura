# Datura Changelog

All notable changes to Datura will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic
Versioning](https://semver.org/spec/v2.0.0.html).

<!-- Template - Please preserve this order of sections
## [Unreleased] - Brief description
[Unreleased]: https://github.com/CDRH/datura/compare/v#.#.#...dev

### Fixed

### Added

### Changed

### Removed

### Migration

### Deprecated

### Security
-->

## [Unreleased](https://github.com/CDRH/datura/compare/v0.2.0-beta...dev)

### Added
- minor test for Datura::Helpers.date_standardize
- documentation for web scraping
- documentation for CsvToEs (transforming CSV files and posting to elasticsearch)
- instructions for installing Javascript Runtime files for Saxon

### Changed
- date_standardize now relies on strftime instead of manual zero padding for month, day
- minor corrections to documentation
- XPath: "text" is now ingested as an array and will be displayed delimitted by spaces

### Migration
- check to make sure "text" xpath is doing desired behavior

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
