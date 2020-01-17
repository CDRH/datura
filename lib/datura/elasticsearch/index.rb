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
      doc = schema["mappings"]["_doc"]

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
        regex = "^#{es_match}$"
        regex_pieces << regex
      end
      if !regex_pieces.empty?
        regex_joined = regex_pieces.join("|")
        @schema_mapping["dynamic"] = /#{regex_joined}/
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
    get_schema_mapping if !defined?(@schema_mapping)
    # NOTE: validation only checking the names of fields
    # against the schema, NOT the contents of fields
    # Elasticsearch itself checks that you are sending date
    # formats to date fields, etc

    doc.all? do |field, value|
      if valid_field?(field)
        # great, the field is valid, now check if it is a parent
        nested = Array(value).map do |nested|
          if nested.class == Hash
            nested.keys.all? { |k| valid_field?(k, field) }
          end
        end
        # if the array is empty, ignore it, otherwise find out if any
        # nested fields failed the validate
        nested.compact.all? { |t| t }
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

end
