class VraToEsPersonography < TeiToEs

  def override_xpaths
    return {
      "titles" => {
        "main" => "persName[@type='display']",
        "alt" => "persName"
      },
      "text" => "note"
    }
  end

  def category
    "Life"
  end

  def creator
    creators = get_list(@xpaths["creators"], false, @parent_xml)
    return creators.map { |creator| { "name" => creator } }
  end

  def creators
    return get_text(@xpaths["creators"], false, @parent_xml)
  end

  def get_id
    person = @xml["id"]
    return "#{@filename}_#{person}"
  end

  def person
    {
      "role" => nil,
      "name" => get_text(@xpaths["titles"]["main"]),
      "id" => @id
    }
  end

  def subcategory
    "Personography"
  end

end
