## Set up for Omeka S posting

### Setting up data repo for Omeka

In your Gemfile, make sure that Datura is on the right branch for Omeka posting. Currently the line should read `gem "datura", git: "https://github.com/CDRH/datura", branch: "omeka_posting_generalized"` (soon it might be incorporated into a formal release). Change `.ruby-gemset` to `datura-omeka` or something similar if this is not the version of Datura you usually use. Run `cd .` and then `bundle install`. Then run `setup`. Copy `omeka_overrides_examples.py` to `omeka_overrides.py` and make desired changes. Alternatively, if you don't want to set up a repo from scratch, clone the `https://github.com/CDRH/datura` repo, switch to the `https://github.com/CDRH/datura` branch, and copy the `lib/datura/python/omeka_overrides_example.py` to `[collection-directory]/scripts/omeka_overrides.py`.

### Enabling a virtual environment

In your collection repo, first exit any virtual environemt if one currently enabled (this may be indicated by `(.venv)` or similar text before your command prompt) with `deactivate`. If you have not previously created a virtual environment, type `python3 -m venv .venv`. The environment will be installed in the `.venv` folder in the root of the collection repo. This folder should not be committed. To enter the virtual environment once it has been created, run `source .venv/bin/activate`. Then, if there is a `requirements.txt` file in the repository, run `pip3 install -r requirements.txt` to install the dependencies. (Otherwise, follow the steps in the below paragraphs). These two steps are necessary to get the `post_omeka` and `post_omeka` scripts to run.

If running the script results in an error that a dependency is missing (i.e. `ModuleNotFound`) run `pip3 install [dependency]`. (It may be necessary to do an Internet search to determine the name of the needed package, which may differ between the `import` statement and the `pip3 install` command; e.g. `import dotenv` but `pip3 install python-dotenv`). After installing all necessary dependencies, you can run `pip3 freeze > requirements.txt`, and commit the `requirements.txt` file within the data repo.

### Config for Omeka S posting

The following settings should be placed in config/private.yml (in addition to the config that is already included for Datura):
```
default:
    omeka_server: servername.unl.edu/path/to/api
    key_identity: *****
    key_credential: *****
    resource_template: ##
    iiif_server: servername.unl.edu
development:
    item_set: ##
production
    item_set: ##
```
The `key_identity` and `key_credential` fields should correspond to the generated API key credentials. which you can generate on your Omeka S user page (click "Edit user" and then the API key). Make sure to copy the credentials down right away after generating the key.

Make sure that config is pointing to the right `resource_template` for the data you want to ingest. The scripts are designed to use the CDRH schema, so look on Omeka to determine the correct template number.

For HTML posting, set `iiif_server` to the base url of the IIIF image server.

`item_set` should be set under the necessary environment (`development` or `production`), to the corresponding item set on Omeka. Not all Omeka projects are set up in this way, so it is not necessary to post.

See [post_omeka instructions](../3_manage/post_omeka.md) and [post_omeka_html instructions](../3_manage/post_omeka_html.md) for more information.