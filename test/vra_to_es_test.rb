require "test_helper"

class VraToEsTest < Minitest::Test
  def setup
    @cody = xml_to_es_instance(VraToEs, "vra", "wfc.img.pc.0001")
  end

  def test_assemble_json
    json = @cody.assemble_json
    assert_equal 41, json.length
    assert_equal "wfc.img.pc.0001", json["identifier"]
  end

  def test_vra_to_es_fields
    json = @cody.assemble_json

    assert_equal "1904", json["date_display"]

    keywords = ["Lakota Performers", "American Indians", "Headgear"]
    assert_equal keywords, json["keywords"]
  end
end
