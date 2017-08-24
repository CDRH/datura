#! /usr/local/rvm/rubies/ruby-2.1.3/bin/ruby

#################
#  Create Core  #
#################

require_relative 'lib/helpers.rb'
require_relative 'lib/parser.rb'

# variables
url = "http://localhost:8983/solr/admin/cores?action=CREATE"

# helpers
def get_input(param, msg)
  if param.nil?
    puts "#{msg}: \n"
    input = STDIN.gets.chomp
    if !input.nil? && input.length > 0
      return input
    else
      # keep bugging the user until they answer or despair
      puts "Please enter a valid response"
      get_input(nil, msg)
    end
  else
    return param
  end
end

# parse incoming options and make sure that they sent in name and configset
params = Parser.solr_create_core_params
core = get_input(params["core"], "Core name")
configset = get_input(params["configset"], "Config set (api_configs, basic_configs)")
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




