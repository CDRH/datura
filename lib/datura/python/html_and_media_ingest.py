"""
html_and_media_ingest.py

Entrypoint script: attaches HTML and IIIF thumbnail media objects to items
that have already been posted to Omeka S by json_to_omeka.py.

For each JSON record this script:
1. Looks up the Omeka item by its CDRH identifier.
2. Optionally deletes any existing media objects (unless --media-skip is set
   and the item already has 2+ media objects).
3. Downloads the IIIF thumbnail from the configured iiif_server and uploads
   it to Omeka as the primary media object (so Omeka designates it the
   primary_media for the item).
4. Reads the pre-rendered HTML file from output/<env>/html/ and uploads it
   as an HTML media object.

Usage (from collection root directory):
    python3 html_and_media_ingest.py            # defaults to development
    python3 html_and_media_ingest.py -e production -r "some_pattern"
    python3 html_and_media_ingest.py -m         # skip items that already have media
    python3 html_and_media_ingest.py --log-level DEBUG

The script is invoked by bin/post_omeka_html in the Datura gem. The Ruby
wrapper passes -e, -r, and -m arguments from its own CLI.
"""

import argparse
import json
import logging
import os
import sys
import time
from pathlib import Path

try:
    import requests
    from requests.exceptions import HTTPError

    import omeka
    from omeka import filter_items, filter_items_by_date, filter_items_by_format
    from omeka_context import (
        OmekaAPIError,
        OmekaAuthError,
        OmekaConfigError,
        OmekaContext,
        OmekaMediaError,
        checkpoint_path,
        configure_logging,
        finish_run,
        read_checkpoint,
        validate_regex_arg,
        write_checkpoint,
    )
except ModuleNotFoundError as err:
    raise SystemExit(
        f"\033[31m ERROR: {err}\n"
        "A required Python package could not be found. "
        "You may need to ensure the virtual environment is activated before running this script.\n"
        "You may also need to be connected to the VPN.\033[0m"
    ) from err

# Module-level logger. Records from this module appear as
# "html_and_media_ingest" in log output.
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# CLI argument parsing
# ---------------------------------------------------------------------------

def _parse_args():
    """
    Parse command-line arguments for the HTML/media ingest entrypoint.

    Returns an argparse.Namespace with:
    * csv_rows     - optional identifier regex for -c item filter, or None
    * environment   - "development" or "production" (default: "development")
    * format_filter - optional format string for -f (directory-based) filter, or None
    * media_skip    - bool; True skips items that already have 2+ media objects
    * proceed      - False (not given), None (-p with no value), or a regex
                     string (-p "pattern") for checkpoint-based resumption
    * regex         - optional file-filter pattern string, or None
    * update_time   - optional date/time string for -u filter, or None
    * media_skip    - bool; True skips items that already have 2+ media objects
    * log_level     - logging level string, default "INFO"
    """
    parser = argparse.ArgumentParser(
        description="Attach HTML and IIIF thumbnail media to existing Omeka S items."
    )
    parser.add_argument(
        "-c", "--csv-rows",
        default=None,
        dest="csv_rows",
        help=(
            "Only process items whose identifier matches this regex.  "
            "Mirrors the Ruby -c flag, which filters CSV rows by identifier."
        ),
    )
    parser.add_argument(
        "-e", "--environment",
        default="development",
        help="Target environment: 'development' or 'production' (default: development).",
    )
    parser.add_argument(
        "-f", "--format",
        default=None,
        dest="format_filter",
        help="Only post files of this format (tei, csv, vra, ead, html, pdf, webs).",
    )
    parser.add_argument(
        "-m", "--media-skip",
        action="store_true",
        dest="media_skip",
        help=(
            "Skip re-ingesting media for items that already have 2 or more "
            "media objects (thumbnail + HTML).  Useful when re-running the "
            "script after a partial failure to avoid re-uploading media that "
            "was already successfully ingested."
        ),
    )
    parser.add_argument(
        "-p", "--proceed",
        nargs="?",
        default=False,
        const=None,
        dest="proceed",
        help=(
            "Proceed with media ingest from (and including) the JSON file "
            "matching this regex.  If given without a value, resumes from "
            "the last checkpoint saved in logs/proceed_omeka_html_{environment}."
        ),
    )
    parser.add_argument(
        "-r", "--regex",
        default=None,
        help=(
            "Optional regex pattern to restrict processing to matching "
            "file paths.  Example: -r 'abc123' processes only files whose "
            "path contains 'abc123'."
        ),
    )
    parser.add_argument(
        "-u", "--update",
        default=None,
        dest="update_time",
        help=(
            "Only process items whose source file was modified at or after "
            "this date/time.  Accepts 'today', a date (2015-01-01), or "
            "date-time (2015-01-01T18:24)."
        ),
    )
    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        dest="log_level",
        help="Set the logging verbosity (default: INFO).",
    )
    return parser.parse_args()


