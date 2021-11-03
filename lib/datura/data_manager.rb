require "colorize"
require "logger"
require "yaml"
require "byebug"
require_relative "./requirer.rb"

class Datura::DataManager
  attr_reader :log
  attr_reader :time

  attr_accessor :error_es
  attr_accessor :error_html
  attr_accessor :error_iiif
  attr_accessor :error_solr

  attr_accessor :files
  attr_accessor :options
  attr_accessor :collection

  def self.format_to_class
    classes = {
      "csv" => FileCsv,
      "ead" => FileEad,
      "html" => FileHtml,
      "tei" => FileTei,
      "vra" => FileVra,
      "webs" => FileWebs
    }
    classes.default = FileCustom
    classes
  end

  def initialize
    @files = []
    # error tallies
    @error_es = []
    @error_html = []
    @error_iiif = []
    @error_solr = []

    # combine user input and config files
    params = Datura::Parser.post_params
    @options = Datura::Options.new(params).all

    # load xslt defaults, ruby overrides, and set up logging
    prepare_xslt
    load_collection_classes
    set_up_logger
  end

  # NOTE: This step is what allows collection specific files to override ANY
  # of the methods from the scripts/ruby/* files
  def load_collection_classes
    # load collection scripts at this point so they will override
    # any of the default ones (for example: TeiToEs)
    path = File.join(@options["collection_dir"], "scripts", "overrides", "*.rb")
    Dir[path].each do |f|
      require f
    end
  end

  def print_options
    pretty = JSON.pretty_generate(@options)
    puts "Options: #{pretty}"
    pretty
  end

  def run
    @time = [Time.now]
    # log starting information for user
    check_options
    set_up_services

    msg = options_msg
    @log.info(msg)
    puts msg

    pre_file_preparation
    @files = prepare_files
    pre_batch_processing
    batch_process_files
    post_batch_processing
    end_run
  end


  private

  def allowed_files(all_files)
    files = []
    if @options["allowed_files"]
      # read in the file with allowed ids
      begin
        ids = File.readlines(@options["allowed_files"]).map(&:strip)
      rescue => e
        raise "Encountered an error while reading in the allowed ids.\nUnable to continue: #{e}".red
      end
        # if item in all_files does not match the desired list, remove it
        files = all_files.select do |file|
          ids.include?(File.basename(file, ".*"))
        end
    else
      files = all_files
    end
    files
  end

  # TODO should this move to Options class?
  def assert_option(opt)
    if !@options.key?(opt)
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
    if should_post?("es")
      assert_option("es_path")
      assert_option("es_index")
      # options used to obtain the mappings
      assert_option("es_schema_override")
      assert_option("es_schema_path")
      assert_option("api_version")

      assert_option("collection")
    end

    if should_post?("solr")
      assert_option("solr_core")
      assert_option("solr_path")
    end
  end

  def end_run
    # tally errors
    error_msg = ""
    error_msg << "#{@error_es.length} ES transform / post error(s)\n"
    error_msg << "#{@error_html.length} HTML transform error(s)\n"
    error_msg << "#{@error_iiif.length} IIIF Manifest transform error(s)\n"
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
      formats = Datura::DataManager.format_to_class.keys
    end
    files = []
    formats.each do |format|
      found = Datura::Helpers.get_directory_files(File.join(@options["collection_dir"], "source", format))
      files += found if found
    end
    files
  end

  def options_msg
    msg = "Start Time: #{Time.now}\n"
    msg << "Running script with following options:\n"
    msg << "collection:           #{@options['collection']}\n"
    msg << "Environment:          #{@options['environment']}\n"
    msg << "Posting to:           #{@es.index_url}\n\n" if should_post?("es")
    msg << "Posting to:           #{@solr_url}\n\n" if should_post?("solr")
    msg << "Format:               #{@options['format']}\n" if @options["format"]
    msg << "Regex:                #{@options['regex']}\n" if @options["regex"]
    msg << "Allowed Files:        #{@options['allowed_files']}\n" if @options["allowed_files"]
    msg << "Update Time:          #{@options['update_time']}\n" if @options["update_time"]
    if @options["verbose"]
      print_options
    end
    msg
  end

  # override this step in project specific files
  # to manipulate the files and transformations
  # after transform and posting has taken place
  def post_batch_processing
  end

  # override this step in project specific files
  # to manipulate the files before they are transformed
  def pre_batch_processing
    # can access @files array
  end

  # override this step in project specific files to
  # manipulate directory contents, files, etc, before
  # this script begins to read files of various formats
  # for example: scrape content from a website and add
  # to the source/webs directory
  def pre_file_preparation
  end

  def prepare_files
    files = get_files
    # filter by collection list of allowed files
    allowed = allowed_files(files)
    # filter by regex
    regexed = Datura::Helpers.regex_files(allowed, @options["regex"])
    # filter by date
    filtered = regexed.select { |f| Datura::Helpers.should_update?(f, @options["update_time"]) }

    file_classes = []
    @log.info("After filters (regex, update time), #{filtered.length}/#{files.length} files remaining")
    filtered.each do |f|
      dirname = File.basename(File.dirname(f))
      type = Datura::DataManager.format_to_class[dirname]
      if type
        file_classes << type.new(f, @options)
      else
        msg = "Could not create filetype #{type}"
        puts msg.red
        @log.error(msg)
      end
    end
    file_classes
  end

  def prepare_xslt
    # check modification date of gemfile.lock against the hidden script files
    # if gemfile newer, copy the xslt over into the hidden files
    gflock = File.join(@options["collection_dir"], "Gemfile.lock")
    datura_xslt = File.join(@options["datura_dir"], "lib", "xslt/.")
    dest = File.join(@options["collection_dir"], "scripts", ".xslt-datura")

    t1 = File.mtime(gflock) if File.exist?(gflock)
    t2 = File.mtime(dest) if File.exist?(dest)

    if !t1 || !t2 || t1 > t2
      puts "Copying datura XSLT default scripts into collection"
      FileUtils.cp_r(datura_xslt, dest)
    end
  end

  def set_up_logger
    # make directory if one does not already exist
    log_dir = File.join(@options["collection_dir"], "logs")
    FileUtils.mkdir(log_dir) if !File.directory?(log_dir)
    file = File.join(log_dir, "#{@options["environment"]}.log")
    @log = Logger.new(
      file,
      @options["log_old_number"],
      @options["log_size"],
      level: Object.const_get(@options["log_level"])
    )
  end

  def set_up_services
    if should_post?("es")
      # set up elasticsearch instance
      @es = Datura::Elasticsearch::Index.new(@options, schema_mapping: true)
    end

    if should_post?("solr")
      # set up posting URLs
      @solr_url = File.join(options["solr_path"], options["solr_core"], "update")
    end
  end

  def should_post?(type)
    should_transform?(type) && !@options["transform_only"]
  end

  def should_transform?(type)
    # adjust default transformation type in params parser
    @options["transform_types"].include?(type)
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
        res_es = file.post_es(@es)
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

    # iiif
    begin
      res_iiif = file.transform_iiif if should_transform?("iiif")
      if res_iiif && res_iiif.has_key?("error")
        error_with_transform_and_post(res_iiif["error"], @error_iiif)
      end
    rescue => e
      error_with_transform_and_post("#{e}", @error_iiif)
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
