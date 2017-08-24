require_relative "../file_type.rb"

class FileVra < FileType

  def initialize file_location, coll_dir, options
    super file_location, coll_dir, options
    @script_html = "#{options["repo_dir"]}/#{options["vra_html_xsl"]}"
    @script_solr = "#{options["repo_dir"]}/#{options["vra_solr_xsl"]}"
  end

  # Note: Uncomment the below to customize how VRA
  # handles transformations, otherwise uses methods from file_type.rb

  # def transform_es
  # end

  # def transform_html
  # end

  # def transform_solr output=false
  # end
end