# ---------------------------------------------------------------------------
# Media operations
# ---------------------------------------------------------------------------

def delete_media_items(ctx, matching_item):
    """
    Delete all media objects currently attached to an Omeka item.

    Called before re-uploading thumbnail and HTML so that the item does not
    accumulate duplicate media objects across repeated script runs.

    HTTP 500 responses from the delete endpoint are treated as non-fatal —
    the Omeka S API occasionally returns 500 for media items that have already
    been removed in a prior step or that reference missing files on disk.
    All other HTTP errors are recorded as OmekaMediaError and processing
    continues with the next media object.

    Parameters:
    * ctx           - OmekaContext providing the authenticated API client
    * matching_item - dict: the Omeka item JSON-LD object whose media to delete
    """
    for media_item in matching_item.get("o:media", []):
        media_id = media_item["o:id"]
        try:
            logger.info(f"Deleting media item {media_id}")
            ctx.client.delete_resource(media_id, "media")
        except HTTPError as err:
            if err.response.status_code == 401 or err.response.status_code == 403:
                raise OmekaAuthError(
                    "Omeka S returned 401 Unauthorized or 403 Forbidden. "
                    "Check that key_identity and key_credential in config/private.yml are correct. "
                    "You may also need to be logged onto the VPN."
                ) from err
            elif err.response.status_code == 500:
                # 500 on DELETE is treated as "already gone" by convention.
                # Log at DEBUG so it does not clutter normal output.
                logger.debug(f"HTTP 500 deleting media {media_id} (may already be absent); continuing")
            else:
                ctx.record_error(
                    OmekaMediaError(f"HTTP {err.response.status_code} deleting media {media_id}: {err}")
                )
        except Exception as err:
            ctx.record_error(
                OmekaMediaError(f"Unexpected error deleting media {media_id}: {err}")
            )

def build_thumbnail_url(ctx, json_item):
    """
    Construct the remote IIIF URL and local cache filename for this item's thumbnail.

    Returns a (remote_url, local_filename) tuple, or None if the item has no
    cover_image. local_filename is a string suitable for joining with iiif_dir;
    ingest_thumbnail() appends it to the iiif_dir path.

    Parameters:
    * ctx       - OmekaContext (provides iiif_server, iiif_collection)
    * json_item - dict: one record from a Datura ES JSON file

    """

    collection_name = ctx.iiif_collection if ctx.iiif_collection else json_item.get("collection", "")
    cover_image = json_item.get("cover_image")

    if not cover_image:
        return None

    # Parse any existing extension from the cover_image name. Image identifiers
    # often contain dots that are not extensions (e.g. loc.00001, ccda.let00001),
    # so only treat the suffix as an extension if it is a known image format.
    _KNOWN_IMAGE_EXTS = {".jpg", ".jpeg", ".png"}
    _stem, _ext = os.path.splitext(cover_image)
    if _ext.lower() in _KNOWN_IMAGE_EXTS:
        stem, image_ext = _stem, _ext
    else:
        stem, image_ext = cover_image, ".jpg"

    # Construct the IIIF Image API URL for the thumbnail.
    # The !200,200 size specifier requests a thumbnail that fits within a
    # 200×200 bounding box while preserving aspect ratio.
    remote = (
        f"{ctx.iiif_server}/iiif/2/{collection_name}%2F{stem}{image_ext}/full/!200,200/0/default.jpg"
    )
    # Cache the thumbnail locally using the same URL-encoded filename so that
    # re-runs can be inspected on disk if needed.
    local_name = f"{collection_name}%2F{stem}{image_ext}"

    return remote, local_name


