require_relative "test_helper"

class Datura::ElasticsearchIndexTest < Minitest::Test

  @@options = {
    "api_version" => "2.0",
    "es_index" => "fake_index",
    "es_path" => "fake_path",
    "es_schema" => File.join(
      File.expand_path(File.dirname(__FILE__)),
        "../lib/config/es_api_schemas/2.0.yml"
    )
  }

  # stub in get_schema so that we can test get_schema_mapping without
  # worrying about integration with actual index

  class Datura::Elasticsearch::Index
    def get_schema
      raw = File.read(
        File.join(
          File.expand_path(File.dirname(__FILE__)),
          "fixtures/es_mapping_2.0.json"
        )
      )
      JSON.parse(raw)
    end
  end

  def test_initialize
    # test that options populate if you pass existing ones in
    es = Datura::Elasticsearch::Index.new(@@options)
    path = File.join(@@options["es_path"], @@options["es_index"])
    assert_equal path, es.index_url

    # test that schema mapping occurs, although it will be with the stubbed
    # in version of get_schema above, rather than index integration
    es = Datura::Elasticsearch::Index.new(@@options, schema_mapping: true)
    assert es.schema_mapping
  end

  def test_get_schema_mapping
    # let's just see what happens
    es = Datura::Elasticsearch::Index.new(@@options)
    es.get_schema_mapping
    assert es.schema_mapping["fields"]
    assert_equal 46, es.schema_mapping["fields"].length
    assert_equal(
      /^.*_d$|^.*_i$|^.*_k$|^.*_n$|^.*_t$|^.*_t_en$|^.*_t_es$/,
      es.schema_mapping["dynamic"]
    )
  end

  def test_valid_document?
    es = Datura::Elasticsearch::Index.new(@@options)

    # basic fields
    assert es.valid_document?({ "identifier" => "a" })
    assert es.valid_document?({
      "collection" => "a",
      "date_not_before" => "2012-01-01",
      "text" => "a",
    })

    # nested fields with child fields not matching top level field
    assert es.valid_document?({
      "creator" => [
        {
          "id" => "a",
          "name" => "a"
        }
      ]
    })

    # nested fields with child fields matching top level / dynamic
    assert es.valid_document?({
      "creator" => [
        {
          "subcategory" => "a",
          "data_type" => "a",
          "keyword_k" => "a"
        }
      ]
    })

    # dynamic fields, each type
    assert es.valid_document?({ "new_field_d" => "2012-01-1" })
    assert es.valid_document?({ "new_field_i" => "1" })
    assert es.valid_document?({ "new_field_k" => "a" })
    assert es.valid_document?({ "new_field_t" => "a" })
    assert es.valid_document?({ "new_field_t_en" => "a" })
    assert es.valid_document?({ "new_field_t_es" => "a" })

    # test failures of basic and dynamic fields
    refute es.valid_document?({ "bad_field" => "a" })
    refute es.valid_document?({ "dynamic_t_bad" => "a" })

    # test failure of nested field with all bad subfields
    refute es.valid_document?({
      "creator" => [
        {
          "bad_field" => "a",
          "another_one" => "a"
        }
      ]
    })

    # test feailure of nested field with mixture of good / bad
    refute es.valid_document?({
      "creator" => [
        {
          "id" => "a",
          "keyword_k" => "a"
        },
        {
          "id" => "a",
          "bad_field" => "a"
        }
      ]
    })

    # test that bad fields hidden with good still fail
    refute es.valid_document?({
      "collection" => "a",
      "keyword_k" => "a",
      "bad_field" => "a"
    })
  end

end
