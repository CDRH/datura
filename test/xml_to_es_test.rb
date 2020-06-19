require "test_helper"

class XmlToEsTest < Minitest::Test

  def setup
    @neihardt = xml_to_es_instance(TeiToEs, "tei", "nei.j4c.12.52")
  end

  def test_get_elements
    # test one xpath
    res = @neihardt.get_elements("//handNote")
    assert_equal Nokogiri::XML::NodeSet, res.class

    assert_equal 2, res.length
    # check that you can access attributes and sub elements
    assert_equal "type", res.first["id"]
    assert_equal "pen", res[1]["medium"]

    assert_equal "Media: type", res.first.text
    assert_equal "Media: type", @neihardt.get_text("p", xml: res.first)
    assert_equal 1, res.first.xpath("p").length

    # test array of xpaths
    res = @neihardt.get_elements([ "//handNote", "//keywords" ])
    assert_equal 9, res.length
    assert_equal "Correspondence", @neihardt.get_text("term", xml: res[2])

    # test list of xpaths
    res = @neihardt.get_elements("//handNote", "//keywords")
    assert_equal 9, res.length

    # test when no results of xpaths
    res = @neihardt.get_elements("//fake/path")
    assert_equal 0, res.length
  end

  def test_get_list
    # should work with single xpath and strip tags
    res0 = @neihardt.get_list("//p")
    assert_equal res0.length, 5
    # should work with multiple xpaths
    res1 = @neihardt.get_list(["//p", "//revisionDesc/change"])
    assert_equal 9, res1.length
  end

  def test_get_text
    # test stripping tags
    text = "I could almost make a living from lecture engagements that are offered me."
    res = @neihardt.get_text("//postscript/p", keep_tags: false, xml: @neihardt.xml)
    assert_equal text, res
    # test keeping tags
    text = "I could almost make a living from lecture engagements that are <u>offered me.</u>"
    res = @neihardt.get_text("//postscript/p", keep_tags: true, xml: @neihardt.xml)
    assert_equal text, res
  end

end
