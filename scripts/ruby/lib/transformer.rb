require 'open3'
require_relative './helpers.rb'

class Transformer

  attr_accessor :saxon_errors
  attr_accessor :solr_errors
  attr_accessor :solr_failed_files

  def initialize(main_directory, project, xslt_location, solr, transform_only, solr_or_html, verbose_flag=false)
    # file locations, etc
    @dir = main_directory
    @project = project
    @project_path = "#{main_directory}/projects/#{project}"
    @xslt_location = xslt_location

    # solr instance
    @solr = solr

    # options
    @solr_html = solr_or_html
    @verbose = verbose_flag
    @transform_only = transform_only

    # error holder
    @saxon_errors = []
    @solr_errors = []
    @solr_failed_files = []
  end

  # expect a specific format -- cannot be "nil" or "all"
  # so this is likely going to be called multiple times
  def transform(format, regex, update_time=nil)
    # depending on the format, treat transformation differently
    # run all types of transformation if the user did not specify
    if format.nil? || format == "tei" 
       @saxon_errors += _transform_tei_html(regex, update_time)
    end
    if (format.nil? || format == "vra") && @solr_html != "html"
      @saxon_errors += _transform_vra(regex, update_time)
    end
    if (format.nil? || format == "dublin_core") && @solr_html != "html"
      @saxon_errors += _transform_dc(regex, update_time)
    end
    # squish out nil values and hope for the best
    return @saxon_errors.compact
  end

  def _transform_tei_html(regex, update_time)
    errors = []
    all_files = get_directory_files("#{@project_path}/tei", @verbose)
    files = regex_files(all_files, regex)
    files.each do |file|
      if should_update?(file, update_time)
        # transform the tei if they requested it
        if @solr_html != "html"
          errors << _transform_and_post(file, @xslt_location["tei"])
        end
        if @solr_html != "solr"
          # make a name for the html snippet and transform it
          file_name = File.basename(file, ".*")
          file_path = "#{@project_path}/html-generated/#{file_name}.txt"
          errors << _transform_and_post(file, @xslt_location["html"], false, file_path)
        end
      end
    end
    return errors
  end

  def _transform_vra(regex, update_time)
    errors = []
    all_files = get_directory_files("#{@project_path}/vra", @verbose)
    files = regex_files(all_files, regex)
    files.each do |file|
      if should_update?(file, update_time)
        errors << _transform_and_post(file, @xslt_location["vra"])
      end
    end
    return errors
  end

  def _transform_dc(regex, update_time)
    errors = []
    all_files = get_directory_files("#{@project_path}/dublin_core", @verbose)
    files = regex_files(all_files, regex)
    files.each do |file|
      if should_update?(file, update_time)
        errors << _transform_and_post(file, @xslt_location["dc"])
      end
    end
    return errors
  end

  # _transform
  #    Transforms xml file with xslt and assigns to tmp file
  def _transform_and_post(source, xslt, for_solr=true, file_path=nil)
    error = nil
    output = file_path.nil? ? create_temp_name(@dir, "xml") : file_path
    xslt_loc = "#{@dir}/#{xslt}"  # make absolute path so that script can be run anywhere
    puts "output file #{output}" if @verbose
    saxon = "saxon -s:#{source} -xsl:#{xslt_loc} -o:#{output}"
    # execute the saxon command and make sure that you don't get a stderr!
    Open3.popen3(saxon) do |stdin, stdout, stderr|
      out = stdout.read
      err = stderr.read
      if err.length > 0
        puts "There was an error with the saxon transformation: "
        puts "#{err}"
        error = source
      else
        puts "Successfully transformed #{source}"
        # now post it to solr if it is not an html snippet and if user did not specify against posting
        if for_solr && !@transform_only
          puts "Posting to solr: #{source}"
          _post(source, output)
        end
      end
    end
    return error
  end

  def _post(source, output)
    solr_res = @solr.post_file(output)
    if solr_res.nil?
      @solr_errors << "There was no content associated with #{source} to post to solr"
    elsif solr_res.code != "200"
      @solr_errors << solr_res.body
      @solr_failed_files << source
    end
  end

end
