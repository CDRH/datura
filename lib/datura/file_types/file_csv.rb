require "csv"
require_relative "../file_type.rb"

class FileCsv < FileType
  def initialize(file_location, options)
    super(file_location, options)
    @csv = read_csv(file_location, options["csv_encoding"])
  end

  def build_html_from_csv
    @csv.each_with_index do |row, index|
      next if row.header_row?
      # Note: if overriding this function, it's recommended to use
      # a more specific identifier for each row of the CSV
      # but since this is a generic version, simply using the current iteration number
      id = index
      # using XML instead of HTML for simplicity's sake
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.div(class: "main_content") {
          xml.ul {
            @csv.headers.each do |header|
              xml.li("#{header}: #{row[header]}")
            end
          }
        }
      end
      write_html_to_file(builder, index)
    end
  end

  def present?(item)
    !item.nil? && !item.empty?
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
    if doc.key?("text") && doc.key?("title")
      doc["text"] << " #{doc["title"]}"
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
      filepath = "#{@out_es}/#{self.filename(false)}.json"
      File.open(filepath, "w") { |f| f.write(pretty_json(es_doc)) }
    end
    es_doc
  end

  def transform_html
    puts "transforming #{self.filename} to HTML subdocuments"
    build_html_from_csv
    # transform_html method is expected to send back a hash
    # but already wrote to filesystem so just sending back empty
    {}
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

  def write_html_to_file(builder, index)
    filepath = "#{@out_html}/#{index}.html"
    puts "writing to #{filepath}" if @options["verbose"]
    File.open(filepath, "w") { |f| f.write(builder.to_xml) }
  end
end
