#import necessary modules, including csv and omeka, and the fields
import csv
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
        items = json.load(jsonfile)
        # TODO change template_number to actual number, account for other schemas is necessary
        template_number = 0
        for item in items:
            pass

