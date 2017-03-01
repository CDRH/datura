require "json"
require "rest-client"
require_relative "lib/requirer.rb"

this_dir = File.dirname(__FILE__)

# run the parameters through the option parser
params = Parser.clear_index_params
options = Options.new(params, "#{this_dir}/../../config", "#{this_dir}/../../projects/#{params['project']}/config").all
project = options["project"]

# verify that the user is really sure about the index they're about to wipe
puts "Are you sure that you want to remove entries from"
puts " #{project}'s #{options['environment']} environment?"
if project == "all"
  puts "CAUTION: this will remove entries across ALL PROJECTS"
end
puts "y/N"
confirm = STDIN.gets.chomp

if confirm && (confirm == "y" || confirm == "Y")
  path = options["es_path"] || "http://localhost:9200"
  path += "/#{options['es_index']}" if options["es_index"]
  url = ""
  if project == "all"
    puts "Please verify that you want to clear EVERY ENTRY from the ENTIRE INDEX"
    puts "Type: 'Yes I'm sure'"
    confirm2 = STDIN.gets.chomp
    if confirm2 == "Yes I'm sure"
      url = "#{path}/_delete_by_query?pretty"
    else
      puts "You typed '#{confirm2}'. This is incorrect, exiting program"
      exit
    end
  else
    url = "#{path}/#{project}/_delete_by_query?pretty"
  end
  puts url

  data = {}
  if options["regex"]
    field = options["field"] || "identifier"
    data = {
      "query" => {
        "regexp" => { field => options["regex"] }
      }
    }
  else
    data = {
      "query" => { "match_all" => {} }
    }
  end
  begin
    puts "clearing: #{data.to_json}"
    res = RestClient.post(url, data.to_json, {:content_type => :json})
    puts res.body
  rescue => e
    puts "error posting to ES: #{e.response}"
  end
else
  puts "okay, come back whenever you like!"
  exit
end
