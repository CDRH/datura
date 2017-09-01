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

  def annotations
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

  def contributors
    get_list(@xpaths["contributors"]).join("; ")
  end

  def date(before=true)
    get_text(@xpaths["date"])
  end

  def date_display
    get_text(@xpaths["dateDisplay"])
  end

  def description
    # Note: override per collection as needed
  end

  def format
    # iterate through all the formats until the first one matches
    get_text(@xpaths["format"])
  end

  def keywords
    get_list(@xpaths["keywords"])
  end

  def language
    # TODO need some examples to use
    # look for attribute anywhere in whole text and add to array
  end

  def person
    # TODO will need some examples of how this will work
    # and put in the xpaths above, also for attributes, etc
    # should contain name, id, and role
    eles = @xml.xpath(@xpaths["person"])
    return eles.map { |p| { "role" => p["role"], "name" => p.text, "id" => "" } }
  end

  def person_sort
    return get_text(@xpaths["person"])
  end

  def places
    get_list(@xpaths["places"])
  end

  def collection
    @options["collection_desc"] || @options["collection"]
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

  def shortname
    @options["shortname"]
  end

  def source
    # TODO default behavior?
  end

  def subcategory
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

  def uri_html
    "#{@options["uri_html"]}/#{@id}.html"
  end

  def works
    # TODO default behavior?
  end
end
