class EadToEs < XmlToEs
  # These are the default xpaths that are used for collections
  #  if you require a different xpath, please override the xpath in
  #  the specific collection's TeiToEs file or create a new method
  #  in that file which returns a different value
  def xpaths_list
      {
        "abstract" => "/ead/archdesc/did/abstract",
        # "category" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='category'][1]/term",
        # "contributors" => [
        #   "/TEI/teiHeader/revisionDesc/change/name",
        #   "/TEI/teiHeader/fileDesc/titleStmt/editor"
        # ],
        "creators" => ["/ead/archdesc/did/origination/persname", "/ead/eadheader/filedesc/titlestmt/creator"],
        "date" => "/ead/eadheader/filedesc/publicationstmt/date",
        "description" => "/ead/archdesc/scopecontent/p",
        # a non normalized date taken directly from the source material ("Dec 9", "Winter 1889")
        # "date_display" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/date",
        "formats" => "/ead/archdesc/did/physdesc/genreform",
        # "image_id" => "/TEI/text//pb/@facs",
        # "keywords" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='keywords']/term",
        # note: language is global attribute xml:lang
        "identifier" => "/ead/archdesc/did/unitid",
        "language" => "/ead/eadheader/profiledesc/langusage/language",
        # "languages" => "//body/div1/@lang",
        # "person" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term",
        # "places" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='places']/term",
        "publisher" => "/ead/eadheader/filedesc/publicationstmt/publisher",
        # "recipient" => "/TEI/teiHeader/profileDesc/particDesc/person[@role='recipient']/persName",
        "repository_contact" => "/ead/archdesc/did/repository/address/*",
        "rights" => "/ead/archdesc/descgrp/accessrestrict/p",
        "rights_holder" => "/ead/archdesc/did/repository/corpname",
        "source" => "/ead/archdesc/descgrp/prefercite/p",
        "subjects" => "/ead/archdesc/controlaccess/*[not(name()='head')]",
        # "subcategory" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory'][1]/term",
        "title" => "/ead/archdesc/did/unittitle",
        "text" => "/ead/eadheader/filedesc/titlestmt/*",
        "items" => "//*[@level='item']/did/unitid[@type='WWA']"
      }.merge(override_xpaths)
    end
  end
