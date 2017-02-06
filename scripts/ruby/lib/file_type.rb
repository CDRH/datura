require "json"
require "open3"

class FileType

  # general information about file
  attr_reader :file_location
  attr_reader :options
  attr_reader :proj_dir

  # script locations
  attr_accessor :script_es
  attr_accessor :script_html
  attr_accessor :script_solr

  # output directories
  attr_accessor :out_es
  attr_accessor :out_html
  attr_accessor :out_solr

  def initialize location, project_dir, options
    @file_location = location
    @options = options
    # set output directories
    @out_es = "#{project_dir}/es"
    @out_html = "#{project_dir}/html-generated"
    @out_solr = "#{project_dir}/solr"
    # script locations will need to be set in child classes
  end

  def filename ext=true
    if ext
      File.basename(@file_location)
    else
      File.basename(@file_location, ".*")
    end
  end

  def transform_es output=false
    # TODO should there be any default transform behavior at all?
    # each filetype child could have some, but it seems like this
    # won't be able to accommodate dc, vra, tei here alone
  end

  def transform_html
    # TODO will need to make sure the right params are going through
    exec_xsl @file_location, @script_html, @out_html
  end

  def transform_solr output=false
    # this assumes that solr uses XSL transformation
    # make sure to override behavior in CSV / YML child classes
    # TODO make sure the right params are going through
    if output
      return exec_xsl @file_location, @script_solr, @out_solr
    else
      return exec_xsl @file_location, @script_solr
    end
  end

  private

  # TODO will need to make params string at some point
  def exec_xsl input, xsl, output=nil, params=nil
    cmd = "saxon -s:#{input} -xsl:#{xsl}"
    # TODO which way would we rather do this?
    # cmd << " -o:#{output}/#{filename(false)}.txt" if output
    cmd << " #{params}"
    cmd << " | tee #{output}/#{filename(false)}.txt" if output
    puts "using command #{cmd}" if @options["verbose"]
    Open3.popen3(cmd) do |stdin, stdout, stderr|
      out = stdout.read
      err = stderr.read
      if err.length > 0
        msg = "There was an error transforming #{filename}: #{err}"
        puts msg.red
        return { "error" => msg }
      else
        puts "Successfully transformed #{filename}"
        return { "doc" => out }
      end
    end
  end

  def pretty_json json
    JSON.pretty_generate(json)
  end

end
