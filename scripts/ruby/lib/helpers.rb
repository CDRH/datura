require 'fileutils'
require 'net/http'
require 'nokogiri'
require 'yaml'

module Common

  # returns a nokogiri xml object
  def self.convert_tags(xml)
    # italic(s)
    xml.css("hi[rend^='italic']").each do |ele|
      ele.name = "em"
      ele.delete "rend"
    end
    # bold (sometimes they include bold as second part of attr)
    xml.css("hi[rend~='bold']").each do |ele|
      ele.name = "strong"
      ele.delete "rend"
    end
    # underline(d)
    xml.css("hi[rend^='underline']").each do |ele|
      ele.name = "u"
      ele.delete "rend"
    end
    xml = Common.to_display_text(xml)
    return xml
  end

  # wrap in order to make valid xml
  def self.convert_tags_in_string(text)
    xml = Nokogiri::XML("<xml>#{text}</xml>")
    converted = convert_tags(xml)
    return converted.xpath("//xml").inner_html
  end

  def self.create_xml_object(filepath, remove_ns=true)
    file_xml = File.open(filepath) { |f| Nokogiri::XML f }
    # TODO is this a good idea?
    file_xml.remove_namespaces! if remove_ns
    return file_xml
  end

  # pass in a date and identify whether it should be before or after
  # in order to fill in dates (ex: 2014 => 2014-12-31)

  def self.date_display(date, nd_text="N.D.")
    date_hyphen = Common.date_standardize(date)
    if date_hyphen
      y, m, d = date_hyphen.split("-").map { |s| s.to_i }
      date_obj = Date.new(y, m, d)
      return date_obj.strftime("%B %-d, %Y")
    else
      return nd_text
    end
  end

  # automatically defaults to setting incomplete dates to the earliest
  # date (2016-07 becomes 2016-07-01) but pass in "false" in order
  # to set it to the latest available date
  def self.date_standardize(date, before=true)
    return_date = nil
    if date
      y, m, d = date.split(/-|\//)
      if y && y.length == 4
        # use -1 to indicate that this will be the last possible
        m_default = before ? "01" : "-1"
        d_default = before ? "01" : "-1"
        m = m_default if !m
        d = d_default if !d
        # TODO clean this up because man it sucks
        if Date.valid_date?(y.to_i, m.to_i, d.to_i)
          date = Date.new(y.to_i, m.to_i, d.to_i)
          month = date.month.to_s.rjust(2, "0")
          day = date.day.to_s.rjust(2, "0")
          return_date = "#{date.year}-#{month}-#{day}"
        end
      end
    end
    return_date
  end

  def self.normalize_name(abnormal)
    # put in lower case
    # remove starting a, an, or the
    down = abnormal.downcase
    normal = down.gsub(/^the |^a |^an /, "")
    return normal
  end

  # saxon accepts params in following manner
  #   fw=true pb=true figures=false
  def self.stringify_params(param_hash)
    params = ""
    if param_hash
      params = param_hash.map{ |k, v| "#{k}=#{v}" }.join(" ")
    end
    return params
  end

  # replaces normalize-space
  def self.squeeze(string)
    string.strip.gsub(/\s+/, " ")
  end

  def self.to_display_text(aXml)
    # sub <corr>.*</corr> for [.*]
    xml = aXml.dup
    xml.css("corr").each {|e| e.replace("[#{e.text}]") }
    return xml.text
  end

end

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

# get_input
#    gets user input from terminal and won't take
#    no for an answer
def get_input(original_input, msg)
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
def get_url(url)
  url = URI.parse(URI.escape(url))
  res = Net::HTTP.get_response(url)
  return res
end

# make_dirs
#   given any number of paths, creates directories / subdirectories
#   does not wipe content in existing directories
def make_dirs(*args)
  FileUtils.mkdir_p(args)
end

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
