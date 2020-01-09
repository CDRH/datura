require "json"
require "rest-client"

require_relative "./../elasticsearch.rb"

module Datura::Elasticsearch::Alias

  def self.add
    params = Datura::Parser.es_alias
    options = Datura::Options.new(params).all

    ali = options["alias"]
    idx = options["index"]

    base_url = File.join(options["es_path"], "_aliases")

    data = {
      actions: [
        { remove: { alias: ali, index: "_all" } },
        { add: { alias: ali, index: idx } }
      ]
    }
    RestClient.post(base_url, data.to_json, { content_type: :json }) { |res, req, result|
      if result.code == "200"
        puts res
        puts "Successfully added alias #{ali}. Current alias list:"
        puts list
      else
        raise "#{result.code} error managing aliases: #{res}"
      end
    }
  end

  def self.delete
    params = Datura::Parser.es_alias
    options = Datura::Options.new(params).all

    ali = options["alias"]
    idx = options["index"]

    url = File.join(options["es_path"], idx, "_alias", ali)

    res = JSON.parse(RestClient.delete(url))
    puts JSON.pretty_generate(res)
    list
  end

  def self.list
    options = Datura::Options.new({}).all

    res = RestClient.get(File.join(options["es_path"], "_aliases"))
    JSON.pretty_generate(JSON.parse(res))
  end

end
