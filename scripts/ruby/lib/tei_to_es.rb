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
    "category" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='category'][1]/term",
    "contributors" => [
      "/TEI/teiHeader/revisionDesc/change/name",
      "/TEI/teiHeader/fileDesc/titleStmt/editor"
    ],
    "creators" => [
      "/TEI/teiHeader/fileDesc/titleStmt/author",
      "//persName[@type = 'author']"
    ],
    "date" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when",
    "formats" => {
      "letter" => "/TEI/text/body/div1[@type='letter']",
      "periodical" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level='j']",
      "manuscript" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level='m']"
    },
    "keywords" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='keywords']/term",
    # note: language is global attribute xml:lang
    "language" => "//[@lang]",
    "person" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term",
    "places" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='places']/term",
    "publisher" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1]",
    "recipients" => "/TEI/teiHeader/profileDesc/particDesc/person[@role='recipient']/persName",
    "rights_holder" => "/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository",
    "source" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[@level='j']",
    "subcategory" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory'][1]/term",
    "text" => "//text",
    "titles" => {
      "main" => "/TEI/teiHeader/fileDesc/titleStmt/title[@type='main'][1]",
      "alt" => "/TEI/teiHeader/fileDesc/titleStmt/title[1]"
    },
    "topic" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='topic']/term",
    "works" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='works']/term",
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
    @json["dc:description"] = description
    # @json["cdrh:topics"]
    # @json["dcterms:alternative"]

    ##################
    # other metadata #
    ##################
    @json["dc:format"] = format
    @json["dc:language"] = language
    # @json["dc:relation"]
    # @json["dc:type"]
    # @json["dcterms:extent"]
    @json["dcterms:medium"] = format

    #########
    # dates #
    #########
    @json["cdrh:date_display"] = date_display
    @json["dc:date"] = date
    @json["cdrh:date_not_before"] = date
    @json["cdrh:date_not_after"] = date false

    ####################
    # publishing stuff #
    ####################
    @json["cdrh:rights_uri"] = rights_uri
    @json["dc:publisher"] = publisher
    @json["dc:rights"] = rights
    @json["dc:source"] = source
    @json["dcterms:rights_holder"] = rights_holder

    ##########
    # people #
    ##########
    @json["cdrh:creator_sort"] = creator_sort
    @json["cdrh:people"] = person_sort
    # container fields
    @json["cdrh:person"] = person
    @json["dc:contributor"] = contributors
    @json["dc:creator"] = creator

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
    @json["cdrh:keywords"] = keywords
    @json["cdrh:places"] = places
    @json["cdrh:works"] = works

    #################
    # text searches #
    #################
    @json["cdrh.annotations"] = annotations
    @json["cdrh:text"] = text
    # @json["dc:abstract"]

    project_specific_fields

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

  def self.annotations
    # TODO what should default behavior be?
  end

  def self.category
    category = get_text @xpaths["category"]
    return category.length > 0 ? category : "texts"
  end

  # note this does not sort the creators
  def self.creator
    creators = get_list @xpaths["creators"]
    return creators.map { |creator| { "name" => creator } }
  end

  # returns ; delineated string of alphabetized creators
  def self.creator_sort
    return get_text @xpaths["creators"]
  end

  def self.contributors
    contribs = []
    @xpaths["contributors"].each do |xpath|
      eles = @xml.xpath(xpath)
      eles.each do |ele|
        contribs << { "label" => ele.text, "id" => ele["id"], "role" => ele["role"] }
      end
    end
    return contribs
  end

  def self.date before=true
    date = get_text @xpaths["date"]
    return Common.date_standardize(date, before)
  end

  def self.date_display
    date = get_text @xpaths["date"]
    return Common.date_display(date)
  end

  def self.description
    # Note: override per project as needed
  end

  def self.format
    # iterate through all the formats until the first one matches
    @xpaths["formats"].each do |type, xpath|
      text = get_text xpath
      if text
        return type
      end
    end
    # if no format, should we pick a default value?
    return nil
  end

  def self.keywords
    return get_list @xpaths["keywords"]
  end

  def self.language
    # TODO need some examples to use
    # look for attribute anywhere in whole text and add to array
  end

  def self.person
    # TODO will need some examples of how this will work
    # and put in the xpaths above, also
    # should contain name, id, and role
    []
  end

  def self.person_sort
    return get_text @xpaths["person"]
  end

  def self.places
    # TODO will need to figure out some default behavior for this field
    return get_list @xpaths["places"]
  end

  def self.project
    @options["project_desc"] || @options["project"]
  end

  def self.project_specific_fields
    # Note: customize this per project to include more information
    # to be posted to elasticsearch.  Example:

    # @json["novel_id"] = get_text @xpaths["novel"]
    # @json["publicity"] = "some message that will always be displayed"
  end

  def self.publisher
    get_text @xpaths["publisher"]
  end

  def self.rights
    # Note: override by project as needed
    "All Rights Reserved"
  end

  def self.rights_holder
    get_text @xpaths["rights_holder"]
  end

  def self.rights_uri
    # by default projects have no uri associated with them
    # copy this method into project specific tei_to_es.rb
    # to return specific string or xpath as required
  end

  def self.shortname
    @options["shortname"]
  end

  def self.source
    get_text @xpaths["source"]
  end

  def self.subcategory
    subcategory = get_text @xpaths["subcategory"]
    subcategory.length > 0 ? subcategory : "texts"
  end

  def self.text
    # handling separate fields in array
    # means no worrying about handling spacing between words
    text = []
    body = get_text(@xpaths["text"])
    text << Common.convert_tags(body)
    text += text_additional
    return text.join(" ")
  end

  def self.text_additional
    # Note: Override this per project if you need additional
    # searchable fields or information for projects
    # just make sure you return an array at the end!

    # text = []
    # text << your_new_fields_and_stuff
    # return text
    return []
  end

  def self.title
    title = get_text @xpaths["titles"]["main"]
    if !title
      title = get_text @xpaths["titles"]["alt"]
    end
    return title
  end

  def self.title_sort
    t = @json["dc:title"] ? @json["dc:title"] : title
    Common.normalize_name t
  end

  def self.works
    # TODO figure out how this behavior should look
    return []
  end

  ###########
  # HELPERS #
  ###########

  # see helpers.rb's Common module for methods imported from common.xsl

  # get the value of one of the xpaths listed at the top
  # Note: if the xpath returns multiple values they will be squished together
  # TODO should we make it so that this can optionally look for more than one
  # result?

  # get_list
  #   can pass it a string xpath or array of xpaths
  # returns an array with the html value in xpath
  def self.get_list xpaths, strip_tags=false
    xpaths = xpaths.class == Array ? xpaths : [xpaths]
    return get_xpaths xpaths, strip_tags
  end

  # get_text
  #   can pass it a string xpath or array of xpaths
  #   can optionally set a delimiter, otherwise ;
  # returns a STRING
  # if you want a multivalued result, please refer to get_list
  def self.get_text xpaths, strip_tags=false, delimiter=";"
    # ensure all xpaths are an array before beginning
    xpaths = xpaths.class == Array ? xpaths : [xpaths]
    list = get_xpaths xpaths, strip_tags
    sorted = list.sort
    return sorted.join("#{delimiter} ")
  end

  # Note: Recommend that project team do NOT use this method directly
  #   please use get_list or get_text instead
  # strip_tags true will take out all tags entirely
  # strip_tags false will convert tags like <hi> to <em>
  def self.get_xpaths xpaths, strip_tags=false
    list = []
    xpaths.each do |xpath|
      contents = @xml.xpath(xpath)
      contents.each do |content|
        text = ""
        if strip_tags
          text = content.text
        else
          converted = Common.convert_tags(content)
          text = content.inner_html
        end
        text = Common.squeeze(text)
        if text.length > 0
          list << text
        end
      end
    end
    return list.uniq
  end

end
