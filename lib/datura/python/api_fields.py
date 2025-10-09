import json
import re
import omeka
from datetime import datetime

def build_item_dict(json, existing_item):
    """Takes in JSON with CDRH API fields and an existing API item from Omeka S in format. 
    Returns Omeka API item (in JSON format) updated with values from new CDHR schema for Omeka."""
    try:
        built_item = existing_item if existing_item else {}
        update_item_value(built_item, "dcterms:title", json["title"])
        update_item_value(built_item, "dcterms:identifier", json["identifier"])
        update_item_value(built_item, "dh:collection", json["collection"])
        update_item_value(built_item, "dh:category", json["category"])
        update_item_value(built_item, "dh:category2", json["category2"])
        #uri_data
        update_item_value(built_item, "dh:uriData", json["uri_data"])
        #type
        update_item_value(built_item, "dcterms:type", json["type"])
        if json["creator"]:
            creator_names = [creator['name'] for creator in json["creator"] if 'name' in creator]
            update_item_value(built_item, "dcterms:creator", creator_names)
        if json["contributor"]:
            contributor_names = [contributor['name'] for contributor in json["contributor"] if 'name' in contributor]
            update_item_value(built_item, "dcterms:contributor", contributor_names)
        update_item_value(built_item, "dcterms:date", json["date"], datatype="numeric:timestamp")
        update_item_value(built_item, "dcterms:description", json["description"])
        update_item_value(built_item, "dcterms:format", json["format"])
        #TODO better as a linked record?
        if json["has_relation"]:
            relation_ids = [relation['id'] for relation in json["has_relation"] if 'name' in relation]
            update_item_value(built_item, "dcterms:relation", relation_ids)
        #TODO is citation always single-valued? if array might need to add code to deal with that
        try:
            update_item_value(built_item, "dcterms:publisher", json["citation"]["publisher"])
        except Exception:
            pass
        #citation.id
        try:
            #not working, currently
            update_item_value(built_item, "dh:biblID", json["citation"]["id"])
        except Exception:
            pass
        #citation.date TODO will also use dcterms:date
        #citation.title
        try:
            update_item_value(built_item, "tei:biblTitle", json["citation"]["title"])
        except Exception:
            pass
        #citation.pubplace
        try:
            update_item_value(built_item, "tei:biblPubPlace", json["citation"]["pubplace"])
        except Exception:
            pass
        #citation.issue
        try:
            update_item_value(built_item, "bibo:issue", json["citation"]["issue"])
        except Exception:
            pass
        try:
            update_item_value(built_item, "bibo:pageStart", json["citation"]["page_start"])
        except Exception:
            pass
        try:
            update_item_value(built_item, "bibo:pageEnd", json["citation"]["page_end"])
        except Exception:
            pass
        try:
            update_item_value(built_item, "bibo:section", json["citation"]["section"])
        except Exception:
            pass
        try:
            update_item_value(built_item, "bibo:volume", json["citation"]["volume"])  
        except Exception:
            pass      
        #citation.title variants
        try:
            update_item_value(built_item, "tei:biblTitleA", json["citation"]["title_a"])
        except Exception:
            pass
        try:
            update_item_value(built_item, "tei:biblTitleM", json["citation"]["title_m"])
        except Exception:
            pass
        try:
            update_item_value(built_item, "tei:biblTitleJ", json["citation"]["title_j"])
        except Exception:
            pass
        update_item_value(built_item, "dcterms:rightsHolder", json["rights_holder"])
        update_item_value(built_item, "dcterms:license", json["rights"])
        #update_item_value(built_item, "dcterms:license", json["rights_uri"])
        update_item_value(built_item, "dcterms:subject", json["subjects"])
        update_item_value(built_item, "dh:topic", json["topics"])
        #category3
        update_item_value(built_item, "dh:category3", json["category3"])
        #category4
        update_item_value(built_item, "dh:category4", json["category4"])
        #category5
        update_item_value(built_item, "dh:category5", json["category5"])
        #note
        update_item_value(built_item, "dh:note", json["notes"])
        #abstract
        update_item_value(built_item, "dcterms:abstract", json["abstract"])
        #keyword
        update_item_value(built_item, "dh:keyword", json["keywords"])
        #keyword2
        update_item_value(built_item, "dh:keyword2", json["keywords2"])
        #keyword3
        update_item_value(built_item, "dh:keyword3", json["keywords3"])
        #keyword4
        update_item_value(built_item, "dh:keyword4", json["keywords4"])
        update_item_value(built_item, "dh:keyword5", json["keywords5"])
        #source id (has_source.id) TODO is this single-valued? also may conflict with citation
        # if json["has_source"] and json["has_source"]["id"]:
        #     update_item_value(built_item, "tei:sourceID", json["has_source"]["id"])
        try:
            update_item_value(built_item, "dcterms:source", json["has_source"]["title"])
        except Exception:
            pass
        # #has_part
        # try:
        #     part_ids = [part['id'] for part in json["has_part"]]
        #     update_item_value(built_item, "dcterms:hasPart", part_ids)
        # except Exception:
        #     pass
        # #is_part_of
        # try:
        #     update_item_value(built_item, "dcterms:isPartOf", json["is_part_of"]["id"])
        # except Exception:
        #     pass
        # #previous
        # try:
        #     update_item_value(built_item, "dh:orderPrev", json["previous_item"]["id"])
        # except Exception:
        #     pass
        # #next
        # try:
        #     update_item_value(built_item, "dh:orderNext", json["next_item"]["id"])
        # except Exception:
        #     pass
        #medium
        update_item_value(built_item, "dcterms:medium", json["medium"])
        #extent
        update_item_value(built_item, "dcterms:extent", json["extent"])
        #language
        update_item_value(built_item, "dcterms:language", json["language"])
        #container_box
        update_item_value(built_item, "dh:box", json["container_box"])
        #container_folder
        update_item_value(built_item, "dh:folder", json["container_folder"])

        ##TODO fields not in TEI schema yet, and fields with no corresponding CDRH API field
        #person
        if json["person"]:
            person_names = [person['name'] for person in json["person"] if 'name' in person]
            update_item_value(built_item, "foaf:name", person_names)
        #spatial
        if json["spatial"]:
            places = json["spatial"] if isinstance(json["spatial"], list) else [json["spatial"]]
            try:
                place_names = [place['short_name'] for place in places if 'short_name' in place]
                update_item_value(built_item, "dh:spatial_short_name", place_names)
            except Exception:
                pass
        #event
        #correspondence
        try:
            update_item_value(built_item, "tei:correspSentName", json["correspSentName_omeka_s"])
        except Exception:
            pass
        try:
            update_item_value(built_item, "tei:correspSentPlace", json["correspSentPlace_omeka_s"])
        except Exception:
            pass
        #TODO convert to datatype="numeric:timestamp"?
        try:
            update_item_value(built_item, "tei:correspSentDate", json["correspSentDate_omeka_s"], datatype="numeric:timestamp")
        except Exception:
            pass
        try:
            update_item_value(built_item, "tei:correspDeliveredName", json["correspDeliveredName_omeka_s"])
        except Exception:
            pass
        try:
            update_item_value(built_item, "tei:correspDeliveredPlace", json["correspDeliveredPlace_omeka_s"])
        except Exception:
            pass
        #TODO convert to datatype="numeric:timestamp"?
        try:
            update_item_value(built_item, "tei:correspDeliveredDate", json["correspDeliveredDate_omeka_s"])
        except Exception:
            pass
        # update_item_value(built_item, "tei:correspNext", json["correspNext_omeka_s"])
        # update_item_value(built_item, "tei:correspPrev", json["correspPrev_omeka_s"])
        #editor
        #date created
        #sponsor
        #funder
        #addr line
        #license
        #distributor
        try:
            update_item_value(built_item, "tei:distributor", json["distributor_omeka_s"])
        except Exception:
            pass
        #authority
        try:
            update_item_value(built_item, "tei:authority", json["authority_omeka_s"])
        except Exception:
            pass
        #file notes
        try:
            update_item_value(built_item, "tei:biblNote", json["biblNote_omeka_s"])
        except Exception:
            pass
        #annotations_text
        update_item_value(built_item, "dh:annotationsText", json["annotations_text"])
        #text_field
        update_item_value(built_item, "dh:itemText", json["text"])
        #update_item_value()
        return built_item
    except ValueError:
        breakpoint()

