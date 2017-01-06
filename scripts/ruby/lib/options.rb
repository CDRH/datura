require 'colorize'

require_relative './helpers.rb'

class Options
  attr_reader :all

  def initialize params, general_config_path, project_config_path
    @directory = File.dirname(__FILE__)
    @project_dir = params["project"]
    @environment = params["environment"]

    # read and store raw config files
    read_all_configs general_config_path, project_config_path
    # make a smushed version that overrides like this: general < project < user specified
    @all = smash_configs.merge!(params)
  end

  def print_message variable, name
    if variable
      puts "√ .... found #{name} config".green
    else
      puts "X .... did NOT find #{name} config".light_yellow
    end
  end

  def read_all_configs general, project
    @general_config_pub = read_config "#{general}/public.yml"
    @general_config_priv = read_config "#{general}/private.yml"
    @project_config_pub = read_config "#{project}/public.yml"
    @project_config_priv = read_config "#{project}/private.yml"
    print_message @general_config_pub, "base public"
    print_message @general_config_priv, "base private"
    print_message @project_config_pub, "project public"
    print_message @project_config_priv, "project private"
  end

  # read_config
  #   reads in a yml file, throws an error if cannot read
  def read_config path
    if File.file?(path)
      begin
        return YAML.load_file(path)
      rescue Exception => e
        puts "There was an error reading config file #{path}: #{e.message}"
      end
    end
  end
  # end read_configs

  def remove_environments config
    new_config = {}
    if config
      # add the default settings
      if config.has_key?("default")
        config["default"].each do |key, value|
          new_config[key] = value
        end
      end
      # add the environment settings and override default as needed
      if config.has_key?(@environment)
        config[@environment].each do |key, value|
          new_config[key] = value
        end
      end
    end
    return new_config
  end

  # remove the unneeded environment and put everything at the first level
  # then override general configuration with project specific
  def smash_configs
    # private overrides public general config
    a = remove_environments @general_config_pub
    b = remove_environments @general_config_priv
    general = a.merge(b)

    # private overrides public project config
    c = remove_environments @project_config_pub
    d = remove_environments @project_config_priv
    project = c.merge(d)

    # project overrides general config
    return general.merge(project)
  end

end
