#!/usr/bin/env ruby

require "json"
require "rest-client"

require_relative "lib/parser.rb"

params = Parser.es_alias_add
# Note: hardcoded path
es_path = "localhost:9200"

ali = params["alias"]
idx = params["index"]
url = "#{es_path}/_aliases"

data = {
  actions: [
    { remove: { alias: ali, index: "_all" } },
    { add: { alias: ali, index: idx } }
  ]
}

begin
  res = RestClient.post(url, data.to_json, { content_type: :json })
  puts "Results of setting alias #{ali} to index #{idx}"
  puts res
  list = JSON.parse(RestClient.get("#{url}"))
  puts "\nAll aliases: #{JSON.pretty_generate(list)}"
rescue => e
  puts "Error: #{e.response}"
end
