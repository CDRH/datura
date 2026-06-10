"""
omeka.py

Utility functions for the Omeka S ingestion pipeline.

"""

from datetime import datetime
from pathlib import Path
import logging
import os
import re

logger = logging.getLogger(__name__)


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
            logger.warning("Term %r not in template; skipping", term)
            continue

        property_details = template_properties[term]
        payload[term] = []

        for value in values:
            # Ensure value is a dict with at least a "value" key.
            if not isinstance(value, dict):
                value = {'value': value}

            # Validate the supplied data type against the template's allowed types.
            if 'type' in value and value['type'] not in property_details['type']:
                logger.warning(
                    "Data type %r for term %r not allowed by template; skipping value",
                    value['type'], term
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
                    logger.warning("Cannot determine data type for term %r; skipping value",term)
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

def filter_items(regex, pathlist):
    """
    Filter a list of file paths to those matching a regex pattern.

    Used by both entrypoint scripts to restrict processing to a subset of
    files when the -r / --regex flag is passed on the command line.

    Parameters:
    * regex    - regex pattern string, compiled with re.compile()
    * pathlist - iterable of pathlib.Path or string paths to filter

    Returns a list containing only the paths whose stem (identifier, without
    extension or directory components) matches the pattern.
    """
    reg = re.compile(regex)
    return [p for p in pathlist if reg.search(p.stem)]


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
    # Build index once: stem -> list of source paths
    source_index = {}
    for sf in source_base.glob("*/*.*"):
        source_index.setdefault(sf.stem, []).append(sf)

    result = []
    for p in pathlist:
        identifier = Path(p).stem
        source_files = source_index.get(identifier, [])
        if not source_files:
            logger.debug(
                "No source file found for %r; including without date filter", identifier
            )
            result.append(p)
            continue
        source_mtime = max(
            datetime.fromtimestamp(sf.stat().st_mtime) for sf in source_files
        )
        if source_mtime >= update_time:
            result.append(p)
    return result


def filter_items_by_format(format_type, pathlist):
    """
    Filter a list of output JSON file paths to those whose source file lives
    in the source/<format_type>/ directory.

    Mirrors the Ruby DataManager convention: source files for a given format
    are stored under source/<format>/ (e.g. source/csv/, source/tei/). A JSON
    output file belongs to that format if and only if a corresponding source
    file exists at source/<format_type>/<stem>.*.

    Files with no match in source/<format_type>/ are excluded. This correctly
    drops stale JSON left in the output directory from earlier runs of a
    different format.

    Parameters:
    * format_type - string, e.g. "tei" or "csv"
    * pathlist    - iterable of pathlib.Path or string paths to filter
    """
    source_dir = Path.cwd() / "source" / format_type
    # Build the set of stems once instead of globbing per item
    source_stems = {sf.stem for sf in source_dir.glob("*")}
    return [p for p in pathlist if Path(p).stem in source_stems]