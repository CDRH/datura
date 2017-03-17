class TeiToEs
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
    # TODO what should default behavior be?
  end

  def category
    category = get_text @xpaths["category"]
    return category.length > 0 ? category : "none"
  end

  # note this does not sort the creators
  def creator
    creators = get_list @xpaths["creators"]
    return creators.map { |creator| { "name" => creator } }
  end

  # returns ; delineated string of alphabetized creators
  def creator_sort
    return get_text @xpaths["creators"]
  end

  def contributors
    contribs = []
    @xpaths["contributors"].each do |xpath|
      eles = @xml.xpath(xpath)
      eles.each do |ele|
        contribs << { "name" => ele.text, "id" => ele["id"], "role" => ele["role"] }
      end
    end
    return contribs
  end

  def date before=true
    date = get_text @xpaths["date"]
    return Common.date_standardize(date, before)
  end

  def date_display
    date = get_text @xpaths["date"]
    return Common.date_display(date)
  end

  def description
    # Note: override per project as needed
  end

  def format
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

  def keywords
    return get_list @xpaths["keywords"]
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
    return get_text @xpaths["person"]
  end

  def places
    # TODO will need to figure out some default behavior for this field
    return get_list @xpaths["places"]
  end

  def project
    @options["project_desc"] || @options["project"]
  end

  def project_specific_fields
    # Note: customize this per project to include more information
    # to be posted to elasticsearch.  Example:

    # json["novel_id"] = get_text @xpaths["novel"]
    # json["publicity"] = "some message that will always be displayed"
    return {}
  end

  def publisher
    get_text @xpaths["publisher"]
  end

  def rights
    # Note: override by project as needed
    "All Rights Reserved"
  end

  def rights_holder
    get_text @xpaths["rights_holder"]
  end

  def rights_uri
    # by default projects have no uri associated with them
    # copy this method into project specific tei_to_es.rb
    # to return specific string or xpath as required
  end

  def shortname
    @options["shortname"]
  end

  def source
    get_text @xpaths["source"]
  end

  def subcategory
    subcategory = get_text @xpaths["subcategory"]
    subcategory.length > 0 ? subcategory : "none"
  end

  def text
    # handling separate fields in array
    # means no worrying about handling spacing between words
    text = []
    body = get_text(@xpaths["text"], true)
    text << Common.convert_tags(body)
    text += text_additional
    return text.join(" ")
  end

  def text_additional
    # Note: Override this per project if you need additional
    # searchable fields or information for projects
    # just make sure you return an array at the end!

    # text = []
    # text << your_new_fields_and_stuff
    # return text
    return []
  end

  def title
    title = get_text @xpaths["titles"]["main"]
    if title.empty?
      title = get_text @xpaths["titles"]["alt"]
    end
    return title
  end

  def title_sort
    t = title
    Common.normalize_name t
  end

  def works
    # TODO figure out how this behavior should look
    return []
  end
end
