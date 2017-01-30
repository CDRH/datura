require_relative "file_type.rb"
require_relative "helpers.rb"
require_relative "options.rb"
require_relative "parser.rb"

# convertors
require_relative "tei_to_es.rb"

# file types
Dir["#{File.expand_path(File.dirname(__FILE__))}/file_types/*.rb"].each {|f| require f }
