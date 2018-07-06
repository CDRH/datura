class TeiToEs

  ################
  #    XPATHS    #
  ################

  # in the below example, the xpath for "person" is altered
  def override_xpaths
    xpaths = {}
    xpaths["person"] = "/TEI/teiHeader/profileDesc/particDesc/person"
    return xpaths
  end

  #################
  #    GENERAL    #
  #################

  # do something before pulling fields
  def preprocessing
    # read additional files, alter the @xml, add data structures, etc
  end

  # do something after pulling the fields
  def postprocessing
    # change the resulting @json object here
  end

  # Add more fields
  #  make sure they follow the custom field naming conventions
  #  *_d, *_i, *_k, *_t
  def assemble_collection_specific
  #   @json["fieldname_k"] = some_value_or_method
  end

  ################
  #    FIELDS    #
  ################

  # Please see docs/tei_to_es.rb for complete instructions and examples

  # Note: basic override
  # def self.fieldname
  #   your custom code
  # end

  # Use CommonXml.normalize_space() the same way as XSL's normalize-space
  #   string = " example of   weird stuff"
  #   CommonXml.normalize_space(string)
  #   ==> "example of weird stuff"

  # In the below example, the normal "person" behavior is customized
  def person
    # TODO will need some examples of how this will work
    # and put in the xpaths above, also for attributes, etc
    # should contain name, id, and role
    eles = @xml.xpath(@xpaths["person"])
    return eles.map do |p|
      {
        "id" => "",
        "name" => CommonXml.normalize_space(p.text),
        "role" => CommonXml.normalize_space(p["role"])
      }
  end

end
