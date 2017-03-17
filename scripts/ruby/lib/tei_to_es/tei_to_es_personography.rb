class TeiToEsPersonography < TeiToEs

  def override_xpaths
    xpaths = {
      "titles" => {
        "main" => "persName[@type='display']",
        "alt" => "persName"
      }
    }
    return xpaths
  end

  def category
    "Life"
  end

  def creator
    creators = get_list @xpaths["creators"], @parent_xml
    return creators.map { |creator| { "name" => creator } }
  end

  def creators
    return get_text @xpaths["creators"], @parent_xml
  end

  def get_id
    person = @xml["id"]
    return "#{@filename}_#{person}"
  end

  def person
    { "role" => nil, "name" => get_text("//persName"), "id" => @id }
  end

  def subcategory
    "Personography"
  end

end
