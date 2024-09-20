require "test_helper"

class HtmlToEsTest < Minitest::Test
  def setup
    @test = xml_to_es_instance(HtmlToEs, "html", "testing")
  end

  def test_assemble_json
    json = @test.assemble_json
    assert_equal 58, json.length
    assert_equal "testing", json["identifier"]
  end

  def test_vra_to_es_fields
    json = @test.assemble_json
    
    assert_equal "Title of Resource", json["title"]
    text = "Some TextThis is some text Title of Resource"
    assert_equal text, json["text"]
  end
end
