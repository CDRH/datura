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

  def remove_environment(config)
    to_remove = @environment == "production" ? "development" : "production"
    config.delete(to_remove)
    config[@environment].each do |key, value|
      config[key] = value
    end
    config.delete(@environment)
    return config
  end

  # remove the unneeded environment and put everything at the first level
  # then override general configuration with project specific
  def smash_configs
    config = remove_environment(@general_config.clone)
    tempProj = remove_environment(@project_config.clone)
    config.merge!(tempProj)  # project will override the general ones here
    return config
  end
end
