# assemble_json sets up the JSON structure that will be
# ingested into omeka s documents. However, the JSON
# structure depends on subclasses to define methods like
# "category" and "subcategory" to populate the JSON.
#
# This module itself is not standalone, but by putting
# the JSON structure in a common place, those classes
# including it do not each need to redefine the JSON
# request structure

module JsonRequest

  def assemble_json
    # Note: if your collection does not require a specific field
    # it may be better to override the field's behavior to return
    # nil than to alter the below field list methods
    # values being sent, because otherwise they could just override
    # the field behavior to be blank

    # TODO: we may want to break this out into methods based on namespace
    # or some other organization scheme but for now just dumping all into one 
    # to get things started
    assemble_fields_omeka_s
    assemble_collection_specific
    assemble_text
    @json
  end

  ##############
  # components #
  ##############
  def assemble_collection_specific
    # add your own per collection
    # with format
    # @json["fieldname"] = field_contents
  end

  def assemble_fields_omeka_s
    @json["tei:authority"] = authority
    @json["tei:biblAuthor"] = bibl_author
    @json["tei:biblDate"] = bibl_date
    @json["tei:biblNote"] = bibl_note
    @json["tei:biblPublisher"] = bibl_publisher
    @json["tei:biblPubPlace"] = bibl_pub_place
    @json["tei:biblTitle"] = bibl_title
    @json["tei:distributor"] = distributor
    @json["tei:idno"] = idno # would @id work?
    @json["tei:language"] = language
    @json["tei:license"] = license
    @json["tei:principal"] = principal
    @json["tei:publisher"] = publisher
    @json["tei:publisherAddrLine"] = publisher_addr_line
    #@json["tei:subtitle"] = subtitle
    @json["tei:resp"] = resp
    @json["tei:sourceCollection"] = source_collection
    @json["tei:sourceID"] = source_id
    @json["tei:sourceRepository"] = source_repo
    @json["tei:title"] = title
    @json["tei:xmlid"] = xmlid
  end

  # TODO: do we need this or will this be handled with the html?
  def assemble_text
    @json["cdrh:annotations_text"] = annotations_text
    @json["cdrh:text"] = text
  end

end
