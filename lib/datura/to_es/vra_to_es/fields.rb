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

  # nested field
  def creator
    creators = get_list(@xpaths["creator"])
    if creators
      creators.map { |c| { "name" => Datura::Helpers.normalize_space(c) } }
    end
  end

  def collection
    @options["collection"]
  end

  def collection_desc
    @options["collection_desc"] || @options["collection"]
  end

  # nested field
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
    datestr = get_list(@xpaths["date"]).first
    if datestr
      Datura::Helpers.date_standardize(datestr, before)
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
    # xpaths return very simple "subject" and more involved "agent"
    eles = get_elements(@xpaths["person"]).map do |p|
      # subject element
      if get_text("@type", xml: p) == "personalName"
        {
          "id" => nil,
          "name" => get_text(".", xml: p),
          "role" => nil
        }
      # agent element
      else
        {
          "id" => nil,
          "name" =>  get_text("name", xml: p),
          "role" => get_text("role", xml: p)
        }
      end
    end
    eles.uniq
  end

  def places
    get_list(@xpaths["places"])
  end

  def publisher
    get_text(@xpaths["publisher"])
  end

  # nested field
  def rdf
  end

  # nested field
  def recipient
    eles = get_elements(@xpaths["recipient"])
    eles.map do |p|
      {
        "id" => "",
        "name" => get_text(".", xml: p),
        "role" => get_text("@role", xml: p)
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

  # nested field
  def spatial
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
    if get_text(@xpaths["text"])
      text_all << get_text(@xpaths["text"])
    end
    # TODO: do we need to preserve tags like <i> in text? if so, turn get_text to true
    # text_all << CommonXml.convert_tags_in_string(body)
    text_all += text_additional
    Datura::Helpers.normalize_space(text_all.join(" "))[0..@options["text_limit"]]
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

  # new/moved fields for API 2.0

  def cover_image
    get_list(@xpaths["image_id"]).first
  end

  def date_updated
    get_list(@xpaths["date_updated"])
  end

  def fig_location
    get_list(@xpaths["fig_location"])
  end

  def category2
    get_list(@xpaths["subcategory"])
  end

  def category3
    get_text(@xpaths["category3"])
  end

  def category4
    get_text(@xpaths["category4"])
  end

  def category5
    get_text(@xpaths["category5"])
  end

  def notes
    get_text(@xpaths["notes"])
  end

  def citation
    # nested
  end

  def container_box
  end

  def container_folder
  end

  def abstract
    get_text(@xpaths["abstract"])
  end

  def keywords2
    get_text(@xpaths["keywords2"])
  end

  def keywords3
    get_text(@xpaths["keywords3"])
  end

  def keywords4
    get_text(@xpaths["keywords4"])
  end

  def keywords5
    get_text(@xpaths["keywords5"])
  end

  def has_part
    # nested
  end

  def is_part_of
    # nested
  end

  def previous_item
    # nested
  end

  def next_item
    # nested
  end

  def event
    # nested
  end
  
  def rdf
    # nested
  end

  def has_source
    # nested
  end

  def has_relation
    # nested
  end
end
