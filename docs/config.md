## Configuration

### Environments

Each config file is only required to have a "default" environment. Typically, the config file may also have "development" and "production", but you may add as many environments as you like with any names.

```
default:
  ...
development:
  ...
production:
  ...
jessica_test:
  ...
```

When you run a script, whether it be to clear an index or post files, you may pass it an environment.  If no environment is specified, it will attempt to use the `development` environment.  Anything NOT specified in a given environment will use the default environment's settings.

For example:

```
default:
  csv_html_ruby: scripts/ruby/csv_to_html.rb
  shortname: example
development:
  csv_html_ruby: collections/example/scripts/csv_testing.rb
```

In the above example, if you run `post.rb example` the script will use the development environment:

```
shortname: example
csv_html_ruby: collections/example/scripts/csv_testing.rb
```

If you instead run `post.rb example -e some_other_environment` then the script will use only the default settings, since it cannot locate that environment.

Each config file will shore up its environment before being compared to any other configurations which might override it.

### Inheritance

When it comes to clearing and posting to an index, there are four configuration files which you must be aware of.

- global public `config/public.yml`
- global private `config/private.yml`
- collection public `collections/[yours]/config/public.yml`
- collection private `collections/[yours]/config/private.yml` (optional)

**The most specific instance of a key will be used. That is, the keys inherit in the above order, waterfall style**

For example, if global public has key `solr_path: dev1.unl.edu` but your collection's private config has `solr_path: project.unl.edu`, the solr path used will be `project.unl.edu`

![Configuration inheritance chart showing least specific to most specific](images/config_inheritance.png)
