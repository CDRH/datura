#! /Users/jdussault2/.rvm/rubies/ruby-2.1.3/bin/ruby
# #! /usr/local/rvm/rubies/ruby-2.1.3/bin/ruby

#################
# Post to Solr  #
#################

require_relative 'lib/helpers.rb'      # helper functions
require_relative 'lib/parser.rb'       # parses script flags
require_relative 'lib/transformer.rb'  # transforms tei/csv to solr/html
require_relative 'lib/solr_poster.rb'  # posts a string (file) to solr

# variables
this_dir = File.dirname(__FILE__)  # directory containing this script
errors = {}                        # keeper of everything that has gone wrong
errors[:failed_files] = []         # array of strings with file names that did not post
errors[:solr_errors] = []          # array of errors from solr to display at the end

options = post_to_solr_params
project = options[:project]
verbose_flag = options[:verbose] == true  # set verbose flag
env = options[:environment]

config = read_configs(this_dir, project, verbose_flag)
# clear out anything in the tmp directory before doing anything else
dir = config[:main]["repo_directory"]
clear_tmp_directory(dir, verbose_flag)
transform(dir, project, options[:format], config[:main]["xsl_scripts"], options[:update_time], options[:regex], verbose_flag)

# only post to solr if the user has not specified that this should be transform_only
if !options[:transform_only]
  files = get_directory_files("#{dir}/tmp", verbose_flag)
  if files.nil?
    puts "tmp directory in your repository was not found."
    exit
  else
    url = "#{config[:main][env]["solr_path"]}#{config[:proj]["solr_core"]}/update"
    files.each do |file_path|
      # read in each file and post to solr
      file = IO.read(file_path)
      puts "posting data to #{url} from #{file_path}" if verbose_flag
      res = post_xml(url, file)
      if !res.nil?
        if res.code == "200"
          puts "Posted #{file_path} successfully" if verbose_flag
        else
          puts "FAILURE. The request to #{url} returned with an error.  Status #{res.code}"
          errors[:failed_files] << file_path
          errors[:solr_errors] << res.body
        end
      else
        # TODO add a log line
        exit
      end
    end  # ends files each loop

    # commit your changes to solr unless if otherwise specified
    if options[:commit]
      commit_res = commit_solr(url)
      if !commit_res.nil? && !commit_res.body.nil? && commit_res.code != "200"
        errors[:solr_errors] << commit_res.body
      end
    end
    summarize_errors(errors)
    # clear anything written to the tmp directory again
    clear_tmp_directory(dir, verbose_flag)
  end
end # ends posting to solr

