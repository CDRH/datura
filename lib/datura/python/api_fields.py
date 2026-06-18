"""
api_fields.py

Transforms a single Datura-generated JSON item into the format expected by the
Omeka S REST API, and resolves inter-item relationships (links) by looking up
CDRH identifiers in the live Omeka instance.

The two primary entry points called by json_to_omeka.py are:
  prepare_item(ctx, row, existing_item)  — build or update item metadata
  link_records(ctx, row, existing_item)  — resolve and attach relationships

All functions that need API access or configuration now receive a ctx
(OmekaContext) parameter. The property ID cache on ctx (ctx.get_property_id()) 
means each Omeka term is looked up only once per run rather than once per field per item.
"""

import json
import logging
import re
import sys

import omeka
from datetime import datetime

# Module-level logger so that log records from this module are identifiable
# by name in the output stream.
logger = logging.getLogger(__name__)


def prepare_item(ctx, row, existing_item=None):
    """
    Build a complete Omeka item dict from a Datura JSON record.

    Iterates over the field manifest declared on ctx.fields, where each entry
    specifies an Omeka property term, the extractor method name to call on
    ctx.fields, and the Omeka datatype. The manifest is defined by
    FieldDefinitions.field_manifest and may be extended by a collection's
    CustomFields subclass to add collection-specific properties.

    Parameters:
    * ctx           - OmekaContext providing config and the property ID cache
    * row           - raw JSON item dict from the Datura ES output
    * existing_item - existing Omeka item dict to update in-place, or None
                      when creating a new item (an empty dict is used instead)

    Returns the built or updated item dict, ready for payload preparation.
    Raises ValueError (caught by the caller) if field extraction fails in an
    unexpected way.
    """
    try:
        built_item = existing_item if existing_item else {}
        for omeka_term, method_name, datatype in ctx.fields.field_manifest():
            value = getattr(ctx.fields, method_name)(row)
            update_item_value(ctx, built_item, omeka_term, value, datatype)
        return built_item
    except ValueError as e:
        logger.error("ValueError building item dict: %s", e)
        raise


def link_records(ctx, row, existing_item):
    """
    Resolve inter-item relationships for a single item and attach them to the
    existing Omeka item dict.

    Each relationship type (has_part, is_part_of, etc.) is handled in its own
    try/except block. A missing or None field in the JSON is expected for most
    items — these are caught as KeyError or TypeError and logged at DEBUG level
    so they do not pollute the run log. Genuine API failures in
    link_item_record() will surface as exceptions and should be caught by the
    caller in json_to_omeka.py.

    Parameters:
    * ctx           - OmekaContext providing the API client and item_set_id
    * row           - raw JSON item dict from the Datura ES output
    * existing_item - the current Omeka item dict, deepcopied by the caller

    Returns the updated existing_item dict with relationship fields populated.

    To extend this function with additional linking logic (e.g. linking person
    names to separate Omeka person-items), override link_records in
    scripts/python/fieldoverrides.py, import and call this default first:

        from api_fields import link_records as default_link_records

        def link_records(ctx, row, existing_item):
            existing_item = default_link_records(ctx, row, existing_item)
            # ... collection-specific linking logic
            return existing_item
    """
    identifier = row.get("identifier")

    try:
        part_ids = [part['id'] for part in row["has_part"]]
        link_item_record(ctx, existing_item, "dcterms:hasPart", part_ids)
    except (KeyError, TypeError) as e:
        logger.debug("No has_part data for %s: %s", identifier, e)

    try:
        link_item_record(ctx, existing_item, "dcterms:isPartOf", row["is_part_of"]["id"])
    except (KeyError, TypeError) as e:
        logger.debug("No is_part_of data for %s: %s", identifier, e)

    try:
        link_item_record(ctx, existing_item, "dcterms:relation", row["has_relation"]["id"])
    except (KeyError, TypeError) as e:
        logger.debug("No has_relation data for %s: %s", identifier, e)

    try:
        link_item_record(ctx, existing_item, "dh:orderPrev", row["previous_item"]["id"])
    except (KeyError, TypeError) as e:
        logger.debug("No previous_item data for %s: %s", identifier, e)

    try:
        link_item_record(ctx, existing_item, "dh:orderNext", row["next_item"]["id"])
    except (KeyError, TypeError) as e:
        logger.debug("No next_item data for %s: %s", identifier, e)

    try:
        link_item_record(ctx, existing_item, "tei:correspNext", row["correspNext_omeka_s"])
    except (KeyError, TypeError) as e:
        logger.debug("No correspNext_omeka_s data for %s: %s", identifier, e)

    try:
        link_item_record(ctx, existing_item, "tei:correspPrev", row["correspPrev_omeka_s"])
    except (KeyError, TypeError) as e:
        logger.debug("No correspPrev_omeka_s data for %s: %s", identifier, e)

    return existing_item


def update_item_value(ctx, item, key, value, datatype="literal"):
    """
    Set or replace a property on an Omeka item dict.

    Clears the existing value list for the key (if any) and writes the new
    value(s). This ensures that re-running the ingest for an existing item
    replaces stale values rather than appending duplicates.

    If value is None or an empty list, the key is initialised to [] and no
    formatted values are added — this effectively clears the field in Omeka
    when the item is PUT back.

    Parameters:
    * ctx      - OmekaContext (passed through to add_formatted_value)
    * item     - the Omeka item dict being built
    * key      - Omeka property term string, e.g. "dcterms:title"
    * value    - the value to set; may be a string, int, float, or list.
                 None and empty list are treated as "no value".
    * datatype - Omeka data type string (default "literal"). Use
                 "uri" for URLs or "numeric:timestamp" for dates.
    """
    # Always reset the key so that old values from a prior ingest are not
    # carried forward when the source data no longer has a value for this field.
    item[key] = []

    if isinstance(value, (str, int, float)):
        item = add_formatted_value(ctx, item, key, value, datatype)
    elif isinstance(value, list):
        # Deduplicate (preserving insertion order) and remove None entries.
        value = list(dict.fromkeys(v for v in value if v is not None))
        for v in value:
            item = add_formatted_value(ctx, item, key, v, datatype)


