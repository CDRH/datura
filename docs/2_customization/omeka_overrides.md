## Omeka fields and overrides

### Standard definitions of fields

Each Omeka field is updated by the method in [api_fields.py](../../../lib/datura/python/api_fields.py) to compile the Omeka S JSON. This method takes the form `update_item_value(item, key, value, datatype="literal")`, the first argumment is the json hash with the API data, the second argument corresponds to the field in the resource template, and the third is the return value the corresponding function of `field_definitions.py`. Optionally, you can pass in the datatype, as the fourth argument. The default definitions of Omeka fields are in [field_definitions.py](../../../lib/datura/python/field_definitions.py). The Omeka API fields defined here must correspond with the Omeka resource template you are using, and the return value should be compatible with the data type.If you do not specify it, it will be set to "literal". For example `update_item_value(built_item, "dcterms:date", fields.date(json), "numeric:timestamp")`.

### Overriding fields

To override the field definitions, copy the file [omeka_overrides_example.py](../../../lib/datura/python/omeka_overrides_example.py) to [omeka_overrides.rb](../../../lib/datura/python/omeka_overrides.py) in the `scripts/overrides` file of the project directory. Then override each method as needed, using the existing definitions in `field_definitions.py` as examples. For an example, see https://github.com/CDRH/data_stories_humanity/blob/omeka_s_ingest/scripts/python/omeka_overrides.py (not currently field).

Each overriden method needs to take the arguments `self` (a Python placeholder for a class instance) and `json` (representing the generated JSON) and to match the methods defined on `field_definitions.py`. (The same goes for adding new methods to `field_definitions.py`.)
For instance:

```python
    def folder(self, json):
        return json.get("container_folder", None)

    def name(self, json):
        person_names = [person['name'] for person in json.get("person") or [] if  'name' in person]
        return person_names
```

First retrieve the value from the Elasticsearch `json` (keeping in mind that it is sometimes nil), then do any manipulations needed before returning the desired value. The return value must be either an list or single value. For single values, usually this will be the same as the value in the JSON. But Unlike the Elasticsearch-based API, it is not possible to ingest nested fields into Omeka S, so they must be reduced into array form. See [field_definitions.py](../../../lib/datura/python/field_definitions.py)for examples of how to retrieve single and nested values from the JSON, manipulate them and return the proper values for Omeka S.

### Linking items

Any new fields that link to the id of another item should be added to the `link_item` in [api_fields.py](../../../lib/datura/python/api_fields.py). `link_item_record` works in the same way as `update_item_value` but the value of the ES field must be a CDRH ID.

```python
    try:
        part_ids = [part['id'] for part in json_item["has_part"]]
        link_item_record(existing_item, "dcterms:hasPart", part_ids)
    except Exception:
        pass
```

`link_item_record` searches the Omeka S API for an item that matches the CDRH ID in `dcterms:identifier` and then adds a link on the Omeka S item. Note that item linking in [json_to_omeka.py](../../../lib/datura/python/json_to_omeka.py) only happens after all items have been posted or updated, in order to ensure that all items are in the API before trying to link them together.
