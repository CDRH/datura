# request creation portion of Xml to ES transformation
# override for VRA / TEI concerns in [type]_to_es.rb
# files or in collection specific overrides

class XmlToEs

  def assemble_json
    # Note: if your collection does not require a specific field
    # it may be better to override the field's behavior to return
    # nil than to alter the below field list methods
    # values being sent, because otherwise they could just override
    # the field behavior to be blank

    # below not alphabetical to reflect their position
    # in the cdrh api schema

    assemble_identifiers
    assemble_categories
    assemble_locations
    assemble_descriptions    
    assemble_other_metadata
    assemble_dates
    assemble_publishing
    assemble_people
    assemble_spatial
    assemble_references
    assemble_text
    assemble_collection_specific

    return @json
  end

  ##############
  # components #
  ##############

  def assemble_categories
    @json["category"] = category
    @json["subcategory"] = subcategory
    @json["data_type"] = "tei"
    @json["collection"] = collection
    @json["shortname"] = shortname
    # @json["subject"]
  end

  def assemble_collection_specific
    # add your own per collection
    # with format
    # @json["fieldname"] = field_contents
  end

  def assemble_dates
    @json["date_display"] = date_display
    @json["date"] = date
    @json["date_not_before"] = date
    @json["date_not_after"] = date false
  end

  def assemble_descriptions
    @json["title_sort"] = title_sort
    @json["title"] = title
    @json["description"] = description
    # @json["topics"]
    # @json["alternative"]
  end

  def assemble_identifiers
    @json["identifier"] = @id
  end

  def assemble_locations
    # TODO check, because I'm not sure the schema
    # lists the urls that we actually want to use
    # earlywashingtondc.org vs cdrhmedia, etc
    # @json["uri"]
    # @json["uri_data"]
    @json["uri_html"] = uri_html
    # @json["image_location"]
    # @json["image_id"]
  end

  def assemble_other_metadata
    @json["format"] = format
    @json["language"] = language
    # @json["relation"]
    # @json["type"]
    # @json["extent"]
    @json["medium"] = format
  end

  def assemble_people
    # container fields
    @json["person"] = person
    @json["contributor"] = contributors
    @json["creator"] = creator
    # can draw off of container fields
    @json["creator_sort"] = creator_sort
    @json["people"] = person_sort
  end

  def assemble_publishing
    @json["rights_uri"] = rights_uri
    @json["publisher"] = publisher
    @json["rights"] = rights
    @json["source"] = source
    @json["rights_holder"] = rights_holder
  end

  def assemble_references
    @json["keywords"] = keywords
    @json["places"] = places
    @json["works"] = works
  end

  def assemble_spatial
    # TODO not sure about the naming convention here?
    # TODO has place_name, coordinates, id, city, county, country,
    # region, state, street, postal_code
    # @json["coverage.spatial"]
  end

  def assemble_text
    @json["annotations"] = annotations
    @json["text"] = text
    # @json["abstract"]
  end

end
