# Copy this file to scripts/python/json_to_omeka.py in your collection.
# Define only the hook methods you want — all others are no-ops by default.
#
# PostOmeka is available in this file's scope automatically (no import needed).
# Use super() if you want to call the default (no-op) implementation too.
#
# Hook methods receive:
#   ctx      - OmekaContext (API client, config, error log)
#   pathlist - list of pathlib.Path objects for the ES JSON files being processed

class CustomPostOmeka(PostOmeka):
    """
    Override only the hooks whose behavior differs from the defaults (no-ops).
    """

    # Pattern 1: log item count before pass 1 starts
    # def pre_post_items(self, ctx, pathlist):
    #     import logging
    #     logger = logging.getLogger(__name__)
    #     logger.info("Pass 1 starting: %d file(s) to process", len(pathlist))

    # Pattern 2: send a notification after pass 1 completes
    # def post_post_items(self, ctx, pathlist):
    #     import requests
    #     requests.post("https://hooks.example.com/notify", json={"pass": 1, "errors": len(ctx._errors)})

    # Pattern 3: validate that all expected items were posted before linking
    # def pre_link_items(self, ctx, pathlist):
    #     import logging
    #     logger = logging.getLogger(__name__)
    #     if ctx._errors:
    #         logger.warning(
    #             "%d error(s) from pass 1 — some items may be missing from the link pass",
    #             len(ctx._errors),
    #         )

    # Pattern 4: post-link cleanup (e.g. clear a local cache or write a summary file)
    # def post_link_items(self, ctx, pathlist):
    #     from pathlib import Path
    #     summary = Path("logs/omeka_run_summary.txt")
    #     summary.write_text("Processed {} files, {} errors.\n".format(len(pathlist), len(ctx._errors)))
