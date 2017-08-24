#!/usr/bin/env ruby

##################
#  Manage Schema  #
##################

require 'json'
require_relative 'lib/helpers.rb'
require_relative 'lib/parser.rb'
require_relative 'lib/solr_poster.rb'

# parse parameters
params = Parser.solr_manage_schema_params

# variables
this_dir = File.dirname(__FILE__)
solr_url = "http://localhost:8983/solr/#{params['core']}/schema"
json_path = File.expand_path(File.join(this_dir, "../../#{params["json"]}"))

puts "You are changing the schema for... "
puts "Core: #{params['core']}"
puts "With JSON file: #{json_path}"
puts "Override set to: #{params['override']}" 

def handle_res(res)
  solr_errors = JSON.parse(res.body)["errors"]
  if res.code != "200" || (solr_errors && solr_errors.length > 0)
    puts "Something went wrong: "
    puts "Code: #{res.code}"
    puts res.body
  end
end

# send GET request for existing schema fields and copyfields
# curl http://localhost:8983/solr/api_austen/schema/fields?wt=json
# curl http://localhost:8983/solr/api_austen/schema/copyfields?wt=json
fields_res = get_url("#{solr_url}/fields?wt=json")
# cfields_res = get_url("#{solr_url}/copyfields?wt=json")

if fields_res.code == "200"
  fields_json = JSON.parse(fields_res.body)
  existing_fields = fields_json["fields"].map do |field|
    field["name"]
  end

  schema = JSON.parse(File.read(json_path))
  solr = SolrPoster.new(solr_url)
  schema["fields"].each do |field|
    update_data = nil
    if existing_fields.include?(field["name"])
      if params["override"]
        puts "Overriding existing field in core #{field['name']}"
        update_data = "{ 'replace-field': #{field.to_json} }"
      else
        puts "Did not override existing field #{field['name']}"
      end
    else
      # add a brand new field
      puts "Adding new field #{field['name']}"
      update_data = "{ 'add-field': #{field.to_json} }"
    end
    if update_data
      res = solr.post_json(update_data)
      handle_res(res)
    end
  end
  schema["copyfields"].each do |cfield|
    # TODO copyfield rules will continue to be added even if they are identical
    # will need to match them and refrain from repushing existing ones
    puts "Adding copy field #{cfield['name']}"
    update_data = "{ 'add-copy-field': #{cfield.to_json} }"
    if update_data
      res = solr.post_json(update_data)
      handle_res(res)
    end
  end
else
  puts "Something went wrong with a request to #{params['core']}!"
  puts "Code: #{fields_res.code}"
  puts fields_res.body
end
