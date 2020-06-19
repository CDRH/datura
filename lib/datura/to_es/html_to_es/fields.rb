class HtmlToEs < XmlToEs
  # Note to add custom fields, use "assemble_collection_specific" from request.rb
  # and be sure to either use the _d, _i, _k, or _t to use the correct field type

  ##########
  # FIELDS #
  ##########

  def alternative
  end

  def annotations_text
  end

  def category
  end

  # nested field
  def creator
  end

  def collection
    @options["collection"]
  end

  def collection_desc
    @options["collection_desc"] || @options["collection"]
  end

  def contributor
  end

  def data_type
    "html"
  end

  def date(before=true)
  end

  def date_display
  end

  def date_not_after
  end

  def date_not_before
  end

  def description
  end

  def extent
  end

  def format
  end

  def image_id
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
  end

  def person
  end

  def places
  end

  def publisher
  end

  def recipient
  end

  def relation
  end

  def rights
  end

  def rights_holder
  end

  def rights_uri
  end

  def source
  end

  def subjects
  end

  def subcategory
  end

  def text
    # handling separate fields in array
    # means no worrying about handling spacing between words
    text_all = []
    body = get_text(@xpaths["text"], keep_tags: false)
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
    get_text(@xpaths["title"])
  end

  def title_sort
    Datura::Helpers.normalize_name(title)
  end

  def topics
  end

  def type
  end

  def uri
    File.join(
      @options["site_url"],
      "item",
      @id
    )
  end

  def uri_data
  end

  def uri_html
    File.join(
      @options["data_base"],
      "data",
      @options["collection"],
      "output",
      @options["environment"],
      "html",
      "#{@id}.html"
    )
  end

  def works
  end
end
