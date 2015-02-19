require 'fileutils'
require 'yaml'

# This is the most terrifying of functions
def clear_tmp_directory(dir, verbose_flag=false)
  if !dir.nil? && dir.length > 0 && dir != "." && dir != "../"
    # IMPORTANT: Make sure that directory exists or you'll be wiping 
    # something like your /tmp directory which is not desirable.
    puts "Wiping any files in #{dir}/tmp" if verbose_flag
    files = FileUtils.rm_rf(Dir.glob("#{dir}/tmp/*"))
    puts "Removed #{files.length} file(s) from tmp directory" if verbose_flag
  else
    raise "repo_directory is required in config/general.yml file"
  end
end

def create_temp_name(dir, ext)
  time_stamp = Time.now.to_i
  return "#{dir}/tmp/#{time_stamp}.#{ext}"
end

# get_directory_files
#   Note: do not end with /
#   params: directory (string)
#   returns: returns array of all files found ([] if none),
#     returns nil if no directory by that name exists
def get_directory_files(directory)
  exists = File.directory?(directory)
  if exists
    files = Dir["#{directory}/*"]  # grab all the files inside that directory
    return files
  else
    puts "Unable to find a directory at #{directory}."
    return nil
  end
end
# end get_directory_files

# read_configs
#   reads the main config file and extrapolates the project config file from that information
#   params: dir (directory with general config), 
#     project (string of name),
#     verbose_flag (if extra reporting is desired)
#   returns: if unable to read, exits with error, else returns hash
def read_configs(dir, project, verbose_flag=false)
  begin
    config_main = YAML.load_file("#{dir}/../../config/config.yml")
    proj_data = config_main["repo_directory"]
    config_prj = YAML.load_file("#{dir}/../../projects/#{project}/config/config.yml")
    return { :main => config_main, :proj => config_prj }
  rescue Exception => e
    puts "There was an error reading a config file: #{e.message}"
    puts "Stacktrace: \n\t#{e.backtrace.inspect}" if verbose_flag
    exit
  end
end
# end read_configs

# summarize_errors
#   outputs to stdout if there were any errors
#   params: error hash object with :solr_errors and :failed_files arrays
#   returns: nothing of great value
def summarize_errors(errors)
  if errors[:solr_errors].length > 0
    puts "==============================================="
    puts "============  Errors from Solr ================"
    puts "==============================================="
    puts "#{errors[:solr_errors]} solr error(s) reported!"
    puts "#{errors[:solr_errors].join('\n')}"
  end
  if errors[:failed_files].length > 0
    puts "==============================================="
    puts "==============  Failed Files =================="
    puts "==============================================="
    puts "#{errors[:failed_files].length} file(s) failed to upload"
    puts "#{errors[:failed_files].join('\n')}"
  end
end
# end summarize_errors