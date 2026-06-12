# Copy this file to scripts/python/omeka_overrides.py in your collection.
# This file is for overriding individual FIELD EXTRACTION methods (how values
# are pulled from the Datura ES JSON and returned for each Omeka property).
#
# To override the API field ASSEMBLY logic (how values are built, deduplicated,
# formatted, or linked in Omeka), copy examples/api_fields_example.py to
# scripts/python/api_fields.py instead.

from field_definitions import FieldDefinitions

class CustomFields(FieldDefinitions):
    """
    Override only the methods whose behavior differs from the defaults in
    FieldDefinitions. The following patterns address common override categories.
    """

    # Pattern 1: read from a different ES key
    # def title(self, json):
    #     return json.get("preferred_title") or json.get("title")

    # Pattern 2: citation sub-field (base class handles null/array automatically)
    # def publisher(self, json):
    #     return self._get_citation(json).get("publisher", None)

    # Pattern 3: combine multiple ES fields into one Omeka value
    # def creator(self, json):
    #     creators = json.get("creator") or []
    #     return [
    #         f"{c['name']} ({c['role']})" if c.get("role") else c["name"]
    #         for c in creators if c.get("name")
    #     ]

    # Pattern 4: transform a value (e.g. reformat a date or strip whitespace)
    # def dateDisplay(self, json):
    #     raw = json.get("date_display", None)
    #     return raw.strip() if raw else None

    # Pattern 5: date display fix for -01-01
    # dates are automatically converted by Datura to yyyy-01-01 if month and date are missing
    # use the below to convert such dates back to yyyy for Omeka S (since it is allowed by the date parser)
    # def date(self, json):
    #     date_to_parse = json.get("date", None)
    #     if date_to_parse and "-01-01" in date_to_parse:
    #         return datetime.strptime(date_to_parse, "%Y-%m-%d").year
    #     else:
    #         return date_to_parse