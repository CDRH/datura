require "json"
require "rest-client"
require "yaml"

require_relative "lib/options.rb"
require_relative "lib/parser.rb"

this_dir = File.dirname(__FILE__)

params = Parser.es_set_schema_params
options = Options.new(params, "#{this_dir}/../../config", "#{this_dir}/../../collections/#{params['collection']}/config").all

begin
  idx = options["es_index"]
  type = options["es_type"]

  url = "#{options["es_path"]}/#{idx}/_mapping/#{type}?pretty"
  puts "environment: #{options["environment"]}"
  res = RestClient.get(url)
  puts res.body
rescue => e
  puts "Error: #{e.response}"
end
