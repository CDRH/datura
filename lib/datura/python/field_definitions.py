import importlib.util
import logging
from datetime import datetime
from pathlib import Path

logger = logging.getLogger(__name__)

class FieldDefinitions:
    """
    Default field extraction patterns for the Omeka S ingestion pipeline.

    Each method receives the raw JSON item dict (a single record from the
    Datura-generated ES output file) and returns the value to be posted for
    that Omeka property, or None if the field is absent.

    To override any method for a specific collection, copy
    omeka_overrides_example.py to scripts/python/omeka_overrides.py in the
    collection repository and subclass FieldDefinitions there. The get_fields()
    factory below will load the override class automatically.
    """

    def __init__(self, omeka_data_base=""):
        """
        Parameters:
        * omeka_data_base - base URL used to construct media URIs in uriData().
                            Passed in from OmekaContext.omeka_data_base.
                            Defaults to "" (empty string) so that instantiation
                            without arguments is safe in tests.
        """
        # Stored as a private attribute and accessed only by uriData().
        self._omeka_data_base = omeka_data_base

    def field_manifest(self):
        """
        Declare the ordered list of Omeka property mappings for this collection.

        Each entry is a (omeka_term, method_name, datatype) triple:
        * omeka_term  - Omeka S property term string, e.g. "dcterms:title"
        * method_name - name of the extractor method on this FieldDefinitions
                        instance to call for each JSON item
        * datatype    - Omeka data type string

        prepare_item() in api_fields.py iterates this manifest to build the
        item payload, calling getattr(ctx.fields, method_name)(json_item) for each
        entry. Overriding field_manifest in a CustomFields subclass is the
        recommended way to add collection-specific Omeka properties without
        touching prepare_item() itself.
        """
        return [
            ("dcterms:title",             "title",                "literal"),
            ("dcterms:identifier",        "identifier",           "literal"),
            ("dh:collection",             "collection",           "literal"),
            ("dh:category",               "category",             "literal"),
            ("dh:category2",              "category2",            "literal"),
            ("dh:uriData",                "uriData",              "uri"),
            ("dcterms:type",              "dcterms_type",         "literal"),
            ("dcterms:creator",           "creator",              "literal"),
            ("dcterms:contributor",       "contributor",          "literal"),
            ("dcterms:date",              "date",                 "numeric:timestamp"),
            ("dh:dateDisplay",            "dateDisplay",          "literal"),
            ("dh:dateYear",               "dateYear",             "literal"),
            ("dcterms:description",       "description",          "literal"),
            ("dcterms:format",            "dcterms_format",       "literal"),
            ("dcterms:relation",          "relation",             "literal"),
            ("dcterms:publisher",         "publisher",            "literal"),
            ("dh:biblID",                 "biblID",               "literal"),
            ("tei:biblTitle",             "biblTitle",            "literal"),
            ("tei:biblPubPlace",          "biblPubPlace",         "literal"),
            ("bibo:issue",                "issue",                "literal"),
            ("bibo:pageStart",            "pageStart",            "literal"),
            ("bibo:pageEnd",              "pageEnd",              "literal"),
            ("bibo:section",              "section",              "literal"),
            ("bibo:volume",               "volume",               "literal"),
            ("tei:biblTitleA",            "biblTitleA",           "literal"),
            ("tei:biblTitleM",            "biblTitleM",           "literal"),
            ("tei:biblTitleJ",            "biblTitleJ",           "literal"),
            ("dcterms:rightsHolder",      "rightsHolder",         "literal"),
            ("dcterms:license",           "license",              "literal"),
            ("dcterms:subject",           "subject",              "literal"),
            ("dh:topic",                  "topic",                "literal"),
            ("dh:category3",              "category3",            "literal"),
            ("dh:category4",              "category4",            "literal"),
            ("dh:category5",              "category5",            "literal"),
            ("dh:note",                   "note",                 "literal"),
            ("dcterms:abstract",          "abstract",             "literal"),
            ("dh:keyword",                "keyword",              "literal"),
            ("dh:keyword2",               "keyword2",             "literal"),
            ("dh:keyword3",               "keyword3",             "literal"),
            ("dh:keyword4",               "keyword4",             "literal"),
            ("dh:keyword5",               "keyword5",             "literal"),
            ("dcterms:source",            "source",               "literal"),
            ("dcterms:medium",            "medium",               "literal"),
            ("dcterms:extent",            "extent",               "literal"),
            ("dcterms:language",          "language",             "literal"),
            ("dh:box",                    "box",                  "literal"),
            ("dh:folder",                 "folder",               "literal"),
            ("foaf:name",                 "name",                 "literal"),
            ("dh:spatial_short_name",     "spatial_short_name",   "literal"),
            ("dh:annotationsText",        "annotationsText",      "literal"),
            ("dh:itemText",               "itemText",             "literal"),
        ]

    def _get_citation(self, json):
        """Return the citation sub-dict, or {} if absent or null."""
        return json.get("citation") or {}

    def title(self, json):
        return json.get("title", None)
    
    def identifier(self, json):
        return json.get("identifier", None)

    def collection(self, json):
        return json.get("collection", None)
    
    def category(self, json):
        return json.get("category", None)
    
    def category2(self, json):
        return json.get("category2", None)
    
    def uriData(self, json):
        uri_data = json.get("uri_data", None)
        if uri_data:
            # Strip the original path and reconstruct the URI under the
            # collection's configured media base URL. 
            filename = uri_data.split("/")[-1]
            new_uri_data = f"{self._omeka_data_base}/{filename}"
            return new_uri_data
    
    def dcterms_type(self, json):
        #note that "type" is a builtin function in Python
        return json.get("type", None)
    
    def creator(self, json):
        creator_names = [creator['name'] for creator in json.get("creator") or [] if 'name' in creator]
        return creator_names
    
    def contributor(self, json):
        contributor_names = [contributor['name'] for contributor in json.get("contributor") or [] if 'name' in contributor]
        return contributor_names
    
    # NOTE: use Pattern 5 in omeka_overrides if automatic conversion of dates with year or month only to yyyy-01-01
    # back to yyyy for Omeka is desired
    def date(self, json):
        date_to_parse = json.get("date", None)
        return date_to_parse
    
    def dateYear(self, json):
        date_to_parse = json.get("date", None)
        if date_to_parse:
            try:
                return datetime.strptime(date_to_parse, "%Y-%m-%d").year
            except ValueError:
                return None
    
    def dateDisplay(self, json):
        return json.get("date_display", None)
    
    def description(self, json):
        return json.get("description", None)
    
    def dcterms_format(self, json):
        #note that "format" is a builtin function in Python
        return json.get("format", None)
    
    def relation(self, json):
        relations = json.get("has_relation") or {}
        relation_ids = [relations['id']] if relations.get('id') is not None else []
        return relation_ids
    
    def publisher(self, json):
        return self._get_citation(json).get("publisher", None)
        
    def biblID(self, json):
        #note: this field is not yet implemented in the schema
        return self._get_citation(json).get("id", None)
        
    def biblTitle(self, json):
        return self._get_citation(json).get("title", None)
        
    def biblPubPlace(self, json):
        return self._get_citation(json).get("pubplace", None)
        
    def issue(self, json):
        return self._get_citation(json).get("issue", None)
        
    def pageStart(self, json):
        return self._get_citation(json).get("page_start", None)
        
    def pageEnd(self, json):
        return self._get_citation(json).get("page_end", None)
        
    def section(self, json):
        return self._get_citation(json).get("section", None)
        
    def volume(self, json):
        return self._get_citation(json).get("volume", None)
        
    def biblTitleA(self, json):
        return self._get_citation(json).get("title_a", None)
        
    def biblTitleM(self, json):
        return self._get_citation(json).get("title_m", None)
    
    def biblTitleJ(self, json):
        return self._get_citation(json).get("title_j", None)
        
    def rightsHolder(self, json):
        return json.get("rights_holder", None)
    
    def license(self, json):
        return json.get("rights", None)
    
    def subject(self, json):
        return json.get("subjects", None)
    
    def topic(self, json):
        return json.get("topics", None)
    
    def category3(self, json):
        return json.get("category3", None)
        
    def category4(self, json):
        return json.get("category4", None)
    
    def category5(self, json):
        return json.get("category5", None)
    
    def note(self, json):
        return json.get("notes", None)
    
    def abstract(self, json):
        return json.get("abstract", None)
    
    def keyword(self, json):
        return json.get("keywords", None)
    
    def keyword2(self, json):
        return json.get("keywords2", None)
    
    def keyword3(self, json):
        return json.get("keywords3", None)
    
    def keyword4(self, json):
        return json.get("keywords4", None)
    
    def keyword5(self, json):
        return json.get("keywords5", None)
    
    def source(self, json):
        return (json.get("has_source") or {}).get("title")
        
    def medium(self, json):
        return json.get("medium", None)
    
    def extent(self, json):
        return json.get("extent", None)
    
    def language(self, json):
        return json.get("language", None)
    
    def box(self, json):
        return json.get("container_box", None)
    
    def folder(self, json):
        return json.get("container_folder", None)
    
    def name(self, json):
        person_names = [person['name'] for person in json.get("person") or [] if  'name' in person]
        return person_names
    
    def spatial_short_name(self, json):
        spatial = json.get("spatial")
        if not spatial:
            return []
        places = [spatial] if isinstance(spatial, dict) else spatial
        short_names = [place['short_name'] for place in places if 'short_name' in place]
        return short_names
        
    def correspSentName(self, json):
        return json.get("correspSentName_omeka_s", None)
    
    def correspSentPlace(self, json):
        return json.get("correspSentPlace_omeka_s", None)
    
    def correspSentDate(self, json):
        return json.get("correspSentDate_omeka_s", None)
    
    def correspDeliveredName(self, json):
        return json.get("correspDeliveredName_omeka_s", None)
    
    def correspDeliveredPlace(self, json):
        return json.get("correspDeliveredPlace_omeka_s", None)
    
    def correspDeliveredDate(self, json):
        return json.get("correspDeliveredDate_omeka_s", None)
    
    def distributor(self, json):
        return json.get("distributor_omeka_s", None)
    
    def authority(self, json):
        return json.get("authority_omeka_s", None)
    
    def biblNote(self, json):
        return json.get("biblNote_omeka_s", None)
    
    def annotationsText(self, json):
        return json.get("annotations_text", None)
    
    def itemText(self, json):
        text = json.get("text", None)
        if text and json.get("data_type"):
            identifier = self.identifier(json)
            if identifier:
                text += (" " + identifier)
        return text
    
