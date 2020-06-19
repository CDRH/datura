class CsvToEs
  # Note to add custom fields, use "assemble_collection_specific" from request.rb
  # and be sure to either use the _d, _i, _k, or _t to use the correct field type

  ##########
  # FIELDS #
  ##########
  def id
    @id
  end

  def alternative
    @row["alternative"]
  end

  def annotations_text
    @row["annotations_text"]
  end

  def category
    @row["category"]
  end

  # nested field
  def creator
    if @row["creator"]
      @row["creator"].split("; ").map do |p|
        { "name" => p }
      end
    end
  end

  def collection
    @options["collection"]
  end

  def collection_desc
    @options["collection_desc"] || @options["collection"]
  end

  def contributor
    if @row["contributor"]
      @row["contributor"].split("; ").map do |p|
        { "name" => p }
      end
    end
  end

  def data_type
    "csv"
  end

  def date(before=true)
    Datura::Helpers.date_standardize(@row["date"], before)
  end

  def date_display
    Datura::Helpers.date_display(date)
  end

  def date_not_after
    if @row["date_not_after"]
      Datura::Helpers.date_standardize(@row["date_not_after"], false)
    else
      date(false)
    end
  end

  def date_not_before
    if @row["date_not_before"]
      Datura::Helpers.date_standardize(@row["date_not_before"], true)
    else
      date(true)
    end
  end

  def description
    @row["description"]
  end

  def extent
    @row["extent"]
  end

  def format
    @row["format"]
  end

  def image_id
    @row["image_id"]
  end

  def keywords
    if @row["keywords"]
      @row["keywords"].split("; ")
    end
  end

  def language
    @row["language"]
  end

  def languages
    if @row["languages"]
      @row["languages"].split("; ")
    end
  end

  def medium
    @row["medium"]
  end

  def person
    if @row["person"]
      @row["person"].split("; ").map do |p|
        { "name" => p }
      end
    end
  end

  def places
    if @row["places"]
      @row["places"].split("; ")
    end
  end

  def publisher
    @row["publisher"]
  end

  def recipient
    if @row["recipient"]
      @row["recipient"].split("; ").map do |p|
        { "name" => p }
      end
    end
  end

  def relation
    @row["relation"]
  end

  def rights
    @row["rights"]
  end

  def rights_holder
    @row["rights_holder"]
  end

  def rights_uri
    @row["rights_uri"]
  end

  def source
    @row["source"]
  end

  def subjects
    if @row["subjects"]
      @row["subjects"].split("; ")
    end
  end

  def subcategory
    @row["subcategory"]
  end

  # text is generally going to be pulled from
  def text
    text_all = [ @row["text"] ]

    text_all += text_additional
    text_all = text_all.compact
    Datura::Helpers.normalize_space(text_all.join(" "))
  end

  # override and add by collection as needed
  def text_additional
    [ title ]
  end

  def title
    @row["title"]
  end

  def title_sort
    Datura::Helpers.normalize_name(title) if title
  end

  def topics
    if @row["topics"]
      @row["topics"].split("; ")
    end
  end

  def type
    @row["type"]
  end

  def uri
    File.join(
      @options["site_url"],
      "item",
      @id
    )
  end

  def uri_data
    File.join(
      @options["data_base"],
      "data",
      @options["collection"],
      "source/csv",
      "#{@filename}.csv"
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
    if @row["works"]
      @row["works"].split("; ")
    end
  end

end
