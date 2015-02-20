require 'open3'

# TODO if anything is going to be asynchronous, this would be a great spot
def transform(dir, project, format, xslt_location, update_time, verbose_flag=false)
  project_path = "#{dir}/projects/#{project}"
  log.error("but does this work?")
  # go check the project directory for files of specific format
  if format.nil? || format == "tei"
    files = get_directory_files("#{project_path}/tei", verbose_flag)
    if !files.nil?
      files.each do |file|
        if should_update?(file, update_time)
          # construct a new filename for html generation
          file_name = File.basename(file, ".*")
          file_path = "#{project_path}/html-generated/#{file_name}.html"
          _transform(file, xslt_location["tei"], dir, nil, verbose_flag)
          _transform(file, xslt_location["html"], dir, file_path, verbose_flag)
        else
          puts "file #{file} has not been changed since #{update_time}" if verbose_flag
        end
      end
    end
  end

  if format.nil? || format == "dc"
    files = get_directory_files("#{project_path}/dublin_core", verbose_flag)
    if !files.nil?
      files.each do |file|
        if should_update?(file, update_time)
          _transform(file, xslt_location["dc"], dir, verbose_flag)
        end
      end
    end
  end

  if format.nil? || format == "vra"
    files = get_directory_files("#{project_path}/vra_core", verbose_flag)
    if !files.nil?
      files.each do |file|
        if should_update?(file, update_time)
          _transform(file, xslt_location["vra"], dir, verbose_flag)
        end
      end
    end
  end
end

# _transform
#    Transforms xml file with xslt and assigns to tmp file
def _transform(source, xslt, dir, file_name=nil, verbose_flag=false)
  output = file_name.nil? ? create_temp_name(dir, "xml") : file_name
  puts "output file #{output}" if verbose_flag
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