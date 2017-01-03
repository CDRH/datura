require_relative './helpers.rb'

class Options
  attr_reader :all
  # attr_reader :xsl_params
  # attr_reader :xsl_location

  def initialize(params, general_config_path, project_config_path)
    @directory = File.dirname(__FILE__)
    @project_dir = params["project"]
    @environment = params["environment"]

    # read and store raw config files
    @general_config = read_config(general_config_path)
    @project_config = read_config(project_config_path)
    # make a smushed version that overrides like this: general < project < user specified
    @all = smash_configs.merge!(params)
  end

  # read_config
  #   reads in a yml file or throws an error
  def read_config(path)
    begin
      return config = YAML.load_file(path)
    rescue Exception => e
      raise("There was an error reading config file #{path}: #{e.message}")
    end
  end
  # end read_configs

  def remove_environments(config)
    new_config = {}
    # put the default settings in at base level
    if config.has_key?("default")
      config["default"].each do |key, value|
        new_config[key] = value
      end
    end
    if config.has_key?(@environment)
      config[@environment].each do |key, value|
        new_config[key] = value
      end
    end
    return new_config
  end

  # remove the unneeded environment and put everything at the first level
  # then override general configuration with project specific
  def smash_configs
    config = remove_environments(@general_config)
    tempProj = remove_environments(@project_config)
    config.merge!(tempProj)  # project will override the general ones here
    return config
  end
end
