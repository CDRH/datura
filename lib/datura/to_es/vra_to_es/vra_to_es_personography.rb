class VraToEsPersonography < TeiToEs

  def override_xpaths
    {
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
    creators.map { |c| { "name" => c } }
  end

  def creator_sort
    get_text(@xpaths["creators"], false, @parent_xml)
  end

  def get_id
    person = @xml["id"]
    "#{@filename}_#{person}"
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
