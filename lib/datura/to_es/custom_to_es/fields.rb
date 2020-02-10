class CustomToEs
  # Note to add custom fields, use "assemble_collection_specific" from request.rb
  # and be sure to either use the _d, _i, _k, or _t to use the correct field type

  ##########
  # FIELDS #
  ##########
  def id
    @id
  end

  def id_dc
    "https://cdrhapi.unl.edu/doc/#{@id}"
  end

  def annotations_text
    # TODO what should default behavior be?
  end

  def category
    # TODO
  end

  # nested field
  def creator
    # TODO
  end

  # returns ; delineated string of alphabetized creators
  def creator_sort
    # TODO
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
    @file_type
  end

  def date(before=true)
    # TODO
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
    # Note: override per collection as needed
  end

  def format
    # TODO
  end

  def image_id
    # TODO
  end

  def keywords
    # TODO
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
    # TODO
  end

  def publisher
    # TODO
  end

  def recipient
    # TODO
  end

  def rights
    # Note: override by collection as needed
    "All Rights Reserved"
  end

  def rights_holder
    # TODO
  end

  def rights_uri
    # TODO
  end

  def source
    # TODO
  end

  def subjects
    # TODO
  end

  def subcategory
    # TODO
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
    # TODO
  end

  def title_sort
    Datura::Helpers.normalize_name(title) if title
  end

  def topics
    # TODO
  end

  def uri
    # override per collection
    # should point at the live website view of resource
  end

  def uri_data
    base = @options["data_base"]
    subpath = "data/#{@options["collection"]}/source/#{@file_type}"
    "#{base}/#{subpath}/#{@filename}"
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
