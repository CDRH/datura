require_relative "../file_type.rb"

class FileTei < FileType
  # TODO we could include the tei_to_es and other modules directly here
  # as a mixin, though then we'll need to namespace them or perish

  def initialize file_location, proj_dir, options
    super file_location, proj_dir, options
    @script_es = options["tei_es_xsl"]
    @script_html = options["tei_html_xsl"]
    @script_solr = options["tei_solr_xsl"]
  end

  def transform_es output=false
    json = TeiToEs.create_json(self, @options)
    pretty = pretty_json json
    puts "values: #{pretty}"
  end

  # if there should not be any html transformation taking place
  # then leave this method empty but uncommented to override default behavior

  # if you would like to use the default transformation behavior
  # then comment or remove both of the following methods!
  def transform_html
  end

  def transform_solr output=false
  end
end
