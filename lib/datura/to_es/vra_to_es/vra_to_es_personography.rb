class VraToEsPersonography < TeiToEs

  def override_xpaths
    {
      "title" => "persName[@type='display']",
      "text" => "note"
    }
  end

  def category
    "Personography"
  end

  def creator
    creators = get_list(@xpaths["creators"], xml: @parent_xml)
    if creators
      creators.map { |c| { "name" => c } }
    end
  end

  def creator_sort
    get_text(@xpaths["creators"], xml: @parent_xml)
  end

  def get_id
    person = @xml["id"]
    "#{@filename}_#{person}"
  end

  def person
    {
      "role" => nil,
      "name" => get_text(@xpaths["title"]),
      "id" => @id
    }
  end

  def subcategory
    "Personography"
  end

end
