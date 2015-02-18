#! /Users/jdussault2/.rvm/rubies/ruby-2.1.3/bin/ruby
# #! /usr/local/rvm/rubies/ruby-2.1.3/bin/ruby

#################
# Post to Solr  #
#################

require 'net/http'  # used by helpers.rb for http request
require 'optparse'  # used by parser.rb for parameter handling
require 'yaml'      # used to helpers.rb to read config files
require_relative 'helpers.rb'
require_relative 'parser.rb'
require_relative 'transformer.rb'
# TODO might be nice to use ansicolor gem for terminal output

# directory containing this script
dir = File.dirname(__FILE__)

# handle the incoming command parameters (-f, -h, etc)
options = handle_parameters

# Read the config files related to the specified project
config = read_configs(dir, options)

##########################################
# Transform some format to solr readable #
##########################################

# TODO let's pretend it's done already
transform_to_solr(config, options, dir)

###################
# Post files solr #
###################

errors = {}
errors[:failed_files] = []
errors[:solr_errors] = []

# TODO hardcoding this for now
dir_path = "#{dir}/../../solr/test_data/"
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

  # url = URI.parse("#{config[:main]["server_path"]}#{options[:project]}/update")
  url = "#{config[:main]["server_path"]}jessica_testing/update"
  # create an http / request object and post Solr format XML
  puts "posting data to #{url} from #{file_path}" if options[:verbose]
  res = post_xml(url, file)

  if res.code == "200"
    puts "Posted #{file_path} successfully"
  else
    puts "FAILURE. The request to #{url} returned with an error.  Status #{res.code}"
    # puts res.body if options[:verbose]
    errors[:failed_files] << file_path
    errors[:solr_errors] << res.body
  end
  if errors[:failed_files].length == 0
    # create another request and post the commit message
    commit_res = post_xml(url, "<commit/>")
    if commit_res.code == "200"
      puts "SUCCESS! Committed your changes to Solr index"
    else
      puts "UNABLE TO COMMIT YOUR CHANGES TO SOLR."
      puts "Please view in web portal to reattempt commit."
      puts res.body
      errors[:solr_errors] << res.body
    end
  end

  # Report any errors
  summarize_errors(errors)

end


