require_relative "../helpers.rb"
require_relative "../file_type.rb"
require_relative "../solr_poster.rb"
require "rest-client"

class FileEad < FileType
  # TODO we could include the tei_to_es and other modules directly here
  # as a mixin, though then we'll need to namespace them or perish
  attr_reader :es_req


  def initialize(file_location, options)
    super(file_location, options)
    @script_html = File.join(options["collection_dir"], options["ead_html_xsl"]) # There needs to be an xsl file to transform into html
    # I don't think we need solr at this point)
    # @script_solr = File.join(options["collection_dir"], options["tei_solr_xsl"])
  end

  def subdoc_xpaths
    # match subdocs against classes
    return {
      "/EAD" => EadToEs,
      # "//dsc/c01" => EadToEsItems,
    }
  end

  # if there should not be any html transformation taking place
  # then leave this method empty but uncommented to override default behavior

  # if you would like to use the default transformation behavior
  # then comment or remove both of the following methods!

  # def transform_es
  # end

  # def transform_html
  # end

  def transform_iiif
    raise "EAD to IIIF is not yet generalized, please override on a per project basis"
  end

  # def transform_solr
  # end
end
