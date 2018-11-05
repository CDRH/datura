module Parser
  def self.es_alias_add
    @usage = "Usage: ruby scripts/ruby/es_alias_add.rb -a alias -i index"
    options = {}

    optparse = OptionParser.new do |opts|
      opts.banner = @usage

      opts.on( '-h', '--help', 'How does this work?') do
        puts opts
        exit
      end

      options["alias"] = nil
      opts.on( '-a', '--alias [input]', 'Alias (cdrhapi-v1') do |input|
        if input && input.length > 0
          options["alias"] = input
        else
          puts "Must specify an alias with -a flag"
          exit
        end
      end

      options["index"] = nil
      opts.on( '-i', '--index [input]', 'Index (cdrhapi-v1.1') do |input|
        if input && input.length > 0
          options["index"] = input
        else
          puts "Must specify an index with -i flag"
          exit
        end
      end

    end

    optparse.parse!
    if options["alias"].nil? || options["index"].nil?
      puts "must specify alias and index with -a and -i, respectively"
      exit
    end
    options
  end
end
