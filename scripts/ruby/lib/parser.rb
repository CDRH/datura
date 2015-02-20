require 'optparse'

# this function is specific to the post_to_solr.rb script
# and so will exit if required parameters are not met
# TODO use OptionParser::MissingArgument exception?

# returns options hash

def handle_parameters
  usage = "Usage: ruby post_to_solr.rb [project] -[options]..."
  options = {}  # will hold all the options passed in by user

  optparse = OptionParser.new do |opts|
    # Set a banner
    opts.banner = usage

    # set the available options
    opts.on( '-h', '--help', 'Computer, display script options.' ) do
      puts opts
      exit
    end

    options[:environment] = "test"
    opts.on( '-e', '--environment [input]', 'Environment (test, production)') do |input|
      if input == "test" || input == "production"
        options[:environment] = input
      else
        puts "Must choose environment of test or production"
        exit
      end
    end

    # default to no restricted format
    options[:format] = nil
    opts.on( '-f', '--format [input]', 'Restrict to one format (tei, csv, dublin-core)') do |input|
      if input == "tei" || input == "csv" || input == "dublin-core"
        options[:format] = input
      else
        puts "Format #{input} is not recognized."
        puts "Allowed formats are tei, csv, and dublin-core"
        exit
      end
    end

    options[:commit] = true
    opts.on('-n', '--no-commit', 'Post files to solr but do not commit') do
      options[:commit] = false
    end

    options[:transform_only] = false
    opts.on('-t', '--transform-only', 'Do not post to solr or erase tmp/') do
      options[:transform_only] = true
    end

    options[:update_time] = nil
    opts.on('-', '--update [2015-01-01T18:24]', 'Transform and post only new files') do |input|
      if input.length == 0
        puts "Please specify date (req) and time (opt): 2015-01-01T18:24"
        exit
      else
        # TODO should verify that this is a correct date and turn it into a time object
        datetime = timify(input)
        if datetime.nil?
          exit
        else
          options[:update_time] = datetime
        end
      end
    end

    options[:verbose] = false
    opts.on( '-v', '--verbose', 'More messages and stacktraces than ever before!') do
      options[:verbose] = true
    end
  end

  # magic
  optparse.parse!



  # put this after calling parse! on the incoming option flags
  # or the flags will be picked up as args also
  if ARGV.length == 0
    puts "CRITICAL ERROR! You must specify a project that you want to post!"
    puts usage
    exit
  elsif ARGV.length == 1
    options[:project] = ARGV[0]
  else
    # they entered too many projects! (or something else is terribly wrong)
    puts "Captain, sensors detect more than one project!"
    puts usage
    exit
  end

  puts "Options set:\n\t #{options}" if options[:verbose]

  return options
end

# helpers

# take a string in utc and create a time object with it
# Expects something from this format: 2015-01-01T18:24
def timify(time_string)
  datetime = nil
  begin
    arr = time_string.split(/[-T:]/)
    # if the y, m, or d are not filled out, return nil
    if arr[0].empty? || arr[1].empty? || arr[2].empty?
      puts "Must enter a valid date"
    else
      # if there are only three, convert to date time
      if arr.length == 3
        datetime = Time.new(arr[0], arr[1], arr[2])
      elsif arr.length == 5 && !arr[3].empty? && !arr[4].empty?
        datetime = Time.new(arr[0], arr[1], arr[2], arr[3], arr[4])
      else
        puts "Unable to understand the entered date."
      end
    end
  rescue Exception => e
    puts "Unable to understand entered date time: #{e}"
  end
  return datetime
end