#TODO change item linking for JSON and new API
def link_item(json_item, existing_item):

    #has_part
    try:
        part_ids = [part['id'] for part in json_item["has_part"]]
        link_item_record(existing_item, "dcterms:hasPart", part_ids)
    except Exception:
        pass
    #is_part_of
    try:
        link_item_record(existing_item, "dcterms:isPartOf", json_item["is_part_of"]["id"])
    except Exception:
        pass
    #has_relation
    try:
        link_item_record(existing_item, "dcterms:relation", json_item["has_relation"]["id"])
    except Exception:
        pass
    #previous
    try:
        link_item_record(existing_item, "dh:orderPrev", json_item["previous_item"]["id"])
    except Exception:
        pass
    #next
    try:
        link_item_record(existing_item, "dh:orderNext", json_item["next_item"]["id"])
    except Exception:
        pass
    try:
        link_item_record(existing_item, "tei:correspNext", json_item["correspNext_omeka_s"])
    except Exception:
        pass
    try:
        link_item_record(existing_item, "tei:correspPrev", json_item["correspPrev_omeka_s"])
    except Exception:
        pass
    return existing_item
#     # need to get matching item TODO add conditional logic for blank entries
#     # update_item_value(built_item, "foaf:maker", row["University Omeka ID (from [universities]) (from educations [join])"])


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
    """
    takes in JSON representation of API item, the field name, the value to add or update, and a datatype (defaults to "literal")
    value may be in string format or list. Should be able to modify existing values and update new ones. (Note that there are still issues with updating fields
    returns the JSON hash with the updated value
    """
    if type(value) == str:
        if key in item:
            item[key][0]['@value'] = value
        else: 
            #add the key
            item = add_formatted_value(item, key, value, datatype)
    elif type(value) == list:
        # make sure values are unique
        value = list(set(value))
        value = [v for v in value if v is not None] # remove None values
        if key not in item:
            item[key] = []
            for v in value:
                item = add_formatted_value(item, key, v, datatype)
        else:
            for i, v in enumerate(value):
                # replace value at the given index, if it exists
                try:
                    item[key][i]['@value'] = v
                # otherwise, prepare value and append it
                except IndexError:
                    item = add_formatted_value(item, key, v, datatype)
    return item

