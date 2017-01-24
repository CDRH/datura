require "nokogiri"
require_relative "helpers.rb"

# TODO would this whole thing be better as a class instead of a module?
# originally planning on mixing in generic module with project specific classes
# but this seems like it's actually working okay, but maybe it could be better???

module TeiToEs

  # getter for json response object
  def self.create_json xml, params={}
    @json = self.assemble_json xml, params
  end

  # These are the default xpaths that are used for projects
  #  if you require a different xpath, please override the xpath in
  #  the specific project's TeiToEs file or create a new method
  #  in that file which returns a different value
  @xpaths = {
    "title_main" => "/TEI/teiHeader/fileDesc/titleStmt/title[@type='main'][1]",
    "title_alt" => "/TEI/teiHeader/fileDesc/titleStmt/title[1]",
    "category" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='category'][1]/term",
    "creators" => [
      "/TEI/teiHeader/fileDesc/titleStmt/author",
      "//persName[@type = 'author']"
    ],
    "publisher" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1]",
    "contributors" => "/TEI/teiHeader/revisionDesc/change/name",
    "date" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when",
    "formats" => [
      "/TEI/text/body/div1[@type='letter']",
      "/TEI/teiHeader/fileDesc/sourceDesc/bibl/title"
    ],
    "source" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[@level='j']",
    "rightsholder" => "/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository",
    "recipients" => "/TEI/teiHeader/profileDesc/particDesc/person[@role='recipient']/persName",
    "subcategory" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory'][1]/term",
    "topic" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='topic']/term",
    "keywords" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='keywords']/term",
    "people" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term",
    "places" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='places']/term",
    "works" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='works']/term",
    "text" => "//text",
  }

  # TODO a lot of stuff comes in from the specific params objects
  # but those will be very different for the new api schema
  # so I'm just waiting on that for now

  def self.assemble_json file, options
    @id = file.filename(false)
    @options = options
    @xml = File.open(file.file_location) { |f| Nokogiri::XML f }
    # TODO is this a good idea?
    @xml.remove_namespaces!
    @json = {}

    # TODO might put these into methods themselves
    # so that a project could override only a clump of fields
    # rather than all?
    # Note: the above might only matter if ES can't handle nil
    # values being sent, because otherwise they could just override
    # the field behavior to be blank

    ###############
    # identifiers #
    ###############
    @json["_id"] = id
    @json["_type"] = shortname
    @json["cdrh:identifier"] = id
    @json["dc:identifier"] = id_dc

    ##############
    # categories #
    ##############
    @json["cdrh:category"] = category
    @json["cdrh:subcategory"] = subcategory
    @json["cdrh:data_type"] = "tei"
    @json["cdrh:project"] = project
    @json["cdrh:shortname"] = shortname
    # @json["dc:subject"]

    #############
    # locations #
    #############

    # TODO check, because I'm not sure the schema
    # lists the urls that we actually want to use
    # earlywashingtondc.org vs cdrhmedia, etc
    # @json["cdrh:uri"]
    # @json["cdrh:uri_data"]
    # @json["cdrh:uri_html"]
    # @json["cdrh:fig_location"]
    # @json["cdrh:image_id"]

    ###############
    # description #
    ###############
    @json["cdrh:title_sort"] = title_sort
    @json["dc:title"] = title
    # @json["dc:description"]
    # @json["cdrh:topics"]
    # @json["dcterms:alternative"]

    ##################
    # other metadata #
    ##################
    # @json["dc:format"]
    # @json["dc:language"]
    # @json["dc:relation"]
    # @json["dc:type"]
    # @json["dcterms:extent"]
    # @json["dcterms:medium"]

    #########
    # dates #
    #########
    @json["cdrh:date_display"] = date_display
    @json["dc:date"] = date
    # @json["cdrh:date_not_before"]
    # @json["cdrh:date_not_after"]

    ####################
    # publishing stuff #
    ####################
    # @json["cdrh:rights_uri"]
    # @json["dc:publisher"]
    # @json["dc:rights"]
    # @json["dc:source"]
    # @json["dcterms:rights_holder"]

    ##########
    # people #
    ##########
    # @json["cdrh:creator_sort"]
    # @json["cdrh:people"]
    # person is a container field with name, id, role
    # @json["cdrh:person"]
    # dc contributor is a container field with name and id and role
    @json["dc:contributor"] = contributors
    # dc creator is a container field with name and id
    @json["dc:creator"] = creators

    ###########
    # spatial #
    ###########
    # TODO not sure about the naming convention here?
    # TODO has place_name, coordinates, id, city, county, country,
    # region, state, street, postal_code
    # @json["dcterms:coverage.spatial"]

    ##############
    # referenced #
    ##############
    # @json["cdrh:keywords"]
    # @json["cdrh:places"]
    # @json["cdrh:works"]

    #################
    # text searches #
    #################
    # @json["cdrh.annotations"]
    # @json["cdrh:text"]
    # @json["dc:abstract"]

    return @json
  end

  ##########
  # FIELDS #
  ##########

  def self.id
    @id
  end

  def self.id_dc
    # TODO use api path from config or something?
    "https://cdrhapi.unl.edu/doc/#{@id}"
  end

  def self.category
    category = get_text "category"
    category ? category : "texts"
  end

  def self.creators
    # TODO this should do something snazzy with the nested structure
  end

  def self.contributors
    # TODO
  end

  def self.date
    date = get_text "date"
    Common.date_standardize(date)
  end

  def self.date_display
    date = get_text "date"
    Common.date_display(date)
  end

  def self.shortname
    @options["shortname"]
  end

  def self.subcategory
    subcategory = get_text "subcategory"
    subcategory ? subcategory : "texts"
  end

  def self.project
    @options["project_desc"] || @options["project"]
  end

  def self.title
    title = get_text "title_main"
    if !title
      title = get_text "title_alt"
    end
    return title
  end

  def self.title_sort
    t = @json["dc:title"] ? @json["dc:title"] : title
    Common.normalize_name t
  end

  ###########
  # HELPERS #
  ###########

  # see helpers.rb's Common module for methods imported from common.xsl

  # get the value of one of the xpaths listed at the top
  # Note: if the xpath returns multiple values they will be squished together
  def self.get_text xpath_name
    contents = @xml.xpath(@xpaths[xpath_name]).inner_html || ""
    squeezed = Common.squeeze(contents)
    converted = Common.convert_tags(squeezed)
    final = converted && converted.length > 0 ? converted : nil
    return final
  end
end
