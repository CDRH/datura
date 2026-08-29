"""
omeka_context.py

Central context object and exception hierarchy for the Omeka S ingestion pipeline.

"""

import importlib.util
import logging
from logging.handlers import RotatingFileHandler
import os
import re
import sys

from field_definitions import get_fields
import time
from datetime import date, datetime
from pathlib import Path
from typing import Dict, List, Optional

import yaml
from omeka_s_tools.api import OmekaAPIClient

# Module-level logger. Using __name__ means log records from this module
# appear as "omeka_context" in the output, making it easy to filter.
logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Logging setup
# ---------------------------------------------------------------------------

# --- Colored console handler ---
CYAN = "\033[36m"
GREEN = "\033[32m"
RED = "\033[31m"
BRIGHTRED = "\033[1;31m"
YELLOW = "\033[33m"
RESET = "\033[0m"

class ColoredConsoleHandler(logging.StreamHandler):
    COLORS = {
        logging.DEBUG:    CYAN,
        logging.INFO:     GREEN,
        logging.WARNING:  YELLOW,
        logging.ERROR:    RED,
        logging.CRITICAL: BRIGHTRED,
    }
    RESET = RESET
    def emit(self, record):
        color = self.COLORS.get(record.levelno, self.RESET)
        record.msg = f"{color}{record.msg}{self.RESET}"
        super().emit(record)

def configure_logging(level="INFO"):
    numeric_level = getattr(logging, level.upper(), logging.INFO)
    
    os.makedirs("logs", exist_ok=True) 

    # File handler — verbose
    file_handler = RotatingFileHandler(
        "logs/python.log", maxBytes=5 * 1024 * 1024, backupCount=3
    )
    file_handler.setFormatter(logging.Formatter("%(asctime)s [%(levelname)-8s] %(name)s: %(message)s"))
    file_handler.setLevel(logging.DEBUG)  # always save everything to logs

    # Console handler — respects the requested level
    console_handler = ColoredConsoleHandler()
    console_handler.setFormatter(logging.Formatter("%(asctime)s %(levelname)-8s %(name)s: %(message)s"))
    console_handler.setLevel(numeric_level)

    # Root logger
    root = logging.getLogger()
    root.setLevel(logging.DEBUG)  # let handlers decide what to filter
    root.addHandler(file_handler)
    root.addHandler(console_handler)

# ---------------------------------------------------------------------------
# Exception hierarchy
# ---------------------------------------------------------------------------

class OmekaError(Exception):
    """
    Base class for all Omeka pipeline errors.

    Catch this to handle any pipeline error generically, or catch a subclass
    to handle a specific failure mode. All subclasses produce a descriptive
    human-readable message so that log entries are self-explanatory without
    requiring a full traceback.
    """


class OmekaConfigError(OmekaError):
    """
    Raised when the pipeline cannot start due to a configuration problem.

    Common causes:
    - config/private.yml does not exist in the collection directory
    - The YAML file is malformed and cannot be parsed
    - A required key (e.g. "omeka_server", "key_identity") is absent

    This is always a fatal error: the pipeline cannot connect to or
    authenticate with Omeka S without a valid configuration, so the process
    exits immediately rather than attempting to continue.
    """

class OmekaAuthError(OmekaConfigError):
    """
    Raised when the Omeka S API returns 401 Unauthorized or 403 Forbidden.

    This is always fatal: if credentials are wrong every API call will fail,
    so the process exits immediately rather than accumulating per-item failures.

    Common causes:
    - key_identity or key_credential is wrong or has been revoked
    - The Omeka S instance URL points to the wrong server
    """


def _is_unauthorized(err):
    """Return True if err is an HTTP 401 or 403 response error from the requests library."""
    try:
        from requests.exceptions import HTTPError
        return isinstance(err, HTTPError) and getattr(
            getattr(err, "response", None), "status_code", None
        ) in {401, 403}
    except ImportError:
        return False