def add_formatted_value(ctx, item, key, value, datatype, label=""):
    """
    Format a single value and append it to the property list on an item dict.

    Calls ctx.get_property_id() to obtain the numeric Omeka property ID for
    the given term. The cache on ctx ensures this API call is made at most once
    per unique term per run.

    Parameters:
    * ctx      - OmekaContext; provides get_property_id() and the API client
    * item     - the Omeka item dict being built
    * key      - Omeka property term string, e.g. "dcterms:title"
    * value    - the scalar value to format
    * datatype - Omeka data type string, e.g. "literal", "uri",
                 "numeric:timestamp"
    * label    - optional display label for URI values

    Returns the item dict with the new value appended to item[key].
    """
    # Coerce to string for literal values to avoid sending a bare int or float
    # in the API payload, which Omeka S may reject.
    if datatype == "literal":
        value = str(value)

    # Look up the property ID via the cache — avoids one API round-trip per
    # field per item across the entire run.
    prop_id = ctx.get_property_id(key)

    prop_value = {
        "value": value,
        "type": datatype,
    }
    formatted = ctx.client.prepare_property_value(prop_value, prop_id, label)

    if key in item and isinstance(item[key],list):
        item[key].append(formatted)
    else:
        item[key] = [formatted]

    return item

def get_omeka_ids(ctx, lookup_values, filter_property):
    """
    Resolve a list of lookup values to Omeka numeric item IDs.

    For each lookup value, queries the Omeka API to find the matching item
    within the configured item set. Used during the linking pass to convert
    CDRH identifiers into the Omeka IDs required for resource:item links.

    Parameters:
    * ctx            - OmekaContext providing the API client and item_set_id
    * lookup_values  - a single value or list of values to look up; typically
                       CDRH identifier strings but may be Omeka IDs directly
                       when filter_property is "o:id"
    * filter_property - the Omeka property to match against, e.g.
                        "dcterms:identifier" or "o:id"

    Returns a list of integer Omeka item IDs for all successfully resolved values.
    Logs a warning for values that cannot be resolved.
    """
    omeka_ids = []

    # Normalise a single value to a list for uniform iteration.
    lookup_values = [lookup_values] if not isinstance(lookup_values, list) else lookup_values

    for lookup_value in lookup_values:
        # Skip blank or None values — these are common when optional relation
        # fields are absent in some records but not others.
        if not lookup_value or lookup_value == '':
            continue

        if filter_property == "o:id":
            # The value is already an Omeka ID; cast to int and add directly.
            omeka_ids.append(int(lookup_value))
        else:
            match = ctx.client.filter_items_by_property(
                filter_property=filter_property,
                filter_value=lookup_value,
                item_set_id=ctx.item_set_id,
            )
            if match["total_results"] >= 1:
                if match["total_results"] > 1:
                    # Multiple matches indicate a data integrity issue; take
                    # the first result and log a warning for investigation.
                    logger.warning(
                        "Multiple matches for %r, taking first result", lookup_value
                    )
                omeka_ids.append(match['results'][0]["o:id"])
            else:
                logger.warning("Unable to link %r: no matching items found", lookup_value)

    return omeka_ids


def link_item_record(ctx, item, key, values, item_set=False, filter_property="dcterms:identifier"):
    """
    Resolve lookup values to Omeka IDs and attach them as resource links on
    the item dict.

    Clears the existing value list for the key before writing, so re-running
    this function replaces stale links rather than appending duplicates.

    Parameters:
    * ctx             - OmekaContext providing the API client
    * item            - the Omeka item dict being built
    * key             - Omeka property term for this relationship,
                        e.g. "dcterms:hasPart" or "dh:orderNext"
    * values          - lookup values to resolve; either already-resolved Omeka
                        IDs (when item_set=True) or CDRH identifiers to look up
    * item_set        - if True, treat values as Omeka item set IDs rather than
                        item IDs; uses "resource:itemset" type and adds the
                        extra fields required by the item-sets plugin
    * filter_property - the Omeka property to use when looking up items by value;
                        defaults to "dcterms:identifier"

    Returns the updated item dict.
    """
    # When item_set=True the caller has already resolved the IDs; otherwise
    # resolve them from CDRH identifiers via the API.
    omeka_ids = values if item_set else get_omeka_ids(ctx, values, filter_property)

    # Deduplicate while preserving order (dict.fromkeys is stable in Python 3.7+).
    omeka_ids = list(dict.fromkeys(omeka_ids))

    # Look up the property ID via the cache.
    prop_id = ctx.get_property_id(key)

    # Always clear the existing values for this relationship field so that
    # stale links from a prior ingest are removed.
    item[key] = []

    resource_type = "resource:itemset" if item_set else "resource:item"

    for omeka_id in omeka_ids:
        prop_value = {
            "type": resource_type,
            "value": omeka_id,
        }
        formatted = ctx.client.prepare_property_value(prop_value, prop_id)

        if item_set:
            # The item-sets plugin requires these extra fields in addition
            # to what prepare_property_value generates.
            formatted['@id'] = '{}/item_sets/{}'.format(ctx.client.api_url, omeka_id)
            formatted['value_resource_id'] = omeka_id
            formatted['value_resource_name'] = 'item_sets'

        item[key].append(formatted)

    return item