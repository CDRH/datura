require_relative "file_type.rb"
require_relative "helpers.rb"
require_relative "options.rb"
require_relative "parser.rb"

current_dir = File.expand_path(File.dirname(__FILE__))

require_relative "to_es/es_request.rb"

# x_to_es classes
Dir["#{current_dir}/to_es/*.rb"].each { |f| require f }
Dir["#{current_dir}/to_es/**/*.rb"].each { |f| require f }

# file types
Dir["#{current_dir}/file_types/*.rb"].each { |f| require f }