class OmekaAPIError(OmekaError):
    """
    Raised when an Omeka S API call fails for a specific item or resource.

    Unlike OmekaConfigError, this is typically a per-item failure. The run
    continues and the error is accumulated via ctx.record_error() so that
    a full summary is printed at the end of the run.

    Attributes:
    * identifier - the CDRH identifier string of the item that failed,
                   or "unknown" if the identifier could not be determined
    * operation  - short description of the failing operation, e.g. "add_item"
    * cause      - the original exception raised by the API client
    """
    def __init__(self, identifier, operation, cause):
        self.identifier = identifier
        self.operation = operation
        self.cause = cause
        super().__init__(
            f"{operation} failed for {identifier!r}: {cause}"
        )
        

class OmekaMediaError(OmekaError):
    """
    Raised when a media upload or deletion operation fails.

    Separated from OmekaAPIError so that callers can distinguish between failures
    on item metadata (OmekaAPIError) and failures on associated media objects
    (OmekaMediaError), which may warrant different recovery strategies.
    """


# ---------------------------------------------------------------------------
# Date parsing
# ---------------------------------------------------------------------------

def parse_update_time(s):
    """
    Parse a -u / --update date string into a datetime object.

    Accepts the same formats as the Ruby Datura -u flag:
    * "today"            - midnight of the current local date
    * "2015-01-01"       - date only
    * "2015-01-01T18:24" - date and time

    Raises OmekaConfigError with a descriptive message if the string does not
    match any expected format.
    """
    if s == "today":
        d = date.today()
        return datetime(d.year, d.month, d.day)
    for fmt in ("%Y-%m-%dT%H:%M", "%Y-%m-%d"):
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            continue
    raise OmekaConfigError(
        f"{RED}Invalid --update value {s!r}. "
        f"Expected 'today', a date (2015-01-01), or date-time (2015-01-01T18:24).{RESET}"
    )

# ---------------------------------------------------------------------------
# Regex parsing
# ---------------------------------------------------------------------------

def validate_regex_arg(pattern, flag):
    """
    Compile a regex string, raising OmekaConfigError immediately if invalid.

    Mirrors the Ruby Datura::Helpers.validate_regex check. Called in each
    entrypoint's main() before OmekaContext is built, so that an invalid
    -r or -c value exits with a clean error message rather than a traceback.

    Parameters:
    * pattern - the regex string from the CLI argument
    * flag    - the flag name for the error message, e.g. "--regex"
    """
    try:
        re.compile(pattern)
    except re.error as e:
        raise OmekaConfigError(
            f"Invalid regex for {flag} {pattern!r}: {e}"
        )

# ---------------------------------------------------------------------------
# Context
# ---------------------------------------------------------------------------

