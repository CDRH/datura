require "colorize"
require "logger"

require_relative "./requirer.rb"

class EsDataManager
  attr_reader :log
  attr_reader :proj_dir
  attr_reader :repo_dir

  attr_accessor :errors
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
    # combine user input and config files
    params = Parser.post_to_solr_params
    @project = params["project"]
    # assign locations
    @repo_dir = "#{File.dirname(__FILE__)}/../../.."
    @proj_dir = "#{@repo_dir}/projects/#{@project}"
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

  def run
    # log starting information for user
    @log.info(options_msg true)
    puts options_msg @options["verbose"]

    setup_classes
    @files = prepare_files

    # in batches
      # transform to json
      # if requested, write json to project files
      # post json to elastic search if requested
      # transform with xsl to html if requested
    # 
  end


  private

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
    msg << "Posting to:  #{@options['es_path']}\n\n"
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
        file_classes << type.new(f)
      else
        msg = "Could not create filetype #{type}"
        puts msg.red
        @log.error(msg)
      end
    end
    return file_classes
  end

  def setup_classes
    # use configuration specified by user to assign the script paths
    # that will be used by various file types
    EsDataManager.format_to_class.each do |abbrev, classname|
      classname.script_es = @options["#{abbrev}_es_xsl"]
      classname.script_html = @options["#{abbrev}_html_xsl"]
      classname.script_solr = @options["#{abbrev}_solr_xsl"]
    end
    puts FileTei.script_html
  end
end
