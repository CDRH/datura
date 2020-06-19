class CustomToEs
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
    @file_type
  end

  def date(before=true)
    # Datura::Helpers.date_standardize(??, before)
  end

  def date_display
    Datura::Helpers.date_display(date) if date
  end

  def date_not_after
    date(false)
  end

  def date_not_before
    date(true)
  end

  def description
  end

  def format
  end

  def image_id
  end

  def keywords
  end

  def language
  end

  def languages
  end

  def medium
  end

  def person
  end

  def people
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

  # text is generally going to be pulled from
  def text
    # TODO
    # get text, add text_additional
    # Datura::Helpers.normalize_space(your_text.join(" ")))
  end

  # override and add by collection as needed
  def text_additional
    [ title ]
  end

  def title
  end

  def title_sort
    Datura::Helpers.normalize_name(title) if title
  end

  def topics
  end

  def type
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
      "source",
      @file_type,
      @filename
    )
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
