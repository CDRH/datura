## Omeka fields and overrides

### Standard definitions of fields

Each Omeka field is updated by the method in [api_fields.py](../../../lib/datura/python/api_fields.py) to compile the Omeka S JSON. This method takes the form `update_item_value(ctx, item, key, value, datatype="literal")`. The first argument is the context parameter (providing access to config values, OmekaAPIClient, and property ID cache), the second argument is the json hash with the API data, the third argument corresponds to the field in the resource template, and the fourth is the return value of the corresponding function of `field_definitions.py`. Optionally, you can pass in the datatype, as the fifth argument. The default definitions of Omeka fields are in [field_definitions.py](../../../lib/datura/python/field_definitions.py). The Omeka API fields defined here must correspond with the Omeka resource template you are using, and the return value should be compatible with the data type. If you do not specify it, it will be set to "literal". For example `update_item_value(ctx, built_item, "dcterms:date", fields.date(json), "numeric:timestamp")`.

### Overriding fields

To override the field definitions, copy the file [field_overrides_example.py](../../../lib/datura/python/field_overrides_example.py) to [field_overrides.py](../../../lib/datura/python/field_overrides.py) in the `scripts/python` file of the project directory. Then override each method as needed, using the commented patterns in the example overrides file as a guide. 

Each overridden method needs to take the arguments `self` (a Python placeholder for a class instance) and `json` (representing the generated JSON) and to match the methods defined in `field_definitions.py`. (The same goes for adding new methods to `field_definitions.py`.)
For instance:

```python
    def folder(self, json):
        return json.get("container_folder", None)

    def name(self, json):
        person_names = [person['name'] for person in json.get("person") or [] if  'name' in person]
        return person_names
```

First retrieve the value from the Elasticsearch `json` (keeping in mind that it is sometimes nil), then do any manipulations needed before returning the desired value. The return value must be either an list or single value. For single values, usually this will be the same as the value in the JSON. But unlike the ElasticSearch-based API, it is not possible to ingest nested fields into Omeka S, so they must be reduced into array form. See [field_definitions.py](../../../lib/datura/python/field_definitions.py)for examples of how to retrieve single and nested values from the JSON, manipulate them and return the proper values for Omeka S.

### Overriding processes

Some core functions involved in the Omeka posting can also be overridden. To do this, copy the file [process_overrides_example.py](../../../lib/datura/python/process_overrides_example.py) to [process_overrides.py](../../../lib/datura/python/process_overrides.py) in the `scripts/python` file of the project directory. Then override each method as needed, using the commented patterns in the example overrides file as a guide. 

### Linking items

Any new fields that link to the id of another item should be added to the `link_records` in `process_overrides.py`. `link_item_record` works in the same way as `update_item_value` but the value of the ES field must be a CDRH ID.

```python
    try:
        part_ids = [part['id'] for part in json_item["has_part"]]
        link_item_record(ctx, existing_item, "dcterms:hasPart", part_ids)
    except (KeyError, TypeError):
        pass
```

`link_item_record` searches the Omeka S API for an item that matches the CDRH ID in `dcterms:identifier` and then adds a link on the Omeka S item. Note that item linking in [json_to_omeka.py](../../../lib/datura/python/json_to_omeka.py) only happens after all items have been posted or updated, in order to ensure that all items are in the API before trying to link them together.
