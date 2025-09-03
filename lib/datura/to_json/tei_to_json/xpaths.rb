class TeiToJson < XmlToJson
  # These are the default xpaths that are used for collections
  #  if you require a different xpath, please override the xpath in
  #  the specific collection's TeiToJson file or create a new method
  #  in that file which returns a different value
  def xpaths_list
    {

      "annotations_text" => [
        "/TEI/text/back/note",
        "//notesStmt/note",
        "//note[@type='editorial']",
        "//note[@type='project']"
      ],

      "authority" => "/TEI/teiHeader/fileDesc/publicationStmt/authority[1]",

      "bibl_author" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/author",
        
      "bibl_date" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/date[1]",
        
      "bibl_note" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/note",
        
      "bibl_pub_place" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/pubPlace[1]",
        
      "bibl_publisher" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1]",
        
      "bibl_title" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[1]",

      "distributor" => "/TEI/teiHeader/fileDesc/publicationStmt/distributor/name[1]",

      "idno" => "/TEI/teiHeader/fileDesc/publicationStmt/idno[1]",

      "language" => "/TEI/teiHeader/profileDesc/langUsage/language",

      "license" => {
        "url" => "/TEI/teiHeader/fileDesc/publicationStmt/availability/licence",
        "text" => "/TEI/teiHeader/fileDesc/publicationStmt/availability/p",
      },

      "principal" => "/TEI/teiHeader/fileDesc/titleStmt/principal",

      # currently only supporting a single publisher, but some resources may
      # need multiple (change xpath and method behavior)
      "publisher" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1]",

      "publisher_addr_line" => "/TEI/teiHeader/fileDesc/publicationStmt/distributor/address[1]/addrLine",

      #"subtitle" => "/TEI/teiHeader/fileDesc/titleStmt/title[@type='sub']",

      "resp" => "/TEI/teiHeader/fileDesc/titleStmt/respStmt/name",

      "source_collection" => "/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/collection[1]",

      "source_id" => "/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno[1]",

      "source_repo" => "/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository[1]",

      # NOTE this xpath will often catch notes, back, etc which a project may wish to
      # exclude if they are using the annotations_text field for editorial comments
      "text" => ["//text//text()", "//note[@type='project']"],

      "title" => "/TEI/teiHeader/fileDesc/titleStmt/title[1]",

      "xmlid" => "/TEI/@id",

    }.merge(override_xpaths)
  end
end
