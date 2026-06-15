require "json"

require_relative "./../elasticsearch.rb"

module Datura::Elasticsearch::Alias

  def self.add
    params = Datura::Parser.es_alias_add
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
    response = Datura::Helpers.es_http_request("POST", base_url,
      body: data.to_json,
      headers: (@auth_header || {}).merge("Content-Type" => "application/json"))
    if response.code == "200"
      puts response.body
      puts "Successfully added alias #{ali}. Current alias list:"
      puts list
    else
      raise "#{response.code} error managing aliases: #{response.body}"
    end
  end

  def self.delete
    params = Datura::Parser.es_alias_add
    options = Datura::Options.new(params).all

    ali = options["alias"]
    idx = options["index"]

    url = File.join(options["es_path"], idx, "_alias", ali)

    response = Datura::Helpers.es_http_request("DELETE", url,
      headers: @auth_header || {})
    puts JSON.pretty_generate(JSON.parse(response.body))
    list
  end

  def self.list
    options = Datura::Options.new({}).all

    auth = Datura::Helpers.construct_auth_header(options)
    response = Datura::Helpers.es_http_request("GET", File.join(options["es_path"], "_aliases"),
      headers: auth)
    JSON.pretty_generate(JSON.parse(response.body))
  end

end
