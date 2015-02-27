require 'net/http'

class SolrPoster
  attr_accessor :url

  def initialize(url, commit=true)
    if url.nil? || url.empty?
      puts "Unable to find solr url"
      ArgumentError.new("Must have a solr url (even if you're just generating html)")
    else
      @url = url       # the solr url (with /update)
      @commit = commit # if the solr posts should be committed or not
    end
  end

  # TODO this is very similar to the below _by_regex function
  # so could stick them together later
  def clear_index
    del_str = "<delete><query>*:*</query></delete>"
    res = post_xml(del_str)
    if res.code == "200"
      puts "Successfully cleared index of requested entries"
    else
      puts "Unable to clear index!"
    end
    return res
  end

  def clear_index_by_regex(field, regex)
    puts "reg #{regex}"
    exp = "/.*#{regex}.*/"  # pad the regex so solr knows how to handle it
    del_str = "<delete><query>#{field}:#{exp}</query></delete>"
    puts "del string #{del_str}"
    res = post_xml(del_str)
    if res.code == "200"
      puts "Successfully cleared index of requested entries"
    else
      puts "Unable to clear files from index!"
    end
    return res
  end

  # returns an error or nil
  def commit_solr
    commit_res = nil
    if @commit
      commit_res = post_xml("<commit/>")
      if commit_res.code == "200"
        puts "SUCCESS! Committed your changes to Solr index"
      else
        puts "UNABLE TO COMMIT YOUR CHANGES TO SOLR."
      end
    end
    return commit_res
  end

  def post_file(file_location)
    file = IO.read(file_location)
    return post_xml(file)
  end

  # post_xml
  #   posts a request with an xml body
  #   params: content: "<xml>Stuff</xml>"
  #   returns: a response object that can be used with http
  def post_xml(content)
    if content.nil? || content.empty?
      puts "Missing content to index to Solr. Please check that files are"
      puts "available to be converted to Solr format and that they were transformed."
      return nil
    else
      url = URI.parse(@url)
      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Post.new(url.request_uri)
      request.body = content
      request["Content-Type"] = "application/xml"
      return http.request(request)
    end
  end # end post_xml
end