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
    "people" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term",
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
    category ? category : "texts"
  end

  # note this does not sort the creators
  def self.creator
    creators = []
    @xpaths["creators"].each do |xpath|
      # TODO this will need to be beefed up if we
      # get some examples where the creator has an
      # id attr which we can add, for now going for the
      # easiest option, which is just to grab the name
      creator = get_text xpath
      creators << creator if creator
    end
    creators.uniq!
    return creators.map { |creator| { "name" => creator } }
  end

  # returns ; delineated string of alphabetized creators
  def self.creator_sort
    creators = @json["dc:creator"] || creator
    sorted = creators.sort
    return sorted.join("; ")
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
    Common.date_standardize(date, before)
  end

  def self.date_display
    date = get_text @xpaths["date"]
    Common.date_display(date)
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
    keywords = []
    eles = @xml.xpath(@xpaths["keywords"])
    eles.each do |ele|
      keywords << ele.text
    end
    return keywords
  end

  def self.language
    # TODO need some examples to use
    # look for attribute anywhere in whole text and add to array
  end

  def self.person
    # TODO will need some examples of how this will work
    # and put in the xpaths above, also
    # should contain name, id, and role
    return []
  end

  def self.person_sort
    people = @json["cdrh:person"] || person
    list = people.map { |p| p.name }
    sorted = list.sort
    return sorted.join("; ")
  end

  def self.places
    # TODO will need to figure out some default behavior for this field
    return []
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
    "Covered by a CC-By License https://creativecommons.org/licenses/by/2.0/"
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
    subcategory ? subcategory : "texts"
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
  def self.get_text xpath
    contents = @xml.xpath(xpath).inner_html || ""
    squeezed = Common.squeeze(contents)
    converted = Common.convert_tags(squeezed)
    final = converted && converted.length > 0 ? converted : nil
    return final
  end

end
