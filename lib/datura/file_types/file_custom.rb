require_relative "../helpers.rb"
require_relative "../file_type.rb"

require "rest-client"

class FileCustom < FileType
  attr_reader :es_req, :format

  def initialize(file_location, options)
    super(file_location, options)
    @format = get_format
    @file = read_file
  end

  def build_es_documents
    # currently assuming that the file has one document to post
    # but since some may include more (personographies, spreadsheets, etc)
    # this should return an array of documents
    # NOTE this would also be a pretty reasonable method to override
    # if you need to split your documents into classes of your own creation
    # like "YamlToEs" or "XlsToEs", etc
    docs = []
    subdocs.each do |subdoc|
      puts "just checking that there's a subdoc here!"
      docs << CustomToEs.new(
        subdoc,
        options: @options,
        file: @file,
        filename: self.filename,
        file_type: @format)
      .json
    end
    docs.compact
  end

  def get_format
    # assumes that the format is in the directory structure
    File.dirname(@file_location).split("/").last
  end

  # NOTE: you will likely need to override this method
  # depending on the format in question
  def read_file
    File.read(@file_location)
  end

  def subdocs
    # if the file should be split into components (such as a CSV row
    # or personography person entry), override this method to return
    # an array of items
    Array(@file)
  end

  def transform_es
    puts "transforming #{self.filename}"
    # expecting an array
    es_doc = build_es_documents

    if @options["output"]
      filepath = "#{@out_es}/#{self.filename(false)}.json"
      File.open(filepath, "w") { |f| f.write(pretty_json(es_doc)) }
    end
    es_doc
  end

  # CURRENTLY NO SUPPORT FOR FOLLOWING TRANSFORMATIONS
  def transform_html
    raise "Custom format to HTML transformation must be implemented in collection"
  end

  def transform_iiif
    raise "Custom format to IIIF transformation must be implemented in collection"
  end

  def transform_solr
    raise "Custom format to Solr transformation must be implemented in collection"
  end
end
