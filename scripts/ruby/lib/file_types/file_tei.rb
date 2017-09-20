require_relative "../helpers.rb"
require_relative "../file_type.rb"
require_relative "../solr_poster.rb"
require "rest-client"

class FileTei < FileType
  # TODO we could include the tei_to_es and other modules directly here
  # as a mixin, though then we'll need to namespace them or perish
  attr_reader :es_req


  def initialize(file_location, coll_dir, options)
    super(file_location, coll_dir, options)
    @script_html = "#{options["repo_dir"]}/#{options["tei_html_xsl"]}"
    @script_solr = "#{options["repo_dir"]}/#{options["tei_solr_xsl"]}"
  end

  def subdoc_xpaths
    # match subdocs against classes
    return {
      "/TEI" => TeiToEs,
      "//listPerson/person" => TeiToEsPersonography,
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

  # def transform_solr
  # end
end
