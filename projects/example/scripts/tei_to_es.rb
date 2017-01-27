module TeiToEs

  @xpaths["person"] = "/TEI/teiHeader/profileDesc/particDesc/person"

  def self.person
    # TODO will need some examples of how this will work
    # and put in the xpaths above, also for attributes, etc
    # should contain name, id, and role
    eles = @xml.xpath(@xpaths["person"])
    return eles.map { |p| { "role" => p["role"], "name" => p.text, "id" => nil } }
  end

end
