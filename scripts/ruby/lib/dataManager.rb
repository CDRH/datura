require "colorize"
require "logger"

require_relative "./requirer.rb"

class DataManager
  attr_reader :log
  attr_reader :coll_dir
  attr_reader :repo_dir
  attr_reader :time

  attr_accessor :error_es
  attr_accessor :error_html
  attr_accessor :error_solr

  attr_accessor :files
  attr_accessor :options
  attr_accessor :collection

  def self.format_to_class
    {
      "csv" => FileCsv,
      "dc" => FileDc,
      "tei" => FileTei,
      "vra" => FileVra,
      "yml" => FileYml
    }
  end

  def initialize
    @files = []
    @error_es = []
    @error_html = []
    @error_solr = []
    # combine user input and config files
    params = Parser.post_params
    @collection = params["collection"]
    # assign locations
    @repo_dir = "#{File.dirname(__FILE__)}/../../.."
    @coll_dir = "#{@repo_dir}/collections/#{@collection}"
    load_collection_classes
    # check if collection exists
    if File.directory?(@coll_dir)
      @options = Options.new(params, "#{@repo_dir}/config", "#{@coll_dir}/config").all
      @options["coll_dir"] = @coll_dir
      @options["repo_dir"] = @repo_dir
      @log = Logger.new("#{@repo_dir}/logs/#{@collection}-#{@options['environment']}.log")
      @es_url = "#{@options['es_path']}/#{@options['es_index']}"
      @solr_url = "#{@options['solr_path']}/#{@options['solr_core']}/update"
    else
      puts "Could not find collection directory named '#{@collection}'!".red
      exit
    end
  end

  # NOTE: This step is what allows collection specific files to override ANY
  # of the methods from the scripts/ruby/* files
  def load_collection_classes
    # load collection scripts at this point so they will override
    # any of the default ones (for example: TeiToEs)
    Dir["#{@coll_dir}/scripts/overrides/*.rb"].each do |f|
      require f
    end
  end

  def print_options
    pretty = JSON.pretty_generate(@options)
    puts "Options: #{pretty}"
    return pretty
  end

  def run
    @time = [Time.now]
    # log starting information for user
    @log.info(options_msg)
    puts options_msg

    check_options
    check_schema
    @files = prepare_files
    batch_process_files
    end_run
  end


  private

  # TODO should this move to Options class?
  def assert_option(opt)
    if !@options.has_key?(opt)
      puts "Option #{opt} was not found!  Check config files and add #{opt} to continue".red
      raise "Missing configuration options"
    end
  end

  def batch_process_files
    threads = []
    filesChunked = @files.each_slice(@options["threads"]).to_a
    filesChunked.each do |files_subset|
      threads = files_subset.each_with_index.map do |file, index|
        Thread.new do
          transform_and_post(file)
        end
      end
      # wait for all the files to process before moving on with the next chunk
      threads.each { |t| t.join }
    end
  end

  def check_options
    # verify that everything's all good before moving to per-file level processing
    if should_transform?("es")
      assert_option("es_path")
      assert_option("es_index")
      assert_option("es_type")
    end

    if should_transform?("solr")
      assert_option("solr_core")
      assert_option("solr_path")
    end
  end

  def check_schema
    # if ES is requested and not transform only, then check the schema
    # if there is no schema for this type, shut it all down
    if should_transform?("es") && !@options["transform_only"]
      url = "#{@options["es_path"]}/#{@options["es_index"]}/_mapping/#{@options["es_type"]}?pretty"
      msg = "\nSchema url: #{url}\n"
      begin
        res = RestClient.get(url)
        body = res.body
      rescue => e
        msg << e.to_s.red
        raise msg
      end
      json = JSON.parse(body)
      if json.nil? || json.empty?
        msg << "No schema found for #{@options["es_type"]}\n".red
        msg << "Please check your config file and run the es_set_schema.rb script if necessary"
        raise msg
      end
    end
  end

  def end_run
    # tally errors
    error_msg = ""
    error_msg << "#{@error_es.length} ES transform / post error(s)\n"
    error_msg << "#{@error_html.length} HTML transform error(s)\n"
    error_msg << "#{@error_solr.length} Solr transform / post error(s)\n"
    puts error_msg
    @log.info(error_msg)

    # figure time for running
    @time << Time.now
    dur = @time[1] - @time[0]
    friendly_dur = Time.at(dur).utc.strftime("%H hrs %M mins %S secs")
    puts "Script finished in #{friendly_dur}".cyan
    @log.info("Script finished in #{friendly_dur}")
    @log.close
  end

  def error_with_transform_and_post(e, error_obj)
    error_obj << e
    puts e.red
    @log.error(e)
  end

  def get_files
    formats = []
    if @options["format"]
      formats = [@options["format"]]
    else
      formats = DataManager.format_to_class.keys
    end
    files = []
    formats.each do |format|
      found = get_directory_files("#{@coll_dir}/#{format}")
      files += found if found
    end
    return files
  end

  def options_msg
    msg = "Start Time: #{Time.now}\n"
    msg << "Running script with following options:\n"
    msg << "collection:     #{@options['collection']}\n"
    msg << "Environment: #{@options['environment']}\n"
    msg << "Posting to:  #{@es_url}\n\n" if should_transform?("es")
    msg << "Posting to:  #{@solr_url}\n\n" if should_transform?("solr")
    msg << "Format:      #{@options['format']}\n" if @options["format"]
    msg << "Regex:       #{@options['regex']}\n" if @options["regex"]
    msg << "Update Time: #{@options['update_time']}\n" if @options["update_time"]
    if @options["verbose"]
      print_options
    end
    return msg
  end

  def prepare_files
    files = get_files
    regexed = regex_files(files, @options["regex"])
    filtered = regexed.select { |f| should_update?(f, @options["update_time"]) }

    file_classes = []
    @log.info("After filters (regex, update time), #{filtered.length}/#{files.length} files remaining")
    filtered.each do |f|
      dirname = File.basename(File.dirname(f))
      type = DataManager.format_to_class[dirname]
      if type
        file_classes << type.new(f, @coll_dir, @options)
      else
        msg = "Could not create filetype #{type}"
        puts msg.red
        @log.error(msg)
      end
    end
    return file_classes
  end

  def should_transform?(type)
    # adjust default transformation type in params parser
    return @options["transform_types"].include?(type)
  end

  def transform_and_post(file)

    # elasticsearch
    if should_transform?("es")
      if @options["transform_only"]
        # TODO transformation is not treated the same way here as in
        # most post methods, so having to use try catch block
        begin
          res_es = file.transform_es
        rescue => e
          error_with_transform_and_post("#{e}", @error_es)
        end
      else
        res_es = file.post_es(@es_url)
        if res_es && res_es.has_key?("error")
          error_with_transform_and_post(res_es["error"], @error_es)
        end
      end
    end

    # html
    begin
      res_html = file.transform_html if should_transform?("html")
      if res_html && res_html.has_key?("error")
        error_with_transform_and_post(res_html["error"], @error_html)
      end
    rescue => e
      error_with_transform_and_post("#{e}", @error_html)
    end

    # solr
    if should_transform?("solr")
      if @options["transform_only"]
        res_solr = file.transform_solr
      else
        res_solr = file.post_solr(@solr_url)
      end
      if res_solr && res_solr.has_key?("error")
        error_with_transform_and_post(res_solr["error"], @error_solr)
      end
    end
  end

end
