#copy this file to omeka_overrides.py in your scripts/python directory. Edit the return values as needed

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