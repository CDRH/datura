class TeiToEs < XmlToEs
  # These are the default xpaths that are used for collections
  #  if you require a different xpath, please override the xpath in
  #  the specific collection's TeiToEs file or create a new method
  #  in that file which returns a different value
  def xpaths_list
    {
      # "alternative" => "",

      "annotations_text" => [
        "/TEI/text/back/note",
        "//notesStmt/note",
        "//note[@type='editorial']",
        "//note[@type='project']"
      ],

      "category" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='category'][1]/term",

      "contributor" => [
        "/TEI/teiHeader/revisionDesc/change/name",
        "/TEI/teiHeader/fileDesc/titleStmt/editor",
        "/TEI/teiHeader/fileDesc/titleStmt/respStmt/persName",
        "/TEI/teiHeader/fileDesc/titleStmt/principal"
      ],

      "creator" => [
        "/TEI/teiHeader/fileDesc/titleStmt/author",
        "//persName[@type = 'author']",
        "/TEI/teiHeader/fileDesc/sourceDesc/bibl/author",
        "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/author",
        "//correspDesc/correspAction[@type='sentBy']/persName"
      ],

      # NOTE: general guidance for correspondence is to use the sent date
      # rather than the received date if you must select only one
      # uses the FIRST successful match
      #   to change this behavior either modify the date method OR
      #   override the date @xpath to use only one xpath
      "date" => [
        "/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@when",
        "//correspDesc/date/@when"
      ],

      "date_display" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/date",

      "date_not_before" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@notBefore",

      "date_not_after" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl/date/@notAfter",

      # "description" => "",

      "extent" => "//sourceDesc/bibl/extent",

      "format" => [
        "/TEI/text/body/div1/@type",
        "//body/div1/@type"
      ],

      "image_id" => "/TEI/text//pb/@facs",

      "keywords" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='keywords']/term",

      "language" => [
        "/TEI/@lang",
        "//body/div1/@lang",
      ],

      "languages" => [
        "/TEI/@lang",
        "//body/div1/@lang",
      ],

      # "medium" => "",

      # NOTE: if you would like to associate a role you may need the parent element
      # such as correspAction[@type='deliveredTo'], etc
      "person" => [
        "//persName",
        "/TEI/teiHeader/profileDesc/textClass/keywords[@n='people']/term",
      ],

      "places" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='places']/term",

      # currently only supporting a single publisher, but some resources may
      # need multiple (change xpath and method behavior)
      "publisher" => "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/publisher[1]",

      "recipient" => [
        "//correspDesc/correspAction[@type='deliveredTo']/persName",
        "//correspDesc/correspAction[@type='receivedBy']/persName",
        "//particDesc/person[@role='recipient']/persName",
      ],

      # "relation" => "",

      "rights" => "//availability",

      # TODO check for distributor field instead
      "rights_holder" => "/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository",

      "rights_uri" => [
        "//availability//license",
        "//availability//ref/@target"
      ],

      # NOTE source is a complicated field built from many other fields
      #   author, title, publisher, pubplace, date are fairly typical for published works
      #   if msDesc, includes collection, repository, and idno as well
      "source" => {
        "author" => "//sourceDesc/bibl[1]/author",
        "date" => "//sourceDesc/bibl[1]/date/@when",
        "publisher" => "//sourceDesc/bibl[1]/publisher",
        "title" => "//sourceDesc/bibl[1]/title[1]",
        "collection" => "//sourceDesc/msDesc/msIdentifier/collection",
        "idno" => "//sourceDesc/msDesc/msIdentifier/idno",
        "pubplace" => "//sourceDesc/bibl[1]/pubPlace",
        "repository" => "//sourceDesc/msDesc/msIdentifier/repository",
      },

      # "spatial" => "",

      "subcategory" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='subcategory'][1]/term",

      # "subjects" => "",

      # NOTE this xpath will often catch notes, back, etc which a project may wish to
      # exclude if they are using the annotations_text field for editorial comments
      "text" => "//text//text()",

      "title" => "/TEI/teiHeader/fileDesc/titleStmt/title[1]",

      "topics" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='topic']/term",

      # "type" => "",

      "works" => "/TEI/teiHeader/profileDesc/textClass/keywords[@n='works']/term"
    }.merge(override_xpaths)
  end
end