class OmekaContext:
    """
    Encapsulates all configuration and shared state for one pipeline run.

    Create exactly one OmekaContext per entrypoint invocation using the class
    method from_args(). Pass the resulting context object to every pipeline
    function that needs configuration or API access.

    The context holds:
    - Parsed, validated configuration from config/private.yml
    - A single authenticated OmekaAPIClient (self.client)
    - A property ID cache to avoid repeated API lookups per field per item
    - An error accumulator that collects per-item failures without halting the run

    """

    @classmethod
    def from_args(cls, args):
        """
        Build an OmekaContext from a parsed argparse.Namespace.

        Loads config/private.yml from the current working directory (the
        collection root), validates that all required keys are present, and
        initialises the authenticated API client.

        Parameters:
        * args - argparse.Namespace produced by an entrypoint's _parse_args().
                 Expected attributes:
                   .environment     str   "development" or "production"
                   .format_filter   str   optional format string for -f (directory-based) 
                                       filter, or None
                   .regex           str   optional file-filter pattern, or None
                   .update_time     str   optional date/time string for -u filter, or None
                   .csv_rows        str   optional identifier regex for -c filter, or None
                   .media_skip      bool  skip re-ingesting existing media
                                       (html_and_media_ingest only; absent on
                                       json_to_omeka args, defaults to False)

        Raises OmekaConfigError if the config file is missing, unparseable,
        or is missing a required key.
        """
        conf_path = Path.cwd() / "config" / "private.yml"
        logger.debug("Loading config from %s", conf_path)

        # Load the top-level "default" section, which holds credentials and
        # settings common to all environments.
        default_config = cls._load_config(conf_path, env="default")

        # Load the environment-specific section (primarily contains item_set).
        # If the section is absent (e.g. an unrecognised environment name was
        # passed), raise an error and exit.
        env_config = cls._load_config(conf_path, env=args.environment)

        # Merge so that environment-specific values override defaults, giving
        # collections the ability to override any default key (e.g.
        # resource_template, omeka_data_base) on a per-environment basis.
        env_config = {**default_config, **env_config}

        raw_update = getattr(args, "update_time", None)
        return cls(
            env_config=env_config,
            environment=args.environment,
            # getattr with a default handles entrypoints that don't define
            # every flag (e.g. json_to_omeka.py has no --media-skip).
            regex=getattr(args, "regex", None),
            media_skip=getattr(args, "media_skip", False),
            update_time=parse_update_time(raw_update) if raw_update else None,
            format_filter=getattr(args, "format_filter", None),
            csv_rows=getattr(args, "csv_rows", None),
        )

    @staticmethod
    def _load_config(path, env):
        """
        Load a single environment section from a YAML config file.

        Parameters:
        * path - pathlib.Path pointing to the YAML file
        * env  - the top-level key to extract, e.g. "default" or "development"

        Returns the dict for that section.

        Raises OmekaConfigError with a descriptive message on any I/O or parse
        failure, so that operators know exactly what to fix without reading a
        Python traceback.
        """
        try:
            with open(path) as f:
                contents = yaml.safe_load(f)
        except FileNotFoundError:
            raise OmekaConfigError( 
                f"{RED}Config file not found: {path}. "
                "Ensure config/private.yml exists in the collection directory "
                f"and that you are running the script from the collection root.{RESET}"
            )
        except yaml.YAMLError as exc:
            raise OmekaConfigError(
                f"{RED}Could not parse YAML in {path}: {exc}{RESET}"
            )

        if env not in contents:
            raise OmekaConfigError(RED + 
                f"{RED}Environment section {env!r} not found in {path}. "
                f"Available sections: {list(contents.keys())}{RESET}"
            )

        return contents[env]

    def __init__(self, env_config, environment, regex, media_skip, update_time=None, format_filter=None, csv_rows=None):
        """
        Initialise the context. Prefer OmekaContext.from_args() over calling
        this constructor directly except in tests.

        Parameters:
        * env_config    - merged dict: the "default" section of private.yml
                          overlaid with the environment-specific section so that
                          per-environment values take precedence over defaults.
                          Must contain omeka_server, key_identity, key_credential,
                          resource_template, omeka_data_base, and item_set.
        * environment   - "development" or "production"
        * format_filter - optional format string to filter files by format (directory); 
                          None means process all files in the output directory
        * regex         - optional regex string to filter input file paths;
                          None means process all files in the output directory
        * media_skip    - if True, items that already have 2+ media objects
                          (thumbnail + HTML) are skipped during media ingest
        * update_time   - optional datetime; if set, only items whose source file
                          mtime >= this value are processed (mirrors the -u flag
                          from the main Datura post command)
        * csv_rows    - optional regex string; if set, only items whose 
                        "identifier" field matches are processed (mirrors the 
                        -c flag from the main Datura post command)
        """
        # ---- Validate required config keys --------------------------------
        # Validate up front so that failures are immediate and descriptive.
        # Checks for all keys so user is alerted to any missing key at the outset.
        required_keys = [
            "omeka_server",
            "key_identity",
            "key_credential",
            "resource_template",
            "omeka_data_base",
        ]
        missing_keys = [key for key in required_keys if key not in env_config]
        if missing_keys:
            raise OmekaConfigError(
                f"{RED}Missing required config key(s): {missing_keys}. "
                f"Check the 'default' or {environment!r} section of config/private.yml.{RESET}"
            )

        # ---- Validate environment-specific item_set ---------------------------
        if "item_set" not in env_config:
            raise OmekaConfigError(
                f"{RED}Missing 'item_set' for environment {environment!r} in config/private.yml.\n"
                "Add the item set ID for this environment before running. Example:\n\n"
                f"  {environment}:\n"
                "    item_set: 123\n\n"
                "To find your item set ID, log into the Omeka S admin and navigate "
                f"to Items > Item Sets.{RESET}"
            )

        # ---- Runtime flags ------------------------------------------------
        self.environment = environment
        self.regex = regex
        self.media_skip = media_skip
        self.update_time = update_time
        self.format_filter = format_filter
        self.csv_rows = csv_rows

        # ---- Config values ------------------------------------------------
        self.template_number = env_config["resource_template"]
        self.omeka_data_base = env_config["omeka_data_base"]
        # iiif_server is optional — not all collections ingest thumbnails.
        self.iiif_server = env_config.get("iiif_server", "")
        # iiif_collection is optional — not all collections have different iiif collection names.
        self.iiif_collection = env_config.get("iiif_collection", "")

        # Keep the merged config dict for the item_set_id property.
        self._env_config = env_config

        # ---- Credentials (stored for reset_client) ------------------------
        # Stored privately so that credential strings are not accidentally
        # printed, logged, or serialised through the public interface.
        self._api_url = env_config["omeka_server"]
        self._key_identity = env_config["key_identity"]
        self._key_credential = env_config["key_credential"]

        # ---- API client ---------------------------------------------------
        # Single authenticated client used for all API operations.
        self.client = OmekaAPIClient(
            api_url=self._api_url,
            key_identity=self._key_identity,
            key_credential=self._key_credential,
        )
        logger.debug(
            "OmekaContext initialised (environment=%r, template=%s)",
            self.environment,
            self.template_number,
        )

        # ---- Property ID cache --------------------------------------------
        # Maps Omeka term strings (e.g. "dcterms:title") to their numeric IDs.
        # IDs are stable within a single Omeka S instance for the lifetime of
        # a run, so fetching each term once is sufficient.
        self._property_id_cache = {}  # type: Dict[str, int]

        # ---- Error accumulator --------------------------------------------
        # Non-fatal per-item errors are appended here rather than aborting the
        # run. report_run() logs a consolidated summary at the end.
        self._errors = []  # type: List[OmekaError]

        # ---- Warning accumulator ------------------------------------------
        # Non-fatal per-item warnings (skipped items, ambiguous matches, etc.)
        # are appended here. report_run() displays a consolidated block at end.
        self._warnings = []  # type: List[str]

        # ---- Field definitions --------------------------------------------
        # Load collection-specific field mappings once here. get_fields() returns 
        # a CustomFields subclass if scripts/python/field_overrides.py is present; 
        # otherwise the default FieldDefinitions instance.
        self.fields = get_fields(omeka_data_base=self.omeka_data_base)

        # ---- Process function overrides -----------------------------------
        # Load collection-specific replacements for four pipeline functions:
        #   link_records, update_item_value, link_item_record  (api_fields.py)
        #   build_thumbnail_url                     (html_and_media_ingest.py)
        #
        # Each attribute is None when no override is present; call sites
        # resolve the default via:  (ctx._fn_X or module.X)(ctx, ...)
        #
        # importlib.util is used to load the file by explicit path so that
        # sys.path is not mutated and the module is not cached in sys.modules,
        # keeping each context init independent.
        self._fn_link_records = None
        self._fn_update_item_value = None
        self._fn_link_item_record = None
        self._fn_build_thumbnail_url = None

        _process_override_path = Path.cwd() / "scripts" / "python" / "process_overrides.py"
        _process_override_relative_path = "scripts/python/process_overrides.py"
        if _process_override_path.exists():
            try:
                _spec = importlib.util.spec_from_file_location(
                    "process_overrides", _process_override_path
                )
                _po = importlib.util.module_from_spec(_spec)
                _spec.loader.exec_module(_po)
                self._fn_link_records        = getattr(_po, "link_records", None)
                self._fn_update_item_value   = getattr(_po, "update_item_value", None)
                self._fn_link_item_record    = getattr(_po, "link_item_record", None)
                self._fn_build_thumbnail_url = getattr(_po, "build_thumbnail_url", None)
                _active = [
                    n for n, f in [
                        ("link_records",        self._fn_link_records),
                        ("update_item_value",   self._fn_update_item_value),
                        ("link_item_record",    self._fn_link_item_record),
                        ("build_thumbnail_url", self._fn_build_thumbnail_url),
                    ] if f is not None
                ]
                if _active:
                    logger.warning(
                        "Process overrides found at %s; active overrides: %s",
                        _process_override_relative_path,
                        _active,
                    )
            except Exception as e:
                raise OmekaConfigError(
                    f"Failed to load process overrides from {_process_override_relative_path}: {e}"
                ) from e


    # -----------------------------------------------------------------------
    # Properties
    # -----------------------------------------------------------------------

    @property
    def item_set_id(self):
        # type: () -> Optional[int]
        """
        The Omeka item set ID for the current environment.

        Stored in the environment-specific config section so that development
        and production ingests can target different item sets. 
        """
        return self._env_config.get("item_set")

    @property
    def is_public(self):
        # type: () -> bool
        """
        Always returns False. Items are posted as private (visible only to logged-in Omeka
        admins) regardless of environment. Visibility can be changed manually in the Omeka S
        admin interface after ingest if needed. 

        If it is desired to change this behavior at some future point such that items posted 
        to the production environment will be public by default, replace `return False` below 
        with `return self.environment == "production"`.

        """
        return False

    # -----------------------------------------------------------------------
    # API helpers
    # -----------------------------------------------------------------------

    def get_property_id(self, term):
        # type: (str) -> int
        """
        Return the numeric Omeka property ID for a term, using a per-run cache.

        The first call for a given term makes one API request and stores the
        result. All subsequent calls return the cached integer immediately.
        The cache is preserved across reset_client() calls because term-to-ID
        mappings are stable within a single Omeka S instance.

        Parameters:
        * term - Omeka property term string, e.g. "dcterms:title", "dh:collection"
        """
        if term not in self._property_id_cache:
            logger.debug("Fetching property ID for term %r (not yet cached)", term)
            self._property_id_cache[term] = self.client.get_property_id(term)
        return self._property_id_cache[term]

    def reset_client(self):
        """
        Re-instantiate the authenticated API client with a fresh connection
        to clear its HTTP response cache. (Otherwise Pass 2 would return the 
        stale responses from GET requests in Pass 1, per the OmekaAPIClient's 
        requests_cache session wrapper.)

        The property ID cache is intentionally preserved: term-to-ID mappings
        do not change between passes, so clearing and re-fetching them would
        waste API calls without any benefit.
        """
        logger.debug("Resetting API client (property ID cache preserved)")
        self.client = OmekaAPIClient(
            api_url=self._api_url,
            key_identity=self._key_identity,
            key_credential=self._key_credential,
        )

    # -----------------------------------------------------------------------
    # Path resolution
    # -----------------------------------------------------------------------

    def resolve_path(self, relative):
        # type: (str) -> Path
        """
        Resolve a path relative to the current working directory (collection root).
        Callers interpolate the environment into the path template:

            json_dir = ctx.resolve_path(f"output/{ctx.environment}/es")

        This ensures that passing -e production reads from output/production/
        rather than always using output/development/.

        Parameters:
        * relative - path string relative to cwd, e.g. "output/development/es"

        Returns an absolute pathlib.Path.
        """
        return (Path.cwd() / relative).resolve()

    # -----------------------------------------------------------------------
    # Error accumulation
    # -----------------------------------------------------------------------

    def record_error(self, err):
        # type: (OmekaError) -> None
        """
        Record a non-fatal per-item error without halting the run.

        Use for item-level failures (API errors, missing files, malformed data)
        where the correct behaviour is to log the problem, skip the affected
        item, and continue processing the rest of the batch.

        Fatal errors that make the entire run impossible (wrong credentials,
        missing config file) should raise OmekaConfigError directly and let
        the process exit with a traceback.

        Parameters:
        * err - an OmekaError (or subclass) instance describing the failure
        """
        cause = getattr(err, "cause", None)
        if _is_unauthorized(cause):
            raise OmekaAuthError(RED + 
                "Omeka S returned 401 Unauthorized or 403 Forbidden. "
                "Check that key_identity and key_credential in config/private.yml are correct. "
                "You may also need to be logged onto the VPN."
                + RESET
            ) from cause
        logger.error(str(err))
        self._errors.append(err)

    def record_warning(self, msg):
        # type: (str) -> None
        """
        Record a non-fatal per-item warning without halting the run.

        Logs immediately at WARNING level and appends the message to
        _warnings for consolidated display at the end of the run via
        report_run().

        Parameters:
        * msg - human-readable warning string
        """
        logger.warning(msg)
        self._warnings.append(msg)

    def report_run(self):
        """
        Log a consolidated summary of all warnings and errors recorded during the run.

        Called by finish_run() just before sys.exit(). If any errors
        were recorded, the entrypoint should exit with code 1 so that the
        calling Ruby process (system() in bin/post_omeka or bin/post_omeka_html)
        can detect that the run completed with failures.

        If no warnings or errors were recorded, logs a single success message.
        """
        if self._warnings:
            logger.warning("Run completed with %d warning(s):", len(self._warnings))
            for w in self._warnings:
                logger.warning("  %s", w)
        if self._errors:
            logger.warning("Run completed with %d error(s):", len(self._errors))
            for err in self._errors:
                logger.warning("  %s", err)
        if not self._warnings and not self._errors:
            logger.info("Run completed successfully with no warnings or errors.")

