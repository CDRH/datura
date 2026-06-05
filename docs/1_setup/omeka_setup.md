## Set up for Omeka S posting

### Step 1: Set up a data repository for Omeka

#### If you would like to create a new repository

Follow [the steps](https://github.com/CDRH/datura/blob/dev/docs/1_setup/collection_setup.md#step-1--create-a-new-collection-directory) in the `collection_setup` documentation for Datura, specifying any recent release of Datura in your Gemfile. If you know out of the gate that you plan to create overrides for any Omeka fields, copy `omeka_overrides_examples.py` (in the `/scripts/python` directory) to `omeka_overrides.py`. 

#### If you are working with an existing data repository

In your Gemfile, make sure that Datura is on the right branch for Omeka posting. This functionality should be included in any recent release. Change `.ruby-gemset` to `datura-omeka` or something similar if this is not the version of Datura you usually use. Run:

```bash
cd . 
bundle install
``` 

If you plan to create overrides for any Omeka fields, you can copy the `lib/datura/python/omeka_overrides_example.py` in the Datura library (at `/lib/datura/python/`) to your repository as `[collection-directory]/scripts/python/omeka_overrides.py`.

### Step 2: Enable a virtual environment

In your collection repo, first exit any virtual environment if one is currently enabled (this may be indicated by `(.venv)` or similar text before your command prompt) with `deactivate`. If you have not previously created a virtual environment, run: 

```bash
python3 -m venv .venv 
```

The environment will be installed in the `.venv` folder in the root of the collection repo. This folder should not be committed. If you are working in a newly created repo, it should already be added to the `.gitignore` file. If you are working with an existing data repository, you may have to add the `.venv` directory to `.gitignore`. 

To enter the virtual environment once it has been created, run 

```bash
source .venv/bin/activate
```

### Step 3: Install Python dependencies

Next, confirm you have a `requirements.txt` file in the root directory of your collection. If you are working with an existing repository, you may need to copy this over from Datura. Then, to install the dependencies, run: 

```bash
pip3 install packaging
pip3 install -r requirements.txt
```

The `packaging` library will need to be installed separately so the `omeka_s_tools` installation (part of the `requirements.txt` list) will work. 

### Step 4: Set up config for Omeka S posting

If you have a newly created repo, you should see some omeka-related config values in your auto-generated `config/private.yml` config file. Uncomment these and fill in the values. If you are working with an existing repo, the following settings should be placed in `config/private.yml` (in addition to the config that is already included for Datura):

```yaml
default:
    omeka_server: servername.unl.edu/path/to/api
    key_identity: *****
    key_credential: *****
    resource_template: ##
    omeka_data_base: desired/base/url/for/tei/files
    iiif_server: servername.unl.edu # optional, if the collection uses the image server
    iiif_collection: collection_name # optional, if the collection uses the image server
development:
    item_set: ##
production:
    item_set: ##
```

All values not listed as optional are required for the omeka scripts to run. 

- (for developers) `json_dir`, `html_id`, and `iiif_dir` are set within the script and correspond to the standard Datura output folders.

The `key_identity` and `key_credential` fields should correspond to the generated API key credentials. which you can generate on your Omeka S user page (click "Edit user" and then the API key). Make sure to copy the credentials down right away after generating the key.

Make sure that config is pointing to the right `resource_template` for the data you want to ingest. Append `admin/resource-template` to the base Omeka site URL, and click on the resource template for the data schema (most CDRH sites use `CDRH schema`). The id of the resource template is found at the end of the url.

`omeka_data_base` is necessary to indicate the URL to the TEI data documents. It should have a format like `https://github.com/CDRH/[repo_name]/blob/[env]/source/tei` or specify a similar relative path. The Omeka script adds the filename at the end. Make sure you have the right repo to make this a valid url.

For media posting, set `iiif_server` to the base url of the IIIF image server and `iiif_collection` to the name of the collection or whatever name is used for the collection's iiif directory on the image server. 

`item_set` should be specified by environment in `private.yml` in order to categorize items by environment on Omeka S. The proper item_set id can be found in Omeka if you append `admin/item-set` to the base Omeka site URL. Look for `Environment--Development` or something similar; the id will appear at the end of the URL if you click the link. Not all projects have environments.

### Step 5: Prepare to post!

See [post_omeka instructions](../3_manage/post_omeka.md) and [post_omeka_html instructions](../3_manage/post_omeka_html.md) for information about posting to Omeka S.