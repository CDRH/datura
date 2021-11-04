class EadToEsItems < XmlToEs
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

  # def annotations_text
  #   # TODO what should default behavior be?
  # end

  # def category
  #   category = get_text(@xpaths["category"])
  #   return category.length > 0 ? CommonXml.normalize_space(category) : "none"
  # end

  # note this does not sort the creators
  def creator
    creators = get_list(@xpaths["creators"])
    return creators.map { |creator| { "name" => CommonXml.normalize_space(creator) } }
  end

  # returns ; delineated string of alphabetized creators
  def creator_sort
    return get_text(@xpaths["creators"])
  end

  def collection
    "manuscripts"
  end

  def collection_desc
    @options["collection_desc"] || @options["collection"]
  end

  # def contributor
  #   contribs = []
  #   @xpaths["contributors"].each do |xpath|
  #     eles = @xml.xpath(xpath)
  #     eles.each do |ele|
  #       contribs << {
  #         "id" => ele["id"],
  #         "name" => CommonXml.normalize_space(ele.text),
  #         "role" => CommonXml.normalize_space(ele["role"])
  #       }
  #     end
  #   end
  #   contribs.uniq
  # end

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
    # Note: override per collection as needed
  end

  def format
    matched_format = nil
    # iterate through all the formats until the first one matches
    @xpaths["formats"].each do |type, xpath|
      text = get_text(xpath)
      matched_format = type if text && text.length > 0
    end
    matched_format
  end

  def image_id
    # Note: don't pull full path because will be pulled by IIIF
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
    eles = @xml.xpath(@xpaths["person"])
    people = eles.map do |p|
      {
        "id" => "",
        "name" => CommonXml.normalize_space(p.text),
        "role" => CommonXml.normalize_space(p["role"])
      }
    end
    return people
  end

  def people
    @json["person"].map { |p| CommonXml.normalize_space(p["name"]) }
  end

  def places
    return get_list(@xpaths["places"])
  end

  def publisher
    get_text(@xpaths["publisher"])
  end

  def recipient
    eles = @xml.xpath(@xpaths["recipient"])
    people = eles.map do |p|
      {
        "id" => "",
        "name" => CommonXml.normalize_space(p.text),
        "role" => "recipient"
      }
    end
    return people
  end

  def rights
    # Note: override by collection as needed
    "All Rights Reserved"
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
    # TODO default behavior?
  end

  def subcategory
    subcategory = get_text(@xpaths["subcategory"])
    subcategory.length > 0 ? subcategory : "none"
  end

  def text
    # handling separate fields in array
    # means no worrying about handling spacing between words
    text = []
    body = get_text(@xpaths["text"], false)
    text << body
    # TODO: do we need to preserve tags like <i> in text? if so, turn get_text to true
    # text << CommonXml.convert_tags_in_string(body)
    text += text_additional
    return CommonXml.normalize_space(text.join(" "))
  end

  def text_additional
    # Note: Override this per collection if you need additional
    # searchable fields or information for collections
    # just make sure you return an array at the end!

    text = []
    text << title
  end

  def title
    title = get_text(@xpaths["titles"]["main"])
    if title.empty?
      title = get_text(@xpaths["titles"]["alt"])
    end
    return title
  end

  def title_sort
    t = title
    CommonXml.normalize_name(t)
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
    # TODO figure out how this behavior should look
  end
end