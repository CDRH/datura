require_relative "../file_type.rb"

class FileVra < FileType

  def initialize(file_location, coll_dir, options)
    super(file_location, coll_dir, options)
    @script_html = "#{options["repo_dir"]}/#{options["vra_html_xsl"]}"
    @script_solr = "#{options["repo_dir"]}/#{options["vra_solr_xsl"]}"
  end

  def subdoc_xpaths
    # planning ahead on this one, but not necessary at the moment
    return {
      "/vra" => VraToEs,
      "//listPerson/person" => VraToEsPersonography
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
