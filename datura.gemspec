
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "datura/version"

Gem::Specification.new do |spec|
  spec.name          = "datura"
  spec.version       = Datura::VERSION
  spec.authors       = [
                         "Center for Digital Research in the Humanities",
                         "Karin Dalziel",
                         "Jessica Dussault",
                         "Gregory Tunink"
                       ]
  spec.email         = ["cdrhdev@unl.edu"]

  spec.summary       = "CDRH API ingest scripts. Transform data from one format to another and post to Solr / Elasticsearch"
  spec.description   = %q{Input CSV, HTML, TEI, VRA and output HTML and Elasticsearch / Solr ready formats for the CDRH API.}
  spec.homepage      = "https://cdrh.unl.edu"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.executables   = [
    "about",
    "admin_es_create_index",
    "admin_es_delete_index",
    "es_alias_add",
    "es_alias_delete",
    "es_alias_list",
    "es_clear_index",
    "es_get_schema",
    "es_set_schema",
    "post",
    "print_options",
    "setup",
    "solr_clear_index",
    "solr_create_api_core",
    "solr_manage_schema"
  ]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = "~> 2.5"
  spec.add_runtime_dependency "colorize", "~> 0.8.1"
  spec.add_runtime_dependency "nokogiri", "~> 1.8.1"
  spec.add_runtime_dependency "rest-client", "~> 2.0.2"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 10.0"
end
