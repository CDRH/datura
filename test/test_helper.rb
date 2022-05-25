$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "datura"

require "minitest/autorun"

$options = {
  "collection" => "test_collection",
  "data_base" => "cdrhtest.unl.edu/media",
  "environment" => "test",
  "site_url" => "cdrhtest.unl.edu"
}

current_dir = File.expand_path(File.dirname(__FILE__))
$fixture_path = "#{current_dir}/fixtures/"


def xml_to_es_instance(classname, type, fixture)
  ext = type == "html" || type == "webs" ? "html" : "xml"
  xml = CommonXml.create_xml_object(
    File.join($fixture_path, type, "#{fixture}.#{ext}")
  )
  classname.new(xml, $options, nil, fixture)
end
