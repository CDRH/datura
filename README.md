# Datura

Welcome to this temporary documentation for Datura, a gem dedicated to transforming and posting data sources from CDRH projects.  This gem is intended to be used with a collection containing TEI, VRA, CSVs, and more.

Looking for information about how to post documents? Check out the
[documentation for posting](/docs/3_manage/post.md).

## Install / Set Up Data Repo

Check that Ruby is installed, preferably 2.7.x or up.

If your project already has a Gemfile, add the `gem "datura"` line. If not, create a new directory and add a file named `Gemfile` (no extension).

```
source "https://rubygems.org"

# fill in the latest available release for the tag
gem "datura", git: "https://github.com/CDRH/datura.git", tag: "v0.0.0"
```

If this is the first datura repository on your machine, install saxon as a system wide executable. [Saxon setup documentation](docs/4_developers/saxon.md).

Then, in the directory with the Gemfile, run the following:

```
gem install bundler
bundle install

bundle exec setup
```

The last step should add files and some basic directories. Have a look at the [setup instructions](/docs/1_setup/collection_setup.md) to learn how to add your files and start working with the data!

## Local Development


Add this to your collection's Gemfile:

```
source 'https://rubygems.org'

gemspec path: '/path/to/local/datura/repo'
```

Then in your repo you can run:

```
bundle install
# create the gem package if the above doesn't work
gem install --local path/to/local/datura/pkg/datura-0.x.x.gem
```

You will need to recreate your gem package for some changes you make in Datura. From the DATURA directory, NOT your data repo directory, run:

```
bundle exec rake install
```

Note: You may also need to delete your `scripts/.xslt-datura` folder if you are making changes to the default Datura scripts.

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
