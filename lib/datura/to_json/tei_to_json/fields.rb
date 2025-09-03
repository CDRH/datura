class TeiToJson < XmlToJson
  # Note to add custom fields, use "assemble_collection_specific" from request.rb
  # and be sure to either use the _d, _i, _k, or _t to use the correct field type

  ##########
  # FIELDS #
  ##########

  def authority
    get_text(@xpaths["authority"])
  end

  def annotations_text
    get_text(@xpaths["annotations_text"])
  end

  def bibl_author
    authors = get_list(@xpaths["bibl_author"])
    if authors
      authors.join("; ")
    end
  end

  def bibl_date
    get_text(@xpaths["bibl_date"])
  end

  def bibl_note
    get_list(@xpaths["bibl_note"])
  end

  def bibl_publisher
    get_text(@xpaths["bibl_publisher"])
  end

  def bibl_pub_place
    get_text(@xpaths["bibl_pub_place"])
  end

  def bibl_title
    get_text(@xpaths["bibl_title"])
  end

  def distributor
    get_text(@xpaths["distributor"])
  end

  def idno
    get_text(@xpaths["idno"])
  end

  def language
    langs = get_list(@xpaths["language"])
    # if langs
    #   langs.join(", ")
    # end
  end

  def license
    lic = @xpaths["license"]
    lic_fields = {}
    lic.each do |field, xpath|
      lic_fields[field] = get_text(xpath)
    end
    lic_fields
  end

  def principal
    principals = get_list(@xpaths["principal"])
    # if principals
    #   principals.join("; ")
    # end
  end

  def publisher
    get_text(@xpaths["publisher"])
  end

  def publisher_addr_line
    get_list(@xpaths["publisher_addr_line"])
  end

  def resp
    contribs = get_list(@xpaths["resp"])
  end

  def source_collection
    get_text(@xpaths["source_collection"])
  end

  def source_id
    get_text(@xpaths["source_id"])
  end

  def source_repo
    get_text(@xpaths["source_repo"])
  end

  def xmlid
    get_text(@xpaths["xmlid"])
  end

  def text
    # handling separate fields in array
    # means no worrying about handling spacing between words
    text_all = []
    body = get_text(@xpaths["text"], keep_tags: false, delimiter: '')
    if body
      text_all << body
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
    [
      title,
      get_text(@xpaths["text_additional"])
    ]
  end

  def title
    get_text(@xpaths["title"])
  end

  def xmlid
    get_text(@xpaths["xmlid"])
  end

  protected

  # default behavior is simply to comma delineate fields
  # but you may override if you need additional behavior
  # such as <em>title</em>, (date), etc
  def source_to_s(f)
    #   author, title, publisher, pubplace, date,
    #   collection, repository, idno
    source_order = [
      f["author"], f["title"], f["publisher"], f["pubplace"], f["date"],
      f["collection"], f["repository"], f["idno"]
    ]
    source_order
      .reject! { |value| value.nil? || value.strip.empty? }
      .join(", ")
  end
  

end
