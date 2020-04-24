require_relative "../file_type.rb"

class FileVra < FileType

  def initialize(file_location, options)
    super(file_location, options)
    # TODO these paths no longer work now that override xsl is not inside of the data repo, fix during xslt sweep
    @script_html = File.join(options["collection_dir"], options["vra_html_xsl"])
    @script_solr = File.join(options["collection_dir"], options["vra_solr_xsl"])
  end

  def subdoc_xpaths
    # planning ahead on this one, but not necessary at the moment
    {
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

  def transform_iiif
    raise "VRA to IIIF is not yet generalized, please override on a per project basis"
  end

  # def transform_solr
  # end
end
