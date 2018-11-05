module Parser
  def self.es_set_schema_params
    @usage = "Usage: ruby scripts/ruby/es_set_schema.rb collection -e environment"
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
    options["collection_dir"] = Parser.argv_collection_dir(ARGV)
    return options
  end
end
