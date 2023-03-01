require_relative "test_helper"
require "nokogiri"

class CommonXmlTest < Minitest::Test

  def test_convert_tags
    test1a = Nokogiri::XML "<TEI><body>Some text goes <hi rend='italic'>here</hi></body></TEI>"
    test1b = "<TEI><body>Some text goes <em>here</em>\n</body></TEI>"
    assert_equal test1b, CommonXml.convert_tags(test1a).inner_html

    test2a = Nokogiri::XML '<title type="main">Willa Cather to Helen Louise Stevens Stowell, August 31, 1888</title>'
    test2b = '<title type="main">Willa Cather to Helen Louise Stevens Stowell, August 31, 1888</title>'
    assert_equal test2b, CommonXml.convert_tags(test2a).inner_html

    test3a = Nokogiri::XML '<title><hi rend="bold">Indian Farmer Association</hi> Meeting <hi rend="italics">Poorly Attended</hi></title>'
    test3b = "<title>\n<strong>Indian Farmer Association</strong> Meeting <em>Poorly Attended</em>\n</title>"
    assert_equal test3b, CommonXml.convert_tags(test3a).inner_html

    test4a = Nokogiri::XML "<xml><hi rend='underline'>Test</hi> <hi rend='underlined'>Underline</hi></xml>"
    test4b = "<xml><u>Test</u> <u>Underline</u></xml>"
    assert_equal test4b, CommonXml.convert_tags(test4a).inner_html

    # test with multiple blobs
    test5a = Nokogiri::XML '<xml><text>Text <hi rend="bold">Portion</hi> 1</text><text>Text Portion 2</text></xml>'
    texts = test5a.xpath("//text")
    test5b = "Text <strong>Portion</strong> 1Text Portion 2"
    assert_equal test5b, CommonXml.convert_tags(texts).inner_html

    test6a = Nokogiri::XML '<xml>leaving to become an assistant editor of <hi rend="italic">The Nation</hi>, and a regular contributor to the <hi rend="italic">Atlantic Monthly</hi> and <hi rend="italic">Harper’s</hi></xml>'
    test6b = "<xml>leaving to become an assistant editor of <em>The Nation</em>, and a regular contributor to the <em>Atlantic Monthly</em> and <em>Harper&#x2019;s</em></xml>"
    assert_equal test6b, CommonXml.convert_tags(test6a).inner_html
    # test with substutions for corrections
    test7a = Nokogiri::XML "<xml><title><hi rend='italics'>Some</hi> title <corr>Title</corr></title></xml>"
    test7b = "<xml><title>\n<em>Some</em> title [Title]</title></xml>"
    assert_equal test7b, CommonXml.convert_tags(test7a).inner_html
  end

  def test_convert_tags_in_string
    test1a = "This is a bunch of texxt <corr>text</corr>"
    assert_equal "This is a bunch of texxt [text]", CommonXml.convert_tags_in_string(test1a)
  end

  def test_create_xml_object
    # TODO
  end

  def test_sub_corrections
    xml_string = "<xml>Somethng <corr>Something</corr></xml>"
    xml = Nokogiri::XML xml_string
    assert_equal "Somethng [Something]", CommonXml.sub_corrections(xml).text
    assert_equal xml_string, xml.inner_html
  end

  def test_to_display_text
    # test with italics and correction
    test1a = Nokogiri::XML "<xml><title><hi rend='italics'>Some</hi> title <corr>Title</corr></title></xml>"
    test1b = "Some title [Title]"
    assert_equal test1b, CommonXml.to_display_text(test1a)

    test2a = Nokogiri::XML "<xml><title>Lots of <stuff>nested</stuff> things <blah>of <more>stuff</more></blah></title></xml>"
    test2b = "Lots of nested things of stuff"
    assert_equal test2b, CommonXml.to_display_text(test2a)
  end

end
