# Copy this file to scripts/python/html_and_media_ingest.py in your collection.
# Define only the methods you want to override — all others fall through to
# the datura defaults in MediaIngest.
#
# MediaIngest is available in this file's scope automatically (no import needed).
# Use super() to call the default datura implementation from within an override.

class CustomMediaIngest(MediaIngest):
    """
    Override only the methods whose behavior differs from the defaults.
    """

    # Pattern 1: custom IIIF URL structure or thumbnail size
    # def ingest_thumbnail(self, ctx, json_item, matching_item, iiif_dir):
    #     # Example: use a different IIIF size specifier
    #     import os, requests
    #     from omeka_context import OmekaMediaError
    #     collection_name = ctx.iiif_collection if ctx.iiif_collection else json_item.get("collection", "")
    #     cover_image = json_item.get("cover_image")
    #     identifier = json_item.get("identifier", "unknown")
    #     if not cover_image:
    #         return
    #     thumbnail_remote = (
    #         "{}/iiif/2/{collection}%2F{image}/full/!400,400/0/default.jpg".format(
    #             ctx.iiif_server,
    #             collection=collection_name,
    #             image=cover_image,
    #         )
    #     )
    #     # ... download and upload logic ...

    # Pattern 2: extend the media pipeline with an additional media type
    # def process_items(self, ctx, pathlist, html_dir, iiif_dir):
    #     # Run the default pipeline first, then add a third media attachment
    #     super().process_items(ctx, pathlist, html_dir, iiif_dir)
    #     # ... custom third-media logic ...

    # Pattern 3: change the media skip threshold (default is >= 2)
    # def process_items(self, ctx, pathlist, html_dir, iiif_dir):
    #     # Override to skip items that already have 3+ media objects
    #     import json
    #     from pathlib import Path
    #     from omeka_context import OmekaAPIError
    #     for path in pathlist:
    #         with open(str(path)) as jsonfile:
    #             json_items = json.load(jsonfile)
    #         for json_item in json_items:
    #             identifier = json_item.get("identifier")
    #             if not identifier:
    #                 continue
    #             # ... lookup logic ...
    #             if ctx.media_skip and media_count >= 3:  # changed threshold
    #                 continue
    #             self.delete_media_items(ctx, matching_item)
    #             self.ingest_thumbnail(ctx, json_item, matching_item, iiif_dir)
    #             self.ingest_html(ctx, json_item, matching_item, html_dir)

    # Pattern 4: post-process HTML content before uploading (e.g. inject analytics)
    # def ingest_html(self, ctx, json_item, matching_item, html_dir):
    #     from pathlib import Path
    #     from omeka_context import OmekaMediaError
    #     identifier = json_item.get("identifier", "unknown")
    #     file_path = html_dir / "{}.html".format(identifier)
    #     try:
    #         with open(file_path, "r", encoding="utf-8") as f:
    #             html_content = f.read()
    #     except FileNotFoundError:
    #         return
    #     if not html_content.strip():
    #         return
    #     # Inject a tracking snippet before </body>
    #     html_content = html_content.replace("</body>", "<script>...</script></body>")
    #     # then upload as usual ...