def ingest_thumbnail(ctx, json_item, matching_item, iiif_dir):
    """
    Download a IIIF thumbnail and upload it to Omeka as the item's primary media.

    Thumbnail ingest is performed before HTML ingest so that Omeka designates
    the image as the item's primary_media (Omeka S uses the first media object
    as the primary).

    URL construction is delegated to build_thumbnail_url(), which can be
    overridden independently. 
    
    If build_thumbnail_url() returns None (no cover_image on the item), or if
    the download or upload fails, the function returns — the HTML ingest still
    proceeds.

    Parameters:
    * ctx           - OmekaContext (provides iiif_server, client, item_set_id)
    * json_item     - dict: one record from a Datura ES JSON file
    * matching_item - dict: the Omeka item to attach the thumbnail to
    * iiif_dir      - pathlib.Path pointing to the local IIIF output directory
                      where the downloaded thumbnail is cached temporarily
    """
    identifier = json_item.get("identifier", "unknown")

    _build_thumbnail_url = ctx._fn_build_thumbnail_url or build_thumbnail_url
    result = _build_thumbnail_url(ctx, json_item)
    if result is None:
        # No thumbnail for this item — nothing to do.
        logger.debug(f"No cover_image for {identifier!r}; skipping thumbnail ingest")
        return

    thumbnail_remote, local_name = result
    thumbnail_local = iiif_dir / local_name

    # --- Download ---
    try:
        logger.info(f"Downloading thumbnail for {identifier!r}")
        response = requests.get(thumbnail_remote, timeout=30)
        response.raise_for_status()
        with open(thumbnail_local, "wb") as thumb_file:
            thumb_file.write(response.content)
    except Exception as err:
        ctx.record_warning(f"Could not download thumbnail for {identifier!r}: {err}; skipping thumbnail ingest")
        return

    # --- Upload ---
    # The title property ID is fetched via the cache so repeated calls for
    # the same term do not make redundant API requests.
    try:
        media_payload = {
            "o:is_public": ctx.is_public,
            "data": {
                "upload": str(thumbnail_local),
                "dcterms:title": ctx.client.prepare_property_value(
                    json_item.get("title", ""),
                    ctx.get_property_id("dcterms:title"),
                ),
            },
            "o:ingester": "upload",
        }
        logger.info(f"Posting thumbnail for {identifier!r}")
        ctx.client.add_media_to_item(matching_item["o:id"], thumbnail_local, payload=media_payload)
    except FileNotFoundError:
        # The download step wrote the file, but something removed it between
        # download and upload. Unlikely in practice but handled explicitly
        # so the error message is clear.
        ctx.record_warning(f"Thumbnail file {thumbnail_local} not found at upload time; skipping")
    except Exception as err:
        ctx.record_error(
            OmekaMediaError(
                f"Error posting thumbnail for {identifier!r}: {err}"
            )
        )


def ingest_html(ctx, json_item, matching_item, html_dir):
    """
    Read a pre-rendered HTML file and upload it to Omeka as an HTML media object.

    The HTML ingester reads content from payload["data"]["html"] rather than
    from the uploaded file bytes; the file is opened only to read its content
    into memory. The Omeka S "html" ingester stores the markup directly in
    the database, making it searchable and renderable within Omeka.

    Skips silently if:
    * The .html file does not exist at html_dir/<identifier>.html.
    * The file exists but is empty or contains only whitespace.

    Parameters:
    * ctx           - OmekaContext
    * json_item     - dict: one record from a Datura ES JSON file
    * matching_item - dict: the Omeka item to attach the HTML to
    * html_dir      - pathlib.Path pointing to the HTML output directory
    """
    identifier = json_item.get("identifier", "unknown")
    file_path = html_dir / f"{identifier}.html"

    try:
        with open(file_path, "r", encoding="utf-8") as file:
            html_content = file.read()
    except FileNotFoundError:
        # A missing HTML file is common for items that have no text
        # representation (e.g. pure image records). Log at INFO so users
        # can see which items were skipped without it being alarming.
        logger.info(f"HTML file {file_path} not found; skipping")
        return

    # Guard against empty or whitespace-only files.
    if not html_content.strip():
        ctx.record_warning(
            f"HTML file for {identifier!r} is empty; skipping.  "
            "Check whether the XSLT transform produced output for this item."
        )
        return

    media_payload = {
        "o:is_public": ctx.is_public,
        "data": {
            "html": html_content,
        },
        "o:ingester": "html",
    }

    try:
        logger.info(f"Posting HTML for {identifier!r}")
        ctx.client.add_media_to_item(matching_item["o:id"], file_path, payload=media_payload)
    except Exception as err:
        ctx.record_error(
            OmekaMediaError(
                f"Error posting HTML for {identifier!r}: {err}"
            )
        )


