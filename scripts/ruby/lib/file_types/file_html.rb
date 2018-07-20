require_relative "../helpers.rb"
require_relative "../file_type.rb"
require_relative "../solr_poster.rb"
require "rest-client"

class FileHtml < FileType
  attr_reader :es_req


  def initialize(file_location, coll_dir, options)
    super(file_location, coll_dir, options)
    @script_html = "#{options["repo_dir"]}/#{options["html_html_xsl"]}"
  end

  # if there should not be any html transformation taking place
  # then leave this method empty but uncommented to override default behavior

  # if you would like to use the default transformation behavior
  # then comment or remove both of the following methods!

  def transform_es
    raise "HTML to ES transformation not supported"
  end

  # def transform_html
  #   raise "HTML to HTML transformation not supported"
  # end

  def transform_solr
    raise "HTML to Solr transformation not supported"
  end
end
