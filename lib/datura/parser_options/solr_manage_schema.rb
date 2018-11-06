module Datura::Parser
  def self.solr_manage_schema_params
    @usage = "Usage: solr_manage_schema -o true -j config/name_of_schema_file.json"
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

    return options
  end
end