def finish_run(ctx, args, start_time):
    """
    Report warnings and errors, print summary block and timing, and exit.

    Called at the end of each Omeka entrypoint script's main() function.
    Exits 0 on success, 1 if any errors were recorded.

    Parameters:
    * ctx        - OmekaContext whose _warnings and _errors lists are inspected
    * args       - argparse.Namespace (unused; kept for call-site compatibility)
    * start_time - float from time.time() captured at the top of main()
    """
    ctx.report_run()
    # Count summary
    print(f"{len(ctx._warnings)} Omeka warning(s)")
    print(f"{len(ctx._errors)} Omeka posting error(s)")
    # Warning detail block
    if ctx._warnings:
        print("\n--- Warning details ---")
        for w in ctx._warnings:
            print(f"  {w}")
        print("-----------------------")
    # Error detail block
    if ctx._errors:
        print(RED + "\n--- Error details ---" + RESET)
        for err in ctx._errors:
            print(RED + f"  {err}" + RESET)
        print(RED + "---------------------" + RESET)
    elapsed = int(time.time() - start_time)
    hours, rem = divmod(elapsed, 3600)
    mins, secs = divmod(rem, 60)
    print(f"{CYAN}Script finished in {hours:02d} hrs {mins:02d} mins {secs:02d} secs{RESET}")
    sys.exit(1 if ctx._errors else 0)

