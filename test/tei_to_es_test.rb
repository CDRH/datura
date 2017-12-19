require "minitest/autorun"
require "nokogiri"
require_relative "classes.rb"

class TeiToEsTest < Minitest::Test
  def setup
    current_dir = File.expand_path(File.dirname(__FILE__))
    fixture_path = "#{current_dir}/fixtures/nei.news.00001.xml"
    xml = CommonXml.create_xml_object(fixture_path)
    @teitoes = TeiToEs.new(xml)
  end

  def test_assemble_json
    # should return a json object with a few keys
    # but will be testing values more in collection specific test suite
    json = @teitoes.assemble_json
    assert_equal 38, json.length
  end

  def test_get_list
    # should work with single xpath and strip tags
    res0 = @teitoes.get_list("//p")
    assert_equal res0.length, 6
    refute res0[0].include?("<hi rend=")
    # should work with multiple xpaths and keep / convert tags
    res1 = @teitoes.get_list(["//p", "//revisionDesc/change"], true)
    assert_equal 9, res1.length
    assert_equal "ALFRED", res1[0][0..5]
    assert res1[0].include?("<em>")
    assert res1[8].include?("<name")
  end

  def test_get_text
    # test stripping tags
    text = "ALFRED RUSSEL WALLACE, the nonogenarian, who has just departed this life, was not only a contemporary of CHARLES DARWIN and simultaneous discoverer with him of the laws of evolution, but also a friend and admirer of the author of The Origin of Species. Yet he and DARWIN, who agreed upon so much, disagreed upon an important matter.; DARWIN had a wholly material concept of the development of the human mind. Mental and spiritual phenomena he held to be the consequence entirely of a physical evolution. But WALLACE contended that physical evolution was not sufficient to explain the whole of the human mind, and he believed that somewhere in the process the brain of man had been inspired by the Greater Mind, the Universal Mind, or by a Power other than physical at least. And WALLACE lived long enough to see Twentieth Century science inclining to his view, or to something as good as his. In this particular it is probably not too much to say that WALLACE was superior to DARWIN, although the latter was the greater biologist.; How can the human brain, regarded as a biological product wholly, have come to the infinitesimal calculus? Is it not more feasible to suppose that Universal Mind, finding such a vibrating instrument as the human brain, availed itself of the chance to embody itself in a measure? And is not progress an increasing measure of such embodiment?; Moreover, the dignity of the human mind has been increased by researches since DARWIN'S day. The powers of the mind are viewed as more transcendant than they seemed to him. The gap between animal and man, between savage and civilized being, between ordinary mind and mind of the sage — all these gaps are now seen to be much wider than DARWIN in his day supposed, and by that much they are the harder to explain by a process of merely physical evolution.; The physicist no longer explains the brain wholly in terms of physics. He is aware that physics and chemistry will not explain all. The brain is an instrument, a violin, a net of wires stretched to receive vibrations that are no more material than are those that the wireless draws down. Up-to-date science is very near to postulating Universal Mind, much as the mathematicians were compelled to postulate the planets Uranus and Neptune before they were discovered.; What DARWIN lacked, despite his genius for generalization, was imagination. As an elucidator of the philosophy of BERGSON (in the spirit of his master's thought) says: There is no authority for a dogmatic insistence that there is \"forever only one order of life, only one plane of action, only one rhythm of duration, only one perspective of existence.\" DARWIN was confident there was only one. And to do him justice, it was only natural that in his day that there could be another should not occur to him. But our day sees differently."
    res = @teitoes.get_text("//p", false, @teitoes.xml)
    assert_equal text, res
    # test keeping tags
    text = "ALFRED RUSSEL WALLACE, the nonogenarian, who has just departed this life, was not only a contemporary of CHARLES DARWIN and simultaneous discoverer with him of the laws of evolution, but also a friend and admirer of the author of <em>The Origin of Species</em>. Yet he and DARWIN, who agreed upon so much, disagreed upon an important matter.; DARWIN had a wholly material concept of the development of the human mind. Mental and spiritual phenomena he held to be the consequence entirely of a physical evolution. But WALLACE contended that physical evolution was not sufficient to explain the whole of the human mind, and he believed that somewhere in the process the brain of man had been inspired by the Greater Mind, the Universal Mind, or by a Power other than physical at least. And WALLACE lived long enough to see Twentieth Century science inclining to his view, or to something as good as his. In this particular it is probably not too much to say that WALLACE was superior to DARWIN, although the latter was the greater biologist.; How can the human brain, regarded as a biological product wholly, have come to the infinitesimal calculus? Is it not more feasible to suppose that Universal Mind, finding such a vibrating instrument as the human brain, availed itself of the chance to embody itself in a measure? And is not progress an increasing measure of such embodiment?; Moreover, the dignity of the human mind has been increased by researches since DARWIN'S day. The powers of the mind are viewed as more transcendant than they seemed to him. The gap between animal and man, between savage and civilized being, between ordinary mind and mind of the sage — all these gaps are now seen to be much wider than DARWIN in his day supposed, and by that much they are the harder to explain by a process of merely physical evolution.; The physicist no longer explains the brain wholly in terms of physics. He is aware that physics and chemistry will not explain all. The brain is an instrument, a violin, a net of wires stretched to receive vibrations that are no more material than are those that the wireless draws down. Up-to-date science is very near to postulating Universal Mind, much as the mathematicians were compelled to postulate the planets <em>Uranus</em> and <em>Neptune</em> before they were discovered.; What DARWIN lacked, despite his genius for generalization, was imagination. As an elucidator of the philosophy of BERGSON (in the spirit of his master's thought) says: There is no authority for a dogmatic insistence that there is \"forever only one order of life, only one plane of action, only one rhythm of duration, only one perspective of existence.\" DARWIN was confident there was only one. And to do him justice, it was only natural that in his day that there could be another should not occur to him. But our day sees differently."
    res = @teitoes.get_text("//p", true, @teitoes.xml)
    assert_equal text, res
  end
end
