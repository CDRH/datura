require "minitest/autorun"
require_relative "classes.rb"

class HelpersTest < Minitest::Test
  def test_date_display
    # normal dates
    assert_equal Common.date_display("2016-12-02"), "December 2, 2016"
    assert_equal Common.date_display("2014-01-31", "no date"), "January 31, 2014"
    # no date
    assert_equal Common.date_display(nil), "N.D."
    assert_equal Common.date_display("20143183", "no date"), "no date"
    assert_equal Common.date_display(nil, ""), ""
  end

  def test_date_standardize
    # missing month and day
    assert_equal Common.date_standardize("2016"), "2016-01-01"
    assert_equal Common.date_standardize("2016", false), "2016-12-31"
    # missing day
    assert_nil Common.date_standardize("01-12")
    assert_equal Common.date_standardize("2014-01"), "2014-01-01"
    assert_equal Common.date_standardize("2014-01", false), "2014-01-31"
    # complete date
    assert_equal Common.date_standardize("2014-01-12"), "2014-01-12"
    # invalid date
    assert_nil Common.date_standardize("2014-30-31")
    # February final day
    assert_equal Common.date_standardize("2015-2", false), "2015-02-28"
    assert_equal Common.date_standardize("2016-02", false), "2016-02-29"
  end

end
