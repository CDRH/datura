require "minitest/autorun"
require "nokogiri"
require_relative "classes.rb"

class CommonXmlTest < Minitest::Test

  def test_convert_tags
    test1a = Nokogiri::XML "<TEI><body>Some text goes <hi rend='italic'>here</hi></body></TEI>"
    test1b = "<TEI><body>Some text goes <em>here</em>\n</body></TEI>"
    assert_equal CommonXml.convert_tags(test1a).inner_html, test1b

    test2a = Nokogiri::XML '<title type="main">Willa Cather to Helen Louise Stevens Stowell, August 31, 1888</title>'
    test2b = '<title type="main">Willa Cather to Helen Louise Stevens Stowell, August 31, 1888</title>'
    assert_equal CommonXml.convert_tags(test2a).inner_html, test2b

    test3a = Nokogiri::XML '<title><hi rend="bold">Indian Farmer Association</hi> Meeting <hi rend="italics">Poorly Attended</hi></title>'
    test3b = "<title>\n<strong>Indian Farmer Association</strong> Meeting <em>Poorly Attended</em>\n</title>"
    assert_equal CommonXml.convert_tags(test3a).inner_html, test3b

    test4a = Nokogiri::XML "<xml><hi rend='underline'>Test</hi> <hi rend='underlined'>Underline</hi></xml>"
    test4b = "<xml><u>Test</u> <u>Underline</u></xml>"
    assert_equal CommonXml.convert_tags(test4a).inner_html, test4b

    # test with multiple blobs
    test5a = Nokogiri::XML '<xml><text>Text <hi rend="bold">Portion</hi> 1</text><text>Text Portion 2</text></xml>'
    texts = test5a.xpath("//text")
    test5b = "Text <strong>Portion</strong> 1Text Portion 2"
    assert_equal CommonXml.convert_tags(texts).inner_html, test5b

    test6a = Nokogiri::XML '<xml>leaving to become an assistant editor of <hi rend="italic">The Nation</hi>, and a regular contributor to the <hi rend="italic">Atlantic Monthly</hi> and <hi rend="italic">Harper’s</hi></xml>'
    assert_equal CommonXml.convert_tags(test6a).inner_html, "<xml>leaving to become an assistant editor of <em>The Nation</em>, and a regular contributor to the <em>Atlantic Monthly</em> and <em>Harper&#x2019;s</em></xml>"

    # test with substutions for corrections
    test7a = Nokogiri::XML "<xml><title><hi rend='italics'>Some</hi> title <corr>Title</corr></title></xml>"
    test7b = "<xml><title>\n<em>Some</em> title [Title]</title></xml>"
    assert_equal CommonXml.convert_tags(test7a).inner_html, test7b
  end

  def test_convert_tags_in_string
    test1a = "This is a bunch of texxt <corr>text</corr>"
    assert_equal CommonXml.convert_tags_in_string(test1a), "This is a bunch of texxt [text]"
  end

  def test_create_xml_object
    # TODO
  end

  def test_date_display
    # normal dates
    assert_equal CommonXml.date_display("2016-12-02"), "December 2, 2016"
    assert_equal CommonXml.date_display("2014-01-31", "no date"), "January 31, 2014"
    # no date
    assert_equal CommonXml.date_display(nil), "N.D."
    assert_equal CommonXml.date_display("20143183", "no date"), "no date"
    assert_equal CommonXml.date_display(nil, ""), ""
  end

  def test_date_standardize
    # missing month and day
    assert_equal CommonXml.date_standardize("2016"), "2016-01-01"
    assert_equal CommonXml.date_standardize("2016", false), "2016-12-31"
    # missing day
    assert_nil CommonXml.date_standardize("01-12")
    assert_equal CommonXml.date_standardize("2014-01"), "2014-01-01"
    assert_equal CommonXml.date_standardize("2014-01", false), "2014-01-31"
    # complete date
    assert_equal CommonXml.date_standardize("2014-01-12"), "2014-01-12"
    # invalid date
    assert_nil CommonXml.date_standardize("2014-30-31")
    # February final day
    assert_equal CommonXml.date_standardize("2015-2", false), "2015-02-28"
    assert_equal CommonXml.date_standardize("2016-02", false), "2016-02-29"
  end

  def test_normalize_name
    assert_equal CommonXml.normalize_name("The Title"), "title"
    assert_equal CommonXml.normalize_name("Anne of Green Gables"), "anne of green gables"
    assert_equal CommonXml.normalize_name("A Fancy Party"), "fancy party"
    assert_equal CommonXml.normalize_name("An Hour"), "hour"
  end

  def test_squeeze
    # ensure that return characters are replaced by spaces, and multispaces squashed
    test1 = "<xml>\n<title>Example    </title>\n  </xml>\n"
    assert_equal CommonXml.squeeze(test1), "<xml> <title>Example </title> </xml>"
  end

  def test_sub_corrections
    xml_string = "<xml>Somethng <corr>Something</corr></xml>"
    xml = Nokogiri::XML xml_string
    assert_equal CommonXml.sub_corrections(xml).text, "Somethng [Something]"
    assert_equal xml.inner_html, xml_string
  end

  def test_to_display_text
    # test with italics and correction
    test1a = Nokogiri::XML "<xml><title><hi rend='italics'>Some</hi> title <corr>Title</corr></title></xml>"
    test1b = "Some title [Title]"
    assert_equal CommonXml.to_display_text(test1a), test1b

    test2a = Nokogiri::XML "<xml><title>Lots of <stuff>nested</stuff> things <blah>of <more>stuff</more></blah></title></xml>"
    test2b = "Lots of nested things of stuff"
    assert_equal CommonXml.to_display_text(test2a), test2b
  end

end
