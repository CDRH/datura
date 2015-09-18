#! /usr/local/rvm/rubies/ruby-2.1.3/bin/ruby

#################
# Post to Solr  #
#################

require 'logger'                       # logging functionality
require_relative 'lib/helpers.rb'      # helper functions
require_relative 'lib/options.rb'      # compiles all the options from configs and user input
require_relative 'lib/parser.rb'       # parses script flags
require_relative 'lib/transformer.rb'  # transforms tei/csv to solr/html
require_relative 'lib/solr_poster.rb'  # posts a string (file) to solr

# variables
this_dir = File.dirname(__FILE__)  # directory containing this script
errors = {}                        # keeper of everything that has gone wrong
errors[:failed_files] = []         # array of strings with file names that did not post
errors[:solr_errors] = []          # array of errors from solr to display at the end

params = post_to_solr_params      # user supplied parameters via command line
options = Options.new(params, "#{this_dir}/../../../config/config.yml", "#{this_dir}/../../../projects/#{options[:project]}/config/config.yml")
project = options[:project]
verbose_flag = options[:verbose] == true  # set verbose flag

repodir = config[:main]["repo_directory"]
log = Logger.new("#{repodir}/logs/#{project}.log", config[:main]["log_old_number"], config[:main]["log_size"])
log.info("===========================================")
log.info("===========================================")
start_time = Time.now
log.info("Starting script at #{start_time}")
log.info("Script running with following options: #{options}")

# create a new solr instance that will be used by the transformer
url = "#{options["solr_path"]}#{options["solr_core"]}/update"
puts "Using solr url: #{url}" if verbose_flag
log.info("Solr URL: #{url}")
solr = SolrPoster.new(url, options[:commit])

# make a new transformer and run it (pass it an instance of solr)
transformer = Transformer.new(repodir, solr, options)
transform_errors = transformer.transform(options[:format], options[:regex], options[:update_time])

# write the saxon errors to a log
if transform_errors.empty?
  msg = "Transformed all specified files for #{project} successfully"
  log.info(msg)
  puts msg
else
  log.error("Failed to transform following files for #{project}: #{transform_errors.join("\n ")}")
  puts "#{transform_errors.length} FILE(S) FAILED TO TRANSFORM."
  puts "Please check the logs for more information."
end

# write the solr errors to a log
solr_errors = transformer.solr_errors.compact
solr_failed = transformer.solr_failed_files
if solr_errors.empty? && solr_failed.empty?
  msg = "Posted all specified files for #{project} successfully"
  log.info(msg)
  puts msg
else
  log.error("Failed to post the following files for #{project}: #{solr_failed.join("\n ")}")
  log.error(solr_errors.join("\n"))
  puts "#{solr_failed.length} FILE(S) FAILED TO POST TO SOLR"
  puts "Please check the logs for more information"
end

# commit your changes to solr unless if otherwise specified
if options[:commit] && options[:solr_or_html] != "html"
  commit_res = solr.commit_solr
  if !commit_res.nil? && !commit_res.body.nil? && commit_res.code != "200"
    errors[:solr_errors] << commit_res.body
    log.error("Failed to commit changes to solr: #{errors[:solr_errors]}")
  end
end

end_time = Time.now
duration = end_time - start_time
friendly_dur = Time.at(duration).utc.strftime("%H hrs %M mins %S secs")
puts "script finished in #{friendly_dur}"
log.info("Script finished running at #{end_time}")
log.info("Script completed in #{friendly_dur}")
log.close

