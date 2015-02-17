#! /Users/jdussault2/.rvm/rubies/ruby-2.1.3/bin/ruby
# #! /usr/local/rvm/rubies/ruby-2.1.3/bin/ruby

#################
# Post to Solr  #
#################

require 'optparse'
require 'yaml'
require 'net/http'
# TODO might be nice to use ansicolor gem for terminal output

######################
# Handle Parameters  #
######################

usage = "Usage: ruby post_to_solr.rb [project] -[options]..."

options = {}  # will hold all the options passed in by user

optparse = OptionParser.new do |opts|
  # Set a banner
  opts.banner = usage
  # set the available options
  opts.on( '-h', '--help', 'Computer, display script options.' ) do
    puts opts
    exit
  end

  # default format to tei
  options[:format] = "tei"
  opts.on( '-f', '--format [input]', 'Specify format (tei, csv, dublin-core)') do |input|
    if input == "tei" || input == "csv" || input == "dublin-core"
      options[:format] = input
    else
      puts "Format #{input} is not recognized."
      puts "Allowed formats are tei, csv, and dublin-core"
      exit
    end
  end

  options[:verbose] = false
  opts.on( '-v', '--verbose', 'More messages, stacktraces than ever before!') do
    options[:verbose] = true
  end
end

# magic
optparse.parse!

# put this after calling parse! on the incoming option flags
# or the flags will be picked up as args also
if ARGV.length == 0
  puts "CRITICAL ERROR! You must specify a project that you want to post!"
  puts usage
  exit
elsif ARGV.length == 1
  options[:project] = ARGV[0]
else
  # they entered too many projects! (or something else is terribly wrong)
  puts "Captain, sensors detect more than one project!"
  puts usage
  exit
end

puts "Options set:\n\t #{options}" if options[:verbose]

#########################
# Read the config files #
#########################

begin
  config_main = YAML.load_file('../../config/general.yml')
  proj_data = config_main["project_data_dir"]
  # TODO having problems getting this to work
  # config_prj = YAML.load_file("#{proj_data}#{options[:project]}/config.yml")
  config_prj = YAML.load_file("../../projects/#{options[:project]}/config.yml")
rescue Exception => e
  puts "There was an error reading a config file: #{e.message}"
  puts "Stacktrace: \n\t#{e.backtrace.inspect}" if options[:verbose]
  exit
end

##########################################
# Transform some format to solr readable #
##########################################

# TODO let's pretend it's done already


###################
# Post files solr #
###################

errors = {}
errors[:failed_files] = []
errors[:solr_errors] = []

# TODO hardcoding this for now
dir_path = "../../solr/test_data/"
files = Dir["#{dir_path}*"]  # grab all the files inside that directory
if files.length == 0
  puts "There are no files in the directory #{dir_path}. Ending script"
  exit
end
files.each do |file_path|
  # file_path = "../../solr/test_data/Photographs.xml"
  puts "reading from directory #{dir_path}" if options[:verbose]
  file = IO.read(file_path)
  puts "could not find requested file #{file_path}" if file.nil?

  # url = URI.parse("#{config_main["server_path"]}#{options[:project]}/update")
  url = URI.parse("#{config_main["server_path"]}jessica_testing/upd")
  puts "posting data to #{url} from #{file_path}" if options[:verbose]

  # create an http / request object
  http = Net::HTTP.new(url.host, url.port)
  request = Net::HTTP::Post.new(url.request_uri)
  request.body = file
  request["Content-Type"] = "application/xml"

  res = http.request(request)
  if res.code == "200"
    puts "Posted #{file} successfully"
  else
    puts "FAILURE. The request to #{url} returned with an error.  Status #{res.code}"
    puts res.body if options[:verbose]
    errors[:failed_files] << file
    errors[:solr_errors] << res.body
  end
  puts "response from solr post #{res.message}" if options[:verbose]
end





