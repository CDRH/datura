module Parser
  def self.es_set_schema_params
    @usage = "Usage: ruby scripts/ruby/es_set_schema.rb name_of_type"
    options = {}

    optparse = OptionParser.new do |opts|
      opts.banner = @usage

      opts.on( '-h', '--help', 'How does this work?') do
        puts opts
        exit
      end

    end

    optparse.parse!

    if ARGV.length == 1
      options["type"] = ARGV[0]
    elsif ARGV.length > 1
      puts "You can only have one name for a type / collection".red
      puts @usage
      exit
    elsif ARGV.length == 0
      puts "You must list a name for the type / collection".red
      exit
    end

    return options
  end
end
