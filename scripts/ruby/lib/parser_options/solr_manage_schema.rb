module Parser
  def self.solr_manage_schema_params
    @usage = "Usage: ruby solr_manage_schema.rb name_of_core -o true -j config/api_schema_solr.json"
    options = {}

    optparse = OptionParser.new do |opts|
      opts.banner = @usage

      opts.on( '-h', '--help', 'How does this work?') do
        puts opts
        exit
      end

      options["json"] = nil
      opts.on('-j', '--json [filepath]', 'Location of JSON schema file') do |input|
        options["json"] = input
      end

      options["override"] = false
      opts.on('-o', '--override [bool]', 'Override existing fields? (t / true)') do |input|
        if input != "false" && input != "f" && input.length > 0
          options["override"] = true
        end
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
