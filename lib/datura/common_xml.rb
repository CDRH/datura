require 'nokogiri'

module CommonXml

  # returns Nokogiri XML object
  def self.convert_tags(xml)
    # italic(s)
    xml.css("hi[rend^='italic']").each do |ele|
      ele.name = "em"
      ele.delete("rend")
    end
    # bold (sometimes they include bold as second part of attr)
    xml.css("hi[rend~='bold']").each do |ele|
      ele.name = "strong"
      ele.delete("rend")
    end
    # underline(d)
    xml.css("hi[rend^='underline']").each do |ele|
      ele.name = "u"
      ele.delete("rend")
    end
    xml = CommonXml.sub_corrections(xml)
    return xml
  end

  # wrap in order to make valid xml
  # for cases where get_text or similar was used
  # so no longer an XML object, but still need to have tags altered
  def self.convert_tags_in_string(text)
    xml = Nokogiri::XML("<xml>#{text}</xml>")
    converted = convert_tags(xml)
    return converted.xpath("//xml").inner_html
  end

  def self.create_xml_object(filepath, remove_ns=true)
    file_xml = File.open(filepath) { |f| Nokogiri::XML(f, &:noblanks) }
    # TODO is this a good idea?
    file_xml.remove_namespaces! if remove_ns
    return file_xml
  end

  # pass in a date and identify whether it should be before or after
  # in order to fill in dates (ex: 2014 => 2014-12-31)

  def self.date_display(date, nd_text="N.D.")
    date_hyphen = CommonXml.date_standardize(date)
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
    down.gsub(/^the |^a |^an /, "")
  end

  # imitates xslt fn:normalize-space
  # removes leading / trailing whitespace, newlines, repeating whitespace, etc
  def self.normalize_space(abnormal)
    if abnormal
      normal = abnormal.strip.gsub(/\s+/, " ")
    end
    normal || abnormal
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

  def self.sub_corrections(aXml)
    # sub <corr>.*</corr> for [.*]
    xml = aXml.dup
    xml.css("corr").each {|e| e.replace("[#{e.text}]") }
    xml
  end

  # returns string object
  def self.to_display_text(aXml)
    CommonXml.sub_corrections(aXml).text
  end

end
