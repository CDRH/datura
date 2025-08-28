import json
import re
import omeka
from datetime import datetime

# TODO comvert to standard CDRH API for Omeka S
# def build_item_dict(row, existing_item):
#     #in the news people only
#     try:
#         built_item = existing_item if existing_item else {}
#         #new_item['schema:name'][0]['@value'] = "value" is how you update
#         #TODO need to separate out Index and In the News more
#         update_item_value(built_item, "dcterms:title", row["Name Built"])
#         update_item_value(built_item, "dcterms:identifier", row["In the News Unique ID"])
#         update_item_value(built_item, "dcterms:description", row["Biography"])
#         update_item_value(built_item, "foaf:givenName", row["Name given"])
#         update_item_value(built_item, "foaf:lastName", row["Name last"])
#         try:
#             #make sure date can be parsed in the correct format, will throw exception if not
#             date = datetime.strptime(row["Date birth"], '%Y-%m-%d')
#             if date:
#                 update_item_value(built_item, "dcterms:date", row["Date birth"], datatype="numeric:timestamp")
#         except:
#             print(row["Date birth"] + " is not a valid date")
#             pass
#         update_item_value(built_item, "dcterms:bibliographicCitation", row["Bio Sources (MLA)"])
#         update_item_value(built_item, "dcterms:spatial", location(row["birth_spatial.city"]))
#         update_item_value(built_item, "dcterms:coverage", location(row["nationality-region"]))
#         #omitting 
#         # names = get_matching_names_from_markdown(row, "related-people")
#         # if names:
#         #     update_item_value(built_item, "dcterms:relation", names)
#         lat = json.loads(row["Latitude (from Place of birth)"])[0]
#         lon = json.loads(row["Longitude (from Place of birth)"])[0]
#         if lat and lon:
#             update_item_value(built_item, "geo:lat_long", f"{lat}, {lon}")
#         update_item_value(built_item, "bibo:section", "people")
#         #get count of associated news items
#         update_item_value(built_item, "curation:number", row["Number of linked News Items"])
#         return built_item
#     except ValueError:
#         breakpoint()

# TODO change item linking for JSON and new API
# def link_item(row, existing_item):
#     cdrh_news_ids = get_matching_ids_from_markdown(row, "news item roles")
#     if cdrh_news_ids:
#         link_item_record(existing_item, "foaf:isPrimaryTopicOf", cdrh_news_ids)
#     cdrh_event_ids = get_matching_ids_from_markdown(row, "events")
#     if cdrh_event_ids:
#         link_item_record(existing_item, "dcterms:isReferencedBy", cdrh_event_ids)
#     cdrh_work_ids = get_matching_ids_from_markdown(row, "work roles")
#     if cdrh_work_ids:
#         link_item_record(existing_item, "foaf:made", cdrh_work_ids)
#     cdrh_person_ids = get_matching_ids_from_markdown(row, "related-people")
#     if cdrh_person_ids:
#         link_item_record(existing_item, "dcterms:relation", cdrh_person_ids)
#     cdrh_commentary_ids = get_matching_ids_from_markdown(row, "commentaries_relation")
#     if cdrh_commentary_ids:
#         link_item_record(existing_item, "foaf:depiction", cdrh_commentary_ids)
#     if row["Unique ID"]:
#           link_item_record(existing_item, "dcterms:references", [row["Unique ID"]])
#     if row["University Omeka ID"]:
#         link_item_record(existing_item, "foaf:maker", json.loads(row["University Omeka ID"]), filter_property="o:id")
#     if row["Place of Birth Omeka ID"]:
#         #look up place name
#         link_item_record(existing_item, "geo:location", json.loads(row["Place of Birth Omeka ID"]), filter_property="o:id")
#     item_set_id = get_ids_from_tags("[\"Poets in the News\"]")
#     existing_item["o:item_set"] = item_set_id
#     link_item_record(existing_item, "dcterms:type", item_set_id, item_set=True)
#     return existing_item
#     # need to get matching item TODO add conditional logic for blank entries
#     # update_item_value(built_item, "foaf:maker", row["University Omeka ID (from [universities]) (from educations [join])"])

# def spatial(row):
#     places = []
#     if row["nationality-region"]:
#         places.append({ "region" : json.loads(row["nationality-region"])[0], "type": "nationality" })
#     if row["birth_spatial.country"]:
#       birthplace = { "country" : json.loads(row["birth_spatial.country"])[0], "type": "birth place" }
#       if row["birth_spatial.city"]:
#         birthplace["city"] = json.loads(row["birth_spatial.city"])[0]
#       places.append(birthplace)
#     return places


def prepare_item(row, existing_item = None):
    item_dict = build_item_dict(row, existing_item)
    # TODO add conditional logic for different templates?
    return item_dict

def link_records(row, existing_item):
    item_dict = link_item(row, existing_item)
    # TODO add conditional logic?
    return item_dict

def get_json_value(row, name):
    if len(row[name]) > 0:
        if row[name].startswith('["'):
            return json.loads(row[name])
        elif ";;;" in row[name]:
            return row[name].split(";;;")
        else:
            return row[name]
    else:
        return row[name]
    
