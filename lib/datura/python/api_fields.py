import json
import re
import omeka
from datetime import datetime
from field_definitions import get_fields

def build_item_dict(json, existing_item):
    """Takes in JSON with CDRH API fields and an existing API item from Omeka S in format. 
    Returns Omeka API item (in JSON format) updated with values from new CDHR schema for Omeka."""
    try:
        fields = get_fields()
        built_item = existing_item if existing_item else {}
        update_item_value(built_item, "dcterms:title", fields.title(json))
        update_item_value(built_item, "dcterms:identifier", fields.identifier(json))
        update_item_value(built_item, "dh:collection", fields.collection(json))
        update_item_value(built_item, "dh:category", fields.category(json))
        update_item_value(built_item, "dh:category2", fields.category2(json))
        update_item_value(built_item, "dh:uriData", fields.uriData(json))
        update_item_value(built_item, "dcterms:type", fields.dcterms_type(json))
        update_item_value(built_item, "dcterms:creator", fields.creator(json))
        update_item_value(built_item, "dcterms:contributor", fields.contributor(json))
        update_item_value(built_item, "dcterms:date", fields.date(json))
        update_item_value(built_item, "dcterms:description", fields.description(json))
        update_item_value(built_item, "dcterms:format", fields.dcterms_format(json))
        update_item_value(built_item, "dcterms:relation", fields.relation(json))
        update_item_value(built_item, "dcterms:publisher", fields.publisher(json))
        update_item_value(built_item, "dh:biblID", fields.biblID(json))
        update_item_value(built_item, "tei:biblTitle", fields.biblTitle(json))
        update_item_value(built_item, "tei:biblPubPlace", fields.biblPubPlace(json))
        update_item_value(built_item, "bibo:issue", fields.issue(json))
        update_item_value(built_item, "bibo:pageStart", fields.pageStart(json))
        update_item_value(built_item, "bibo:pageEnd", fields.pageEnd(json))
        update_item_value(built_item, "bibo:section", fields.section(json))
        update_item_value(built_item, "bibo:volume", fields.volume(json))
        update_item_value(built_item, "tei:biblTitleA", fields.biblTitleA(json))
        update_item_value(built_item, "tei:biblTitleM", fields.biblTitleM(json))
        update_item_value(built_item, "tei:biblTitleJ", fields.biblTitleJ(json))
        update_item_value(built_item, "dcterms:rightsHolder", fields.rightsHolder(json))
        update_item_value(built_item, "dcterms:license", fields.license(json))
        update_item_value(built_item, "dcterms:subject", fields.subject(json))
        update_item_value(built_item, "dh:topic", fields.topic(json))
        update_item_value(built_item, "dh:category3", fields.category3(json))
        update_item_value(built_item, "dh:category4", fields.category4(json))
        update_item_value(built_item, "dh:category5", fields.category5(json))
        update_item_value(built_item, "dh:note", fields.note(json))
        update_item_value(built_item, "dcterms:abstract", fields.abstract(json))
        update_item_value(built_item, "dh:keyword", fields.keyword(json))
        update_item_value(built_item, "dh:keyword2", fields.keyword2(json))
        update_item_value(built_item, "dh:keyword3", fields.keyword3(json))
        update_item_value(built_item, "dh:keyword4", fields.keyword4(json))
        update_item_value(built_item, "dh:keyword5", fields.keyword5(json))
        update_item_value(built_item, "dcterms:source", fields.source(json))
        update_item_value(built_item, "dcterms:medium", fields.medium(json))
        update_item_value(built_item, "dcterms:extent", fields.extent(json))
        update_item_value(built_item, "dcterms:language", fields.language(json))
        update_item_value(built_item, "dh:box", fields.box(json))
        update_item_value(built_item, "dh:folder", fields.folder(json))
        update_item_value(built_item, "foaf:name", fields.name(json))
        update_item_value(built_item, "dh:spatial_short_name", fields.spatial_short_name(json))
        update_item_value(built_item, "tei:correspSentName", fields.correspSentName(json))
        update_item_value(built_item, "tei:correspSentPlace", fields.correspSentPlace(json))
        update_item_value(built_item, "tei:correspSentDate", fields.correspSentDate(json))
        update_item_value(built_item, "tei:correspDeliveredName", fields.correspDeliveredName(json))
        update_item_value(built_item, "tei:correspDeliveredPlace", fields.correspDeliveredPlace(json))
        update_item_value(built_item, "tei:correspDeliveredDate", fields.correspDeliveredDate(json))
        update_item_value(built_item, "tei:distributor", fields.distributor(json))
        update_item_value(built_item, "tei:authority", fields.authority(json))
        update_item_value(built_item, "tei:biblNote", fields.biblNote(json))
        update_item_value(built_item, "dh:annotationsText", fields.annotationsText(json))
        update_item_value(built_item, "dh:itemText", fields.itemText(json))
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
    #clear the existing values of the key, or initialize it if it is new
    item[key] = []
    if type(value) == str:
        item = add_formatted_value(item, key, value, datatype)
    elif type(value) == list:
        # make sure values are unique
        value = list(set(value))
        value = [v for v in value if v is not None] # remove None values for v in value:
        for v in value:
            item = add_formatted_value(item, key, v, datatype)

def add_formatted_value(item, key, value, datatype, label=""):
    # takes in item, key, value, and datatype, returns item with key set or added to value, and formatted in the format Omeka S
    # expects as
    # used when adding a new value that is not already in the Omeka JSON, so that Omeka will properly update the value
    # this comes up
    prop_id = omeka.omeka_auth.get_property_id(key)
    prop_value = {
        "value": value,
        "type": datatype
    }
    formatted = omeka.omeka_auth.prepare_property_value(prop_value, prop_id, label)
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
    
            

def get_omeka_ids(lookup_values, filter_property, item_set_id = None):
    item_set_id = omeka.get_item_set()
    omeka_ids = []
    #lookup_values are usually a list of cdrh_ids, but may be another value
    lookup_values = [lookup_values] if not isinstance(lookup_values, list) else lookup_values
    for lookup_value in lookup_values:
        if not lookup_value or lookup_value == '':
            continue
        if filter_property == "o:id":
            omeka_ids.append(int(lookup_value))
        else:
            match = omeka.omeka_auth.filter_items_by_property(filter_property = filter_property, filter_value = lookup_value, item_set_id=item_set_id)
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
