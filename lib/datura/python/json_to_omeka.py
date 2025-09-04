#import necessary modules, including omeka, and the fields
import omeka
import api_fields

import copy
import json
import markdown
import os
from pathlib import Path

        
#look for the output folder: /output/development/es
json_dir = omeka.get_dir("output/development/es")
pathlist = Path(json_dir).glob('**/*.json')

#iterate through each file
for path in pathlist:
    filename = str(path)
    with open(filename) as jsonfile:
        json_items = json.load(jsonfile)
        # TODO change template_number to actual number, account for other schemas is necessary
        template_number = omeka.template_number
        for json_item in json_items:
            matching_items = omeka.omeka_auth.filter_items_by_property(filter_property = "dcterms:identifier", filter_value = json_item["identifier"])
            if matching_items:
                #if item exists, update item
                if matching_items["total_results"] == 1:
                    print(f"updating item {matching_items["results"][0]["dcterms:identifier"][0]["@value"]}")
                    item_to_update = copy.deepcopy(matching_items["results"][0])
                    updated_item = api_fields.prepare_item(json_item, item_to_update)
                    if updated_item:
                        omeka.omeka_auth.update_resource(updated_item, "items")
                elif matching_items["total_results"] == 0:
                    new_item = api_fields.prepare_item(json_item)
                    if new_item:
                        print(f"creating item {new_item['dcterms:identifier'][0]["value"]}")
                        payload = omeka.omeka_auth.prepare_item_payload_using_template(new_item, template_number)
                        omeka.omeka_auth.add_item(payload, template_id=template_number)
                    else:
                        print(f"error preparingg item {json_item["identifier"]}")
                #if multiple matches, warn but don't ingest
                else:
                    print(f"multiple matches for {json_item['Unique ID']}, please check Omeka admin site")