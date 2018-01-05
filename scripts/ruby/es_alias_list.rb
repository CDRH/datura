#!/usr/bin/env ruby

require "json"
require "rest-client"

# not currently hooked up to configuration file
# since generally intended to be collection specific
url = "localhost:9200/_aliases"

res = JSON.parse(RestClient.get(url))
puts JSON.pretty_generate(res)