# ---------------------------------------------------------------------------
# Checkpoint helpers  (-p / --proceed support)
# ---------------------------------------------------------------------------

def checkpoint_path(ctx, label):
    """
    Return the Path to the checkpoint file for this environment and pipeline.

    The checkpoint file records the stem of the last JSON file that was
    successfully processed so that a subsequent run with -p (no value) can
    resume from the same point rather than restarting from the beginning.

    Parameters:
    * ctx   - OmekaContext providing the current environment string
    * label - pipeline label used to keep each script's checkpoint separate,
              e.g. "omeka" for json_to_omeka or "omeka_html" for
              html_and_media_ingest
    """
    return Path.cwd() / "logs" / f"proceed_{label}_{ctx.environment}"


def read_checkpoint(ctx, label):
    """
    Read the last-saved checkpoint stem for this pipeline and environment.

    Returns the identifier stem string written by the most recent
    write_checkpoint() call, or None if no checkpoint file exists or the
    file is empty (e.g. first run, or file was manually cleared).

    Parameters:
    * ctx   - OmekaContext
    * label - pipeline label (see checkpoint_path)
    """
    path = checkpoint_path(ctx, label)
    if not path.exists():
        return None
    content = path.read_text().strip()
    return content if content else None


def write_checkpoint(stem, ctx, label):
    """
    Save stem as the most recently processed item identifier for this pipeline.

    Called after each JSON file is processed so that a run interrupted
    mid-way can be resumed with -p. Creates the logs/ directory if it does
    not yet exist.

    Parameters:
    * stem  - identifier string (JSON file stem) to record, e.g. "abc123"
    * ctx   - OmekaContext
    * label - pipeline label (see checkpoint_path)
    """
    path = checkpoint_path(ctx, label)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(f"{stem}\n")