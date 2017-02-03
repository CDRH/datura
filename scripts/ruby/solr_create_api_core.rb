#! /usr/local/rvm/rubies/ruby-2.1.3/bin/ruby

#################
#  Create Core  #
#################

require_relative 'lib/helpers.rb'
require_relative 'lib/parser.rb'

# variables
configset = "api_configs"
url = "http://localhost:8983/solr/admin/cores?action=CREATE"

# parse incoming options and make sure that they sent in name and configset
params = Parser.create_core_params
core = get_input(params["core"], "Core name")
url += "&name=#{core}&configSet=#{configset}"

res = get_url(url)
if res.code == '200'
  puts "Created core successfully"
  puts res.body
else
  puts "There was a problem with your request"
  puts "Code: #{res.code}"
  puts res.body
end




