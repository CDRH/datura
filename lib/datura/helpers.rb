require 'fileutils'
require 'net/http'
require 'nokogiri'
require 'yaml'

module Datura::Helpers

  # get_directory_files
  #   Note: do not end with /
  #   params: directory (string)
  #   returns: returns array of all files found ([] if none),
  #     returns nil if no directory by that name exists
  def self.date_display(date, nd_text="N.D.")
    date_hyphen = self.date_standardize(date)
    if date_hyphen
      y, m, d = date_hyphen.split("-").map { |s| s.to_i }
      date_obj = Date.new(y, m, d)
      date_obj.strftime("%B %-d, %Y")
    else
      nd_text
    end
  end

  # date_standardize
  #   automatically defaults to setting incomplete dates to the earliest
  #   date (2016-07 becomes 2016-07-01) but pass in "false" in order
  #   to set it to the latest available date
  def self.date_standardize(date, before=true)
    if date
      y, m, d = date.split(/-|\//)
      if y && y.length == 4
        # use -1 to indicate that this will be the last possible
        m_default = before ? "01" : "-1"
        d_default = before ? "01" : "-1"
        m = m_default if !m
        d = d_default if !d
        if Date.valid_date?(y.to_i, m.to_i, d.to_i)
          date = Date.new(y.to_i, m.to_i, d.to_i)
          date.strftime("%Y-%m-%d")
        end
      end
    end
  end
  
  def self.get_directory_files(directory, verbose_flag=false)
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

  # get_input
  #    gets user input from terminal and won't take
  #    no for an answer
  def self.get_input(original_input, msg)
    if original_input.nil?
      puts "#{msg}: \n"
      new_input = STDIN.gets.chomp
      if !new_input.nil? && new_input.length > 0
        return new_input
      else
        # keep bugging the user until they answer or despair
        puts "Please enter a valid response"
        get_input(nil, msg)
      end
    else
      return original_input
    end
  end

  # get_url
  #   sends a request to a given url
  def self.get_url(url)
    url = URI.parse(url)
    Net::HTTP.get_response(url)
  end

  # make_dirs
  #   given any number of paths, creates directories / subdirectories
  #   does not wipe content in existing directories
  def self.make_dirs(*args)
    FileUtils.mkdir_p(args)
  end

  # regex_files
  #   looks through a directory's files for those matching the regex
  #   params: files (array of file names), regex (regular expression)
  #   returns: array ([] if none matched or if regex is nil)
  def self.regex_files(files, regex=nil)
    array = files.nil? ? [] : files
    if !files.nil? && !regex.nil?
      exp = Regexp.new(regex)
      array = files.select do |file|
        file_name = File.basename(file, ".*")
        match = exp.match(file_name)
        !match.nil?  # return this line
      end
    end
    array
  end

  # should_update?
  #   determines if a user has changed a file since specified date
  #   params: file (string path), since_date (Time format or nil)
  #   returns: boolean
  def self.should_update?(file, since_date=nil)
    if since_date.nil?
      # if there is no specified date, then update everything
      return true
    else
      # if a file has been updated since a time specified by user
      file_date = File.mtime(file)
      return file_date > since_date
    end
  end

end
