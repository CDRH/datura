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
    xml
  end

  # wrap in order to make valid xml
  # for cases where get_text or similar was used
  # so no longer an XML object, but still need to have tags altered
  def self.convert_tags_in_string(text)
    xml = Nokogiri::XML("<xml>#{text}</xml>")
    converted = convert_tags(xml)
    converted.xpath("//xml").inner_html
  end

  def self.create_html_object(filepath, remove_ns=true)
    file_html = File.open(filepath) { |f| Nokogiri::HTML(f, &:noblanks) }
    file_html.remove_namespaces! if remove_ns
    file_html
  end

  def self.create_xml_object(filepath, remove_ns=true)
    file_xml = File.open(filepath) { |f| Nokogiri::XML(f, &:noblanks) }
    # TODO is this a good idea?
    file_xml.remove_namespaces! if remove_ns
    file_xml
  end

  # deprecated method
  def self.date_display(date, nd_text="N.D.")
    Datura::Helpers.date_display(date, nd_text)
  end

  # deprecated method
  def self.date_standardize(date, before=true)
    Datura::Helpers.date_standardize(date, before)
  end

  # deprecated method
  def self.normalize_name(abnormal)
    Datura::Helpers.normalize_name(abnormal)
  end

  # deprecated method
  def self.normalize_space(abnormal)
    Datura::Helpers.normalize_space(abnormal)
  end

  # saxon accepts params in following manner
  #   fw=true pb=true figures=false
  def self.stringify_params(param_hash)
    params = ""
    if param_hash
      params = param_hash.map{ |k, v| "#{k}=#{v}" }.join(" ")
    end
    params
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

  # TODO remove in 2021
  class << self
    extend Gem::Deprecate
    deprecate :date_display, :"Datura::Helpers.normalize_space", 2021, 1
    deprecate :date_standardize, :"Datura::Helpers.normalize_space", 2021, 1
    deprecate :normalize_name, :"Datura::Helpers.normalize_space", 2021, 1
    deprecate :normalize_space, :"Datura::Helpers.normalize_space", 2021, 1
  end

end
