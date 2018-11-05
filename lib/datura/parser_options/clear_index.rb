module Datura::Parser
  def self.clear_index_params
    @usage = "Usage: clear_index -[options]..."
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

    options
  end # ends clear_index_params
end
