module TeiToEs

  #### XPATHS ####
  # override default fields and add new xpaths here
  # @xpaths["new_or_old_xpath"] = "/your/path"

  @xpaths["person"] = "/TEI/teiHeader/profileDesc/particDesc/person"

  #### FIELDS ####
  # Note: if you wanted to override a default field, it would look
  # something like this:
  # def self.fieldname
  #   your custom code
  # end
  #
  # If you want to add more fields, add them as follows
  #
  # def self.project_specific_fields
  #   custom = {}
  #   custom["your_new_field"] = get_text @xpaths["desired_xpath_name"]
  #   custom["more_new_fields"] = "hard_coded"
  #   return custom
  # end
  #
  # Please see docs/tei_to_es.rb for complete instructions and examples

  def self.person
    # TODO will need some examples of how this will work
    # and put in the xpaths above, also for attributes, etc
    # should contain name, id, and role
    eles = @xml.xpath(@xpaths["person"])
    return eles.map { |p| { "role" => p["role"], "name" => p.text, "id" => nil } }
  end

end
