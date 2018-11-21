module Datura::Parser
  def self.es_create_delete_index
    @usage = "Usage: admin_es_(create|delete)_index -e environment"
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

    end

    # magic
    optparse.parse!

    options
  end # ends clear_index_params
end
