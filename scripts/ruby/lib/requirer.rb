require_relative "file_type.rb"
require_relative "helpers.rb"
require_relative "options.rb"
require_relative "parser.rb"

current_dir = File.expand_path(File.dirname(__FILE__))

require_relative "to_es/tei_to_es.rb"
require_relative "to_es/tei_to_es/tei_to_es_personography.rb"

require_relative "to_es/vra_to_es.rb"
require_relative "to_es/vra_to_es/vra_to_es_personography.rb"

# Dir["#{current_dir}/tei_to_es/*.rb"].each {|f| require f }

# file types
Dir["#{current_dir}/file_types/*.rb"].each {|f| require f }
