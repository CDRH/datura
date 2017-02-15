require "colorize"
require "logger"

require_relative "./requirer.rb"

class EsDataManager
  attr_reader :log
  attr_reader :proj_dir
  attr_reader :repo_dir
  attr_reader :time

  attr_accessor :error_es
  attr_accessor :error_html
  attr_accessor :error_solr

  attr_accessor :files
  attr_accessor :options
  attr_accessor :project

  def self.format_to_class
    {
      "csv" => FileCsv,
      "dc" => FileDc,
      "tei" => FileTei,
      "vra" => FileVra,
      "yaml" => FileYaml
    }
  end

  def initialize
    @files = []
    @error_es = []
    @error_html = []
    @error_solr = []
    # combine user input and config files
    # TODO this name is gonna need to change fo sho
    params = Parser.post_params
    @project = params["project"]
    # assign locations
    @repo_dir = "#{File.dirname(__FILE__)}/../../.."
    @proj_dir = "#{@repo_dir}/projects/#{@project}"
    load_project_classes
    # check if project exists
    if File.directory?(@proj_dir)
      @options = Options.new(params, "#{@repo_dir}/config", "#{@proj_dir}/config").all
      @log = Logger.new("#{@repo_dir}/logs/#{@project}-#{@options['environment']}.log")
    else
      puts "Could not find project directory named '#{@project}'!".red
      exit
    end
  end

  def clear
    # TODO this would use the same mechanisms to clear out
    # docs from the index based on field + regex, etc
    # but would not use all of the same parsing options
    # so I'm not sure what the best design would be here
    # (possibly moving some stuff out of the initialization step)
  end

  # TODO should this happen here or in the FileType specific to each one?
  # or maybe just all of them get loaded in the generic FileType class??
  def load_project_classes
    Dir["#{@proj_dir}/scripts/*.rb"].each do |f|
      require f
    end
  end

  def run
    @time = [Time.now]
    # log starting information for user
    @log.info(options_msg true)
    puts options_msg @options["verbose"]
    if options["es_type"]
      @files = prepare_files

      batch_process_files
      end_run
    else
      raise "Check project specific config files for missing 'es_type' ".red
    end
  end


  private

  def batch_process_files
    # in batches
      # transform to json
      # if requested, write json to project files
      # post json to elastic search if requested
      # transform with xsl to html if requested
    #
    threads = []
    filesChunked = @files.each_slice(@options["threads"]).to_a
    filesChunked.each do |files_subset|
      # sleep 2
      threads = files_subset.each_with_index.map do |file, index|
        Thread.new do
          transform_and_post file
        end
      end
      # wait for all the files to process before moving on with the next chunk
      threads.each { |t| t.join }
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

  def get_files
    formats = []
    if @options["format"]
      formats = @options["format"]
    else
      formats = EsDataManager.format_to_class.keys
    end
    files = []
    formats.each do |format|
      found = get_directory_files "#{@proj_dir}/#{format}"
      files += found if found
    end
    return files
  end

  def options_msg all=false
    msg = "Start Time: #{Time.now}\n"
    msg << "Running script with following options:\n"
    msg << "Project:     #{@options['project']}\n"
    msg << "Environment: #{@options['environment']}\n"
    msg << "Posting to:  #{@options['es_path']}/#{@options['es_index']}\n\n"
    msg << "Format:      #{@options['format']}\n" if @options["format"]
    msg << "Regex:       #{@options['regex']}\n" if @options["regex"]
    msg << "Update Time: #{@options['update_time']}\n" if @options["update_time"]
    msg << "All options: #{@options}".light_cyan if all
    return msg
  end

  def prepare_files
    files = get_files
    regexed = regex_files files, @options["regex"]
    filtered = regexed.select { |f| should_update? f, @options["update_time"] }

    file_classes = []
    @log.info("After filters (regex, update time), #{filtered.length}/#{files.length} files remaining")
    filtered.each do |f|
      dirname = File.basename(File.dirname(f))
      type = EsDataManager.format_to_class[dirname]
      if type
        file_classes << type.new(f, @proj_dir, @options)
      else
        msg = "Could not create filetype #{type}"
        puts msg.red
        @log.error(msg)
      end
    end
    return file_classes
  end

  def should_transform type
    return @options["transform_type"].nil? || @options["transform_type"] == type
  end

  def transform_and_post file
    if should_transform("es")
      res = file.post_es
      if res && res.has_key?("error")
        @error_es << res["error"]
        puts res["error"].red
        @log.error(res["error"])
      end
    end

    # TODO finish setting up solr and html stuff
    # file.transform_solr(true) if should_transform("solr")
    # TODO don't post solr if options["transform-only"] is true

    res = file.transform_html if should_transform("html")
    if res && res.has_key?("error")
      @error_html << res["error"]
      @log.error(res["error"])
    end
  end
end