def update_item_value(item, key, value, datatype="literal"):
    if type(value) == str:
        if key in item:
            item[key][0]['@value'] = value
        else: 
            #add the key
            item[key] = [ 
                {
                    "value": value,
                    "type": datatype
                }
            ]
    elif type(value) == list:
        # make sure values are unique
        value = list(set(value))
        if key not in item:
            item[key] = []
            for v in value:
                item[key].append(
                    { 
                        "value": v,
                        "type": datatype 
                    }
                )
        else:
            for i, v in enumerate(value):
                # replace value at the given index, if it exists
                try:
                    item[key][i]['@value'] = v
                # otherwise, prepare value and append it
                except IndexError:
                    prop_id = omeka.omeka.get_property_id(key)
                    prop_value = {
                        "value": v,
                        "type": type
                    }
                    formatted = omeka.omeka.prepare_property_value(prop_value, prop_id)
                    item[key].append(formatted)
    return item



def get_matching_ids_from_markdown(row, field):
    # takes in an array of strings in markdown format, which include CDRH IDs
    # returns an array of just the IDs
    if row[field]:
        markdown_values = sorted(get_json_value(row, field))
        ids = []
        if markdown_values:
            #should be either single value or array
            if type(markdown_values) == str:
                match = re.search(r"\]\((.*)\)", markdown_values)
                if match:
                    id_no = match.group(1)
                    ids.append(id_no)
            else:
                for value in markdown_values:
                    #parse with regex to get ids
                    # ruby code below
                    # /\]\((.*)\)/.match(query)[1] if /\]\((.*)\)/.match(query)
                    match = re.search(r"\]\((.*)\)", value)
                    if match:
                        id_no = match.group(1)
                        ids.append(id_no)
                if len(ids) > 1:
                    ids = list(filter(None, ids))
            return ids
            
    else:
        return []
    
def get_matching_names_from_markdown(row, field):
    # takes in an array of strings in markdown format, which include names
    # returns an array of just the names
    # filters out the ones that have a corresponding id, it is not necessary to get their names
    if row[field]:
        markdown_values = get_json_value(row, field)
        names = []

        if markdown_values:
            #should be either single value or array
            if type(markdown_values) == str:
                name_match = re.search(r"\[(.*?)\]", markdown_values)
                # filter out entries that have ids
                id_match = re.search(r"\]\((.*)\)", markdown_values)
                if name_match and not id_match.group(1):
                    name = name_match.group(1)
                    names.append(name)
            else:
                for value in markdown_values:
                    #parse with regex to get ids
                    # ruby code below
                    # /\]\((.*)\)/.match(query)[1] if /\]\((.*)\)/.match(query)
                    name_match = re.search(r"\[(.*?)\]", value)
                    id_match = re.search(r"\]\((.*)\)", value)
                    if name_match and not id_match.group(1):
                        name = name_match.group(1)
                        names.append(name)
            return names
    else:
        return []
    
            

def get_omeka_ids(lookup_values, filter_property):
    #lookup_values are usually a list of cdrh_ids, but may be another value
    omeka_ids = []
    for lookup_value in lookup_values:
        if lookup_value == '':
            continue
        if filter_property == "o:id":
            omeka_ids.append(int(lookup_value))
        else:
            match = omeka.omeka.filter_items_by_property(filter_property = filter_property, filter_value = lookup_value)
            if match["total_results"] >= 1:
                if match["total_results"] > 1:
                    print(f"warning: multiple matches for {lookup_value}, taking first match")
                omeka_id = match['results'][0]["o:id"]
                omeka_ids.append(omeka_id)
            else:
                print(f"Unable to link {lookup_value}, no matches")
    return omeka_ids



def link_item_record(item, key, values, item_set=False, filter_property = "dcterms:identifier"):
    omeka_ids = values if item_set else get_omeka_ids(values, filter_property)
    #dedupe
    omeka_ids = list(dict.fromkeys(omeka_ids))
    prop_id = omeka.omeka.get_property_id(key)
    #if not key in item:
    #changing to always clear items
    item[key] = []
    # commenting out below because we only want to link items that have ids
    # if there are no ids found, just add the provided value(s) under the provided key
    # if len(omeka_ids) == 0:
    #     for value in list(set(values)):
    #         #need to check to make sure that the value isn't already there
    #         if value in [v["@value"] for v in item[key]]:
    #             prop_value = {
    #                 "value": value
    #             }
    #             formatted = omeka.omeka.prepare_property_value(prop_value, prop_id)
    #             item[key].append(formatted)

    resource_type = "resource:itemset" if item_set else "resource:item"
    for omeka_id in omeka_ids:
        #make sure item isn't already linked, to avoid duplicates
        if not item[key] or not omeka_id in [value.get("value_resource_id") for value in item[key]]:
            prop_value = {
                "type": resource_type,
                "value": omeka_id
            }
            formatted = omeka.omeka.prepare_property_value(prop_value, prop_id)
            #different format for item sets, plugin doesn't do it automatically
            if item_set:
                formatted['@id'] = f'{omeka.omeka_auth.api_url}/item_sets/{omeka_id}'
                formatted['value_resource_id'] = omeka_id
                formatted["value_resource_name"] = "item_sets"
            item[key].append(formatted)
    return item

def build_citation(row):
    # TODO format the date better
    if row["publisher"]:
        return f"""
            "{row["title"]}", {json.loads(row["publisher"])[0]}, {row["Article Date (formatted)"]}, {row["Source page no"]}.
            Accessed {row["Source access date"]}. {row["Source link"]}.
        """
