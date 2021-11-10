class HtmlToEs < XmlToEs
  # These are the default xpaths that are used for collections
  #  if you require a different xpath, please override the xpath in
  #  the specific collection's HtmlToEs file or create a new method
  #  in that file which returns a different value
  def xpaths_list
    {
      # "alternative" => "",
      # "category" => "",
      # "contributor" => "",
      # "creator" => "",
      # "date" => "",
      # "date_display" => "",
      # "date_not_after" => "",
      # "date_not_before" => "",
      # "data_type" => "",
      # "description" => "",
      # "extent" => "",
      # "format" => "",
      "keywords" => "//meta[@name='dc.keywords']",
      "language" => "//meta[@name='dc.language']",
      "languages" => "//meta[@name='dc.language']",
      # "medium" => "",
      # "person" => "",
      # "places" => "",
      # "publisher" => "",
      # "recipient" => "",
      # "relation" => "",
      # "rights" => "",
      # "rights_holder" => "",
      # "rights_uri",
      # "source" => "",
      # "spatial" => "",
      # "subcategory" => "",
      # "subjects" => "",
      "text" => "//body",
      "title" => "//title",
      # "topics" => "",
      # "type" => "",
      # "works" => "",
    }.merge(override_xpaths)
  end
end
