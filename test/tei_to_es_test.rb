require "minitest/autorun"
require "nokogiri"
require_relative "classes.rb"

class TeiToEsTest < Minitest::Test
  def setup
    current_dir = File.expand_path(File.dirname(__FILE__))
    fixture_path = "#{current_dir}/fixtures/nei.news.00001.xml"
    xml = Common.create_xml_object(fixture_path)
    @teitoes = TeiToEs.new(xml)
  end

  def test_assemble_json
    # should return a json object with a few keys
    # but will be testing values more in project specific test suite
    json = @teitoes.assemble_json
    assert_equal json.length, 31
  end

  def test_get_list
    # should work with single xpath and strip tags
    res0 = @teitoes.get_list("//p")
    assert_equal res0.length, 6
    refute res0[0].include?("<hi rend=")
    # should work with multiple xpaths and keep / convert tags
    res1 = @teitoes.get_list(["//p", "//revisionDesc/change"], true)
    assert_equal res1.length, 9
    assert_equal res1[0][0..5], "ALFRED"
    assert res1[0].include?("<em>")
    assert res1[8].include?("<name")
  end
end
