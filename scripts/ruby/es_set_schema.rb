require "json"
require "rest-client"
require "yaml"

properties = YAML.load_file('config/api_schema.yml')

begin
  RestClient.put(
    "localhost:9200/test1/_mapping/cather?pretty",
    properties.to_json,
    { :content_type => :json }
  )
rescue => e
  puts "Error: #{e.response}"
end