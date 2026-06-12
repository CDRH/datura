# Copy this file to scripts/python/api_fields.py in your collection.
# Define only the methods you want to override — all others fall through to
# the datura defaults in ApiFields.
#
# ApiFields is available in this file's scope automatically (no import needed).
# Use super() to call the default datura implementation from within an override.

class CustomApiFields(ApiFields):
    """
    Override only the methods whose behavior differs from the defaults in ApiFields.
    """

    # Pattern 1: custom deduplication (e.g. case-insensitive dedup)
    # def update_item_value(self, ctx, item, key, value, datatype="literal"):
    #     item[key] = []
    #     if isinstance(value, list):
    #         seen = {}
    #         for v in value:
    #             if v is None:
    #                 continue
    #             dedup_key = v.lower() if isinstance(v, str) else v
    #             if dedup_key not in seen:
    #                 seen[dedup_key] = v
    #         for v in seen.values():
    #             item = self.add_formatted_value(ctx, item, key, v, datatype)
    #     elif isinstance(value, (str, int, float)):
    #         item = self.add_formatted_value(ctx, item, key, value, datatype)

    # Pattern 2: change how relationship IDs are resolved (e.g. use a different
    # filter property for a particular collection's identifier scheme)
    # def get_omeka_ids(self, ctx, lookup_values, filter_property):
    #     if filter_property == "dcterms:identifier":
    #         filter_property = "dh:localIdentifier"
    #     return super().get_omeka_ids(ctx, lookup_values, filter_property)

    # Pattern 3: add extra relationship fields or skip fields entirely
    # def link_item(self, ctx, json_item, existing_item):
    #     existing_item = super().link_item(ctx, json_item, existing_item)
    #     # add a custom relationship not in the datura defaults
    #     try:
    #         self.link_item_record(ctx, existing_item, "dh:customRelation", json_item["custom_relation"]["id"])
    #     except (KeyError, TypeError):
    #         pass
    #     return existing_item

    # Pattern 4: strip a field from every item built by this collection
    # def build_item_dict(self, ctx, json_item, existing_item):
    #     built = super().build_item_dict(ctx, json_item, existing_item)
    #     built.pop("dh:itemText", None)
    #     return built
