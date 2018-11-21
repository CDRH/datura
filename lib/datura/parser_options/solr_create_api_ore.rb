module Datura::Parser
  def self.solr_create_api_core_params
    @usage = "Usage: solr_create_api_core name_of_core"
    options = {}

    optparse = OptionParser.new do |opts|
      opts.banner = @usage

      opts.on( '-h', '--help', 'What do I do?') do
        puts opts
        puts "If you do not put any options, the script will ask you for them"
        exit
      end

      options["environment"] = "development"
      opts.on('-e', '--environment [input]', 'Environment') do |input|
        options["environment"] = input
      end
    end

    optparse.parse!

    if ARGV.length == 1
      options["core"] = ARGV[0]
    elsif ARGV.length > 1
      puts "You can only have one name for a core".red
      puts @usage
      exit
    end

    return options
  end
end
