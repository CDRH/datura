class FieldDefinitions:
    #these are the default field definitions, which may be overridden in specific projects
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
        return json.get("uri_data", None)
    
    def dcterms_type(self, json):
        #note that "type" is a builtin function in Python
        return json.get("type", None)
    
    def creator(self, json):
        creator_names = [creator['name'] for creator in json.get("creator") or [] if 'name' in creator]
        return creator_names
    
    def contributor(self, json):
        contributor_names = [contributor['name'] for contributor in json.get("contributor") or [] if 'name' in contributor]
        return contributor_names
    
    def date(self, json):
        return json.get("date", None)
    
    def description(self, json):
        return json.get("description", None)
    
    def dcterms_format(self, json):
        #note that "format" is a builtin function in Python
        return json.get("format", None)
    
    def relation(self, json):
        relation_ids = [relation['id'] for relation in json.get("has_relation") or [] if 'name' in relation]
        return relation_ids
        
    #citation fields
    #TODO is citation always single-valued? if array might need to add code to deal with that
    
    def publisher(self, json):
        return json.get("citation", {}).get("publisher", None)
        
    def biblID(self, json):
        #note: this field is not yet implemented in the schema
        return json.get("citation", {}).get("id", None)
        
    def biblTitle(self, json):
        return json.get("citation", {}).get("title", None)
        
    def biblPubPlace(self, json):
        return json.get("citation", {}).get("pubplace", None)
        
    def issue(self, json):
        return json.get("citation", {}).get("issue", None)
        
    def pageStart(self, json):
        return json.get("citation", {}).get("page_start", None)
        
    def pageEnd(self, json):
        return json.get("citation", {}).get("page_end", None)
        
    def section(self, json):
        return json.get("citation", {}).get("section", None)
        
    def volume(self, json):
        return json.get("citation", {}).get("volume", None)
        
    def biblTitleA(self, json):
        return json.get("citation", {}).get("title_a", None)
        
    def biblTitleM(self, json):
        return json.get("citation", {}).get("title_m", None)
    
    def biblTitleJ(self, json):
        return json.get("citation", {}).get("title_j", None)
        
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
        return json.get("has_source") and json.get("has_source", {}).get("title")

        
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
        places = [json["spatial"]] if isinstance(json["spatial"], dict) else json["spatial"]
        if places:
            try:
                place_names = [place['short_name'] for place in places or [] if 'short_name' in place]
            except:
                breakpoint()
            return place_names
        
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
        return json.get("text", None)
    
def get_fields():
    try:
        from omeka_overrides import CustomFields
        return CustomFields()
    except ImportError:
        return FieldDefinitions()