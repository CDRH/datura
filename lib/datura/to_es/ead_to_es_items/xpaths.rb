class EadToEsItems < EadToEs
  # These are the default xpaths that are used for collections
  #  if you require a different xpath, please override the xpath in
  #  the specific collection's TeiToEs file or create a new method
  #  in that file which returns a different value
  def xpaths_list
      {
        "abstract" => "did/abstract",
        # "category" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='category'][1]/term",
        # "contributors" => [
        #   "/TEI/teiHeader/revisionDesc/change/name",
        #   "/TEI/teiHeader/fileDesc/titleStmt/editor"
        # # ],
        # "creators" => ["/ead/archdesc/did/origination/persname", "/ead/eadheader/filedesc/titlestmt/creator"],
        "date" => "did/unitdate",
        "description" => "scopecontent/p",
        # a non normalized date taken directly from the source material ("Dec 9", "Winter 1889")
        # "date_display" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/date",
        "extent" => "did/physdesc/extent",
        "format" => "did/physdesc/physfacet",
        "image_url" => "did/dao/@href",
        # "image_id" => "/TEI/text//pb/@facs",
        # "keywords" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='keywords']/term",
        # note: language is global attribute xml:lang
        "identifier" => "did/unitid[@type='WWA']",
        # "language" => "(//body/div1/@lang)[1]",
        # "languages" => "//body/div1/@lang",
        # "person" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term",
        # "places" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='places']/term",
        # "publisher" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1]",
        # "recipient" => "/TEI/teiHeader/profileDesc/particDesc/person[@role='recipient']/persName",
        "repository_id" => "did/unitid[@type='repository']",
        # "rights" => "/ead/archdesc/descgrp/accessrestrict/p",
        # "rights_holder" => "/ead/archdesc/descgrp/accessrestrict/p",
        # "source" => "/ead/archdesc/descgrp/prefercite/p",
        # "subjects" => ["/ead/archdesc/controlaccess/[everything after head;persname, subject]"],
        # "subcategory" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory'][1]/term",
        # "text" => "//text",
        "title" => "did/unittitle",
        # "topic" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='topic']/term",
        "type" => "did/physdesc/genreform",
        # "works" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='works']/term",
      }.merge(override_xpaths)
  end
end
