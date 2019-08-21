require_relative "../helpers.rb"
require_relative "../file_type.rb"

require "rest-client"

class FileWebs < FileType
  attr_reader :es_req

  def initialize(file_location, options)
    super(file_location, options)
  end

  def subdoc_xpaths
    { "/" => WebsToEs }
  end

  # override default behavior to warn users that they shouldn't be
  # trying to use the html or solr output options
  def transform_html
    raise "Web scraped HTML to HTML transformation is not supported"
  end

  def transform_iiif
    raise "Web scraped HTML to IIIF is not yet generalized, please override on a per project basis"
  end

  def transform_solr
    raise "Web scraped HTML to Solr transformation not supported"
  end
end
