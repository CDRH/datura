"""
omeka_context.py

Central context object and exception hierarchy for the Omeka S ingestion pipeline.

"""

import logging
import sys
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

def configure_logging(level="INFO"):
    """
    Configure the root logger for the pipeline.

    Should be called once at the very start of each entrypoint script before
    any other work begins. Subsequent calls are safe but have no additional
    effect — Python's logging.basicConfig() is a no-op if handlers are already
    attached to the root logger.

    Parameters:
    * level - logging level string: "DEBUG", "INFO", "WARNING", or "ERROR".
              Defaults to "INFO". Use "DEBUG" to trace individual API calls
              and property ID cache hits/misses.
    """
    logging.basicConfig(
        format="%(asctime)s %(levelname)-8s %(name)s: %(message)s",
        level=getattr(logging, level.upper(), logging.INFO),
    )


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
            "{} failed for {!r}: {}".format(operation, identifier, cause)
        )


class OmekaItemNotFoundError(OmekaError):
    """
    Raised when an item lookup returns zero results but exactly one was expected.

    Typical causes:
    - An item was not ingested during the posting pass before the linking pass ran
    - An identifier was changed between runs, leaving the old Omeka record orphaned
    """


class OmekaMultipleMatchesError(OmekaError):
    """
    Raised when an item lookup returns more than one result for a given identifier.

    Identifiers should be unique within an item set. Multiple matches indicate a
    data integrity problem that must be resolved in the Omeka admin UI before the
    affected item can be updated automatically.
    """


class OmekaMediaError(OmekaError):
    """
    Raised when a media upload or deletion operation fails.

    Separated from OmekaAPIError so that callers can distinguish between failures
    on item metadata (OmekaAPIError) and failures on associated media objects
    (OmekaMediaError), which may warrant different recovery strategies.
    """


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
                   .environment  str   "development" or "production"
                   .regex        str   optional file-filter pattern, or None
                   .media_skip   bool  skip re-ingesting existing media
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
        # passed), log a warning and fall back to an empty dict — item_set_id
        # will be None and the run will proceed without filtering by item set.
        try:
            env_config = cls._load_config(conf_path, env=args.environment)
        except OmekaConfigError:
            logger.warning(
                "No config section found for environment %r; "
                "item_set will be None and items will not be scoped to a set.",
                args.environment,
            )
            env_config = {}

        return cls(
            config=default_config,
            env_config=env_config,
            environment=args.environment,
            # getattr with a default handles entrypoints that don't define
            # every flag (e.g. json_to_omeka.py has no --media-skip).
            regex=getattr(args, "regex", None),
            media_skip=getattr(args, "media_skip", False),
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
                "Config file not found: {}. "
                "Ensure config/private.yml exists in the collection directory "
                "and that you are running the script from the collection root."
                .format(path)
            )
        except yaml.YAMLError as exc:
            raise OmekaConfigError(
                "Could not parse YAML in {}: {}".format(path, exc)
            )

        if env not in contents:
            raise OmekaConfigError(
                "Environment section {!r} not found in {}. "
                "Available sections: {}"
                .format(env, path, list(contents.keys()))
            )

        return contents[env]

    def __init__(self, config, env_config, environment, regex, media_skip):
        """
        Initialise the context. Prefer OmekaContext.from_args() over calling
        this constructor directly except in tests.

        Parameters:
        * config      - dict from the "default" section of private.yml;
                        must contain omeka_server, key_identity, key_credential,
                        resource_template, and omeka_data_base
        * env_config  - dict from the environment-specific section; used to
                        look up item_set
        * environment - "development" or "production"
        * regex       - optional regex string to filter input file paths;
                        None means process all files in the output directory
        * media_skip  - if True, items that already have 2+ media objects
                        (thumbnail + HTML) are skipped during media ingest
        """
        # ---- Validate required config keys --------------------------------
        # Validate up front so that failures are immediate and descriptive.
        # A missing key surfaced here gives a clear error message; the same
        # key missing inside a loop gives an opaque KeyError mid-run.
        required_keys = [
            "omeka_server",
            "key_identity",
            "key_credential",
            "resource_template",
            "omeka_data_base",
        ]
        for key in required_keys:
            if key not in config:
                raise OmekaConfigError(
                    "Missing required config key {!r}. "
                    "Check the 'default' section of config/private.yml."
                    .format(key)
                )

        # ---- Runtime flags ------------------------------------------------
        self.environment = environment
        self.regex = regex
        self.media_skip = media_skip

        # ---- Config values ------------------------------------------------
        self.template_number = config["resource_template"]
        self.omeka_data_base = config["omeka_data_base"]
        # iiif_server is optional — not all collections ingest thumbnails.
        self.iiif_server = config.get("iiif_server", "")

        # Keep the environment-specific dict for the item_set_id property.
        self._env_config = env_config

        # ---- Credentials (stored for reset_client) ------------------------
        # Stored privately so that credential strings are not accidentally
        # printed, logged, or serialised through the public interface.
        self._api_url = config["omeka_server"]
        self._key_identity = config["key_identity"]
        self._key_credential = config["key_credential"]

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
        # run. report_errors() logs a consolidated summary at the end.
        self._errors = []  # type: List[OmekaError]

    # -----------------------------------------------------------------------
    # Properties
    # -----------------------------------------------------------------------

    @property
    def item_set_id(self):
        # type: () -> Optional[int]
        """
        The Omeka item set ID for the current environment, or None.

        Stored in the environment-specific config section so that development
        and production ingests target different item sets. Returns None if no
        item_set key is present (e.g. running locally without a complete
        private.yml, or using an environment that has no item_set configured).
        """
        return self._env_config.get("item_set")

    @property
    def is_public(self):
        # type: () -> bool
        """
        True only when environment is "production".

        Items created with is_public=False are visible only to logged-in Omeka
        admins, which prevents in-progress development ingests from appearing
        to public users of the site.
        """
        return self.environment == "production"

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
        Re-instantiate the authenticated API client with a fresh connection.

        Called in json_to_omeka.py between the item-posting pass and the
        item-linking pass to obtain a clean session before the second round
        of API requests.

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

            json_dir = ctx.resolve_path("output/{}/es".format(ctx.environment))

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
        logger.error(str(err))
        self._errors.append(err)

    def report_errors(self):
        """
        Log a consolidated summary of all errors recorded during the run.

        Called by entrypoint scripts just before sys.exit(). If any errors
        were recorded, the entrypoint should exit with code 1 so that the
        calling Ruby process (system() in bin/post_omeka or bin/post_omeka_html)
        can detect that the run completed with failures.

        If no errors were recorded, logs a single success message.
        """
        if self._errors:
            logger.warning("Run completed with %d error(s):", len(self._errors))
            for err in self._errors:
                logger.warning("  %s", err)
        else:
            logger.info("Run completed successfully with no errors.")
