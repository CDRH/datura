class WebsToEs < XmlToEs
  # Note to add custom fields, use "assemble_collection_specific" from request.rb
  # and be sure to either use the _d, _i, _k, or _t to use the correct field type

  ##########
  # FIELDS #
  ##########

  def alternative
    get_text(@xpaths["alternative"])
  end

  def annotations_text
    get_text(@xpaths["annotations_text"])
  end

  def category
    get_text(@xpaths["category"])
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

  # nested field
  def contributor
  end

  def data_type
    "html"
  end

  def date(before=true)
    datestr = get_list(@xpaths["date"]).first
    if datestr
      Datura::Helpers.date_standardize(datestr, true)
    end
  end

  def date_display
    get_text(@xpaths["date_display"])
  end

  def date_not_after
    datestr = get_text(@xpaths["date_not_after"])
    if datestr && !datestr.empty?
      Datura::Helpers.date_standardize(datestr, false)
    else
      date(false)
    end
  end

  def date_not_before
    datestr = get_text(@xpaths["date_not_before"])
    if datestr && !datestr.empty?
      Datura::Helpers.date_standardize(datestr, true)
    else
      date(true)
    end
  end

  def description
    get_text(@xpaths["description"])
  end

  def extent
    get_text(@xpaths["extent"])
  end

  def format
    get_text(@xpaths["format"])
  end

  def image_id
    get_list(@xpaths["image_id"]).first
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
    get_text(@xpaths["medium"])
  end

  # nested field
  def person
  end

  def places
    get_list(@xpaths["places"])
  end

  def publisher
    get_text(@xpaths["publisher"])
  end

  # nested field
  def recipient
  end

  def relation
    get_text(@xpaths["relation"])
  end

  def rights
    get_text(@xpaths["rights"])
  end

  def rights_holder
    get_text(@xpaths["rights_holder"])
  end

  def rights_uri
    get_text(@xpaths["rights_uri"])
  end

  def source
    get_text(@xpaths["source"])
  end

  # nested field
  def spatial
  end

  def subjects
    get_list(@xpaths["subjects"])
  end

  def subcategory
    get_text(@xpaths["subcategory"])
  end

  def text
    # handling separate fields in array
    # means no worrying about handling spacing between words
    text = []
    body = get_text(@xpaths["text"])
    text << body
    text += text_additional
    Datura::Helpers.normalize_space(text.join(" "))
  end

  def text_additional
    # Note: Override this per collection if you need additional
    # searchable fields or information for collections
    # just make sure you return an array at the end!

    text = []
    text << title
  end

  def title
    get_text(@xpaths["title"])
  end

  def title_sort
    Datura::Helpers.normalize_name(title)
  end

  def topics
    get_list(@xpaths["topics"])
  end

  def type
    get_text(@xpaths["type"])
  end

  def uri
    if @options["site_url"]
      File.join(
        @options["site_url"],
        "item",
        @id
      )
    end
  end

  def uri_data
    File.join(
      @options["data_base"],
      "data",
      @options["collection"],
      "webs",
      "#{@id}.html"
    )
  end

  def uri_html
    # not sure that we will have any output HTML
    # since it already exists on the site
  end

  def works
    get_list(@xpaths["works"])
  end
end
