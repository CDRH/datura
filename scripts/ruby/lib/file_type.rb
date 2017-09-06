require "json"
require "open3"

class FileType

  # general information about file
  attr_reader :file_location
  attr_reader :options
  attr_reader :coll_dir

  # script locations
  attr_accessor :script_es
  attr_accessor :script_html
  attr_accessor :script_solr

  # output directories
  attr_accessor :out_es
  attr_accessor :out_html
  attr_accessor :out_solr

  def initialize location, collection_dir, options
    @file_location = location
    @options = options
    @options["variables_html"]["collection"] = @options["shortname"]
    @options["variables_solr"]["collection"] = @options["shortname"]

    # set output directories
    @out_es = "#{collection_dir}/output/es"
    @out_html = "#{collection_dir}/output/html-generated"
    @out_solr = "#{collection_dir}/output/solr"
    # script locations will need to be set in child classes
  end

  def filename ext=true
    if ext
      File.basename(@file_location)
    else
      File.basename(@file_location, ".*")
    end
  end

  def post_es url=nil
    url = url || "#{@options["es_path"]}/#{@options["es_index"]}"
    begin
      transformed = transform_es(@options["output"])
    rescue => e
      return { "error" => "Error transforming ES for #{self.filename(false)}: #{e}" }
    end
    transformed.each do |doc|
      id = doc["identifier"]
      type = @options["es_type"]
      puts "posting #{id}"
      puts "PATH: #{url}/#{type}/#{id}" if options["verbose"]
      # NOTE: If you need to do partial updates rather than replacement of doc
      # you will need to add _update at the end of this URL
      begin
        RestClient.put("#{url}/#{type}/#{id}", doc.to_json, {:content_type => :json } )
        return { "docs" => transformed }
      rescue => e
        return { "error" => "Error transforming or posting to ES for #{self.filename(false)}: #{e.response}" }
      end
    end
  end

  def post_solr url=nil
    url = url || "#{@options['solr_path']}/#{@options['solr_core']}/update"
    begin
      transformed = @solr_req || transform_solr(@options["output"])["docs"]
      solr = SolrPoster.new(url, @options["commit"])
      # Note: only supporting XML for now since solr is considered "deprecated"
      # but can extend in the future if necessary
      res = solr.post_xml(transformed)
      if res.code == "200"
        solr.commit_solr
        return { "docs" => transformed }
      else
        return { "error" => "Error posting to Solr for #{self.filename(false)}: #{res.body}" }
      end
    rescue => e
      return { "error" => "Error transforming or posting to Solr for #{self.filename(false)}: #{e.inspect}" }
    end
  end

  def print_es
    json = @es_req || transform_es
    return pretty_json json
  end

  def print_solr
    return @solr_req || transform_solr
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
      return @es_req
    rescue => e
      puts "something went wrong transforming #{self.filename}"
      raise e
    end
  end

  def transform_html
    # add html specific variables and shortname as params
    exec_xsl @file_location, @script_html, "html", @out_html, @options["variables_html"]
  end

  def transform_solr output=false
    # this assumes that solr uses XSL transformation
    # make sure to override behavior in CSV / YML child classes
    # TODO make sure the right params are going through
    if output
      req = exec_xsl @file_location, @script_solr, "xml", @out_solr, @options["variables_solr"]
    else
      req = exec_xsl @file_location, @script_solr, "xml", nil, @options["variables_solr"]
    end
    @solr_req = req["doc"] if req && req.has_key?("doc")
    return { "docs" => req["doc"]}
  end

  private

  # TODO will need to make params string at some point
  def exec_xsl input, xsl, ext, output=nil, params=nil
    saxon_params = Common.stringify_params(params)
    cmd = "saxon -s:#{input} -xsl:#{xsl}"
    # TODO which way would we rather do this?
    # cmd << " -o:#{output}/#{filename(false)}.#{ext}" if output
    cmd << " #{saxon_params}"
    cmd << " | tee #{output}/#{filename(false)}.#{ext}" if output
    puts "using command #{cmd}" if @options["verbose"]
    Open3.popen3(cmd) do |stdin, stdout, stderr|
      out = stdout.read
      err = stderr.read
      if err.length > 0
        msg = "There was an error transforming #{filename}: #{err}"
        return { "error" => msg }
      else
        puts "Successfully transformed #{filename}"
        return { "doc" => out }
      end
    end
  end

  def pretty_json json
    JSON.pretty_generate(json)
  end

end
