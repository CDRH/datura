# Copy this file to process_overrides.py in your scripts/python directory.
# Define only the functions whose behavior differs from the defaults in
# api_fields.py (link_records, update_item_value, link_item_record) and
# html_and_media_ingest.py (build_thumbnail_url). Functions not defined
# here fall back to the default implementations automatically.
#
# Each function must match the signature of its default counterpart exactly.
# To extend rather than replace a default, import it directly:
#
#   from api_fields import link_item_record as default_link_item_record
#
# Overriding link_item_record here is automatically picked up by the default
# link_records without needing to override link_records as well.


# Pattern 1: override build_thumbnail_url to use a different IIIF path format
# def build_thumbnail_url(ctx, json_item):
#     collection = ctx.iiif_collection or json_item.get("collection", "")
#     cover_image = json_item.get("cover_image")
#     if not cover_image:
#         return None
#     remote = f"{ctx.iiif_server}/iiif/2/{collection}%2F{cover_image}/full/!150,150/0/default.jpg"
#     local_name = f"{collection}_{cover_image}"
#     return remote, local_name


# Pattern 2: override link_item_record to use a custom filter property
# def link_item_record(ctx, item, key, values, item_set=False, filter_property="dcterms:identifier"):
#     from api_fields import link_item_record as default_link_item_record
#     # Use a collection-specific property for lookups instead of dcterms:identifier
#     return default_link_item_record(ctx, item, key, values, item_set, filter_property="dh:slug")


# Pattern 3: override update_item_value to skip a field under certain conditions
# def update_item_value(ctx, item, key, value, datatype="literal"):
#     from api_fields import update_item_value as default_update_item_value
#     # Do not post empty string values for any field
#     if value == "":
#         value = None
#     return default_update_item_value(ctx, item, key, value, datatype)


# Pattern 4: override link_records to add a custom relationship type
# def link_records(ctx, row, existing_item):
#     from api_fields import link_records as default_link_records
#     existing_item = default_link_records(ctx, row, existing_item)
#     # Add collection-specific "dh:relatedProject" links
#     try:
#         from api_fields import link_item_record
#         project_ids = [p["id"] for p in row["related_projects"]]
#         link_item_record(ctx, existing_item, "dh:relatedProject", project_ids)
#     except (KeyError, TypeError):
#         pass
#     return existing_item