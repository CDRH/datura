require "json"
require "rest-client"
require "yaml"

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
    @mapping_url = File.join(@index_url, "_mapping", "_doc?pretty=true")

    # yaml settings (if exist) and mappings
    @requested_schema = YAML.load_file(@options["es_schema"])
    # if requested, grab the mapping currently associated with this index
    # otherwise wait until after the requested schema is loaded
    get_schema_mapping if schema_mapping
  end

  def create
    json = @requested_schema["settings"].to_json
    puts "Creating ES index for API version #{@options["api_version"]}: #{@pretty_url}"

    if json && json != "null"
      RestClient.put(@pretty_url, json, { content_type: :json }) { |res, req, result|
        if result.code == "200"
          puts res
        else
          raise "#{result.code} error creating Elasticsearch index: #{res}"
        end
      }
    else
      RestClient.put(@pretty_url, nil) { |res, req, result|
        if result.code == "200"
          puts res
        else
          raise "#{result.code} error creating Elasticsearch index: #{res}"
        end
      }
    end
  end

  def delete
    puts "Deleting #{@options["es_index"]} via url #{@pretty_url}"

    RestClient.delete(@pretty_url) { |res, req, result|
      if result.code != "200"
        raise "#{result.code} error deleting Elasticsearch index: #{res}"
      end
    }
  end

  def get_schema
    RestClient.get(@mapping_url) { |res, req, result|
      if result.code == "200"
        JSON.parse(res)
      else
        raise "#{result.code} error getting Elasticsearch schema: #{res}"
      end
    }
  end

  def get_schema_mapping
    # if mapping has not already been set, get the schema and manipulate
    if !defined?(@schema_mapping)
      @schema_mapping = {
        "dyanmic" => nil,  # /regex|regex/
        "fields" => [],    # [ fields ]
        "nested" => {}     # { field: [ nested_fields ] }
      }

      schema = get_schema[@options["es_index"]]
      if schema == nil || schema == ""
        puts "schema is nil!"
      end
      doc = schema["mappings"]["_doc"]
      puts doc
      doc["properties"].each do |field, value|
        @schema_mapping["fields"] << field
        if value["type"] == "nested"
          @schema_mapping["nested"][field] = value["properties"].keys
        end
      end

      regex_pieces = []
      doc["dynamic_templates"].each do |template|
        mapping = template.map { |k,v| v["match"] }.first
        # dynamic fields are listed like *_k and will need
        # to be converted to ^.*_k$, then combined into a mega-regex
        es_match = mapping.sub("*", ".*")
        regex_pieces << es_match
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
    RestClient.put(@mapping_url, json, { content_type: :json }) { |res, req, result|
      if result.code == "200"
        puts res
      else
        raise "#{result.code} error setting Elasticsearch schema: #{res}"
      end
    }
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
              # if one of the nested hashes fails, it 
              return false
            end
          end
        end
        # all nested fields passed, so it is valid
        true
      else
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
      url = File.join(options["es_path"], options["es_index"], "_doc", "_delete_by_query?pretty=true")
      json = { "query" => { "match_all" => {} } }
      RestClient.post(url, json.to_json, { content_type: :json }) { |res, req, result|
        if result.code == "200"
          puts res
        else
          raise "#{result.code} error when clearing entire index: #{res}"
        end
      }
    else
      puts "You typed '#{confirm}'. This is incorrect, exiting program"
      exit
    end
  end

  def self.clear_index(options)
    url = File.join(options["es_path"], options["es_index"], "_doc", "_delete_by_query?pretty=true")
    confirmation = self.confirm_clear(options, url)

    if confirmation
      data = self.build_clear_data(options)
      RestClient.post(url, data.to_json, { content_type: :json }) { |res, req, result|
        if result.code == "200"
          puts res
        else
          raise "#{result.code} error when clearing index: #{res}"
        end
      }
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
