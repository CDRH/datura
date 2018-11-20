require "test_helper"

# override the Options class method so that we
# can test without real config files
class Datura::Options
  def read_all_configs fake1, fake2
    @general_config_pub = {
      "default" => {
        "a" => "general default public"
      }
    }
    @collection_config_pub = {
      "default" => {
        "b" => "proj default public"
      },
      "development" => {
        "a" => "proj dev public",
        "c" => "proj dev public"
      }
    }
    @collection_config_priv = {
      "development" => {
        "c" => "proj dev private"
      },
    }
  end
end

class OptionsTest < Minitest::Test

  def test_dev_overwriting
    params = { "environment" => "development" }
    o = Datura::Options.new(params).all

    assert_equal "proj dev public", o["a"]
    assert_equal "proj default public", o["b"]
    assert_equal "proj dev private", o["c"]
    assert_equal "development", o["environment"]
  end

  def test_default_overwriting
    params = { "environment" => "not_found_config" }
    o = Datura::Options.new(params).all

    assert_equal "general default public", o["a"]
    assert_equal "proj default public", o["b"]
  end

end
