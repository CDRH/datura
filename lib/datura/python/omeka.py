"""
omeka.py

Utility functions for the Omeka S ingestion pipeline.

"""

from datetime import datetime
from pathlib import Path
import json
import logging
import os
import re

logger = logging.getLogger(__name__)

def add_media_to_item(ctx, item_id, media_file, payload=None, template_id=None, class_id=None):
    """
    Upload a media file and associate it with an existing Omeka S item.

    This is a modified version of the omeka-s-tools library method. The key
    difference is that the ingester type ("upload", "html", etc.) is read from
    payload["o:ingester"] rather than always defaulting to "upload". This allows
    the same function to handle both binary file uploads and the HTML ingester,
    which reads content from payload["data"]["html"] instead of a file.

    Parameters:
    * ctx         - OmekaContext providing the authenticated API client
    * item_id     - numeric Omeka ID of the item this media should attach to
    * media_file  - path to the media file as a string or pathlib.Path.
                    For the HTML ingester, this is the path to the .html file,
                    although the Omeka API reads content from payload["data"]["html"]
                    rather than the uploaded bytes.
    * payload     - dict of metadata for the media object. Must contain
                    "o:ingester" (e.g. "upload" or "html") and any additional
                    metadata fields. Defaults to an empty dict.
    * template_id - optional numeric Omeka resource template ID to attach
                    to the media object (rarely needed for media).
    * class_id    - optional numeric Omeka resource class ID. If template_id
                    is given and class_id is not, the class is inferred from
                    the template automatically.

    Returns the Omeka JSON-LD representation of the newly created media object.
    """
    if payload is None:
        payload = {}

    files = {}

    # Legacy dict-style call: {"path": ..., "title": ...}
    # Preserved for backwards compatibility with any callers using the older
    # interface from the omeka-s-tools library.
    if isinstance(media_file, dict):
        path = media_file['path']
        payload = media_file['title']

    # Normalise the path to a pathlib.Path regardless of input type.
    path = Path(media_file)

    # If a bare string title was passed as the payload, wrap it in the
    # standard item payload format expected by the API.
    if isinstance(payload, str):
        payload = ctx.client.prepare_item_payload({'dcterms:title': [payload]})

    # Attach resource template metadata if requested.
    if template_id:
        payload['o:resource_template'] = ctx.client.format_resource_id(
            template_id, 'resource_templates'
        )
        if not class_id:
            # Infer the resource class from the template when not supplied.
            template = ctx.client.get_resource_by_id(template_id, 'resource_templates')
            class_id = template['o:resource_class']['o:id']
    if class_id:
        payload['o:resource_class'] = ctx.client.format_resource_id(
            class_id, 'resource_classes'
        )

    # Use the ingester declared in the payload, falling back to "upload".
    # Using .get() guards against a missing key
    ingester = payload.get("o:ingester") or "upload"

    # Core fields required by Omeka S for any media POST.
    file_data = {
        'o:ingester': ingester,
        'file_index': '0',       # index into the files[] multipart array
        'o:source': path.name,   # original filename, shown in Omeka admin
        'o:item': {'o:id': item_id},
    }
    payload.update(file_data)

    # Read the raw file bytes and attach them as file[0] in the multipart body.
    # For the HTML ingester, Omeka reads content from payload["data"]["html"]
    # and ignores the file bytes, but including them does not cause errors.
    files['file[0]'] = path.read_bytes()
    files['data'] = (None, json.dumps(payload), 'application/json')

    response = ctx.client.s.post(
        '{}/media'.format(ctx.client.api_url),
        files=files,
        params=ctx.client.credentials,
    )
    return ctx.client.process_response(response)


def prepare_item_payload_using_template(ctx, terms, template_id):
    """
    Build an item payload, validating terms and values against a resource template.

    Behaviour:
    - Terms not present in the template are logged and dropped from the payload.
    - Values whose data type does not match the template definition are dropped.
    - If no data type is supplied for a value, the template default is used,
      or "literal" if the template allows it and no single default exists.

    Parameters:
    * ctx         - OmekaContext providing the authenticated API client
    * terms       - dict mapping Omeka property term strings to lists of value
                    dicts, e.g. {"dcterms:title": [{"value": "My Title"}]}
    * template_id - Omeka's internal numeric ID for the resource template

    Returns a payload dict suitable for passing to ctx.client.add_item().
    """
    # Fetch the template's property definitions once; this dict maps term
    # strings to their allowed types and property IDs.
    template_properties = ctx.client.get_template_properties(template_id)
    payload = {}

    for term, values in terms.items():
        if term not in template_properties:
            # Terms outside the template are intentionally dropped — each
            # collection defines which fields are relevant to its template.
            print('Term {} not in template'.format(term))
            continue

        property_details = template_properties[term]
        payload[term] = []

        for value in values:
            # Ensure value is a dict with at least a "value" key.
            if not isinstance(value, dict):
                value = {'value': value}

            # Validate the supplied data type against the template's allowed types.
            if 'type' in value and value['type'] not in property_details['type']:
                print(
                    'Data type "{}" for term "{}" not allowed by template'
                    .format(value['type'], term)
                )
                break

            if 'type' not in value:
                # Infer a data type from the template definition.
                if len(property_details['type']) == 1:
                    # Only one type allowed — use it.
                    value['type'] = property_details['type'][0]
                elif 'literal' in property_details['type']:
                    # Multiple types allowed; prefer "literal" as the default.
                    value['type'] = 'literal'
                else:
                    # Cannot determine a type; skip this value.
                    print('Specify data type for term "{}"'.format(term))
                    break

            if "property_id" in value:
                # Value was already formatted by a prior call; append as-is to
                # avoid double-formatting.
                payload[term].append(value)
            else:
                # Format the value according to the template property definition.
                payload[term].append(
                    ctx.client.prepare_property_value(
                        value, property_details['property_id']
                    )
                )

    return payload


