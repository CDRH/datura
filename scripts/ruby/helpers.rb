# requires 'net/http'


# post_xml
#   posts a request with an xml body
#   params: url_string ("http://www.hello.com"), content: "<xml>Stuff</xml>"
#   returns: a response object that can be used with http
def post_xml(url_string, content)
  if url_string.nil?
    puts "Missing Solr URL!  Unable to continue."
    exit
  elsif content.nil?
    puts "Missing content to index to Solr. Please check that files are"
    puts "available to be converted to Solr format and that they were transformed."
    exit
  else
    url = URI.parse(url_string)
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url.request_uri)
    request.body = content
    request["Content-Type"] = "application/xml"
    return http.request(request)
  end
end
# end post_xml

def read_configs(dir, options)
  begin
    config_main = YAML.load_file("#{dir}/../../config/general.yml")
    proj_data = config_main["project_data_dir"]
    # TODO having problems getting this to work
    # config_prj = YAML.load_file("#{proj_data}#{options[:project]}/config.yml")
    config_prj = YAML.load_file("#{dir}/../../projects/#{options[:project]}/config.yml")
    return { :main => config_main, :proj => config_prj }
  rescue Exception => e
    puts "There was an error reading a config file: #{e.message}"
    puts "Stacktrace: \n\t#{e.backtrace.inspect}" if options[:verbose]
    exit
  end
end
# end read_configs

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