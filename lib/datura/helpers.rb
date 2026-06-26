require 'fileutils'
require 'net/http'
require 'nokogiri'
require 'shellwords'
require 'yaml'
require 'uri'

module Datura::Helpers

  # date_display
  #   pass in a date and identify whether it should be before or after
  #   in order to fill in dates (ex: 2014 => 2014-12-31)
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
      if y && y.length == 4 && y.to_i.to_s == y
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
      files
    else
      puts "Unable to find a directory at #{directory}" if verbose_flag
      nil
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
        new_input
      else
        # keep bugging the user until they answer or despair
        puts "Please enter a valid response"
        get_input(nil, msg)
      end
    else
      original_input
    end
  end

  # get_url
  #   sends a request to a given url
  def self.get_url(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"
    http.request(Net::HTTP::Get.new(uri.request_uri))
  end

  # make_dirs
  #   given any number of paths, creates directories / subdirectories
  #   does not wipe content in existing directories
  def self.make_dirs(*args)
    FileUtils.mkdir_p(args)
  end

  # normalize_name
  #   lowercase and remove articles from front
  def self.normalize_name(abnormal)
    down = abnormal.downcase
    down.gsub(/^the |^a |^an /, "")
  end

  # normalize_space
  #   imitates xslt fn:normalize-space
  #   removes leading / trailing whitespace, newlines, repeating whitespace, etc
  def self.normalize_space(abnormal)
    if abnormal
      normal = abnormal.strip.gsub(/\s+/, " ")
    end
    normal || abnormal
  end

  # regex_files
  #   looks through a directory's files for those matching the regex
  #   params: files (array of file names), regex (regular expression)
  #   returns: array ([] if none matched or if regex is nil)
  def self.regex_files(files, regex=nil)
    array = files.nil? ? [] : files
    if !files.nil? && !regex.nil?
      exp = validate_regex(regex, "--regex")
      array = files.select do |file|
        file_name = File.basename(file, ".*")
        match = exp.match(file_name)
        !match.nil?  # return this line
      end
    end
    array
  end

  # proceed_files
  #   returns all files from the first file matching the proceed regex onward (inclusive),
  #   preserving directory order and sorting alphabetically within each directory.
  #   Exits with an error if the regex matches zero or more than one file.
  #   params: files (array of file paths), regex (string)
  #   returns: array
  def self.proceed_files(files, regex)
    # Preserve directory order from input list; sort alphabetically within each directory
    sorted = files.group_by { |f| File.dirname(f) }
                  .sort_by { |dir, _| dir }
                  .flat_map { |_, fs| fs.sort_by { |f| File.basename(f, ".*") } }
    exp = validate_regex(regex, "--proceed")
    matches = sorted.select { |f| exp.match(File.basename(f, ".*")) }

    if matches.empty?
      puts "ERROR: --proceed regex '#{regex}' matched no files. Exiting.".red
      exit 1
    elsif matches.length > 1
      names = matches.map { |f| File.basename(f, ".*") }.join(", ")
      puts "ERROR: --proceed regex '#{regex}' matched #{matches.length} files (#{names}). Refine your regex to match exactly one file. Exiting.".red
      exit 1
    end

    proceed_index = sorted.index(matches.first)
    sorted[proceed_index..]
  end

  # checkpoint_path
  #   returns the full path to the proceed checkpoint file
  #   params: options (hash with "collection_dir" and "environment" keys)
  #   returns: string
  def self.checkpoint_path(options)
    File.join(options["collection_dir"], "logs", "proceed_#{options["environment"]}")
  end

  # read_checkpoint
  #   reads the proceed checkpoint file and returns its contents
  #   params: options (hash)
  #   returns: string (basename without extension) or nil if file missing/empty
  def self.read_checkpoint(options)
    path = checkpoint_path(options)
    return nil unless File.exist?(path)
    content = File.read(path).strip
    content.empty? ? nil : content
  end

  # write_checkpoint
  #   writes the basename of the last posted file to the checkpoint file
  #   params: basename (string, filename without extension), options (hash)
  #   returns: nil
  def self.write_checkpoint(basename, options)
    path = checkpoint_path(options)
    File.write(path, "#{basename}\n")
  end

  # clear_checkpoint
  #   writes empty content to the checkpoint file, signaling no resume point
  #   params: options (hash)
  #   returns: nil
  def self.clear_checkpoint(options)
    path = checkpoint_path(options)
    File.write(path, "")
  end

  # should_update?
  #   determines if a user has changed a file since specified date
  #   params: file (string path), since_date (Time format or nil)
  #   returns: boolean
  def self.should_update?(file, since_date=nil)
    if since_date.nil?
      # if there is no specified date, then update everything
      true
    else
      # if a file has been updated since a time specified by user
      file_date = File.mtime(file)
      file_date > since_date
    end
  end

  # validate_regex
  #   compiles a regex string; prints a readable error and exits if invalid
  #   params: regex (string), flag (string, e.g. "--regex" or "--proceed")
  #   returns: Regexp
  def self.validate_regex(regex, flag)
    Regexp.new(regex)
  rescue RegexpError => e
    puts "ERROR: Invalid regex for #{flag} '#{regex}': #{e.message}".red
    exit 1
  end

  def self.construct_auth_header(options)
    username = options["es_user"]
    password = options["es_password"]

    if (username || password) && options["es_path"]&.start_with?("http://")
      warn "[SECURITY WARNING] ES credentials are set but es_path uses unencrypted HTTP. " \
           "Credentials will be transmitted in cleartext. Use HTTPS in production."
    end

    { "Authorization" => "Basic #{Base64::strict_encode64("#{username}:#{password}")}" }
  end

  def self.es_http_request(method, url, body: nil, headers: {})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    req_class = {
      "GET"    => Net::HTTP::Get,
      "PUT"    => Net::HTTP::Put,
      "POST"   => Net::HTTP::Post,
      "DELETE" => Net::HTTP::Delete
    }.fetch(method.upcase)
    req = req_class.new(uri.request_uri)
    headers.each { |k, v| req[k.to_s] = v }
    req.body = body if body

    http.request(req)
  end

  def self.run_omeka_script(script_path, options)
    '''
    Build and run a Python Omeka posting script.

    Handles common CLI flag forwarding (-e, -r, -m).
    Called by bin/post_omeka and bin/post_omeka_html.

    Parameters:
    * script_path - absolute path to the Python script to run
    * options     - hash of parsed CLI options ("environment", "regex", "media_skip")
    '''
    unless File.exist?(script_path)
      puts "Omeka script not found at #{script_path}".red
      return
    end
    command = ["python3", script_path]
    command.append("-e", Shellwords.escape(options["environment"])) if options["environment"]
    command.append("-r", Shellwords.escape(options["regex"])) if options["regex"]
    command.append("-c", Shellwords.escape(options["csv_rows"])) if options["csv_rows"]
    command.append("-f", Shellwords.escape(options["format"])) if options["format"]
    command.append("-m") if options["media_skip"]
    command.append("-j") if options["json_output"]
    system(*command)
  end

end