def prepare_property_value(value, property_id, label=""):
    """
    Format a single property value in the structure expected by Omeka S.

    This is a custom version of the omeka-s-tools library method, extended to
    support an optional text label for URI-type values. It is used in
    api_fields.add_formatted_value() for all standard property formatting.

    Parameters:
    * value       - a string, int, float, or dict. Non-dict values are
                    automatically wrapped: {"value": <value>}. Dicts may
                    include a "type" key; if absent, "literal" is used.
    * property_id - numeric Omeka property ID for this term
    * label       - display label for URI values. If omitted, the last path
                    segment of the URI is used as the label.

    Returns a dict formatted for inclusion in an Omeka S item payload.

    NOTE: The "resource:item" branch contains a reference to `self.api_url`
    which is a pre-existing copy-paste bug from the library source (this is a
    standalone function, not a method, so `self` is undefined). This branch
    is not reached by any current pipeline caller — all values are "literal"
    or "uri" — so the bug has been left in place with this comment rather than
    silently changing potentially-load-bearing code during a refactor.
    If you need resource:item linking, use ctx.client.prepare_property_value()
    (the library version) instead.
    """
    # Wrap bare scalars so the rest of the function can assume a dict.
    if not isinstance(value, dict):
        value = {'value': value}

    # Default to "literal" when no explicit type is provided.
    try:
        data_type = value['type']
    except KeyError:
        data_type = 'literal'

    property_value = {
        'property_id': property_id,
        'type': data_type,
    }

    if data_type == 'resource:item':
        # BUG: `self` is not defined here. This is dead code for current callers.
        # Use ctx.client.prepare_property_value() for resource:item values.
        property_value['@id'] = '{}/items/{}'.format(self.api_url, value['value'])  # noqa: F821
        property_value['value_resource_id'] = value['value']
        property_value['value_resource_name'] = 'items'
    elif data_type == 'uri':
        property_value['@id'] = value['value']
        # Fall back to the last URI segment when no explicit label is given.
        if label == "":
            property_value["o:label"] = value["value"].split("/")[-1]
        else:
            property_value["o:label"] = label
    else:
        # "literal", "numeric:timestamp", and any other types store the
        # value under the "@value" key.
        property_value['@value'] = value['value']

    return property_value


def filter_items(regex, pathlist):
    """
    Filter a list of file paths to those matching a regex pattern.

    Used by both entrypoint scripts to restrict processing to a subset of
    files when the -r / --regex flag is passed on the command line.

    Parameters:
    * regex    - regex pattern string, compiled with re.compile()
    * pathlist - iterable of pathlib.Path or string paths to filter

    Returns a list containing only the paths whose string representation
    matches the pattern.
    """
    reg = re.compile(regex)
    return [p for p in pathlist if reg.search(str(p))]


def filter_items_by_date(update_time, pathlist):
    """
    Filter a list of output JSON file paths to those whose corresponding source
    file has a modification time at or after update_time.

    Source files are expected at source/<format>/<identifier>.<ext> relative to
    the collection root (cwd), matching the Datura convention where the output
    JSON stem equals the source filename stem (e.g. source/tei/abc123.xml ->
    output/development/es/abc123.json). Items with no locatable source file are
    included unconditionally so they are not silently dropped.

    Parameters:
    * update_time - datetime object; only items with source mtime >= this are kept
    * pathlist    - iterable of pathlib.Path or string paths to filter
    """
    source_base = Path.cwd() / "source"
    result = []
    for p in pathlist:
        identifier = Path(str(p)).stem
        source_files = list(source_base.glob("*/{}.*".format(identifier)))
        if not source_files:
            logger.debug(
                "No source file found for %r; including without date filter", identifier
            )
            result.append(p)
            continue
        source_mtime = max(
            datetime.fromtimestamp(os.path.getmtime(str(sf))) for sf in source_files
        )
        if source_mtime >= update_time:
            result.append(p)
    return result
