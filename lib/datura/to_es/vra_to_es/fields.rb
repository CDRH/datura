class VraToEs < XmlToEs
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

  # note this does not sort the creators
  def creator
    creators = get_list(@xpaths["creators"])
    creators.map { |c| { "name" => Datura::Helpers.normalize_space(c) } }
  end

  def collection
    @options["collection"]
  end

  def collection_desc
    @options["collection_desc"] || @options["collection"]
  end

  def contributor
    contrib_list = get_elements(@xpaths["contributor"]).map do |ele|
      {
        "id" => "",
        "name" => get_text("name", xml: ele),
        "role" => get_text("role", xml: ele)
      }
    end
    contrib_list.uniq
  end

  def data_type
    "vra"
  end

  def date(before=true)
    datestr = get_text(@xpaths["date"])
    Datura::Helpers.date_standardize(datestr, before)
  end

  def date_display
    get_text(@xpaths["date_display"])
  end

  def date_not_after
    datestr = get_text(@xpaths["date_not_after"])
    if datestr
      Datura::Helpers.date_standardize(datestr, false)
    else
      date(false)
    end
  end

  def date_not_before
    datestr = get_text(@xpaths["date_not_before"])
    if datestr
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

  def person
    eles = get_elements(@xpaths["person"]).map do |p|
      {
        "id" => p["id"],
        "name" => Datura::Helpers.normalize_space(p.text),
        "role" => Datura::Helpers.normalize_space(p["role"])
      }
    end
    eles.uniq
  end

  def places
    get_list(@xpaths["places"])
  end

  def publisher
    get_text(@xpaths["publisher"])
  end

  def recipient
    eles = get_elements(@xpaths["recipient"])
    eles.map do |p|
      {
        "id" => "",
        "name" => Datura::Helpers.normalize_space(p.text),
        "role" => Datura::Helpers.normalize_space(p["role"]),
      }
    end
  end

  def relation
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

  def subcategory
    get_text(@xpaths["subcategory"])
  end

  def subjects
    get_list(@xpaths["subjects"])
  end

  def text
    # handling separate fields in array
    # means no worrying about handling spacing between words
    text_all = []
    text_all << get_text(@xpaths["text"])
    # TODO: do we need to preserve tags like <i> in text? if so, turn get_text to true
    # text_all << CommonXml.convert_tags_in_string(body)
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
      "source/vra",
      "#{@id}.xml"
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
    get_list(@xpaths["works"])
  end
end
