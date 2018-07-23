require "csv"
require_relative "../file_type.rb"

class FileCsv < FileType
  def initialize(file_location, coll_dir, options)
    super(file_location, coll_dir, options)
    @csv = read_csv(file_location, options["csv_encoding"])
  end

  # override to change encoding
  def read_csv(file_location, encoding="utf-8")
    return CSV.read(file_location, {
      encoding: encoding,
      headers: true,
      return_headers: true
    })
  end

  # most basic implementation assumes column header is the es field name
  # operates with no logic on the fields
  # YOU MUST OVERRIDE FOR CSVS WHICH DO NOT HAVE BESPOKE HEADINGS FOR API
  def row_to_es(headers, row)
    doc = {}
    headers.each do |column|
      doc[column] = row[column] if row[column]
    end
    doc
  end

  # most basic implementation assumes column header is the solr field name
  # operates with no logic on the fields
  def row_to_solr(doc, headers, row)
    headers.each do |column|
      doc.add_child("<field name='#{column}'>#{row[column]}</field>") if row[column]
    end
    return doc
  end

  def transform_es
    puts "transforming #{self.filename}"
    es_doc = []
    @csv.each do |row|
      if !row.header_row?
        es_doc << row_to_es(@csv.headers, row)
      end
    end
    if @options["output"]
      filepath = "#{out_es}/#{self.filename(false)}.xml"
      File.open(filepath, "w") { |f| f.write(pretty_json(es_doc)) }
    end
  end

  def transform_html
    raise "Currently CSV to HTML transformation is not supported"
  end

  # I am not sure that this is going to be the best way to set this up
  # but until we have more examples of CSVs that need to be ingested
  # it will have to do! (transmississippi only collection so far)
  def transform_solr
    puts "transforming #{self.filename}"
    solr_doc = Nokogiri::XML("<add></add>")
    @csv.each do |row|
      if !row.header_row?
        doc = Nokogiri::XML::Node.new("doc", solr_doc)
        # row_to_solr should return an XML::Node object with children
        doc = row_to_solr(doc, @csv.headers, row)
        solr_doc.at_css("add").add_child(doc)
      end
    end
    # Uncomment to debug
    # puts solr_doc.root.to_xml
    if @options["output"]
      filepath = "#{@out_solr}/#{self.filename(false)}.xml"
      # puts "output #{@out_solr}"
      File.open(filepath, "w") { |f| f.write(solr_doc.root.to_xml) }
    end
    return { "docs" => solr_doc.root.to_xml }
  end
end
