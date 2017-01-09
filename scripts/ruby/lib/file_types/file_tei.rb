require_relative "../file_type.rb"

class FileTei < FileType

  def initialize file_location, proj_dir, options
    super file_location, proj_dir, options
    @script_es = options["tei_es_xsl"]
    @script_html = options["tei_html_xsl"]
    @script_solr = options["tei_solr_xsl"]
  end

  def transform_es output=false
    # puts "xpaths: #{TeiToEs.xpaths}"
    puts "values: #{TeiToEs.create_json @file_location}"
  end

  # if there should not be any html transformation taking place
  # then leave this method empty but uncommented to override default behavior
  def transform_html
    # puts "transform html #{filename}"
  end

  def transform_solr output=false
    # puts "transform solr #{filename}"
  end
end
