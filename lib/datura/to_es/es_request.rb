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
    if @options["api_version"] == "1.0"
      assemble_json_1
    elsif @options["api_version"] == "2.0"
      assemble_json_2
    end
    assemble_collection_specific
    assemble_text
    @json
  end

  def assemble_json_1
    #fields for API v 1.0
    assemble_identifiers_1
    assemble_categories_1
    assemble_locations_1
    assemble_descriptions_1    
    assemble_other_metadata_1
    assemble_dates_1
    assemble_publishing_1
    assemble_people_1
    assemble_spatial_1
    assemble_references_1
    assemble_rdf_1
  end

  def assemble_json_2
    #field for API v 2.0
    assemble_identifiers_2
    assemble_metadata_digital_2
    assemble_metadata_original_2
    assemble_metadata_interpretive_2
    assemble_relations_2
    assemble_additional_2
  end

  ##############
  # components #
  ##############
  def assemble_collection_specific
    # add your own per collection
    # with format
    # @json["fieldname"] = field_contents
  end

  def assemble_categories_1
    @json["category"] = category
    @json["subcategory"] = subcategory
    @json["data_type"] = data_type
    @json["collection"] = collection
    @json["collection_desc"] = collection_desc
    @json["subjects"] = subjects
  end

  def assemble_dates_1
    @json["date"] = date
    @json["date_not_after"] = date_not_after
    @json["date_not_before"] = date_not_before
    @json["date_display"] = date_display
  end

  def assemble_descriptions_1
    @json["alternative"] = alternative
    @json["description"] = description
    @json["title"] = title
    @json["title_sort"] = title_sort
    @json["topics"] = topics
  end

  def assemble_identifiers_1
    @json["identifier"] = @id
  end

  def assemble_locations_1
    @json["uri"] = uri
    @json["uri_data"] = uri_data
    @json["uri_html"] = uri_html
    @json["image_id"] = image_id
  end

  def assemble_other_metadata_1
    @json["format"] = format
    @json["language"] = language
    @json["languages"] = languages
    @json["relation"] = relation
    @json["type"] = type
    @json["extent"] = extent
    @json["medium"] = medium
  end

  def assemble_people_1
    # container fields
    @json["person"] = person
    @json["contributor"] = contributor
    @json["creator"] = creator
    @json["recipient"] = recipient
  end

  def assemble_publishing_1
    @json["publisher"] = publisher
    @json["rights"] = rights
    @json["rights_uri"] = rights_uri
    @json["rights_holder"] = rights_holder
    @json["source"] = source
  end

  def assemble_references_1
    @json["keywords"] = keywords
    @json["places"] = places
    @json["works"] = works
  end

  def assemble_spatial_1
    @json["spatial"] = spatial
  end

  def assemble_rdf_1
    @json["rdf"] = rdf
  end

  def assemble_identifiers_2
    @json["identifier"] = @id # does this still work?
    @json["collection"] = collection
    @json["collection_desc"] = collection_desc
    @json["uri"] = uri
    @json["uri_data"] = uri_data
    @json["uri_html"] = uri_html
    @json["data_type"] = data_type
    @json["fig_location"] = fig_location
    @json["cover_image"] = cover_image
    @json["title"] = title
    @json["title_sort"] = title_sort
    @json["alternative"] = alternative
    @json["date_updated"] = date_updated
    @json["category"] = category
    @json["category2"] = category2
    @json["category3"] = category3
    @json["category4"] = category4
    @json["category5"] = category5
    @json["notes"] = notes
  end

  def assemble_metadata_digital_2
    @json["contributor"] = contributor
  end

  def assemble_metadata_original_2
    @json["creator"] = creator
    @json["citation"] = citation
    @json["date"] = date
    @json["date_display"] = date_display
    @json["date_not_before"] = date_not_before
    @json["date_not_after"] = date_not_after
    @json["format"] = format
    @json["medium"] = medium
    @json["extent"] = extent
    @json["language"] = language
    @json["rights_holder"] = rights_holder
    @json["rights"] = rights
    @json["rights_uri"] = rights_uri
    @json["container_box"] = container_box
    @json["container_folder"] = container_folder
  end

  def assemble_metadata_interpretive_2
    @json["subjects"] = subjects
    @json["abstract"] = abstract
    @json["description"] = description
    @json["type"] = type
    @json["topics"] = topics
    @json["keywords"] = keywords
    @json["keywords2"] = keywords2
    @json["keywords3"] = keywords3
    @json["keywords4"] = keywords4
  end

  def assemble_relations_2
    @json["relation"] = relation
    @json["source"] = source
    @json["has_part"] = has_part
    @json["is_part_of"] = is_part_of
    @json["previous_item"] = previous_item
    @json["next_item"] = next_item
  end

  def assemble_additional_2
    @json["spatial"] = spatial
    @json["places"] = places
    @json["person"] = person
    @json["event"] = event
    @json["rdf"] = rdf
  end

  def assemble_text
    @json["annotations_text"] = annotations_text
    @json["text"] = text
  end

end
