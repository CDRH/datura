require "json"
require "rest-client"
require "yaml"

require_relative "lib/parser.rb"

properties = YAML.load_file("config/api_schema.yml")

begin
  params = Parser.es_set_schema_params
  type = params["type"]
  puts "type: #{type}"

  RestClient.put(
    "localhost:9200/test1/_mapping/#{type}?pretty&update_all_types",
    properties.to_json,
    { :content_type => :json }
  )
rescue => e
  puts "Error: #{e.response}"
end
