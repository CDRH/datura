module Datura::Parser
  def self.post_params
    @usage = "Usage: post -[options]..."
    options = {}  # will hold all the options passed in by user

    optparse = OptionParser.new do |opts|
      # Set a banner
      opts.banner = @usage

      # set the available options
      opts.on( '-h', '--help', 'Computer, display script options.' ) do
        puts opts
        exit
      end

      options["environment"] = "development"
      opts.on( '-e', '--environment [input]', 'Environment (development, production)') do |input|
        if input && input.length > 0
          options["environment"] = input
        end
      end

      # default to no restricted format
      options["format"] = nil
      opts.on( '-f', '--format [input]', 'Supported formats (csv, ead, html, tei, vra, webs)') do |input|
        if %w[authority annotations].include?(input)
          puts "'authority' and 'annotations' are invalid formats".red
          puts "Please select a supported format or rename your custom format"
          exit
        elsif !%w[csv ead html tei vra webs].include?(input)
          puts "Caution: Requested custom format #{input}.".red
          puts "See FileCustom class for implementation instructions"
        end
        options["format"] = input
      end

      options["commit"] = true
      opts.on('-n', '--no-commit', 'Post files to solr but do not commit') do
        options["commit"] = false
      end

      options["output"] = false
      opts.on('-o', '--output', 'Write solr and elasticsearch docs to file') do
        options["output"] = true
      end

      options["regex"] = nil
      opts.on('-r', '--regex [input]', 'Only post files matching this regex') do |input|
        options["regex"] = input
      end

      options["transform_only"] = false
      opts.on('-t', '--transform-only', 'Do not post to solr / es') do
        options["transform_only"] = true
      end

      options["update_time"] = nil
      opts.on('-u', '--update ["today", 2015-01-01T18:24]', 'Transform and post only new files') do |input|
        if !input || (input != "today" && !input[/\d{4}-\d{1,2}-\d{1,2}(?:T\d{1,2}:\d{2})?/])
          puts "Please specify when files were added".light_yellow
          puts "'today', date (2015-01-01), or date and time (2015-01-01T18:24)".light_yellow
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

      # default to running only elasticsearch if no params passed through
      options["transform_types"] = ["es"]
      opts.on('-x', '--type [input]', 'Transformed output type (es, html, iiif, solr), separate with ,') do |input|
        if input
          options["transform_types"] = input.split(",")
        end
      end
    end

    # magic
    optparse.parse!

    options
  end
end
