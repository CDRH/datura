require "json"
require "yaml"
require "base64"

require_relative "./../elasticsearch.rb"

class Datura::Elasticsearch::Index
  
  attr_reader :schema_mapping
  attr_reader :index_url

  # if options are passed in, then commandline arguments
  # do not need to be parsed
  def initialize(options = nil, schema_mapping: false)
    if !options
      params = Datura::Parser.es_index
      @options = Datura::Options.new(params).all
    else
      @options = options
    end

    @index_url = File.join(@options["es_path"], @options["es_index"])
    @pretty_url = "#{@index_url}?pretty=true"
    @mapping_url = File.join(@index_url, "_mapping?pretty=true")

    # yaml settings (if exist) and mappings
    @requested_schema = YAML.safe_load_file(@options["es_schema"], permitted_classes: [Symbol])
    @auth_header = Datura::Helpers.construct_auth_header(@options)
    # if requested, grab the mapping currently associated with this index
    # otherwise wait until after the requested schema is loaded
    get_schema_mapping if schema_mapping
  end

  def create
    json = @requested_schema["settings"].to_json
    puts "Creating ES index for API version #{@options["api_version"]}: #{@pretty_url}"
    if json && json != "null"
      response = Datura::Helpers.es_http_request("PUT", @pretty_url,
        body: json,
        headers: @auth_header.merge("Content-Type" => "application/json"))
    else
      response = Datura::Helpers.es_http_request("PUT", @pretty_url,
        headers: @auth_header)
    end
    if response.code == "200"
      puts response.body
    else
      raise "#{response.code} error creating Elasticsearch index: #{response.body}"
    end
  end

  def delete
    puts "Deleting #{@options["es_index"]} via url #{@pretty_url}"

    response = Datura::Helpers.es_http_request("DELETE", @pretty_url,
      headers: @auth_header)
    raise "#{response.code} error deleting Elasticsearch index: #{response.body}" if response.code != "200"
  end

  def get_schema
    response = Datura::Helpers.es_http_request("GET", @mapping_url,
      headers: @auth_header)
    if response.code == "200"
      JSON.parse(response.body)
    else
      raise "#{response.code} error getting Elasticsearch schema: #{response.body}"
    end
  end

  def get_schema_mapping
    # if mapping has not already been set, get the schema and manipulate
    if !defined?(@schema_mapping)
      @schema_mapping = {
        "dynamic" => nil,  # /regex|regex/
        "fields" => [],    # [ fields ]
        "nested" => {}     # { field: [ nested_fields ] }
      }

      schema = get_schema[@options["es_index"]]
      doc = schema["mappings"]
      doc["properties"].each do |field, value|
        @schema_mapping["fields"] << field
        if value["type"] == "nested"
          @schema_mapping["nested"][field] = value["properties"].keys
        end
      end

      regex_pieces = []
      if doc["dynamic_templates"]
        doc["dynamic_templates"].each do |template|
          mapping = template.map { |k,v| v["match"] }.first
          # dynamic fields are listed like *_k and will need
          # to be converted to ^.*_k$, then combined into a mega-regex
          es_match = mapping.sub("*", ".*")
          regex_pieces << es_match
        end
      end
      if !regex_pieces.empty?
        regex_joined = regex_pieces.join("|")
        @schema_mapping["dynamic"] = /^(?:#{regex_joined})$/
      end
    end
    @schema_mapping
  end

  def set_schema
    json = @requested_schema["mappings"].to_json

    puts "Setting schema: #{@mapping_url}"
    response = Datura::Helpers.es_http_request("PUT", @mapping_url,
      body: json,
      headers: @auth_header.merge("Content-Type" => "application/json"))
    if response.code == "200"
      puts response.body
    else
      raise "#{response.code} error setting Elasticsearch schema: #{response.body}"
    end
  end

  # doc: ruby hash corresponding with Elasticsearch document JSON
  def valid_document?(doc)
    get_schema_mapping
    # NOTE: validation only checking the names of fields
    # against the schema, NOT the contents of fields
    # Elasticsearch itself checks that you are sending date
    # formats to date fields, etc

    doc.all? do |field, value|
      if valid_field?(field)
        # great, the field is valid, now check if it is a parent
        Array(value).each do |nested|
          if nested.class == Hash
            if nested.keys.all? { |k| valid_field?(k, field) }
              next
            else
              # if one of the nested hashes fails, it is invalid
              puts "Nested field '#{field}' is invalid"
              return false
            end
          end
        end
        # all nested fields passed, so it is valid
        true
      else
        puts "Field '#{field}' is invalid"
        false
      end
    end
  end

  # if a field, including those inside nested fields,
  # matches a top level field mapping or a dynamic field,
  # they are good to go
  # further, if this is a nested field, they may check
  # to see if the specific nesting mapping validates them
  def valid_field?(field, parent=nil)
    @schema_mapping["fields"].include?(field) ||
      field.match(@schema_mapping["dynamic"]) ||
      valid_nested_field?(field, parent)
  end

  def valid_nested_field?(field, parent)
    parent_mapping = @schema_mapping["nested"][parent]
    parent_mapping.include?(field) if parent_mapping
  end

  def self.clear
    # run the parameters through the option parser
    params = Datura::Parser.clear_index
    options = Datura::Options.new(params).all
    if options["collection"] == "all"
      self.clear_all(options)
    else
      self.clear_index(options)
    end
  end

  private

  def self.build_clear_data(options)
    if options["regex"]
      field = options["field"] || "identifier"
      {
        "query" => {
          "bool" => {
            "must" => [
              { "regexp" => { field => options["regex"] } },
              { "term" => { "collection" => options["collection"] } }
            ]
          }
        }
      }
    else
      {
        "query" => { "term" => { "collection" => options["collection"] } }
      }
    end
  end

  def self.clear_all(options)
    puts "Please verify that you want to clear EVERY ENTRY from the ENTIRE INDEX\n\n"
    puts "== FIELD / REGEX FILTERS NOT AVAILABLE FOR THIS OPTION, YOU'LL WIPE EVERYTHING ==\n\n"
    puts "Running this on something other than your computer's localhost? DON'T."
    puts "Type: 'Yes I'm sure'"
    confirm = STDIN.gets.chomp
    if confirm == "Yes I'm sure"
      url = File.join(options["es_path"], options["es_index"], "_delete_by_query?pretty=true")
      auth_header = Datura::Helpers.construct_auth_header(options)
      json = { "query" => { "match_all" => {} } }
      response = Datura::Helpers.es_http_request("POST", url,
        body: json.to_json,
        headers: auth_header.merge("Content-Type" => "application/json"))
      if response.code == "200"
        puts response.body
      else
        raise "#{response.code} error when clearing entire index: #{response.body}"
      end
    else
      puts "You typed '#{confirm}'. This is incorrect, exiting program"
      exit
    end
  end

  def self.clear_index(options)
    url = File.join(options["es_path"], options["es_index"], "_delete_by_query?pretty=true")
    confirmation = self.confirm_clear(options, url)

    if confirmation
      data = self.build_clear_data(options)
      auth_header = Datura::Helpers.construct_auth_header(options)
      response = Datura::Helpers.es_http_request("POST", url,
        body: data.to_json,
        headers: auth_header.merge("Content-Type" => "application/json"))
      if response.code == "200" || response.code == "201"
        puts response.body
      else
        raise "#{response.code} error when clearing index: #{response.body}"
      end
    else
      puts "come back anytime!"
      exit
    end
  end

  def self.confirm_clear(options, url)
    # verify that the user is really sure about the index they're about to wipe
    puts "Are you sure that you want to remove entries from"
    puts " #{options["collection"]}'s #{options['environment']} environment?"
    puts "url: #{url}"
    puts "y/N"
    answer = STDIN.gets.chomp
    # boolean
    !!(answer =~ /[yY]/)
  end

end
