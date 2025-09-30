require_relative "test_helper"

class OptionsTest < Minitest::Test
  # Stub read_all_configs instance method by storing the original, undefining,
  # and redefining before each test is performed
  # so we can test option parsing without reading unfixed config files
  attr_accessor :orig_read_all_configs

  def setup
    super

    self.orig_read_all_configs = Datura::Options.instance_method(:read_all_configs)

    Datura::Options.send(:undef_method, :read_all_configs)
    Datura::Options.define_method(:read_all_configs) do
      |dummy_arg1, dummy_arg2|

      @general_config_pub = {
        "default" => {
          "a" => "general default public",
          "es_schema_path" => "lib/config",
          "api_version" => "2.0"
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

  # Undefine and restore the original read_all_configs instance method
  # after each test is performed to avoid method redefined warnings
  def teardown
    super

    Datura::Options.send(:undef_method, :read_all_configs)
    Datura::Options.define_method(:read_all_configs, orig_read_all_configs)
  end

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
