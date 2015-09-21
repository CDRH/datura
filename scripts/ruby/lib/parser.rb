require 'optparse'

# this function is specific to the post_to_solr.rb script
# and so will exit if required parameters are not met
# TODO use OptionParser::MissingArgument exception?

# returns options hash

def post_to_solr_params
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

    options["environment"] = "development"
    opts.on( '-e', '--environment [input]', 'Environment (development, production)') do |input|
      if input == "development" || input == "production"
        options["environment"] = input
      else
        puts "Must choose environment of development or production"
        exit
      end
    end

    # default to no restricted format
    options["format"] = nil
    opts.on( '-f', '--format [input]', 'Restrict to one format (tei, csv, dublin-core, vra)') do |input|
      if input == "tei" || input == "csv" || input == "dublin-core" || input == "vra"
        options["format"] = input
      else
        puts "Format #{input} is not recognized."
        puts "Allowed formats are tei, csv, vra, and dublin-core"
        exit
      end
    end

    options["solr_or_html"] = nil
    opts.on('-x', '--html-only', 'Will not generate solr snippets, only html') do
      options["solr_or_html"] = "html"
    end

    options["commit"] = true
    opts.on('-n', '--no-commit', 'Post files to solr but do not commit') do
      options["commit"] = false
    end

    options["regex"] = nil
    opts.on('-r', '--regex [input]', 'Only post files matching this regex') do |input|
      options["regex"] = input
    end

    opts.on('-s', '--solr-only', 'Will not generate html snippets') do
      # if they also entered html only, go ahead and run them both because the user is confused
      options["solr_or_html"] = options["solr_or_html"] == "html" ? "both" : "solr"
    end

    options["transform_only"] = false
    opts.on('-t', '--transform-only', 'Do not post to solr or erase tmp/') do
      options["transform_only"] = true
    end

    options["update_time"] = nil
    opts.on('-u', '--update [2015-01-01T18:24]', 'Transform and post only new files') do |input|
      if input.length == 0
        puts "Please specify date (req) and time (opt): 2015-01-01T18:24"
        exit
      else
        # TODO should verify that this is a correct date and turn it into a time object
        datetime = timify(input)
        if datetime.nil?
          exit
        else
          options["update_time"] = datetime
        end
      end
    end

    options["verbose"] = false
    opts.on( '-v', '--verbose', 'More messages and stacktraces than ever before!') do
      options["verbose"] = true
    end
  end

  # magic
  optparse.parse!

  options["project"] = argv_projects(ARGV)
  puts "User entered parameters:\n\t #{options}" if options["verbose"]

  return options
end

def clear_index_params
  usage = "Usage: ruby clear_index.rb [project] -[options]..."
  options = {}  # will hold all the options passed in by user

  optparse = OptionParser.new do |opts|
    # Set a banner
    opts.banner = usage

    # set the available options
    opts.on( '-h', '--help', 'Computer, display script options.' ) do
      puts opts
      exit
    end

    options["environment"] = "development"
    opts.on( '-e', '--environment [input]', 'Environment (development, production)') do |input|
      if input == "development" || input == "production"
        options["environment"] = input
      else
        puts "Must choose environment of development or production"
        exit
      end
    end

    options["field"] = nil
    opts.on('-f', '--field [input]', 'The specific field regex is run on') do |input|
      options["field"] = input
    end

    options["regex"] = nil
    opts.on('-r', '--regex [input]', 'Used as criteria for removing item (books.*, etc') do |input|
      options["regex"] = input
    end
  end

  # magic
  optparse.parse!

  options["project"] = argv_projects(ARGV)

  return options
end # ends clear_index_params

# helpers

def argv_projects(argv)
  project = nil
  # put this after calling parse! on the incoming option flags
  # or the flags will be picked up as args also
  if argv.length == 0
    puts "Crisis! Oh no! You must specify a project that you want to post!"
    puts usage
    exit
  elsif argv.length == 1
    project = argv[0]
  else
    # they entered too many projects! (or something else is terribly wrong)
    puts "Captain, sensors detect more than one project requested!"
    puts usage
    exit
  end
  return project
end

# take a string in utc and create a time object with it
# Expects something from this format: 2015-01-01T18:24
def timify(time_string)
  datetime = nil
  begin
    arr = time_string.split(/[-T:]/)
    # if the y, m, or d are not filled out, return nil
    if arr[0].nil? || arr[1].nil? || arr[2].nil?
      puts "Must enter a valid date with at least YYYY-MM-DD"
    else
      # if there are only three, convert to date time
      if arr.length == 3
        datetime = Time.new(arr[0], arr[1], arr[2])
      elsif arr.length == 5 && !arr[3].empty? && !arr[4].empty?
        datetime = Time.new(arr[0], arr[1], arr[2], arr[3], arr[4])
      else
        puts "Unable to understand the entered date time."
      end
    end
  rescue Exception => e
    puts "Unable to understand entered date time: #{e}"
  end
  return datetime
end
