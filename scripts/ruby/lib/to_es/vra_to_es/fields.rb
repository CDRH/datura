class VraToEs < XmlToEs
  # Note to add custom fields, use "assemble_collection_specific" from request.rb
  # and be sure to either use the _d, _i, _k, or _t to use the correct field type

  ##########
  # FIELDS #
  ##########

  def id
    @id
  end

  def id_dc
    # TODO use api path from config or something?
    "https://cdrhapi.unl.edu/doc/#{@id}"
  end

  def annotations_text
    # TODO default behavior?
  end

  def category
    # TODO default behavior?
  end

  # note this does not sort the creators
  def creator
    creators = get_list(@xpaths["creators"])
    return creators.map { |creator| { "name" => creator } }
  end

  # returns ; delineated string of alphabetized creators
  def creator_sort
    return get_text(@xpaths["creators"])
  end

  def collection
    @options["es_type"]
  end

  def collection_desc
    @options["collection_desc"] || @options["collection"]
  end

  def contributor
    contrib_list = []
    contributors = @xml.xpath(@xpaths["contributors"])
    contributors.each do |ele|
      contrib_list << {
        "name" => ele.xpath("name").text,
        "id" => "",
        "role" => ele.xpath("role").text
      }
    end
    return contrib_list
  end

  def data_type
    "vra"
  end

  def date(before=true)
    datestr = get_text(@xpaths["dates"]["earliest"])
    # cannot send empty value for date object, set to null
    if datestr.empty?
      return nil
    else
      return datestr
    end
  end

  def date_display
    get_text(@xpaths["dates"]["display"])
  end

  def description
    # Note: override per collection as needed
  end

  def format
    # iterate through all the formats until the first one matches
    get_text(@xpaths["format"])
  end

  def image_id
    # TODO only needed for Cody Archive, but put generic rules in here
  end

  def keywords
    get_list(@xpaths["keywords"])
  end

  def language
    # TODO need some examples to use
    # look for attribute anywhere in whole text and add to array
  end

  def medium
    # iterate through all the formats until the first one matches
    get_text(@xpaths["format"])
  end

  def person
    # TODO will need some examples of how this will work
    # and put in the xpaths above, also for attributes, etc
    # should contain name, id, and role
    eles = @xml.xpath(@xpaths["person"])
    return eles.map { |p| { "role" => p["role"], "name" => p.text, "id" => "" } }
  end

  def people
    @json["person"].map { |p| p["name"] }
  end

  def places
    get_list(@xpaths["places"])
  end

  def publisher
    get_list(@xpaths["publisher"])
  end

  def recipients
    # TODO default behavior?
  end

  def rights
    # Note: override by collection as needed
    "All Rights Reserved"
  end

  def rights_holder
    # TODO: default behavior?
  end

  def rights_uri
    # by default collections have no uri associated with them
    # copy this method into collection specific vra_to_es.rb
    # to return specific string or xpath as required
  end

  def source
    # TODO default behavior?
  end

  def subcategory
    # TODO default behavior?
  end

  def subjects
    # TODO default behavior?
  end

  def text
    # handling separate fields in array
    # means no worrying about handling spacing between words
    text = []
    text << get_text(@xpaths["text"], false)
    # TODO: do we need to preserve tags like <i> in text? if so, turn get_text to true
    # text << Common.convert_tags_in_string(body)
    text += text_additional
    return text.join(" ")
  end

  def text_additional
    # Note: Override this per collection if you need additional
    # searchable fields or information for collections
    # just make sure you return an array at the end!

    # text = []
    # text << your_new_fields_and_stuff
    # return text
    return []
  end

  def title
    get_text(@xpaths["title"])
  end

  def title_sort
    t = title
    Common.normalize_name(t)
  end

  def topics
    # TODO default behavior?
  end

  def uri
    # override per collection
    # should point at the live website view of resource
  end

  def uri_data
    base = @options["data_base"]
    subpath = "data/#{@options["collection"]}/vra"
    return "#{base}/#{subpath}/#{@id}.xml"
  end

  def uri_html
    base = @options["data_base"]
    subpath = "data/#{@options["collection"]}/output/html"
    return "#{base}/#{subpath}/#{@id}.html"
  end

  def works
    # TODO default behavior?
  end
end
