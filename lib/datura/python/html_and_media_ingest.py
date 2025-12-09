import omeka
from pathlib import Path
import json
# not used, but needed for debugging
import sys
import traceback
import requests
from requests.exceptions import HTTPError
from copy import deepcopy

#look for the output folder: /output/development/*
json_dir = omeka.get_dir("output/development/es")
pathlist = list(Path(json_dir).glob('**/*.json'))
html_dir = omeka.get_dir("output/development/html")
iiif_dir = omeka.get_dir("output/development/iiif")

item_set_id = omeka.get_item_set()

def delete_media_items(matching_item):
    if len(matching_item["o:media"]) >= 1:
        for media_item in matching_item["o:media"]:
            try:
                print("deleting media item " + str(media_item["o:id"]))
                omeka.omeka_auth.delete_resource(media_item["o:id"], "media")
            except HTTPError as err:
                if err.response.status_code == 500:
                    continue
                else:
                    print("error deleting media item: " + str(err))
                    raise

def ingest_thumbnail(json_item, matching_item):
    ## IIIF THUMBNAIL INGEST
    # note that thumbnail ingest should be done first so that thumbnails are designated primary_media

    collection_name = json_item["collection"]
    cover_image = json_item["cover_image"]
    if not cover_image:
        return
    # download thumbnail from iiif server
    thumbnail_remote = f"{omeka.config['iiif_server']}/iiif/2/{collection_name}%2F{cover_image}.jpg/full/!200,200/0/default.jpg"
    thumbnail_local = f"{iiif_dir}/{collection_name}%2F{cover_image}.jpg"
    try:
        print(f"downloading thumbnail for {json_item['identifier']}")
        response = requests.get(thumbnail_remote)
        response.raise_for_status()
        with open (thumbnail_local, "wb") as thumb_file:
            thumb_file.write(response.content)
    except Exception as err:
        print(err)
        print(f"error downloading thumbnail for {json_item['identifier']}, omitting")
        return
    # attach thumbnail to api item
    try:
        with open(thumbnail_local, "rb") as thumb_file:
            media_payload = {
                "o:is_public": True,
                "data": {
                    "upload": thumbnail_local
                },
                "o:ingester": "upload"
            }
        print(f"posting thumbnail for {json_item['identifier']}")
        try:
            omeka.add_media_to_item(matching_item["o:id"], thumbnail_local, payload=media_payload)
        except Exception as err:
            print(err)
            print(f"error adding image file for {json_item['identifier']}, omitting")
    except FileNotFoundError:
        print(f"file {thumbnail_local} not found, skipping thumbnail")

def ingest_html(json_item, matching_item):
    #get desired path
    file_path = f"{html_dir}/{json_item['identifier']}.html"
    # get data from html
    try:
        with open(file_path, "r") as file:
            html_content = file.read()
        media_payload = {
            "o:is_public": True,
            "data": {
                "html": html_content
            },
            "o:ingester": "html"
        }
        print(f"posting html for {json_item['identifier']}")
        try:
            omeka.add_media_to_item(matching_item["o:id"], file_path, payload=media_payload)
        except Exception as err:
            print(err)
            print(f"error adding html file for {json_item['identifier']}, omitting")
            traceback.print_exc()
    except FileNotFoundError:
        print(f"file {file_path} not found, skipping item")

#iterate through each file
for path in pathlist:
    filename = str(path)
    with open(filename) as jsonfile:
        json_items = json.load(jsonfile)
        for json_item in json_items:
            if not json_item["identifier"]:
                continue
            matching_items = omeka.omeka_auth.filter_items_by_property(filter_property = "dcterms:identifier", filter_value = json_item["identifier"], item_set_id=item_set_id)
            if matching_items:
                if matching_items["total_results"] == 1:
                    matching_item = matching_items["results"][0]
                    media_count = len(matching_item["o:media"])
                elif matching_items["total_results"] > 1:
                    print("multiple items found for " + json_item["identifier"] + ", check admin site")
                    continue
                else:
                    print("no matching items for " + json_item["identifier"] + ", skipping")
                    continue
                #check for existing media items, to avoid duplicates
                #skip with -m flag
                if not(omeka.args.media_skip and media_count >=2):
                    delete_media_items(matching_item)

                    ## IIIF THUMBNAIL INGEST
                    #if -m flag, ingest only if not already present
                    # note that thumbnail ingest should be done first so that thumbnails are designated primary_media
                    ingest_thumbnail(json_item, matching_item)
                    
                    ## HTML INGEST
                    #if -m flag, ingest only if not already present
                    ingest_html(json_item, matching_item)

                    ##TODO add other media ingest as needed
                else:
                    print("skipping media for " + json_item["identifier"] + ", already ingested.")

