require "json"
require "rest-client"

require_relative "./../elasticsearch.rb"

module Datura::Elasticsearch::Data

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
