class VraToEs < XmlToEs
  # These are the default xpaths that are used for collections
  #  if you require a different xpath, please override the xpath in
  #  the specific collection's VraToEs file or create a new method
  #  in that file which returns a different value
  def xpaths_list
    {
      # "alternative" => "",
      # "annotations_text" => "",
      "contributor" => "/vra/work/agentSet/agent",
      "creator" => "/vra/work/agentSet/agent",
      # "data_type" => "",
      "date" => "//dateSet[1]/date",
      "date_display" => "//dateSet[1]/display[1]",
      "date_not_after" => "//dataSet[1]/date[1]/latestDate",
      "date_not_before" => "//dateSet[1]/date[1]/earliestDate",
      "description" => "//descriptionSet/description",
      "extent" => "//measurementSet/display",
      "format" => "/vra/collection[1]/techniqueSet[1]/technique[1]",
      "language" => "/vra/@lang",
      "languages" => "/vra/@lang",
      "image_id" => "/vra/collection[1]/work[1]/image[1]/@id",
      "keywords" => "/vra/work/subjectSet/subject",
      "medium" => "//materialSet/display",
      "places" => "/vra/collection[1]/subjectSet[1]/subject/term[@type='geographicPlace']",
      "publisher" => "/vra/work/agentSet/agent",
      # "recipient" => "",
      "relation" => "//relationSet/relation",
      # "rights" => "",
      "rights_holder" => "/vra/work/image/rightsSet/rights/rightsHolder",
      # "rights_uri" => "",
      # "source" => "",
      # "subjects" = > "",
      "text" => "/inscriptionSet/inscription/text",
      "title" => "//title[@type='descriptive']",
      # "topics" => "",
      # "type" => "",
      # "works" => "",
    }.merge(override_xpaths)
  end
end
