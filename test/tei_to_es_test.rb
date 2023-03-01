require_relative "test_helper"
require "nokogiri"

class TeiToEsTest < Minitest::Test
  def setup
    @cody = xml_to_es_instance(TeiToEs, "tei", "wfc.nsp02639")
    @neihardt = xml_to_es_instance(TeiToEs, "tei", "nei.j4c.12.52")
    @whitman = xml_to_es_instance(TeiToEs, "tei", "med.00314")
  end

  def test_assemble_json
    json = @neihardt.assemble_json
    assert_equal 42, json.length
    assert_equal "nei.j4c.12.52", json["identifier"]
  end

  def test_fields
    cody = @cody.assemble_json
    neihardt = @neihardt.assemble_json
    whitman = @whitman.assemble_json

    # creator
    creator = []
    assert_equal creator, cody["creator"]

    creator = [{"name"=>"Neihardt, John Gneisenau, 1881-1973"}]
    assert_equal creator, neihardt["creator"]

    contributor = [{"id"=>"lkw", "name"=>"Weakly, Laura K.", "role"=>""},
      {"id"=>"swa", "name"=>"Adrales, Samantha W.", "role"=>""},
      {"id"=>"az", "name"=>"Zeljkovic, Arman", "role"=>""},
      {"id"=>"ep", "name"=>"Pedigo, Erin", "role"=>""},
      {"id"=>"", "name"=>"Gossin, Pamela", "role"=>""}
    ]
    assert_equal contributor, neihardt["contributor"]

    # date
    # whitman date is nil with given xpath
    refute whitman["date"]
    assert_equal "late 1865 (?)", whitman["date_display"]
    assert_equal "1865-12-31", whitman["date_not_after"]
    assert_equal "1865-07-01", whitman["date_not_before"]

    # source
    source = "Track and stable talk, Aberdeen, South Dakota, 1888-02-24"
    assert_equal source, cody["source"]

    source = "Neihardt, John Gneisenau, 1881-1973, Letter from John G. Neihardt to Julius T. House, 1927-11-05"
    assert_equal source, neihardt["source"]

    # NOTE: this document does have publisher information in the biblStruct and will
    # need to override the default xpaths to obtain that information for the source field
    source = "Walt Whitman, Walt Whitman to a Soldier, late 1865 (?)"
    assert_equal source, whitman["source"]

  end
end
