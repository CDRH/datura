require "minitest/autorun"
require_relative "classes.rb"

class TeiToEsTest < Minitest::Test
  def setup
    # get a file for testing
    @file = FileTei.new("test/fixtures/nei.news.00001.xml", "", {})
    TeiToEs.create_json(@file)

    # can manually set up instance variables instead of using create_json

    # TeiToEs.instance_variable_set("@file", @file)
    # # set an xml instance variable
    # @xml = TeiToEs.create_xml_object
    # TeiToEs.instance_variable_set("@xml", @xml)
  end

  def test_verify_instance_methods
    # never mind that the setup wouldn't have worked without file but you know
    assert_equal @file.file_location, TeiToEs.instance_variable_get("@file").file_location
  end

  def test_get_docs
    # there should be zero subdocs for this neihardt
    assert_equal 0, TeiToEs.get_docs.length
  end

  def test_assemble_json
    # should return a json object with a few keys
    # but will be testing values more in project specific test suite
    json = TeiToEs.assemble_json
    assert_equal json.length, 32
  end

  def test_get_list
    # should work with single xpath and strip tags
    res0 = TeiToEs.get_list("//p")
    assert_equal res0.length, 6
    refute res0[0].include?("<hi rend=")
    # should work with multiple xpaths and keep / convert tags
    res1 = TeiToEs.get_list(["//p", "//revisionDesc/change"], true)
    assert_equal res1.length, 9
    assert_equal res1[0][0..5], "ALFRED"
    assert res1[0].include?("<em>")
    assert res1[8].include?("<name")
  end
end
