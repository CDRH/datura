require "test_helper"

class WebsToEsTest < Minitest::Test
  def setup
    @test = xml_to_es_instance(WebsToEs, "webs", "testing")
  end

  def test_assemble_json
    json = @test.assemble_json
    assert_equal 41, json.length
    assert_equal "testing", json["identifier"]
  end

  def test_webs_to_es_fields
    json = @test.assemble_json
    
    assert_equal "Title of Resource", json["title"]
    text = "Some TextThis is some text Title of Resource"
    assert_equal text, json["text"]
  end
end
