import csv
import omeka
import markdown # may not be necessary
from pathlib import Path
import json

#look for the output folder: /output/development/es
json_dir = omeka.get_dir("output/development/es")
pathlist = list(Path(json_dir).glob('**/*.json'))
html_dir = omeka.get_dir("output/development/html")

#iterate through each file
for path in pathlist:
    filename = str(path)
    with open(filename) as jsonfile:
        json_items = json.load(jsonfile)
        for json_item in json_items:
            if not json_item["identifier"]:
                continue
            matching_items = omeka.omeka_auth.filter_items_by_property(filter_property = "dcterms:identifier", filter_value = json_item["identifier"])
            if matching_items:
                if matching_items["total_results"] == 1:
                    matching_item = matching_items["results"][0]
                elif matching_items["total_results"] > 1:
                    print("multiple items found for " + json_item["identifier"] + ", check admin site")
                    continue
                else:
                    print("no matching items for " + json_item["identifier"] + ", skipping")
                    continue
                # if len(matching_item["o:media"]) >= 1:
                #     #delete existing media items
                #     # TODO add attached media item
                #     for media_item in matching_item["o:media"]:
                #         try:
                #             omeka.omeka_auth.delete_resource(media_item["o:id"], "media")
                #         except:
                #             print("error deleting media item")
                #get desired path
                file_path = f"{html_dir}/{json_item["identifier"]}.html"
                # get data from html
                with open(file_path, "r") as file:
                    html_content = file.read()
                media_payload = {
                    "o:is_public": True,
                    "data": {
                        "html": html_content
                    },
                    "o:ingester": "html"
                }
                try:
                    omeka.add_media_to_item(matching_item["o:id"], file_path, payload=media_payload)
                except Exception as err:
                    print(err)
                    print(f"error adding html file for {json_item['identifier']}, omitting")