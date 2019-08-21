# Datura Changelog

All notable changes to Datura will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic
Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
Changelog up to date

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
