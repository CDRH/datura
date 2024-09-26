class EadToEs < XmlToEs
  # These are the default xpaths that are used for collections
  #  if you require a different xpath, please override the xpath in
  #  the specific collection's TeiToEs file or create a new method
  #  in that file which returns a different value
  def xpaths_list
    {
      "abstract" => "/ead/archdesc/did/abstract",
      "creator" => ["/ead/archdesc/did/origination/persname", "/ead/eadheader/filedesc/titlestmt/creator"],
      "date" => "/ead/eadheader/filedesc/publicationstmt/date",
      "description" => "/ead/archdesc/scopecontent/p",
      "formats" => "/ead/archdesc/did/physdesc/genreform",
      "identifier" => "/ead/archdesc/did/unitid",
      "language" => "/ead/eadheader/profiledesc/langusage/language",
      "publisher" => "/ead/eadheader/filedesc/publicationstmt/publisher",
      "repository_contact" => "/ead/archdesc/did/repository/address/*",
      "rights" => "/ead/archdesc/descgrp/accessrestrict/p",
      "rights_holder" => "/ead/archdesc/did/repository/corpname",
      "source" => "/ead/archdesc/descgrp/prefercite/p",
      "subjects" => "/ead/archdesc/controlaccess/*[not(name()='head')]",
      "title" => "/ead/archdesc/did/unittitle",
      "text" => "/ead/eadheader/filedesc/titlestmt/*",
      "items" => "//*[@level='item']/did/unitid"
    }.merge(override_xpaths)
  end
end
