"""
json_to_omeka.py

Entrypoint script: reads Datura-generated ElasticSearch JSON files and posts
each item to an Omeka S instance.

The script runs in two sequential passes:

  Pass 1 — Item posting (post_items):
    For each JSON item, check whether the Omeka identifier already exists.
    * If found (one result): update the existing Omeka item's metadata.
    * If not found: create a new Omeka item.
    * If multiple results: warn and skip (data integrity problem).

  Pass 2 — Item linking (link_items):
    After all items exist in Omeka, re-read the same JSON files and populate
    relational fields (has_part, has_source, etc.) by resolving Omeka IDs for
    the referenced items. A separate pass is required because items must exist
    before they can be linked to one another.

Usage (from collection root directory):
    python3 json_to_omeka.py            # defaults to development
    python3 json_to_omeka.py -e production -r "some_pattern"
    python3 json_to_omeka.py --log-level DEBUG

The script is invoked by bin/post_omeka in the Datura gem.  The Ruby wrapper
passes -e and -r arguments from its own CLI.  No changes to bin/post_omeka
are required to support the --log-level flag (it defaults to INFO).
"""

import argparse
import copy
import json
import logging
import os
import sys
import time
from pathlib import Path

try:
    import api_fields
    import omeka
    from omeka_context import (
        OmekaAPIError,
        OmekaConfigError,
        OmekaContext,
        checkpoint_path,
        configure_logging,
        finish_run,
        read_checkpoint,
        validate_regex_arg,
        write_checkpoint,
    )
    from omeka import filter_items, filter_items_by_date, filter_items_by_format, prepare_item_payload_using_template
except ModuleNotFoundError as err:
    raise SystemExit(
        f"\033[31m ERROR: {err}\n"
        "A required Python package could not be found. "
        "You may need to ensure the virtual environment is activated before running this script.\n"
        "You may also need to be connected to the VPN.\033[0m"
    ) from err

# Module-level logger.  Records from this module appear as "json_to_omeka"
# in log output so they can be filtered independently from other modules.
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# CLI argument parsing
# ---------------------------------------------------------------------------

