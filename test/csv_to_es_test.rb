require "test_helper"

class CsvToEsTest < Minitest::Test

  def setup
    path = File.join($fixture_path, "csv", "testing.csv")
    csv = CSV.read(path, headers: true)

    @test1 = CsvToEs.new(csv[0], $options, csv)
    @test2 = CsvToEs.new(csv[1], $options, csv)
  end

  def test_assemble_json
    json = @test1.assemble_json
    assert_equal 41, json.length
    assert_equal "test.001", json["identifier"]

    json = @test2.assemble_json
    assert_equal 41, json.length
    assert_equal "test.002", json["identifier"]
  end

  def test_csv_to_es_fields
    json = @test1.assemble_json
    assert_equal "1887-01-01", json["date"]

    contributors = [{"name"=>"Jessica Dussault"}, {"name"=>"Greg Tunink"}, {"name"=>"Karin Dalziel"}]
    assert_equal contributors, json["contributor"]

    json = @test2.assemble_json
    assert_equal "amanuensis", json["category"]

    assert_equal "1990-01-01", json["date_not_before"]
    assert_equal "1990-01-31", json["date_not_after"]
  end

end