def get_fields(omeka_data_base=""):
    """
    Return the appropriate FieldDefinitions instance for this collection.

    Looks for a CustomFields class in scripts/python/field_overrides.py in
    the collection directory (resolved from the current working directory).
    If that file does not exist, falls back to the default FieldDefinitions
    class. If the file exists but cannot be loaded, raises RuntimeError.

    Parameters:
    * omeka_data_base - passed through to the FieldDefinitions constructor
                        so that uriData() can build correct media URIs.
                        Callers should pass ctx.omeka_data_base.

    Returns a FieldDefinitions instance (or a CustomFields subclass of it).
    """
    override_path = Path.cwd() / "scripts" / "python" / "field_overrides.py"
    if not override_path.exists():
        return FieldDefinitions(omeka_data_base=omeka_data_base)

    try:
        spec = importlib.util.spec_from_file_location("field_overrides", override_path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
    except Exception as e:
        raise RuntimeError(
            f"Failed to load field overrides from {override_path}: {e}"
        ) from e

    CustomFields = getattr(module, "CustomFields", None)
    if CustomFields is None:
        # File exists but defines no CustomFields class — use defaults.
        return FieldDefinitions(omeka_data_base=omeka_data_base)

    # CustomFields inherits __init__ from FieldDefinitions, so
    # omeka_data_base is passed through automatically. Override __init__
    # in CustomFields only if you need additional constructor logic.
    logger.warning(
        "Field overrides found at %s; custom field mappings will be applied.",
        override_path,
    )
    return CustomFields(omeka_data_base=omeka_data_base)