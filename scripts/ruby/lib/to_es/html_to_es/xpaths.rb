class HtmlToEs < XmlToEs
  # These are the default xpaths that are used for collections
  #  if you require a different xpath, please override the xpath in
  #  the specific collection's TeiToEs file or create a new method
  #  in that file which returns a different value
  def xpaths_list
    {
      "category" => "",
      "contributors" => "",
      "creators" => "",
      "date" => "",
      "formats" => "",
      "keywords" => "//meta[@name='dc.keywords']",
      # note: language is global attribute xml:lang
      "language" => "//meta[@name='dc.language']",
      "person" => "",
      "places" => "",
      "publisher" => "",
      "recipient" => "",
      "rights_holder" => "",
      "source" => "",
      "subcategory" => "",
      "text" => "//body",
      "titles" => "//title",
      "topic" => "",
      "works" => "",
    }.merge(override_xpaths)
  end
end
