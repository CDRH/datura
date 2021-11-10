require 'colorize'
require 'optparse'

# require all of the specific parser option sets
Dir["#{File.expand_path(File.dirname(__FILE__))}/parser_options/*.rb"].each {|f| require f }

#####################
#  post_to_solr.rb  #
#####################

module Datura::Parser
  def self.argv_collection_dir(argv)
    collection_dir = nil
    # put this after calling parse! on the incoming option flags
    # or the flags will be picked up as args also
    if argv.length == 0
      puts "Crisis! Oh no! You must specify the collection directory whose contents you wish to post!".red
      puts @usage
      exit
    elsif argv.length == 1
      collection_dir = argv[0]
    else
      # they entered too many collections! (or something else is terribly wrong)
      puts "Captain, sensors detect more than one collection directory requested!".red
      puts @usage
      exit
    end
    collection_dir
  end

  # take a string in utc and create a time object with it
  # Expects something from this format: 2015-01-01T18:24
  def self.timify(time_string)
    datetime = nil
    if time_string == "today"
      # get today's date and then convert it to a time object for comparing
      datetime = Date.today.to_time
    else
      begin
        arr = time_string.split(/[-T:]/)
        # if the y, m, or d are not filled out, return nil
        if arr[0].nil? || arr[1].nil? || arr[2].nil?
          puts "Must enter a valid date with at least YYYY-MM-DD".light_yellow
        else
          # if there are only three, convert to date time
          if arr.length == 3
            datetime = Time.new(arr[0], arr[1], arr[2])
          elsif arr.length == 5 && !arr[3].empty? && !arr[4].empty?
            datetime = Time.new(arr[0], arr[1], arr[2], arr[3], arr[4])
          else
            puts "Unable to understand the entered date time #{time_string}".red
          end
        end
      rescue Exception => e
        puts "Unable to understand entered date time: #{e}".red
      end
    end
    datetime
  end
end