# ---------------------------------------------------------------------------
# Main processing loop
# ---------------------------------------------------------------------------

def ingest_item_media(ctx, json_item, matching_item, html_dir, iiif_dir):
    """
    Run the full media pipeline for a single Omeka item.

    Encapsulates the delete-then-reingest sequence so that collections needing
    a different media pipeline (e.g. adding a PDF step, skipping thumbnails for
    certain item types) can override this function without touching the item-lookup and
    skip logic in process_items().

    Order matters: thumbnail must be uploaded before HTML so that Omeka
    designates the image as primary_media (Omeka S uses the first media object
    attached to an item as its primary).

    Parameters:
    * ctx           - OmekaContext
    * json_item     - dict: one record from a Datura ES JSON file
    * matching_item - dict: the current Omeka item retrieved from the API
    * html_dir      - pathlib.Path to output/<env>/html/
    * iiif_dir      - pathlib.Path to output/<env>/iiif/
    """
    delete_media_items(ctx, matching_item)
    ingest_thumbnail(ctx, json_item, matching_item, iiif_dir)
    ingest_html(ctx, json_item, matching_item, html_dir)

def process_items(ctx, pathlist, html_dir, iiif_dir):
    """
    For each JSON record, look up the Omeka item and ingest its media.

    Logic:
    * Skip items with no identifier (cannot look up in Omeka).
    * Skip items with 0 or >1 Omeka matches (not posted / data integrity issue).
    * If --media-skip is set and the item already has 2+ media objects
      (thumbnail + HTML), skip re-ingestion to avoid unnecessary deletions.
    * Otherwise: delete existing media, ingest thumbnail, ingest HTML.

    Parameters:
    * ctx      - OmekaContext
    * pathlist - list of pathlib.Path objects for ES JSON files
    * html_dir - pathlib.Path to output/<env>/html/
    * iiif_dir - pathlib.Path to output/<env>/iiif/
    """
    for path in pathlist:
        filename = str(path)
        rel = path.relative_to(Path.cwd())
        with open(filename) as jsonfile:
            json_items = json.load(jsonfile)
        # Apply --csv-rows identifier filter if provided.
        if ctx.csv_rows:
            json_items = omeka.filter_items_by_identifier(ctx.csv_rows, json_items)
        for json_item in json_items:
            identifier = json_item.get("identifier")
            if not identifier:
                ctx.record_warning(f"Skipping item without identifier in {rel}")
                continue

            title = json_item.get("title")
            if not title:
                ctx.record_warning(f"Skipping item without title in {rel}")
                continue

            # --- Look up the item in Omeka ---
            try:
                matching_items = ctx.client.filter_items_by_property(
                    filter_property="dcterms:identifier",
                    filter_value=identifier,
                    item_set_id=ctx.item_set_id,
                )
            except Exception as err:
                ctx.record_error(OmekaAPIError(identifier, "filter_items (media)", err))
                continue

            if not matching_items:
                ctx.record_warning(f"Unexpected empty response from filter_items for {identifier!r}; skipping")
                continue

            total = matching_items.get("total_results", 0)
            if total == 0:
                ctx.record_warning(f"No Omeka item found for {identifier!r}; skipping media ingest")
                continue
            if total > 1:
                ctx.record_warning(f"Multiple Omeka items ({total}) found for {identifier!r}; check admin site and skip")
                continue

            matching_item = matching_items["results"][0]
            media_count = len(matching_item.get("o:media", []))

            # --media-skip: if the item already has 2+ media objects
            # (thumbnail + HTML), assume it was already fully ingested and
            # skip it to avoid redundant deletion and re-upload.
            if ctx.media_skip and media_count >= 2:
                logger.info(f"Skipping media for {identifier!r}: already has {media_count} media object(s)")
                continue

            # --- Media pipeline ---
            ingest_item_media(ctx, json_item, matching_item, html_dir, iiif_dir)

        # Record the last-processed file so that -p (no value) can resume
        # from this point on the next run.
        write_checkpoint(path.stem, ctx, "omeka_html")

