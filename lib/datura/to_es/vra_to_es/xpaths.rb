class VraToEs < XmlToEs
  # These are the default xpaths that are used for collections
  #  if you require a different xpath, please override the xpath in
  #  the specific collection's VraToEs file or create a new method
  #  in that file which returns a different value
  def xpaths_list
    {
      "contributors" => "/vra/work/agentSet/agent",
      "creators" => "/vra/work/agentSet/agent",
      "dates" => {
        "earliest" => "/vra/collection[1]/dateSet[1]/date[1]/earliestDate[1]",
        "display" => "/vra/collection[1]/dateSet[1]/display[1]"
      },
      "format" => "/vra/collection[1]/techniqueSet[1]/technique[1]",
      "image_id" => "/vra/collection[1]/work[1]/image[1]/@id",
      "keywords" => "/vra/work/subjectSet/subject",
      "place" => "/vra/collection[1]/subjectSet[1]/subject/term[@type='geographicPlace']",
      "publisher" => "/vra/work/agentSet/agent",
      "rights_holder" => "/vra/work/image/rightsSet/rights/rightsHolder",
      "text" => "/vra",
      "title" => "//title[@type='descriptive']"
    }.merge(override_xpaths)
  end
end
