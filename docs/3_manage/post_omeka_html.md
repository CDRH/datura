## Instructions for attaching media to the Omeka S API

This script should be run after running `post_omeka.md`, as it needs the Omeka S API to be populated. Make sure that you have the usual Datura folders for html and iiif output under output/environment. The script generates html through Datura's usual process (i.e. post -x html), and then deletes existing media, and attaches the thumbnail image and then the html item. It is intentionally structured in this order so that the image will be designated as primary media.

Use the `-s` option to skip the generation step and only post to Omeka S (requires that you have already generated the needed docs).

Use the `-m` option to skip the step of deleting and regenerating for media items that have already been ingested. (It will only do this if both the image and html are uploaded already).

You can specify the environment with `-e [environment]` but you must set an `item_set` with the desired environment in config/private.yml. See 

### Config

- `iiif_server` should be set within the config/private.yml to the base url of the IIIF server.
- `item_set` should be set within config/private.yml under the necessary environment (usually `development` or `production`):
```
default:
    omeka_server: servername.unl.edu/path/to/api
    key_identity: *****
    key_credential: *****
    resource_template: ##
    iiif_server: servername.unl.edu
development:
    item_set: ##
production:
    item_set: ##
```
- (for developers) `json_dir`, `html_id`, and `iiif_dir` are set within the script and correspond to the standard Datura output folders.

### Media ingesters (for developers)

The media payload, set in html_and_media_ingest.py, must be structured in a specific way to add items. It is different in the case of html and iiif images.

For an html field:
```
{
    "o:is_public": True,
    "data": {
        "html": html_content
    },
    "o:ingester": "html"
}
```
For a file upload (i.e. to upload):
{
    "o:is_public": True,
    "data": {
        "upload": html_content
    },
    "o:ingester": "upload"
}

 For posting to the IIIF ingester (not currently implemented):
 {
    "o:is_public": True,
    "data": {
        "upload": iiif_url
    },
    "o:ingester": "iiif"
}
 
  The iiif url should be in the format  https://servername/iiif/2/collection_name%2Fitem_id.jpg/info.json. It should not point to a specific image.
  `o:source`, set in the `add_media_to_item` in omeka.py, either coresponds to the filename or to the remote path if the ingester requires a remote IRL.


### Error you might run into (for developers)
Sometimes it will return error code 422 (unprocessable content) or error code 500. These error messages can be investigated in the Omeka S logs found on the admin page. Check them against the Omeka S source code found in GitHub. (Note that the base Omeka code, powering the website, is in PHP).
- It expects a full URL, not a local file path, in "o:source" which is set when you post media items.
- A malformed URL may cause error that are unable to connect. Make sure that it includes slashes in the proper places
- Internal SQL errors are likely also caused by sending bad data, not corresponding to formats set above
- There is a known issue where Omeka throws an errors when deleting media items and unlinking them 