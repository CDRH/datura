require_relative "../file_type.rb"

class FileTei < FileType

  def initialize location, proj_dir, options
    super location, proj_dir, options
    @script_es = options["tei_es_xsl"]
    @script_html = options["tei_html_xsl"]
    @script_solr = options["tei_solr_xsl"]
  end
  # def transform_es
  #   puts "transform ES #{filename}"
  # end

  # def transform_html
  #   # puts "transform html #{filename}"
  #   puts @@out_html
  # end

  # def transform_solr
  #   puts "transform solr #{filename}"
  # end
end