def add_formatted_value(item, key, value, datatype):
    # takes in item, key, value, and datatype, returns item with key set or added to value, and formatted in the format Omeka S
    # expects as
    # used when adding a new value that is not already in the Omeka JSON, so that Omeka will properly update the value
    # this comes up
    prop_id = omeka.omeka_auth.get_property_id(key)
    prop_value = {
        "value": value,
        "type": datatype
    }
    formatted = omeka.omeka_auth.prepare_property_value(prop_value, prop_id)
    if key in item and type(item[key]) == list:
        item[key].append(formatted)
    else:
        item[key] = [formatted]
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
    omeka_ids = []
    #lookup_values are usually a list of cdrh_ids, but may be another value
    lookup_values = [lookup_values] if not isinstance(lookup_values, list) else lookup_values
    for lookup_value in lookup_values:
        if not lookup_value or lookup_value == '':
            continue
        if filter_property == "o:id":
            omeka_ids.append(int(lookup_value))
        else:
            match = omeka.omeka_auth.filter_items_by_property(filter_property = filter_property, filter_value = lookup_value)
            if match["total_results"] >= 1:
                if match["total_results"] > 1:
                    print(f"warning: multiple matches for {lookup_value}, taking first match")
                    breakpoint()
                omeka_id = match['results'][0]["o:id"]
                omeka_ids.append(omeka_id)
            else:
                print(f"Unable to link {lookup_value}, no matches")
    return omeka_ids



def link_item_record(item, key, values, item_set=False, filter_property = "dcterms:identifier"):
    omeka_ids = values if item_set else get_omeka_ids(values, filter_property)
    #dedupe
    omeka_ids = list(dict.fromkeys(omeka_ids))
    prop_id = omeka.omeka_auth.get_property_id(key)
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
            formatted = omeka.omeka_auth.prepare_property_value(prop_value, prop_id)
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
