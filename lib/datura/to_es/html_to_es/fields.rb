class HtmlToEs < XmlToEs
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
    # TODO what should default behavior be?
  end

  def category
    # category = get_text(@xpaths["category"])
  end

  # nested field
  def creator
    # TODO
  end

  # returns ; delineated string of alphabetized creators
  def creator_sort
    # get_text(@xpaths["creators"])
  end

  def collection
    @options["collection"]
  end

  def collection_desc
    @options["collection_desc"] || @options["collection"]
  end

  def contributor
    # TODO
  end

  def data_type
    "html"
  end

  def date(before=true)
    # TODO
  end

  def date_display
    # TODO
  end

  def description
    # Note: override per collection as needed
  end

  def format
    # TODO
  end

  def image_id
    # TODO
  end

  def keywords
    get_list(@xpaths["keywords"])
  end

  def language
    # TODO
  end

  def languages
    # TODO
  end

  def medium
    # Default behavior is the same as "format" method
    format
  end

  def person
    # TODO
  end

  def people
    # TODO
  end

  def places
    # get_list(@xpaths["places"])
  end

  def publisher
    # get_text(@xpaths["publisher"])
  end

  def recipient
    # TODO
  end

  def rights
    # Note: override by collection as needed
    "All Rights Reserved"
  end

  def rights_holder
    # get_text(@xpaths["rights_holder"])
  end

  def rights_uri
    # by default collections have no uri associated with them
    # copy this method into collection specific tei_to_es.rb
    # to return specific string or xpath as required
  end

  def source
    # get_text(@xpaths["source"])
  end

  def subjects
    # TODO default behavior?
  end

  def subcategory
    # subcategory = get_text(@xpaths["subcategory"])
    # subcategory.length > 0 ? subcategory : "none"
  end

  def text
    # handling separate fields in array
    # means no worrying about handling spacing between words
    text_all = []
    body = get_text(@xpaths["text"], false)
    text_all << body
    text_all += text_additional
    Datura::Helpers.normalize_space(text_all.join(" "))
  end

  def text_additional
    # Note: Override this per collection if you need additional
    # searchable fields or information for collections
    # just make sure you return an array at the end!
    [ title ]
  end

  def title
    get_text(@xpaths["titles"])
  end

  def title_sort
    Datura::Helpers.normalize_name(title)
  end

  def topics
    # TODO
  end

  def uri
    # override per collection
    # should point at the live website view of resource
  end

  def uri_data
    # TODO per repository
  end

  def uri_html
    base = @options["data_base"]
    subpath = "data/#{@options["collection"]}/output/#{@options["environment"]}/html"
    "#{base}/#{subpath}/#{@id}.html"
  end

  def works
    # TODO
  end
end
