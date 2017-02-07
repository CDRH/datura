This is the minimal setup for a project:

```
project_name
|-- config
|      |-- public.yml
|      |-- private.yml
|-- html-generated
|-- scripts
|-- test
       |-- *.yml
```

You may also add the following directories as necessary to hold the data files:

```
project_name
|-- csv
|-- dc
|-- tei
|-- vra
|-- yml
```

Additionally, depending on which formats you are using, you may want the following files and directories:

```
project_name
|-- config
|     |-- solr_schema.json
|-- es
|-- scripts
|     |-- solr_transform_tei.xsl
|     |-- tei_to_es.rb
|     |-- tei.p5.xsl  # html overrides
|-- solr
```