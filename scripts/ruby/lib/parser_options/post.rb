module Parser
  def self.post_params
    @usage = "Usage: ruby post.rb [collection] -[options]..."
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
      opts.on( '-f', '--format [input]', 'Restrict to one format (csv, dublin_core, html, tei, vra)') do |input|
        if %w[csv dublic_core html tei vra].include?(input)
          options["format"] = input
        else
          puts "Format #{input} is not recognized.".red
          puts "Allowed formats are csv, dublic_core, html, tei, and vra"
          exit
        end
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
      opts.on('-u', '--update [2015-01-01T18:24]', 'Transform and post only new files') do |input|
        if !input
          puts "Please specify date (req) and time (opt): 2015-01-01T18:24".light_yellow
          exit
        else
          # TODO should verify that this is a correct date and turn it into a time object
          datetime = Parser.timify(input)
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
      opts.on('-x', '--type [input]', 'Transformed output type (es, html, solr), separate with ,') do |input|
        if input
          options["transform_types"] = input.split(",")
        end
      end
    end

    # magic
    optparse.parse!
    options["collection"] = Parser.argv_collections(ARGV)

    return options
  end
end