# ---------------------------------------------------------------------------
# Entrypoint
# ---------------------------------------------------------------------------

def main():
    """
    Entrypoint: parse arguments, build context, run media ingest, report.

    Execution order:
    1. Parse CLI arguments.
    2. Configure root logger.
    3. Build OmekaContext (loads config, validates keys, creates API client).
    4. Resolve output directories for the requested environment.
    5. Discover JSON files; apply csv (-c), format (-f), regex (-r), and update-time (-u) filters.
    6. Apply proceed filter (-p): resume from a checkpoint or a named file.
    7. Run media ingest for all items; writes a checkpoint after each JSON file.
    8. Report errors; exit 1 if any failures, 0 if clean.
    """
    args = _parse_args()
    start_time = time.time()
    configure_logging(args.log_level)

    # Validate regex for -r and -c option input
    if args.regex:
        validate_regex_arg(args.regex, "--regex")
    if args.csv_rows:
        validate_regex_arg(args.csv_rows, "--csv-rows")

    # OmekaConfigError propagates here as a fatal error — missing or broken
    # config means no API access is possible.
    ctx = OmekaContext.from_args(args)

    # Resolve all three environment-specific directories using the requested
    # environment so that -e production reads from output/production/ rather
    # than always defaulting to output/development/.
    json_dir  = ctx.resolve_path(f"output/{ctx.environment}/es")
    html_dir  = ctx.resolve_path(f"output/{ctx.environment}/html")
    iiif_dir  = ctx.resolve_path(f"output/{ctx.environment}/iiif")

    pathlist = list(Path(json_dir).glob("**/*.json"))

    if ctx.format_filter:
        pathlist = filter_items_by_format(ctx.format_filter, pathlist)
    if ctx.regex:
        pathlist = filter_items(ctx.regex, pathlist)
    if ctx.update_time:
        pathlist = filter_items_by_date(ctx.update_time, pathlist)

    # Apply -p / --proceed: resume from a specific file or the last checkpoint.
    # args.proceed is False (not given), None (-p with no value), or a string.
    proceed = args.proceed
    if proceed is None:
        # -p given with no value — prompt to resume from the saved checkpoint.
        last = read_checkpoint(ctx, "omeka_html")
        if last is None:
            print(
                "ERROR: --proceed given with no value but no checkpoint file "
                "found at {}.".format(checkpoint_path(ctx, "omeka_html"))
            )
            sys.exit(1)
        response = input("Continue from {}? (y/n): ".format(last)).strip().lower()
        if response == "y":
            proceed = last
        else:
            print("Exiting.")
            sys.exit(0)
    if proceed:
        pathlist = omeka.proceed_files(proceed, pathlist)

    logger.info(
        "Found %d JSON file(s) in %s (environment=%r, media_skip=%s)",
        len(pathlist),
        f"output/{ctx.environment}/es",
        ctx.environment,
        ctx.media_skip,
    )

    process_items(ctx, pathlist, html_dir, iiif_dir)

    finish_run(ctx, args, start_time)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nInterrupted. Exiting.")
        sys.exit(1)
    except OmekaConfigError as err:
        logger.debug("Fatal configuration error:", exc_info=True)
        print(f"ERROR: {err}", file=sys.stderr)
        sys.exit(1)
