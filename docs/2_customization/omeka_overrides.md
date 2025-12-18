## Omeka fields and overrides

### Standard definitions of fields

The standard definitions of Omeka API fields are in the `field_definitions.py` file, located in the Datura repo at [../../lib/datura/python/field_definitions.py]. The definitions here must match the Omeka resource template you are using, including the data type. Each field is specified by a corresponding method, all of which are called in [../../lib/datura/python/api_fields.py] by the method `update_item_value()`. to compile the Omeka S JSON. For `update_item_value()`, the first argument is the JSON hash that represents the items, the second argument corresponds to the field name in the resource template, and the third is the field value, returned by a corresponding method from [../../lib/datura/python/field_definitions.py], which returns the contents of the field. Optionally, `update_item_value()` specifies the datatype with `datatype="[datatype]"` as the fourth argument. If you do not specify the datatype, it will be set to "literal".

### Overriding fields

To override the field definitions, copy the file `omeka_overrides_example.rb` to `omeka_overrides.rb` in the `scripts/overrides` file of the project directory. Then edit each field as needed. (If it was not originally copied into your ata repo, you can also copy it from the base Datura repo).

Each overriden method needs to take the arguments `self` (a Python placeholder for an instance of the class) and `json` (for the JSON that represents the API item) and to have the same title as the method from [../../lib/datura/python/field_definitions.py]. First retrieve necessary values from the Elasticsearch `json`, then do any manipulations you want before returning the desired value. The return value, which will be posted into the API, must be either an list or single value. Unlike the Elasticsearch-based API, it is not possible to ingest nested fields directly into Omeka S.  See [../../lib/datura/python/field_definitions.py] for examples of how to retrieve single and nested values from the JSON, manipulate them, and return lists and single values in the proper format for Omeka S.

### Linking items

Fields that reference another item should be added to `link_item` in [../../lib/datura/python/api_fields.py]. The method `link_item_record` works in the same way as `update_item_value` but the third argument for the field value must be a CDRH ID. `link_item_record` searches the Omeka S API for an item that matches the ID in `dcterms:identifier` and then adds a link on the Omeka S item. Linking of items happens in [../../lib/datura/python/json_to_omeka.py] after posting/updating items, in order to ensure that the items are in the API before trying to link them together.