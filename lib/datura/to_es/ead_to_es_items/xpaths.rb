class EadToEsItems < EadToEs
  # These are the default xpaths that are used for collections
  #  if you require a different xpath, please override the xpath in
  #  the specific collection's TeiToEs file or create a new method
  #  in that file which returns a different value
  def xpaths_list
      {
        "abstract" => "did/abstract",
        "date" => "did/unitdate",
        "description" => "scopecontent/p",
        "extent" => "did/physdesc/extent",
        "format" => "did/physdesc/physfacet",
        "image_url" => "did/dao/@href",
        "identifier" => "did/unitid",
        "repository_id" => "did/unitid[@type='repository']",
        "title" => "did/unittitle",
        "type" => "did/physdesc/genreform",
      }.merge(override_xpaths)
  end
end
