## Set up for Omeka S posting

### Setting up data repo for Omeka

In your Gemfile, make sure that Datura is on the right branch for Omeka posting. Currently the line should read `gem "datura", git: "https://github.com/CDRH/datura", branch: "omeka_posting_generalized"` (soon it might be incorporated into a formal release). Change `.ruby-gemset` to `datura-omeka` or something similar if this is not the version of Datura you usually use. Run `cd .` and then `bundle install`. Then run `setup`. Copy `omeka_overrides_examples.py` to `omeka_overrides.py` and make desired changes. Alternatively, if you don't want to set up a repo from scratch, clone the `https://github.com/CDRH/datura` repo, switch to the `https://github.com/CDRH/datura` branch, and copy the `lib/datura/python/omeka_overrides_example.py` to `[collection-directory]/scripts/omeka_overrides.py`.

### Enabling a virtual environment

In your collection repo, first exit any virtual environemt if one currently enabled (this may be indicated by `(.venv)` or similar text before your command prompt) with `deactivate`. If you have not previously created a virtual environment, type `python3 -m venv .venv`. The environment will be installed in the `.venv` folder in the root of the collection repo. This folder should not be committed. To enter the virtual environment once it has been created, run `source .venv/bin/activate`. Then run `pip3 install -r requirements.txt` to install the dependencies. These two steps are necessary to get the `post_omeka` and `post_omeka_html` scripts to run.

If running the script results in an error that a dependency is missing (i.e. `ModuleNotFound`) run `pip3 install [dependency]`. (It may be necessary to do an Internet search to determine the name of the needed package, which may differ between the `import` statement and the `pip3 install` command; e.g. `import dotenv` but `pip3 install python-dotenv`). After installing all necessary dependencies, you can run `pip3 freeze > requirements.txt`, and commit the `requirements.txt` file within the data repo.

### Config for Omeka S posting

The following settings should be placed in `config/private.yml` (in addition to the config that is already included for Datura):

```yaml
default:
    omeka_server: servername.unl.edu/path/to/api
    key_identity: *****
    key_credential: *****
    resource_template: ##
    omeka_data_base: desired/base/url/for/tei/files
    iiif_server: servername.unl.edu
development:
    item_set: ##
production
    item_set: ##
```

- (for developers) `json_dir`, `html_id`, and `iiif_dir` are set within the script and correspond to the standard Datura output folders.

The `key_identity` and `key_credential` fields should correspond to the generated API key credentials. which you can generate on your Omeka S user page (click "Edit user" and then the API key). Make sure to copy the credentials down right away after generating the key.

Make sure that config is pointing to the right `resource_template` for the data you want to ingest. Append `admin/resource-template` to the base Omeka site URL, and click on the resource template for the data schema (most CDRH sites use `CDRH schema`). The id of the resource template is found at the end of the url.

`omeka_data_base` is necessary to indicate the URL to the TEI data documents. It should have a format like `https://github.com/CDRH/[repo_name]/blob/[env]/source/tei` or specify a similar relative path. The Omeka script adds the filename at the end. Make sure you have the right repo to make this a valid url.

For HTML posting, set `iiif_server` to the base url of the IIIF image server.

`item_set` should be specified by environment in `private.yml` in order to categorize items by environment on Omeka S. The proper item_set id can be found in Omeka if you append `admin/item-set` to the base Omeka site URL. Look for `Environment--Development` or something similar; the id will appear at the end of the URL if you click the link. Not all projects have environments and specifying an item set is not necessary to post.

See [post_omeka instructions](../3_manage/post_omeka.md) and [post_omeka_html instructions](../3_manage/post_omeka_html.md) for more information.