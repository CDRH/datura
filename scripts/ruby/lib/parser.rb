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