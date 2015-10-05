require 'fileutils'
require 'yaml'

# get_directory_files
#   Note: do not end with /
#   params: directory (string)
#   returns: returns array of all files found ([] if none),
#     returns nil if no directory by that name exists
def get_directory_files(directory, verbose_flag=false)
  exists = File.directory?(directory)
  if exists
    files = Dir["#{directory}/*"]  # grab all the files inside that directory
    return files
  else
    puts "Unable to find a directory at #{directory}" if verbose_flag
    return nil
  end
end
# end get_directory_files

# regex_files
#   looks through a directory's files for those matching the regex
#   params: files (array of file names), regex (regular expression)
#   returns: array ([] if none matched or if regex is nil)
def regex_files(files, regex=nil)
  array = files.nil? ? [] : files
  if !files.nil? && !regex.nil?
    exp = Regexp.new(regex)
    array = files.select do |file|
      file_name = File.basename(file, ".*")
      match = exp.match(file_name)
      !match.nil?  # return this line
    end
  end
  return array
end

# should_update?
#   determines if a user has changed a file since specified date
#   params: file (string path), since_date (Time format or nil)
#   returns: boolean
def should_update?(file, since_date=nil)
  if since_date.nil?
    # if there is no specified date, then update everything
    return true
  else
    # if a file has been updated since a time specified by user
    file_date = File.mtime(file)
    return file_date > since_date
  end
end
