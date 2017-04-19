require "json"
require "rest-client"
require "yaml"

require_relative "lib/options.rb"
require_relative "lib/parser.rb"

this_dir = File.dirname(__FILE__)

params = Parser.es_set_schema_params
schema = YAML.load_file("config/api_schema.yml")
options = Options.new(params, "#{this_dir}/../../config", "#{this_dir}/../../projects/#{params['project']}/config").all

begin
  idx = options["es_index"]
  type = options["project"]

  url = "#{options["es_path"]}/#{idx}/_mapping/#{type}?pretty&update_all_types"
  puts "environment: #{options["environment"]}"
  puts "Setting schema: #{url}"
  RestClient.put(url, schema.to_json, { :content_type => :json })
rescue => e
  puts "Error: #{e.response}"
end
