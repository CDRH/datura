require "json"
require "rest-client"
require "yaml"

require_relative "./../elasticsearch.rb"

class Datura::Elasticsearch::Index
  
  attr_reader :schema_mapping

  # if options are passed in, then commandline arguments
  # do not need to be parsed
  def initialize(options = nil)
    if !options
      params = Datura::Parser.es_index
      @options = Datura::Options.new(params).all
    else
      @options = options
    end

    @base_url = File.join(@options["es_path"], @options["es_index"])
    @mapping_url = File.join(@base_url, "_mapping", "_doc?pretty=true")
    @index_url = "#{@base_url}?pretty=true"

    # yaml settings (if exist) and mappings
    @requested_schema = YAML.load_file(@options["es_schema"])
    @schema_mapping = nil
  end

  def create
    json = @requested_schema["settings"].to_json
    puts "Creating ES index for API version #{@options["api_version"]}: #{@index_url}"

    if json && json != "null"
      RestClient.put(@index_url, json, { content_type: :json }) { |res, req, result|
        if result.code == "200"
          puts res
        else
          raise "#{result.code} error creating Elasticsearch index: #{res}"
        end
      }
    else
      RestClient.put(@index_url, nil) { |res, req, result|
        if result.code == "200"
          puts res
        else
          raise "#{result.code} error creating Elasticsearch index: #{res}"
        end
      }
    end
  end

  def delete
    puts "Deleting #{@options["es_index"]} via url #{@index_url}"

    RestClient.delete(@index_url) { |res, req, result|
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
    if !@schema_mapping
      schema = get_schema[@options["es_index"]]
      @schema_mapping["fields"] = schema["mappings"]["properties"].keys
      @schema_mapping["dynamic"] = []
      schema["mappings"]["dynamic_templates"].each do |field_type, info|
        es_match = info["match"].sub("*", ".*")
        regex = /^#{es_match}$/
        @schema_mapping["dynamic"] << info["match"]
      end
      # dynamic fields are listed like *_k and will need
      # to be converted to /_k$/ instead
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

end
