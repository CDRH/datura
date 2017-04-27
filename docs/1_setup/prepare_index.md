## Prepare Index and Schema

### Step 1: Config

The following instructions are for Elasticsearch ONLY.  TODO points at the Solr schema instructions on the General Wiki once it is released.

You will need to make sure that somewhere, the following are being set in your public / private / global configs:

- es_path
- es_index
- es_type

### Step 2: Prepare Elasticsearch Index

Make sure elasticsearch is installed and running in the location you wish to push to.  If there is already an index you will be using, take note of its name and skip this step.  If you want to add an index to localhost:

```
./scripts/shell/es_create_index.sh name_of_index
```

Assuming this is successful, now we will need to set up a schema for the `_type` within the index, which will match `es_type` (or the shortname of your collection).  By default this looks at the schema in `config/api_schema.yml`.

```
ruby scripts/ruby/es_set_schema.rb collection [-e environment]
```

You may run the above as many times as you wish, as long as you have not already put items in the index which will conflict with the fieldtypes.

[Now you're ready to customize how the data in your index looks!](../2_customization/tei_to_es.md)
