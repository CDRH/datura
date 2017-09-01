require_relative "../file_type.rb"

class FileVra < FileType

  def initialize(file_location, coll_dir, options)
    super file_location, coll_dir, options
    @script_html = "#{options["repo_dir"]}/#{options["vra_html_xsl"]}"
    @script_solr = "#{options["repo_dir"]}/#{options["vra_solr_xsl"]}"
  end

  def subdoc_xpaths
    # planning ahead on this one, but not necessary at the moment
    return {
      "/vra" => VraToEs
    }
  end

  def transform_es(output=false)
    @es_req = []
    begin
      file_xml = Common.create_xml_object(self.file_location)
      subdoc_xpaths.each do |xpath, classname|
        file_xml.xpath(xpath).each do |subdoc|
          file_transformer = classname.new(subdoc, @options, file_xml, self.filename(false))
          @es_req << file_transformer.json
        end
      end
      if output
        filepath = "#{@out_es}/#{self.filename(false)}.json"
        File.open(filepath, "w") { |f| f.write(self.print_es) }
      end
    rescue => e
      puts "something went wrong transforming #{self.filename}"
      raise e
    end
  end

  # if there should not be any html transformation taking place
  # then leave this method empty but uncommented to override default behavior

  # if you would like to use the default transformation behavior
  # then comment or remove both of the following methods!

  # def transform_html
  # end

  # def transform_solr(output=false)
  # end
end
