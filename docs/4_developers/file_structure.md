This is the minimal setup for a collection:

```
collection_name
|-- config
|      |-- public.yml
|      |-- private.yml
|-- scripts
|-- test
       |-- *.yml
```

You may also add the following directories as necessary to hold the data files:

```
collection_name
|-- csv
|-- dc
|-- tei
|-- vra
|-- yml
```

Additionally, depending on which formats you are using, you may want the following files and directories:

```
collection_name
|-- config
|     |-- solr_schema.json
|-- es
|-- scripts
|     |-- solr_transform_tei.xsl
|     |-- tei_to_es.rb
|     |-- tei.p5.xsl  # html overrides
|-- solr
```

If you run `html` or specify `-o` (output) as a parameter, the script will build the following directory system

```
collection_name
|-- output
|      |-- environment_name
|      |           |-- es
|      |           |-- html
|      |           |-- solr
```

Anything in the `html` directory will be tracked by git, so make sure that you commit it when you are done!  Also be aware that on many servers, these directories are open to the web, so keep that in mind if you are going to be working with any files that should remain private in development, etc.
