#! /Users/jdussault2/.rvm/rubies/ruby-2.1.3/bin/ruby
# #! /usr/local/rvm/rubies/ruby-2.1.3/bin/ruby

##################
#  Manage Index  #
##################

require_relative 'lib/helpers.rb'      # helper functions
require_relative 'lib/parser.rb'       # parses script flags
require_relative 'lib/solr_poster.rb'  # posts a string (file) to solr

this_dir = File.dirname(__FILE__)

# run the parameters through the option parser
options = clear_index_params
env = options[:environment]

# verify that the user is really sure about the index they're about to wipe
puts "Are you sure that you want to remove entries from"
puts " #{options[:project]}'s #{options[:environment]} environment?"
puts "y/N"
confirm = STDIN.gets.chomp
if confirm && (confirm == "y" || confirm == "Y" || confirm == "Yes" || confirm == "yes")
  config = read_configs(this_dir, options[:project])
  url = "#{config[:main][env]["solr_path"]}#{config[:proj]["solr_core"]}/update"
  if !options[:regex].nil?
    field = options[:field].nil? ? "id" : options[:field]
    res = clear_index_by_regex(url, field, options[:regex])
  else
    res = clear_index(url)
  end
  commit_res = commit_solr(url)
else
  puts "exiting"
  exit
end 

# TODO add more options like only removing certain things from index, etc