require 'open3'

# TODO if anything is going to be asynchronous, this would be a great spot
def transform(dir, project, format, xslt_location, verbose_flag=false)
  project_path = "#{dir}/projects/#{project}"
  # go check the project directory for files of specific format
  if format.nil? || format == "tei"
    files = get_directory_files("#{project_path}/tei")
    if !files.nil?
      puts "xslt location #{xslt_location['tei']}"
      files.each do |file|
        _transform(file, xslt_location["tei"], dir, verbose_flag)
      end
    end
  end

  if format.nil? || format == "dc"
    files = get_directory_files("#{project_path}/dublin_core")
    if !files.nil?
      puts "xslt location #{xslt_location['dc']}"
      files.each do |file|
        _transform(file, xslt_location["dc"], dir, verbose_flag)
      end
    end
  end

  if format.nil? || format == "vra"
    files = get_directory_files("#{project_path}/vra_core")
    if !files.nil?
      puts "xslt location #{xslt_location['vra']}"
      files.each do |file|
        _transform(file, xslt_location["vra"], dir, verbose_flag)
      end
    end
  end
end

# _transform
#    Transforms xml file with xslt and assigns to tmp file
def _transform(source, xslt, dir, verbose_flag=false)
  output = create_temp_name(dir, "xml")  # name for new file
  saxon = "saxon -s:#{source} -xsl:#{xslt} -o:#{output}"
  # execute the saxon command and make sure that you don't get a stderr!
  Open3.popen3(saxon) do |stdin, stdout, stderr|
    out = stdout.read
    err = stderr.read
    if err.length > 0
      puts "There was an error with the saxon transformation: "
      puts "#{err}"
      exit
    else
      puts "Saxon transformation successful" if verbose_flag
    end
  end
end