require "json"
require "rest-client"
require "yaml"

require_relative "./../elasticsearch.rb"

class Datura::Elasticsearch::Index
  
  def initialize
    params = Datura::Parser.es_index
    @options = Datura::Options.new(params).all

    @base_url = File.join(@options["es_path"], @options["es_index"])
    @mapping_url = File.join(@base_url, "_mapping", "_doc?pretty=true")
    @index_url = "#{@base_url}?pretty=true"

    # yaml settings (if exist) and mappings
    @schema = YAML.load_file(@options["es_schema"])
  end

  def create
    json = @schema["settings"].to_json
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
        puts res
      else
        raise "#{result.code} error getting Elasticsearch schema: #{res}"
      end
    }
  end

  def set_schema
    json = @schema["mappings"].to_json

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
