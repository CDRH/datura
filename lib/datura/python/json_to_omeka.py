#import necessary modules, including omeka, and the fields
import omeka
import api_fields

import copy
import json
from pathlib import Path
#needed for debugging purposes and path
import sys
import traceback
import os

#look for the output folder: /output/development/es and get all items
json_dir = omeka.get_dir("output/development/es")
pathlist = list(Path(json_dir).glob('**/*.json'))
item_set_id = omeka.get_item_set()
#enables importing of overrides
sys.path.append(os.path.join(os.getcwd(), "scripts/overrides"))

def post_items():
    #iterate through each file
    for path in pathlist:
        filename = str(path)
        with open(filename) as jsonfile:
            json_items = json.load(jsonfile)
            # TODO change template_number to actual number, account for other schemas is necessary
            template_number = omeka.template_number
            for json_item in json_items:
                if not json_item["identifier"]:
                    print("skipping item without identifier")
                    continue
                matching_items = omeka.omeka_auth.filter_items_by_property(filter_property = "dcterms:identifier", filter_value = json_item["identifier"], item_set_id=item_set_id)
                if matching_items:
                    #if item exists, update item
                    if matching_items["total_results"] == 1:
                        update_existing_item(json_item, matching_items)
                    #add new item if item does not exist
                    elif matching_items["total_results"] == 0:
                        add_new_item(json_item)
                    #if multiple matches, warn but don't ingest
                    else:
                        print(f"multiple matches for {json_item['identifier']}, please check Omeka admin site")

def link_items():
    #go through tables again to link records
    for path in pathlist:
        filename = str(path)
        with open(filename) as jsonfile:
            json_items = json.load(jsonfile)
            for json_item in json_items:
                if not json_item["identifier"]:
                    print("skipping item without identifier")
                    continue
                matching_items = omeka.omeka_auth.filter_items_by_property(filter_property = "dcterms:identifier", filter_value = json_item["identifier"], item_set_id=item_set_id)
                if matching_items and matching_items["total_results"] == 1:
                    #if item exists, update item with linked records
                    link_item(json_item, matching_items)
                else:
                    #if multiple matches or item not found, display warning
                    print(f"skipping {json_item["identifier"]}, item not properly ingested")

def link_item(json_item, matching_items):
    item_id = matching_items["results"][0]["dcterms:identifier"][0]["@value"]
    print(f"linking records for {item_id}")
    item_to_link = copy.deepcopy(matching_items["results"][0])
    linked_item = api_fields.link_records(json_item, item_to_link)
    try:
        omeka.omeka_auth.update_resource(linked_item, "items")
    except Exception as err:
        print(str(err))
        traceback.print_exc
        print(f"Error updating item {item_id}")
        breakpoint()
        pass

def add_new_item(json_item):
    new_item = api_fields.prepare_item(json_item)
    if new_item:
        try:
            print(f"creating item {new_item['dcterms:identifier'][0]["@value"]}")
        except KeyError as err:
            print(err)
            breakpoint()
        payload = omeka.prepare_item_payload_using_template(new_item, template_number)
        # add item set
        try:
            omeka.omeka_auth.add_item(payload, template_id=template_number, item_set_id=item_set_id)
        except Exception as err:
            print(err)
            breakpoint()
    else:
        print(f"error preparing item {json_item["identifier"]}")

def update_existing_item(json_item, matching_items):
    print(f"updating item {matching_items["results"][0]["dcterms:identifier"][0]["@value"]}")
    item_to_update = copy.deepcopy(matching_items["results"][0])
    updated_item = api_fields.prepare_item(json_item, item_to_update)
    if updated_item:
        try:
            omeka.omeka_auth.update_resource(updated_item, "items")
        except Exception as err:
            print(err)
            breakpoint()


post_items()
#need to query the API again at this point so that records can be linked    
omeka.reset()
link_items()

