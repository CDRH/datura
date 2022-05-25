class WebsToEs < XmlToEs
  # These are the default xpaths that are used for collections
  #  if you require a different xpath, please override the xpath in
  #  the specific collection's WebsToEs file or create a new method
  #  in that file which returns a different value
  def xpaths_list
    {
      # "alternative" => "",
      # "annotations_text" => "",
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
      # "image_id" => "",
      "keywords" => "//meta[@name='dc.keywords']",
      # note: language is global attribute xml:lang
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
      # "rights_uri" => "",
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
