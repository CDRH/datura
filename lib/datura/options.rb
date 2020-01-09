require 'colorize'

require_relative './helpers.rb'

class Datura::Options
  attr_reader :all

  def initialize(params)
    @environment = params["environment"]
    # paths to the collection and gem directories
    collection_dir = Dir.getwd
    datura_dir = File.join(File.dirname(__FILE__), "..", "..")
    # path to the gem's config files
    general_config_path = File.join(datura_dir, "lib", "config")

    # read and store raw config files
    read_all_configs(general_config_path, File.join(collection_dir, "config"))
    # make a smushed version that overrides like this: general < collection < user specified
    @all = smash_configs.merge!(params)
    # if collection is not specifically set in the configs, then default to the directory name
    @all["collection"] = File.basename(collection_dir) if !@all.key?("collection")
    # include the collection and datura gem directories in the options
    @all["collection_dir"] = collection_dir
    @all["datura_dir"] = datura_dir

    other_configuration
  end

  def es_schema_path
    internal_path = File.join(@all["es_schema_path"], "#{@all["api_version"]}.yml")
    if @all["es_schema_override"]
      File.join(@all["collection_dir"], internal_path)
    else
      File.join(@all["datura_dir"], internal_path)
    end
  end

  # after all options have been flattened, create customization by
  # combining the set options, etc
  def other_configuration
    # put together the elasticsearch schema path
    @all["es_schema"] = es_schema_path
  end

  def print_message(variable, name)
    if variable
      puts "√ .... found #{name} config".green
    else
      puts "X .... did NOT find #{name} config".light_yellow
    end
  end

  def read_all_configs(general, collection)
    @general_config_pub = read_config("#{general}/public.yml")
    @collection_config_pub = read_config("#{collection}/public.yml")
    @collection_config_priv = read_config("#{collection}/private.yml")
    print_message(@general_config_pub, "datura default")
    print_message(@collection_config_pub, "collection public")
    print_message(@collection_config_priv, "collection private")
  end

  # read_config
  #   reads in a yml file, throws an error if cannot read
  def read_config(path)
    if File.file?(path)
      begin
        return YAML.load_file(path)
      rescue Exception => e
        puts "There was an error reading config file #{path}: #{e.message}"
      end
    end
  end
  # end read_configs

  def remove_environments(config)
    new_config = {}
    if config
      # add the default settings
      if config.key?("default")
        config["default"].each do |key, value|
          new_config[key] = value
        end
      end
      # add the environment settings and override default as needed
      if config.key?(@environment)
        config[@environment].each do |key, value|
          new_config[key] = value
        end
      end
    end
    return new_config
  end

  # remove the unneeded environment and put everything at the first level
  # then override general configuration with collection specific
  def smash_configs
    # private overrides public general config
    general = remove_environments(@general_config_pub)

    # private overrides public collection config
    c = remove_environments(@collection_config_pub)
    d = remove_environments(@collection_config_priv)
    collection = c.merge(d)

    # collection overrides general config
    return general.merge(collection)
  end

end
