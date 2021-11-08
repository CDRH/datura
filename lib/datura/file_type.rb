require "json"
require "open3"

class FileType

  # general information about file
  attr_reader :file_location
  attr_reader :options

  # script locations
  attr_accessor :script_es
  attr_accessor :script_html
  attr_accessor :script_iiif
  attr_accessor :script_solr

  # output directories
  attr_accessor :out_es
  attr_accessor :out_html
  attr_accessor :out_iiif
  attr_accessor :out_solr

  def initialize(location, options)
    @file_location = location
    @options = options
    add_xsl_params_options
    # set output directories
    output = File.join(@options["collection_dir"], "output", @options["environment"])
    
    @out_es = File.join(output, "es")
    @out_html = File.join(output, "html")
    @out_iiif = File.join(output, "iiif")
    @out_solr = File.join(output, "solr")
    Datura::Helpers.make_dirs(@out_es, @out_html, @out_iiif, @out_solr)
    # script locations set in child classes
  end

  def filename(ext=true)
    if ext
      File.basename(@file_location)
    else
      File.basename(@file_location, ".*")
    end
  end

  # typically assumed to be an XML file, parsed as XML
  # but in some cases (for example, web scraping) this needs
  # to be overridden to parse HTML instead
  def parse_markup_lang_file
    CommonXml.create_xml_object(self.file_location)
  end

  def post_es(es)
    error = nil
    begin
      transformed = transform_es
    rescue => e
      "Error transforming ES for #{self.filename(false)}: #{e}"
    end
    if transformed && transformed.length > 0
      transformed.each do |doc|
        id = doc["identifier"]
        # before a document is posted, we need to make sure that the fields validate against the schema
        if es.valid_document?(doc)

          puts "posting #{id}"
          puts "PATH: #{es.index_url}/_doc/#{id}" if options["verbose"]
          # NOTE: If you need to do partial updates rather than replacement of doc
          # you will need to add _update at the end of this URL
          begin
            RestClient.put("#{es.index_url}/_doc/#{id}", doc.to_json, {:content_type => :json } )
          rescue => e
            # byebug
            error = "Error transforming or posting to ES for #{self.filename(false)}: #{e.response}"
          end
        else
          error = "Document #{id} did not validate against the elasticsearch schema"
        end
      end
    else
      error = "No file was transformed"
    end
    error ? { "error" => error } : { "docs" => transformed}
  end

  def post_solr(url=nil)
    url = url || "#{@options['solr_path']}/#{@options['solr_core']}/update"
    transformed = transform_solr
    if transformed.nil?
      return { "error" => "Something is super wrong with transform for solr" }
    elsif transformed.has_key?("error") || !transformed.has_key?("doc")
      err = transformed.has_key?("error") ? transformed["error"] : "No error message returned"
      return { "error" => "Error transforming to Solr for #{self.filename}: #{err}" }
    end
    begin
      solr = SolrPoster.new(url, @options["commit"])
      # Note: only supporting XML for now since solr is considered "deprecated"
      # but can extend in the future if necessary
      res = solr.post_xml(transformed["doc"])
      if res.code == "200"
        solr.commit_solr
        return { "docs" => transformed["doc"] }
      else
        return { "error" => "Error posting to Solr for #{self.filename}: #{res.body}" }
      end
    rescue => e
      return { "error" => "Error posting to Solr for #{self.filename}: #{e.inspect}" }
    end
  end

  def print_es
    json = transform_es
    pretty_json(json)
  end

  def print_solr
    transform_solr
  end

  # these rules apply to all XML files (HTML / TEI / VRA)
  # check specific file_x files for overridden behavior for XML files
  # transforming into elasticsearch, html, and solr
  def transform_es
    es_req = []
    begin
      file_xml = parse_markup_lang_file
      # check if any xpaths hit before continuing
      results = file_xml.xpath(*subdoc_xpaths.keys)
      if results.length == 0
        raise "No possible xpaths found fo file #{self.filename}, check if XML is valid or customize 'subdoc_xpaths' method"
      end
      
      subdoc_xpaths.each do |xpath, classname|
        subdocs = file_xml.xpath(xpath)
        subdocs.each do |subdoc|
          file_transformer = classname.new(subdoc, @options, file_xml, self.filename(false))
          es_req << file_transformer.json
        end
      end
      if @options["output"]
        filepath = "#{@out_es}/#{self.filename(false)}.json"
        File.open(filepath, "w") { |f| f.write(pretty_json(es_req)) }
      end
      return es_req
    rescue => e
      puts "something went wrong transforming #{self.filename}"
      puts e
      puts e.backtrace
      raise e
    end
  end

  def transform_html
    exec_xsl(@file_location, @script_html, "html", @out_html, @options["variables_html"])
  end

  def transform_iiif
    raise "iiif from requested formats (#{transform_types.join(", ")}) is not currently implemented"
  end

  def transform_solr
    puts "transforming #{self.filename} into solr request"
    # this assumes that solr uses XSL transformation
    # make sure to override behavior in CSV / non-XML child classes
    if @options["output"]
      req = exec_xsl(@file_location, @script_solr, "xml", @out_solr, @options["variables_solr"])
    else
      req = exec_xsl(@file_location, @script_solr, "xml", nil, @options["variables_solr"])
    end
    req
  end

  private

  def add_xsl_params_options
    # add several variables to both params objects, unless if they already have a value
    html = @options["variables_html"]
    solr = @options["variables_solr"]

    ["collection", "data_base", "media_base", "environment"].each do |opt|
      html[opt] = @options[opt] if !html.has_key?(opt)
      solr[opt] = @options[opt] if !solr.has_key?(opt)
    end
  end

  # TODO can remove most of these parameters and grab them from instance variables
  def exec_xsl(input, xsl, ext, outpath=nil, params=nil)
    saxon_params = CommonXml.stringify_params(params)
    cmd = "saxon -s:#{input} -xsl:#{xsl}"
    # TODO which way would we rather do this?
    # cmd << " -o:#{outpath}/#{filename(false)}.#{ext}" if outpath
    cmd << " #{saxon_params}"
    cmd << " | tee #{outpath}/#{filename(false)}.#{ext}" if outpath
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

  def pretty_json(json)
    JSON.pretty_generate(json)
  end

  def subdoc_xpaths
    # Override this method per file type in order to add subdocuments
    # for example:
    # {
    #   "/TEI" => TeiToEs,
    #   "//listPerson/person" => TeiToEsPersonography,
    # }
  end

end
