## Instructions for posting data into Omeka API

See (omeka setup instructions)[../1_setup/omeka_setup.md] for how to prepare your repo, config, and activate the Python virtual environment.

Running the `post_omeka` script will first run the Datura scripts to generate JSON files with the standard fields and values of the CDRH API (this is what is normally sent to Elasticsearch when you run `post`). This first step is equivalent to running `post -x es -o -t`. It then sends the generated JSON to the Python scripts to be ingested into Omeka S.

Use the `-s` option to skip the generation step and only post to Omeka S (requires that you have already generated the needed documents by running `post_omeka` normally).

It is possible to run `post_omeka` with Datura's other command line options as described in [post.md] (for instance `-f` to filter by file type and `-r` and filter by regex), but it is not recommended to override the default options such as `-x es`

You can specify the environment with `-e [environment]` but you must set an `item_set` with the desired environment in `config/private.yml.` See (omeka setup instructions)[../1_setup/omeka_setup.md] for more details.

For information on how to override field definitions, see [Omeka Overrides](../2_customization/omeka_overrides.md).

## errors that may come up when you post (mostly for developers)

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

Ensure that your script is pointing to the right instance of Omeka S. This may come up in cases where it is trying to link to an item that doesn't currently exist.
