#! /Users/jdussault2/.rvm/rubies/ruby-2.1.3/bin/ruby
# #! /usr/local/rvm/rubies/ruby-2.1.3/bin/ruby

#################
# Post to Solr  #
#################

require_relative 'lib/helpers.rb'      # helper functions
require_relative 'lib/parser.rb'       # parses script flags
require_relative 'lib/transformer.rb'  # transforms tei / csv to solr format
require_relative 'lib/solr_poster.rb'  # posts a string (file) to solr

# variables
dir = File.dirname(__FILE__)  # directory containing this script
errors = {}                   # keeper of everything that has gone wrong
errors[:failed_files] = []    # array of strings with file names that did not post
errors[:solr_errors] = []     # array of errors from solr to display at the end

# handle the incoming command parameters (-f, -h, etc)
options = handle_parameters
verbose_flag = options[:verbose] == true  # set verbose flag
# Read the config files related to the specified project
config = read_configs(dir, options[:project], verbose_flag)

# Run an XSLT transformation on the docs
transform_to_solr(config, options, dir)

# TODO temp hardcoded
hardcoded_dir = "#{dir}/../../solr/test_data/"
files = get_directory_files(hardcoded_dir)

if files.nil?
  puts "Please check that you have the correct location specified."
  exit
else
  # url = URI.parse("#{config[:main]["server_path"]}#{options[:project]}/update")
  # TODO build real url
  url = "#{config[:main]["server_path"]}jessica_testing/update"
  files.each do |file_path|
    # read in each file and post to solr
    file = IO.read(file_path)

    # create an http / request object and post Solr format XML
    puts "posting data to #{url} from #{file_path}" if verbose_flag
    res = post_xml(url, file)

    if res.code == "200"
      puts "Posted #{file_path} successfully"
    else
      puts "FAILURE. The request to #{url} returned with an error.  Status #{res.code}"
      # puts res.body if options[:verbose]
      errors[:failed_files] << file_path
      errors[:solr_errors] << res.body
    end
  end  # ends files each loop

  # commit to solr
  if options[:commit]
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
    else
      puts "No files were committed to solr because one or more files failed to post."
      exit
    end
  end
  # Report any errors
  summarize_errors(errors)
end

