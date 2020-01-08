# Datura

Welcome to this temporary documentation for Datura, a gem dedicated to transforming and posting data sources from CDRH projects.  This gem is intended to be used with a collection containing TEI, VRA, CSVs, and more.

## Install


Gemfile:

```
gem "datura", git: "https://github.com/CDRH/data.git", branch: "datura"
```

Next, install saxon as a system wide executable. [Saxon setup documentation](docs/4_developers/saxon.md).

## Local Development


Add this to your collection's Gemfile:

```
source 'https://rubygems.org'

gemspec path: '/path/to/local/datura/repo'
```

Then in your repo you can run:

```
bundle install
```

If for some reason that is not working, you can instead run the following each time you make a change in datura:

```
bundle exec rake install
```

then from the collection (sub in the correct version):

```
gem install --local path/to/local/datura/pkg/datura-0.1.2.gem
```

Note: You may need to delete your `scripts/.xslt-datura` folder as well.

## First Steps

Test it out by running the `about` command to view all your options (`bundle exec` may not be necessary, but it is recommended):

```
bundle exec about
```

To set up a brand new collection run:

```
bundle exec setup
```

Refer to the [documentation](docs) to learn more about how to configure your collection and about each of the scripts.

## Tests

```
bundle install
rake test
```
