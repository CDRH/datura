# assemble_json sets up the JSON structure that will be
# used to create elasticsearch documents. However, the JSON
# structure depend on subclasses to define methods like
# "category" and "subcategory" to populate the JSON.
#
# This module itself is not standalone, but by putting
# the JSON structure in a common place, those classes
# including it do not each need to redefine the JSON
# request structure

module EsRequest

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

    @json
  end

  ##############
  # components #
  ##############

  def assemble_categories
    @json["category"] = category
    @json["subcategory"] = subcategory
    @json["data_type"] = data_type
    @json["collection"] = collection
    @json["collection_desc"] = collection_desc
    @json["subjects"] = subjects
  end

  def assemble_collection_specific
    # add your own per collection
    # with format
    # @json["fieldname"] = field_contents
  end

  def assemble_dates
    @json["date"] = date
    @json["date_not_after"] = date_not_after
    @json["date_not_before"] = date_not_before
    @json["date_display"] = date_display
  end

  def assemble_descriptions
    @json["alternative"] = alternative
    @json["description"] = description
    @json["title"] = title
    @json["title_sort"] = title_sort
    @json["topics"] = topics
  end

  def assemble_identifiers
    @json["identifier"] = @id
  end

  def assemble_locations
    @json["uri"] = uri
    @json["uri_data"] = uri_data
    @json["uri_html"] = uri_html
    @json["image_id"] = image_id
  end

  def assemble_other_metadata
    @json["format"] = format
    @json["language"] = language
    @json["languages"] = languages
    @json["relation"] = relation
    @json["type"] = type
    @json["extent"] = extent
    @json["medium"] = medium
  end

  def assemble_people
    # container fields
    @json["person"] = person
    @json["contributor"] = contributor
    @json["creator"] = creator
    @json["recipient"] = recipient
  end

  def assemble_publishing
    @json["publisher"] = publisher
    @json["rights"] = rights
    @json["rights_uri"] = rights_uri
    @json["rights_holder"] = rights_holder
    @json["source"] = source
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
    @json["annotations_text"] = annotations_text
    @json["text"] = text
    # @json["abstract"]
  end

end
