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

  # Stub get_schema instance method by storing the original, undefining,
  # and redefining it before each test is performed to avoi
  # method redefined warnings and use fixture data JSON rather than
  # relying on a real request to an Elasticsearch index
  attr_accessor :orig_get_schema

  def setup
    super

    self.orig_get_schema = Datura::Elasticsearch::Index.instance_method(:get_schema)

    Datura::Elasticsearch::Index.send(:undef_method, :get_schema)
    Datura::Elasticsearch::Index.define_method(:get_schema) do
      raw = File.read(
        File.join(
          File.expand_path(File.dirname(__FILE__)),
          "fixtures/es_mapping_2.0.json"
        )
      )
      JSON.parse(raw)
    end
  end

  # Undefine and restore the original get_schema instance method
  # after each test is performed to avoid method redefined warnings
  def teardown
    super

    Datura::Elasticsearch::Index.send(:undef_method, :get_schema)
    Datura::Elasticsearch::Index.define_method(:get_schema, orig_get_schema)
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
    assert_equal 60, es.schema_mapping["fields"].length
    assert_equal(
      /^(?:.*_d|.*_i|.*_k|.*_n|.*_t|.*_t_en|.*_t_es)$/,
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
          "category2" => "a",
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

    # Suppress invalid field warnings for following tests
    orig_stdout = $stdout.clone
    $stdout.reopen File.new('/dev/null', 'w')

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

    # Restore stdout after tests with invalid field warnings
    $stdout.reopen orig_stdout
  end

end
