module Datura::Parser
  def self.es_set_schema_params
    @usage = "Usage: es_set_schema -e environment"
    options = {}

    optparse = OptionParser.new do |opts|
      opts.banner = @usage

      opts.on( '-h', '--help', 'How does this work?') do
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

    optparse.parse!
    options
  end
end
