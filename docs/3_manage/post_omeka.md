## DRAFT instructions for posting data into Omeka API

This is a work in progress and the `post_omeka` script currently does not work to post to the API

Running the `post_omeka` script will run the Datura scripts to generate a JSON file with all the API fields (this is what is normally sent to Elasticsearch when you run `post`). This first step is equivalent to running to running `post -x es -o -t` It then sends the generated to the Omeka Python scripts.

It is possible to run this script with the other command line options (for instance `-f` to filter by file type and `-r` and filter by regex), but it is not recommended to override the default options such as `-x es`.

### Setting up a virtual environemnt

In your collection repo, first exit any virtual environemt you may be in (this may be indicated by  `(.venv)` or similar before your command prompt). If you have not previously created a virtual environment, type `python3 -m venv .venv`. The environment will be installed in the `.venv` folder in the root of the collection repo. To enter the virtual environment once it has been created, run `source .venv/bin/activate`. Then run `pip3 install -r requirements.txt` to install the dependencies. These two steps are necessary to get the `post_omeka` script to run. 

If running the script results in an error that a dependency is missing (i.e. `ModuleNotFound`) run `pip3 install [dependency]`. (It may be necessary to do an Internet search to determine the name of the package, which is not always named the same as the imported file) Then you can run `pip3 freeze > requirements.txt`, update the file in Datura, and commit it on.

### Config

The following setting should be placed in config/private.yml:
```
default:
    omeka_server: servername.unl.edu/path/to/api
    key_identity: *****
    key_credential: *****
```
The `key_identity` and `key_credential` fields will come from your API key which you can generate on Omeka's API page. Make sure to copy them down right away after generating the key.
Make sure that the script is pointing to the right resource template. This is set in (TBD).

### Overriding the Python scripts
TODO