def _parse_args():
    """
    Parse command-line arguments for the JSON-to-Omeka entrypoint.

    Returns an argparse.Namespace with:
    * environment   - "development" or "production" (default: "development")
    * format_filter - optional format string for -f (directory-based) filter, or None
    * json_output   - bool; True skips post to Omeka API and instead writes data to files as JSON
    * regex         - optional file-filter pattern string, or None
    * csv_rows    - optional identifier regex for -c item filter, or None
    * proceed     - False (not given), None (-p with no value), or a regex
                    string (-p "pattern") for checkpoint-based resumption
    * update_time   - optional date/time string for -u filter, or None
    * log_level     - logging level string, default "INFO"

    """
    parser = argparse.ArgumentParser(
        description="Post Datura ES JSON output to an Omeka S instance."
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
        "-j", "--json-output",
        action="store_true",
        dest="json_output",
        default=False,
        help=(
            "Write Omeka S item payloads to output/<environment>/omeka/ instead "
            "of posting to the API. No items are created or updated in Omeka. "
            "An API connection is still required for property ID lookups and "
            "template validation. The link pass is skipped because no live "
            "Omeka item IDs are available."
        ),
    )
    parser.add_argument(
        "-p", "--proceed",
        nargs="?",
        default=False,
        const=None,
        dest="proceed",
        help=(
            "Proceed with posting from (and including) the JSON file matching "
            "this regex.  If given without a value, resumes from the last "
            "checkpoint saved in logs/proceed_omeka_{environment}."
        ),
    )
    parser.add_argument(
        "-r", "--regex",
        default=None,
        help=(
            "Optional regex pattern to restrict processing to matching "
            "file paths. Example: -r 'abc123' processes only files whose "
            "path contains 'abc123'."
        ),
    )
    parser.add_argument(
        "-u", "--update",
        default=None,
        dest="update_time",
        help=(
            "Only process items whose source file was modified at or after "
            "this date/time. Accepts 'today', a date (2015-01-01), or "
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
# Pass 1: item creation / update
# ---------------------------------------------------------------------------

def post_items(ctx, pathlist, json_output_dir=None):
    """
    First pass: create or update Omeka items for every JSON record.

    Iterates over all JSON files in pathlist. For each record:
    * Items whose identifier already exists in Omeka are updated in place.
    * Items not yet in Omeka are created from scratch.
    * Items that return multiple Omeka matches are skipped with a warning
      (duplicate identifiers indicate a data integrity problem that must be
      resolved in the Omeka admin UI before the item can be re-posted).
    * Items whose identifier field is falsy are skipped with a warning.

    Per-item errors (API failures, malformed payload) are recorded via
    ctx.record_error() and do NOT halt the run. Fatal errors (wrong
    credentials, missing config) raise exceptions that propagate to main().

    Parameters:
    * ctx             - OmekaContext providing API client, config, and error log
    * pathlist        - list of pathlib.Path objects pointing to ES JSON files
    * json_output_dir - optional Path; when set, write Omeka S item payloads to
                        this directory instead of posting to the API
    """
    for path in pathlist:
        filename = str(path)
        rel = path.relative_to(Path.cwd())
        with open(filename) as jsonfile:
            json_items = json.load(jsonfile)
        # Apply --csv-rows identifier filter if provided.
        if ctx.csv_rows:
            json_items = omeka.filter_items_by_identifier(ctx.csv_rows, json_items)
        # template_number is stable for the lifetime of a run — read from
        # ctx rather than re-reading from config for every item.
        template_number = ctx.template_number

        for json_item in json_items:
            identifier = json_item.get("identifier")
            if not identifier:
                # Records without an identifier cannot be matched or created.
                logger.warning("Skipping item without identifier in %s", rel)
                continue

            title = json_item.get("title")
            if not title:
                logger.warning("Skipping item without title in %s", rel)
                continue

            if json_output_dir is not None:
                # JSON output mode: build the payload and write it to disk
                # rather than to the Omeka API.
                try:
                    new_item = api_fields.prepare_item(ctx, json_item)
                except Exception as err:
                    ctx.record_error(OmekaAPIError(identifier, "prepare_item", err))
                    continue
                if not new_item:
                    logger.warning("Could not prepare payload for %r; skipping", identifier)
                    continue
                try:
                    payload = prepare_item_payload_using_template(ctx, new_item, template_number)
                except Exception as err:
                    ctx.record_error(OmekaAPIError(identifier, "prepare_template_payload", err))
                    continue
                out_path = json_output_dir / f"{identifier}.json"
                relative_path = f"output/{ctx.environment}/{identifier}.json"
                logger.info("Writing Omeka payload for %r to %s", identifier, relative_path)
                with open(out_path, "w") as f:
                    json.dump(payload, f, indent=2)
                continue

            try:
                matching_items = ctx.client.filter_items_by_property(
                    filter_property="dcterms:identifier",
                    filter_value=identifier,
                    item_set_id=ctx.item_set_id,
                )
            except Exception as err:
                ctx.record_error(OmekaAPIError(identifier, "filter_items", err))
                continue

            if not matching_items:
                # API returned no response object at all — treat as a lookup
                # failure rather than "zero results".
                logger.warning(
                    "Unexpected empty response from filter_items for %r; skipping",
                    identifier,
                )
                continue

            total = matching_items.get("total_results", 0)

            if total == 1:
                # Item exists — refresh its metadata.
                update_existing_item(ctx, json_item, matching_items)
            elif total == 0:
                # Item is new — create it.
                add_new_item(ctx, json_item, template_number)
            else:
                # More than one match — cannot determine which to update.
                logger.warning(
                    "Multiple matches (%d) for %r; check Omeka admin site",
                    total,
                    identifier,
                )

        # Record the last-processed file so that -p (no value) can resume
        # from this point on the next run.
        write_checkpoint(path.stem, ctx, "omeka")


def add_new_item(ctx, json_item, template_number):
    """
    Build the Omeka payload for a new item and POST it to the API.

    Calls api_fields.prepare_item() to extract and format each field from
    the Datura JSON record. If preparation produces no payload (e.g. all
    fields were absent), the item is skipped with a warning rather than
    POSTing an empty object.

    Parameters:
    * ctx             - OmekaContext
    * json_item       - dict: one record from a Datura ES JSON file
    * template_number - Omeka resource template numeric ID (from ctx.template_number)
    """
    identifier = json_item.get("identifier", "unknown")

    new_item = api_fields.prepare_item(ctx, json_item)
    if not new_item:
        logger.warning("Could not prepare payload for %r; skipping", identifier)
        return

    # Log the identifier we are about to create. Use .get() with a default
    # rather than direct dict access so a missing dcterms:identifier key
    # does not raise KeyError and halt the run.
    title_val = (
        new_item.get("dcterms:identifier", [{}])[0].get("@value", identifier)
    )
    logger.info("Creating item %r", title_val)

    # Validate terms against the resource template and wrap values in the
    # JSON-LD structure Omeka S expects.
    payload = prepare_item_payload_using_template(ctx, new_item, template_number)

    try:
        ctx.client.add_item(
            payload,
            template_id=template_number,
            item_set_id=ctx.item_set_id,
            is_public=ctx.is_public,
        )
    except Exception as err:
        ctx.record_error(OmekaAPIError(identifier, "add_item", err))


def update_existing_item(ctx, json_item, matching_items):
    """
    Re-prepare an existing Omeka item's metadata and PATCH it via the API.

    Fetches the current Omeka item, merges it with fresh values from the
    Datura JSON record, and calls update_resource() to apply the changes.

    Parameters:
    * ctx            - OmekaContext
    * json_item      - dict: one record from a Datura ES JSON file
    * matching_items - dict: Omeka API response containing the existing item
                       under matching_items["results"][0]
    """
    identifier = json_item.get("identifier", "unknown")

    # Log the Omeka-side identifier to make it easy to correlate log lines
    # with records in the Omeka admin UI.
    omeka_id_display = (
        matching_items["results"][0]
        .get("dcterms:identifier", [{}])[0]
        .get("@value", identifier)
    )
    logger.info("Updating item %r", omeka_id_display)

    # Deep-copy to avoid mutating the dict returned by the API client; the
    # original might be referenced elsewhere (e.g. in link_items).
    item_to_update = copy.deepcopy(matching_items["results"][0])
    updated_item = api_fields.prepare_item(ctx, json_item, item_to_update)
    if not updated_item:
        logger.warning("Could not prepare update payload for %r; skipping", identifier)
        return

    try:
        ctx.client.update_resource(updated_item, "items")
    except Exception as err:
        ctx.record_error(OmekaAPIError(identifier, "update_resource", err))


# ---------------------------------------------------------------------------
# Pass 2: record linking
# ---------------------------------------------------------------------------

def link_items(ctx, pathlist):
    """
    Second pass: populate relational fields between Omeka items.

    Re-reads the same JSON files processed in pass 1. For each record,
    resolves the Omeka item IDs of related items (has_part, has_source, etc.)
    and PATCHes the item with link values.

    A separate pass is necessary because linked items must already exist in
    Omeka before they can be referenced. Running this pass after all items
    have been created (or updated) in pass 1 guarantees that the target items
    are present.

    Items that cannot be found or that have multiple matches are skipped with
    a warning; they will be logged in the run summary.

    Parameters:
    * ctx      - OmekaContext
    * pathlist - list of pathlib.Path objects (same list used in post_items)
    """
    for path in pathlist:
        filename = str(path)
        rel = path.relative_to(Path.cwd())
        with open(filename) as jsonfile:
            json_items = json.load(jsonfile)
        if ctx.csv_rows:
            json_items = omeka.filter_items_by_identifier(ctx.csv_rows, json_items)

        for json_item in json_items:
            identifier = json_item.get("identifier")
            if not identifier:
                logger.debug("Skipping item without identifier in %s", rel)
                continue

            title = json_item.get("title")
            if not title:
                logger.warning("Skipping item without title in %s", rel)
                continue

            try:
                matching_items = ctx.client.filter_items_by_property(
                    filter_property="dcterms:identifier",
                    filter_value=identifier,
                    item_set_id=ctx.item_set_id,
                )
            except Exception as err:
                ctx.record_error(OmekaAPIError(identifier, "filter_items (link pass)", err))
                continue

            if not matching_items:
                logger.warning(
                    "Unexpected empty response from filter_items for %r during link pass; skipping",
                    identifier,
                )
                continue

            total = matching_items.get("total_results", 0)
            if total == 1:
                _link_item(ctx, json_item, matching_items)
            else:
                # total == 0: item was not successfully posted in pass 1.
                # total > 1: data integrity problem (duplicate identifiers).
                # In both cases, linking is impossible.
                logger.warning(
                    "Skipping link pass for %r: expected 1 match, got %d",
                    identifier,
                    total,
                )


def _link_item(ctx, json_item, matching_items):
    """
    Resolve and attach relational fields for a single Omeka item.

    Extracts the Omeka item from matching_items, calls api_fields.link_records()
    to populate relation fields, and PATCHes the result back to the API.

    Named with a leading underscore to signal that it is an internal helper
    called only by link_items(); external code should use link_items().

    Parameters:
    * ctx            - OmekaContext
    * json_item      - dict: one record from a Datura ES JSON file
    * matching_items - dict: Omeka API response containing the item to link
    """
    # Pull the human-readable identifier from the Omeka item for log messages.
    item_id = (
        matching_items["results"][0]
        .get("dcterms:identifier", [{}])[0]
        .get("@value", json_item.get("identifier", "unknown"))
    )
    logger.info("Linking records for %r", item_id)

    # Deep-copy so that api_fields.link_records() can modify the item dict
    # without affecting the in-memory copy used elsewhere in this pass.
    item_to_link = copy.deepcopy(matching_items["results"][0])

    try:
        _link_records = ctx._fn_link_records or api_fields.link_records
        linked_item = _link_records(ctx, json_item, item_to_link)
    except Exception as err:
        ctx.record_error(OmekaAPIError(item_id, "link_records", err))
        return

    try:
        ctx.client.update_resource(linked_item, "items")
    except Exception as err:
        # Log the full traceback at DEBUG level so that --log-level DEBUG
        # reveals the exact API response; WARNING is shown by default.
        logger.debug("Traceback for update_resource failure:", exc_info=True)
        ctx.record_error(OmekaAPIError(item_id, "update_resource (link pass)", err))


# ---------------------------------------------------------------------------
# Entrypoint
# ---------------------------------------------------------------------------

def main():
    """
    Entrypoint: parse arguments, build context, run both passes, report.

    Execution order:
    1. Parse CLI arguments via _parse_args().
    2. Configure the root logger (before any other work so all output is
       captured at the right level).
    3. Build OmekaContext — loads config/private.yml, validates required keys,
       initialises the authenticated API client. Exits with a descriptive
       error message if the config is missing or malformed (OmekaConfigError).
    4. Discover JSON files under output/<environment>/es/.
    5. Apply csv (-c), format (-f), regex (-r), and update-time (-u) filters.
    6. Apply proceed filter (-p): resume from a checkpoint or a named file.
    7. Add scripts/python to sys.path so that collection-specific
       overrides can be imported by field_definitions.get_fields().
    8. Run pass 1 (post_items); writes a checkpoint after each JSON file.
    9. Reset the API client between passes for a clean connection.
    10. Run pass 2 (link_items); always processes the full filtered pathlist.
    11. Print run summary; exit 1 if any per-item errors were recorded,
    """
    args = _parse_args()
    start_time = time.time()

    # Configure root logger first so that even OmekaContext initialisation
    # errors are captured at the correct level.
    configure_logging(args.log_level)

    # Validate regex for -r and -c option input
    if args.regex:
        validate_regex_arg(args.regex, "--regex")
    if args.csv_rows:
        validate_regex_arg(args.csv_rows, "--csv-rows")

    # OmekaContext.from_args() raises OmekaConfigError (a subclass of
    # OmekaError) if config/private.yml is missing, unparseable, or missing
    # a required key. Let this propagate to the top level — configuration
    # errors are fatal and should produce a clear traceback.
    ctx = OmekaContext.from_args(args)

    # Resolve the ES output directory for the requested environment.
    # ctx.resolve_path() returns an absolute Path relative to cwd (the
    # collection root), so passing -e production reads from output/production/
    # rather than always defaulting to output/development/.
    json_dir = ctx.resolve_path(f"output/{ctx.environment}/es")
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
        last = read_checkpoint(ctx, "omeka")
        if last is None:
            print(
                "ERROR: --proceed given with no value but no checkpoint file "
                "found at {}.".format(checkpoint_path(ctx, "omeka"))
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
        "Found %d JSON file(s) in %s (environment=%r)",
        len(pathlist),
        f"output/{ctx.environment}/es",
        ctx.environment,
    )

    if not pathlist:
        logger.warning(f"No JSON files found in output/{ctx.environment}/es — nothing to post or link. Exiting.")
        sys.exit(0)

    # --- JSON output mode (-j / --json-output) ---
    if args.json_output:
        relative_dir = f"output/{ctx.environment}/omeka"
        omeka_out_dir = ctx.resolve_path(relative_dir)
        Path(omeka_out_dir).mkdir(parents=True, exist_ok=True)
        logger.info(
            "JSON output mode: writing Omeka S payloads to %s (API will not be called)",
            relative_dir,
        )
        post_items(ctx, pathlist, json_output_dir=Path(omeka_out_dir))
        finish_run(ctx, args, start_time)
        return

    # --- Pass 1: create / update items ---
    logger.info("Starting pass 1: item posting")
    post_items(ctx, pathlist)

    # Reset the API client between passes. ctx.reset_client() re-instantiates
    # OmekaAPIClient with the same credentials, giving a fresh connection for
    # the second round of requests. The property ID cache is preserved because
    # term-to-ID mappings do not change between passes.
    logger.info("Pass 1 complete. Resetting API client for pass 2.")
    ctx.reset_client()

    # --- Pass 2: link related items ---
    logger.info("Starting pass 2: record linking")
    link_items(ctx, pathlist)

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
