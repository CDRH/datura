## instructions for posting data into Omeka API

Running the `post_omeka` script will run the Datura scripts to generate a JSON file with all the API fields (this is what is normally sent to Elasticsearch when you run `post`). This first step is equivalent to running to running `post -x es -o -t` It then sends the generated to the Omeka Python scripts. (As of October 2025, the scripts are designed specifically for the Stories of Humanity repo)

It is possible to run this script with the other command line options (for instance `-f` to filter by file type and `-r` and filter by regex), but it is not recommended to override the default options such as `-x es`.

### Setting up a virtual environemnt

In your collection repo, first exit any virtual environemt you may be in (this may be indicated by  `(.venv)` or similar before your command prompt). If you have not previously created a virtual environment, type `python3 -m venv .venv`. The environment will be installed in the `.venv` folder in the root of the collection repo. To enter the virtual environment once it has been created, run `source .venv/bin/activate`. Then run `pip3 install -r requirements.txt` to install the dependencies. These two steps are necessary to get the `post_omeka` script to run. 

If running the script results in an error that a dependency is missing (i.e. `ModuleNotFound`) run `pip3 install [dependency]`. (It may be necessary to do an Internet search to determine the name of the package, which is not always named the same as the imported file) Then you can run `pip3 freeze > requirements.txt`, and commit the file within the data repo.

### Config

The following settings should be placed in config/private.yml (currently, they go under `default:` although environments may be added in the future):
```
default:
    omeka_server: servername.unl.edu/path/to/api
    key_identity: *****
    key_credential: *****
    resource_template: ##
```
The `key_identity` and `key_credential` fields will come from your API key which you can generate on Omeka's API page. Make sure to copy them down right away after generating the key.
Make sure that config is pointing to the right resource template for the data you want to ingest. It is designed to use the CDRH schema, so look on Omeka to determine the correct template number.
It may also be necessary to specify an item set for your items, for instance to specify the environment. Currently, the number corresponding to the item set (which can be found on the Omeka site) is hard coded into `json_to_omeka.py`, and can be changed there. In the near future this is likely to be moved into config/private.yml with options to post by environment.

### setting up api_fields.py
Fields you want to ingest can be added to the `build_item_dict` method, each field being specified by the `update_item_value` method. The first argument `item` is always the Omeka S item, the second `key` is the ontology label for the field in the Omeka S schema, the third `value` is the field in the Elasticsearch-based API. Optionally, you can pass in the argument `datatype="[datatype]"`; if you do not specify it, it will be set to "literal".  Fields can be given either an array or single value; Omeka S does not use nested fields in the same way as Elasticsearch does. The `build_item_dict` is also the place for any processing to get the values into the right format or do any customization. Modifying this script in Datura will change it for all repos ingesting into Omeka S.
Fields that reference another item should be added to `link_item`. `link_item_record` works in the same way as `update_item_value` but the value of the ES field must be a CDRH ID. `link_item_record` searches the Omeka S API for an item that matches the id in `dcterms:identifier` and then adds a link on the Omeka S item. Linking of items happens in `json_to_omeka.py` after posting/updating items, in order to ensure that the items are in the API before trying to link them togehter.

### Overriding the Python scripts
TODO

## errors that may come up when you post

### notes on debugging
The standard way to debug Python scripts is with `breakpoint()`, equivalent to `byebug` in Ruby. Execution will pause and then you can check the contents of variables and try snippets of code from the prompt. Sometimes putting a debugger within an except clause (especially within a loop) makes it difficult to break out of the script and halt execution even if you type `quit`. CTRL-C sometimes works in these cases. If CTRL-C also fails to halt the script, try running `os._exit(0)` (this is the reason for `import os` in some of the scripts, and if you get an error that the module is not found, then `import os` should be run from the debugger prompt first). For more details on a particular error, look at the error message which is printed in some of the except clauses, check online documentation to see if this error message has additional methods (depending on the error), or use `traceback.print_exc()` to print out the full stack trace. In the case of errors in the HTTP reponse, it may be necessary to look in the logs on the Omeka site.

### 500 error
Look in the error log on the Omeka site. This may indicate a configuration problem with Omeka or its modules (this is one cause of a SQL-related error). Sometimes it indicates that data is not in the format expected by Omeka.

### Data type not allowed in template
Check your script in api_fields.py to make sure you are passing the right data types, as specified in the resource template you are using. The default data type is "literal". If the resource template changes you must change the data types in your script, too.

### Term not in template
Make sure that the resource template has the fields you want, and that you are only including Omeka fields that match the resource template.

### 405 error: method not allowed
This error occurs because the server is not configured to allow the necessary HTML request (POST to add a new item, PUT to update, DELETE to delete). Contact a system administrator.

### 404 not found
Ensure that your script is pointing to trhe right instance. This may come up in cases where it is trying to link to an item that doesn't currently exist.