require "test_helper"

class VraToEsTest < Minitest::Test
  def setup
    @cody = xml_to_es_instance(VraToEs, "vra", "wfc.img.pho.69.236.82")
  end

  def test_assemble_json
    json = @cody.assemble_json
    assert_equal 42, json.length
    assert_equal "wfc.img.pho.69.236.82", json["identifier"]
  end

  def test_vra_to_es_fields
    json = @cody.assemble_json

    assert_equal "circa 1898", json["date_display"]
    # this document has no exact date in the encoding to pull
    assert_nil json["date"]

    keywords = ["Spotted Horse, Willie"]
    assert_equal keywords, json["keywords"]

    people = [
      {id: nil, name: "Käsebier, Gertrude, 1852-1934", role: "photographer"},
      {id: nil, name: "Spotted Horse, Willie", role: nil}
    ]
    assert_equal people, json["person"]
  end
end
