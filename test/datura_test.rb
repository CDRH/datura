require_relative "test_helper"

class DaturaTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil Datura::VERSION
  end
end
