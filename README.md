# Datura

Welcome to this temporary documentation for Datura, a gem dedicated to transforming and posting data sources from CDRH projects.  This gem is intended to be used with a "data repository" containing TEI, VRA, CSVs, and more.

## Install


Gemfile:

```
gem "datura", git: "https://github.com/CDRH/data.git", branch: "datura"
```

Next, install saxon as a system wide executable. [Saxon setup documentation](docs/4_developers/saxon.md).

## Local Development


Add this to your data repo's Gemfile:

```
source 'https://rubygems.org'

gemspec path: '/path/to/local/datura/repo'
```

Then in your repo you can run:

```
bundle install
```

And if that doesn't seem like it's working, run this from the datura gem:

```
bundle exec rake install
```

then from the data repo:

```
gem install --local path/to/local/datura/pkg/datura-0.1.0.gem
```

## First Steps

Test it out by running the `about` command to view all your options:

```
about
```

To set up a brand new data repo run:

```
setup
```

Refer to the [documentation](docs) to learn more about how to configure your collection and about each of the scripts.

## Tests

```
bundle install
rake test
```
