require "minitest/autorun"
require_relative "classes.rb"

# override the Options class method so that we
# can test without real config files
class Options
  def read_all_configs fake1, fake2
    @general_config_pub = {
      "default" => {
        "a" => "general default public"
      }
    }
    @general_config_priv = {
      "default" => {
        "b" => "general default private",
        "d" => "general default private"
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
    o = Options.new(params, "fake", "fake").all

    assert_equal o["a"], "proj dev public"
    assert_equal o["b"], "proj default public"
    assert_equal o["c"], "proj dev private"
    assert_equal o["d"], "general default private"
    assert_equal o["environment"], "development"
  end

  def test_default_overwriting
    params = { "environment" => "not_found_config" }
    o = Options.new(params, "fake", "fake").all

    assert_equal o["a"], "general default public"
    assert_equal o["b"], "proj default public"
  end

end
