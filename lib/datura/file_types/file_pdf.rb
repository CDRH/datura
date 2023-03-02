require "pdf-reader"
require_relative "../file_type.rb"

class FilePdf < FileType
  def initialize(file_location, options)
    super(file_location, options)
    #convert to pdf reading
    @pdf = read_pdf(file_location)
  end

  def build_html_from_pdf
    # #can this be converted? not sure
    # @csv.each_with_index do |row, index|
    #   next if row.header_row?
    #   # Note: if overriding this function, it's recommended to use
    #   # a more specific identifier for each row of the CSV
    #   # but since this is a generic version, simply using the current iteration number
    #   # using XML instead of HTML for simplicity's sake
    #   builder = Nokogiri::XML::Builder.new do |xml|
    #     xml.div(class: "main_content") {
    #       xml.ul {
    #         @csv.headers.each do |header|
    #           xml.li("#{header}: #{row[header]}")
    #         end
    #       }
    #     }
    #   end
    #   write_html_to_file(builder, index)
    # end
  end

  def present?(item)
    !item.nil? && !item.empty?
  end

  # override to change encoding
  def read_pdf(file_location)
    #convert to pdf
    PDF::Reader.new(file_location)
  end

  # override as necessary per project
  def pdf_to_es(pdf)
    PdfToEs.new(pdf, options, self.filename(false)).json
  end


  def transform_es
    puts "transforming #{self.filename}"
    es_doc = []
    es_doc << pdf_to_es(@pdf)
    if @options["output"]
      filepath = "#{@out_es}/#{self.filename(false)}.json"
      File.open(filepath, "w") { |f| f.write(pretty_json(es_doc)) }
    end
    es_doc
  end

  def transform_iiif
    raise "PDF to IIIF is not yet generalized, please override on a per project basis"
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
    doc = Nokogiri::XML::Node.new("doc", solr_doc)
    # row_to_solr should return an XML::Node object with children
    doc = pdf_to_solr(doc, pdf)
    solr_doc.at_css("add").add_child(doc)

    # Uncomment to debug
    # puts solr_doc.root.to_xml
    if @options["output"]
      filepath = "#{@out_solr}/#{self.filename(false)}.xml"
      File.open(filepath, "w") { |f| f.write(solr_doc.root.to_xml) }
    end
    { "doc" => solr_doc.root.to_xml }
  end

  def write_html_to_file(builder, index)
    filepath = "#{@out_html}/#{index}.html"
    puts "writing to #{filepath}" if @options["verbose"]
    File.open(filepath, "w") { |f| f.write(builder.to_xml) }
  end
end
