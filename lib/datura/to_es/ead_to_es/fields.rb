class EadToEs < XmlToEs
  # Note to add custom fields, use "assemble_collection_specific" from request.rb
  # and be sure to either use the _d, _i, _k, or _t to use the correct field type

  ##########
  # FIELDS #
  ##########

  def id
    get_text(@xpaths["identifer"])
  end

  # def id_dc
  #   # TODO use api path from config or something?
  #   "https://cdrhapi.unl.edu/doc/#{@id}"
  # end

  def abstract
    get_text(@xpaths["abstract"])
  end

  def annotations_text
    # TODO what should default behavior be?
  end

  def category
  end

  # note this does not sort the creators
  def creator
    creators = get_list(@xpaths["creators"])
    if creators
      return creators.map { |creator| { "name" => CommonXml.normalize_space(creator) } }
    end
  end

  # returns ; delineated string of alphabetized creators
  def creator_sort
    return get_text(@xpaths["creators"])
  end

  def collection
    @options["collection"]
  end

  def collection_desc
    @options["collection_desc"] || @options["collection"]
  end

  def contributor
    # contribs = []
    # @xpaths["contributors"].each do |xpath|
    #   eles = @xml.xpath(xpath)
    #   eles.each do |ele|
    #     contribs << {
    #       "id" => ele["id"],
    #       "name" => CommonXml.normalize_space(ele.text),
    #       "role" => CommonXml.normalize_space(ele["role"])
    #     }
    #   end
    # end
    # contribs.uniq
  end

  def data_type
    "ead"
  end

  def date(before=true)
    datestr = get_text(@xpaths["date"])
    return CommonXml.date_standardize(datestr, before)
  end

  def date_display
    get_text(@xpaths["date_display"])
  end

  def date_not_after
    date(false)
  end

  def date_not_before
    date(true)
  end

  def description
    get_text(@xpaths["description"])
  end

  def extent
    get_text(@xpaths["extent"])
  end

  def format
    get_list(@xpaths["format"])
  end

  def image_id
    # Note: don't pull full path because will be pulled by IIIF
    # How to deal with this?
    images = get_list(@xpaths["image_id"])
    images[0] if images
  end

  def keywords
    get_list(@xpaths["keywords"])
  end

  def language
    get_text(@xpaths["language"])
  end

  def languages
    get_list(@xpaths["languages"])
  end

  def medium
    # Default behavior is the same as "format" method
    format
  end

  def person
    # TODO will need some examples of how this will work
    # and put in the xpaths above, also for attributes, etc
    # should contain name, id, and role
    # eles = @xml.xpath(@xpaths["person"])
    # people = eles.map do |p|
    #   {
    #     "id" => "",
    #     "name" => CommonXml.normalize_space(p.text),
    #     "role" => CommonXml.normalize_space(p["role"])
    #   }
    # end
    # return people
  end

  def people
    # @json["person"].map { |p| CommonXml.normalize_space(p["name"]) }
  end

  def places
    return get_list(@xpaths["places"])
  end

  def publisher
    get_text(@xpaths["publisher"])
  end

  def recipient
    # eles = @xml.xpath(@xpaths["recipient"])
    # people = eles.map do |p|
    #   {
    #     "id" => "",
    #     "name" => CommonXml.normalize_space(p.text),
    #     "role" => "recipient"
    #   }
    # end
    # return people
  end

  def rights
    # Note: override by collection as needed
    get_text(@xpaths["rights"])
  end

  def rights_holder
    get_text(@xpaths["rights_holder"])
  end

  def rights_uri
    # by default collections have no uri associated with them
    # copy this method into collection specific tei_to_es.rb
    # to return specific string or xpath as required
  end

  def source
    get_text(@xpaths["source"])
  end

  def subjects
    get_list(@xpaths["subjects"])
  end

  def subcategory
    # subcategory = get_text(@xpaths["subcategory"])
    # subcategory.length > 0 ? subcategory : "none"
  end

  def text
    # handling separate fields in array
    # means no worrying about handling spacing between words
    text = []
    @xpaths.keys.each do |xpath| 
      body = get_text(@xpaths[xpath])
      text << body
    end
    text
    # TODO: do we need to preserve tags like <i> in text? if so, turn get_text to true
    # text << CommonXml.convert_tags_in_string(body)
    # text += text_additional
    # return CommonXml.normalize_space(text.join(" "))
  end

  # def text_additional
  #   # Note: Override this per collection if you need additional
  #   # searchable fields or information for collections
  #   # just make sure you return an array at the end!

  #   text = []
  #   text << title
  # end

  def title
    get_text(@xpaths["title"])
  end

  def title_sort
    t = title
    CommonXml.normalize_name(t)
  end

  def type
    get_text(@xpaths["type"])
  end

  def topics
    get_list(@xpaths["topic"])
  end

  def uri
    # override per collection
    # should point at the live website view of resource
  end

  def uri_data
    base = @options["data_base"]
    subpath = "data/#{@options["collection"]}/source/tei"
    return "#{base}/#{subpath}/#{@id}.xml"
  end

  def uri_html
    base = @options["data_base"]
    subpath = "data/#{@options["collection"]}/output/#{@options["environment"]}/html"
    return "#{base}/#{subpath}/#{@id}.html"
  end

  def works
    # TODO need to create a list of items, maybe an array of ids
  end
end