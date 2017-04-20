require_relative "../helpers.rb"
require_relative "../file_type.rb"
require_relative "../solr_poster.rb"
require "rest-client"

class FileTei < FileType
  # TODO we could include the tei_to_es and other modules directly here
  # as a mixin, though then we'll need to namespace them or perish
  attr_reader :es_req


  def initialize file_location, coll_dir, options
    super file_location, coll_dir, options
    @es_req = nil
    @script_html = options["tei_html_xsl"]
    @script_solr = options["tei_solr_xsl"]
  end

  def transform_es output=false
    @es_req = []
    begin
      # read in XML file and split up into subdocuments
      # this step should be overrideable
      # match subdocs against classes
      # create class for each one, create_json
      # collect results into @es_req here

      # read in XML
      file_xml = Common.create_xml_object(self.file_location)
      # match subdocs against classes
      subdoc_xpaths = {
        "/TEI" => TeiToEs,
        "//listPerson/person" => TeiToEsPersonography,
      }

      subdoc_xpaths.each do |xpath, classname|
        file_xml.xpath(xpath).each do |subdoc|
          file_transformer = classname.new(subdoc, @options, file_xml, self.filename(false))
          @es_req << file_transformer.json
        end
      end

      if output
        filepath = "#{@out_es}/#{self.filename(false)}.json"
        File.open(filepath, "w") { |f| f.write(self.print_es) }
      end
      return @es_req
    rescue => e
      raise e
    end
  end

  # if there should not be any html transformation taking place
  # then leave this method empty but uncommented to override default behavior

  # if you would like to use the default transformation behavior
  # then comment or remove both of the following methods!

  # def transform_html
  # end

  # def transform_solr output=false
  # end
end
