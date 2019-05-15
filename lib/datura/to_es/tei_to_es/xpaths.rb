class TeiToEs < XmlToEs
  # These are the default xpaths that are used for collections
  #  if you require a different xpath, please override the xpath in
  #  the specific collection's TeiToEs file or create a new method
  #  in that file which returns a different value
  def xpaths_list
    {
      "category" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='category'][1]/term",
      "contributors" => [
        "/TEI/teiHeader/revisionDesc/change/name",
        "/TEI/teiHeader/fileDesc/titleStmt/editor"
      ],
      "creators" => [
        "/TEI/teiHeader/fileDesc/titleStmt/author",
        "//persName[@type = 'author']",
        "/TEI/teiHeader/fileDesc/sourceDesc/bibl/author"
      ],
      "date" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when",
      # a non normalized date taken directly from the source material ("Dec 9", "Winter 1889")
      "date_display" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/date",
      "formats" => {
        "letter" => "/TEI/text/body/div1[@type='letter']",
        "periodical" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level='j']",
        "manuscript" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/title[@level='m']"
      },
      "image_id" => "/TEI/text//pb/@facs",
      "keywords" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='keywords']/term",
      # note: language is global attribute xml:lang
      "language" => "(//body/div1/@lang)[1]",
      "languages" => "//body/div1/@lang",
      "person" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term",
      "places" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='places']/term",
      "publisher" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1]",
      "recipient" => "/TEI/teiHeader/profileDesc/particDesc/person[@role='recipient']/persName",
      "rights_holder" => "/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository",
      "source" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[@level='j']",
      "subcategory" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory'][1]/term",
      "text" => "//text",
      "titles" => {
        "main" => "/TEI/teiHeader/fileDesc/titleStmt/title[@type='main'][1]",
        "alt" => "/TEI/teiHeader/fileDesc/titleStmt/title[1]"
      },
      "topic" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='topic']/term",
      "works" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='works']/term",
    }.merge(override_xpaths)
  end
end
