require 'open3'
require_relative './helpers.rb'

class Transformer

  attr_accessor :saxon_errors
  attr_accessor :solr_errors
  attr_accessor :solr_failed_files

  def initialize(main_directory, solr, options)
    # file locations, etc
    @dir = main_directory
    @project = options["project"]
    @project_path = "#{main_directory}/projects/#{@project}"
    @options = options

    # solr instance
    @solr = solr

    # options
    @solr_html = @options["solr_or_html"]
    @verbose = @options["verbose"]
    @transform_only = @options["transform_only"]
    @format = @options["format"]
    @regex = @options["regex"]
    @update_time = @options["update_time"] || nil

    # xsl parameters
    @xslt_param_json = options["xsl_params"]
    @xslt_param_string = _stringify_params(options["xsl_params"])

    # error holder
    @saxon_errors = []
    @solr_errors = []
    @solr_failed_files = []
  end

  # expect a specific format -- cannot be "nil" or "all"
  # so this is likely going to be called multiple times
  def transform_all
    if @format.nil? || @format == "tei" 
       @saxon_errors += _transform_tei_html
    end
    if (@format.nil? || @format == "vra") && @solr_html != "html"
      @saxon_errors += _transform_vra
    end
    if (@format.nil? || @format == "dublin_core") && @solr_html != "html"
      @saxon_errors += _transform_dc
    end
    if @format.nil? || @format == "csv"
      @saxon_errors += _transform_csv
    end
    # squish out nil values and hope for the best
    return @saxon_errors.compact
  end

  def _stringify_params(param_hash)
    params = ""
    if !param_hash.nil?
      params = param_hash.map{|key, value| "#{key}=#{value}" }.join(" ")
    end
    return params
  end

  def _transform_csv
    errors = []
    all_files = get_directory_files("#{@project_path}/csv", @verbose)
    files = regex_files(all_files, @regex)
    if files && files.length >> 0
      require_relative "../../../#{@options['csv_html']}"
      require_relative "../../../#{@dir}/#{@options['csv_solr']}"
    end
    files.each do |file|
      if should_update?(file, @update_time)
        if @solr_html != "html"
          # transform and post to solr
          errors << _transform_csv_and_post(file)
        end
        if @solr_html != "solr"
          # generate html
          errors << _transform_csv_and_post(file, false)
        end
      end
    end
    return errors
  end

  def _transform_csv_and_post(file, for_solr=true)
    file_name = File.basename(file, ".*")
    output = "#{@project_path}/html-generated"
    if for_solr && !@transform_only
      transformed = csv_to_solr(file, @xslt_param_json)
      solr_res = @solr.post_xml(transformed)
      if solr_res.code == "200"
        puts "File #{file_name} successfully posted to solr (not committed)" if @verbose
      else
        puts "ERROR: file #{file_name} not committed to solr (received code #{solr_res.code})"
        puts "HTTP RESPONSE: #{solr_res.inspect}" 
        @solr_failed_files << file_name
        @solr_errors << solr_res.inspect
      end
    else
      # transform and write html to file
      transformed = csv_to_html(file, @xslt_param_json, output)
    end
    # need to figure out a good way of returning errors
    return nil
  end

  def _transform_tei_html
    errors = []
    all_files = get_directory_files("#{@project_path}/tei", @verbose)
    files_to_run = regex_files(all_files, @regex)
    # Start an asynchronous process so that it doesn't wait for each
    # file before continuing on
    filesChunked = files_to_run.each_slice(50).to_a
    filesChunked.each do |files_subset|
      threads = files_subset.each_with_index.map do |file, index|
        Thread.new do
          if should_update?(file, @update_time)
            # Uncomment to see which file is currently getting sucked in
            puts "Threading file number: #{files_subset.find_index(file)}"
            # transform the tei if they requested it
            if @solr_html != "html"
              errors << _transform_and_post(file, @options["tei_xsl"])
            end
            if @solr_html != "solr"
              # make a name for the html snippet and transform it
              file_name = File.basename(file, ".*")
              file_path = "#{@project_path}/html-generated/#{file_name}.txt"
              errors << _transform_and_post(file, @options["html_xsl"], false, file_path)
            end
          end
        end
      end
      # wait for all the files to process before moving on with the script
      threads.each {|t| t.join}
    end
    return errors
  end

  def _transform_vra
    errors = []
    all_files = get_directory_files("#{@project_path}/vra", @verbose)
    files = regex_files(all_files, @regex)
    files.each do |file|
      if should_update?(file, @update_time)
        errors << _transform_and_post(file, @options["vra_xsl"])
      end
    end
    return errors
  end

  def _transform_dc
    errors = []
    all_files = get_directory_files("#{@project_path}/dublin_core", @verbose)
    files = regex_files(all_files, @regex)
    files.each do |file|
      if should_update?(file, @update_time)
        errors << _transform_and_post(file, @options["dc_xsl"])
      end
    end
    return errors
  end

  # _transform_and_post
  #    Transforms xml file with xslt and posts to solr
  def _transform_and_post(source, xslt, for_solr=true, file_path=nil)
    error = nil
    xslt_loc = "#{@dir}/#{xslt}"  # make absolute path so that script can be run anywhere
    puts "Saxon parameters: #{@xslt_param_string}" if @verbose
    saxon = ""
    if !file_path.nil?
      puts "Transforming #{source} to #{file_path}"
      saxon = "saxon -s:#{source} -xsl:#{xslt_loc} -o:#{file_path} #{@xslt_param_string}"
    else
      puts "Transforming #{source}"
      saxon = "saxon -s:#{source} -xsl:#{xslt_loc} #{@xslt_param_string}"
    end
    puts "transformation line: #{saxon}" if @verbose
    # execute the saxon command and make sure that you don't get a stderr!
    Open3.popen3(saxon) do |stdin, stdout, stderr|
      out = stdout.read
      err = stderr.read
      if err.length > 0
        puts "There was an error transforming #{source}: "
        puts "#{err}"
        error = source
      else
        puts "Successfully transformed #{source}"
        # now post it to solr if it is not an html snippet and if user did not specify against posting
        # TODO I do not like that this posting is happening here or that @solr is a thing in the transformer
        if for_solr && !@transform_only
          solr_res = @solr.post_xml(out)
          if solr_res.code == "200"
            puts "File #{source} successfully posted to solr (not committed)" if @verbose
            return nil  # no errors
          else
            puts "ERROR: file #{source} not committed to solr (received code #{solr_res.code})"
            puts "HTTP RESPONSE: #{solr_res.inspect}"	
            @solr_failed_files << source
            @solr_errors << solr_res.inspect
          end
        end
      end
    end
    return error
  end

end
