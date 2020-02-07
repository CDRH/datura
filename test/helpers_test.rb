require "test_helper"
require "nokogiri"

class Datura::HelpersTest < Minitest::Test

  def test_date_display
    # normal dates
    assert_equal "December 2, 2016", Datura::Helpers.date_display("2016-12-02")
    assert_equal "January 31, 2014", Datura::Helpers.date_display("2014-01-31", "no date")
    # no date
    assert_equal "N.D.", Datura::Helpers.date_display(nil)
    assert_equal "no date", Datura::Helpers.date_display("20143183", "no date")
    assert_equal "", Datura::Helpers.date_display(nil, "")
  end

  def test_date_standardize
    # missing month and day
    assert_equal "2016-01-01", Datura::Helpers.date_standardize("2016")
    assert_equal "2016-12-31", Datura::Helpers.date_standardize("2016", false)
    # missing day
    assert_nil Datura::Helpers.date_standardize("01-12")
    assert_equal "2014-01-01", Datura::Helpers.date_standardize("2014-01")
    assert_equal "2014-01-31", Datura::Helpers.date_standardize("2014-01", false)
    # complete date
    assert_equal "2014-01-12", Datura::Helpers.date_standardize("2014-01-12")
    # invalid date
    assert_nil Datura::Helpers.date_standardize("2014-30-31")
    # February final day
    assert_equal "2015-02-28", Datura::Helpers.date_standardize("2015-2", false)
    assert_equal "2016-02-29", Datura::Helpers.date_standardize("2016-02", false)
  end

  def test_get_directory_files
    # real directory
    files = Datura::Helpers.get_directory_files("#{File.dirname(__FILE__)}/fixtures")
    assert_equal 2, files.length

    # not a real directory
    files = Datura::Helpers.get_directory_files("/fake")
    assert_nil files
  end

  def test_get_input
    # TODO
  end

  def test_get_url
    assert_equal "200", Datura::Helpers.get_url("https://www.unl.edu/").code
  end

  def test_make_dirs
    # TODO
  end

  def test_normalize_name
    assert_equal "title", Datura::Helpers.normalize_name("The Title")
    assert_equal "anne of green gables", Datura::Helpers.normalize_name("Anne of Green Gables")
    assert_equal "fancy party", Datura::Helpers.normalize_name("A Fancy Party")
    assert_equal "hour", Datura::Helpers.normalize_name("An Hour")
  end

  def test_normalize_space
    # ensure that return characters are replaced by spaces, and multispaces squashed
    test1 = " <xml>\r<title>Example    </title>\n  </xml>\n "
    assert_equal "<xml> <title>Example </title> </xml>", Datura::Helpers.normalize_space(test1)

    # check that newlines are dead regardless
    test2 = "<xml>\r<title>Exa\rmple\n</title></xml>"
    assert_equal "<xml> <title>Exa mple </title></xml>", Datura::Helpers.normalize_space(test2)
  end

  def test_regex_files
    test_files = %w[
      /path/to/cody.book.001.xml
      /path/to/cody.book.002.xml
      /path/to/cody.news.001.xml
      /path/to/transmiss.mem.001.xml
      /path/to/cat.let0001.xml
    ]

    # no files
    files = Datura::Helpers.regex_files([], "d")
    assert_equal 0, files.length

    # return original array when no regex
    files = Datura::Helpers.regex_files(test_files)
    assert_equal test_files.length, files.length

    # return only cody files
    files = Datura::Helpers.regex_files(test_files, "cody")
    assert_equal 3, files.length

    # return only books with slightly advanced regex
    files = Datura::Helpers.regex_files(test_files, "book\.0")
    assert_equal 2, files.length

    # return all news or memorabilia
    files = Datura::Helpers.regex_files(test_files, "news|mem")
    assert_equal 2, files.length

    # return a specific id
    files = Datura::Helpers.regex_files(test_files, "cat.let0001")
    assert_equal 1, files.length
  end

  def test_should_update?
    hour_ago = Time.now - 60*60
    test_file = "#{File.dirname(__FILE__)}/fixtures/should_update.txt"

    file = FileUtils.touch(test_file).first
    assert Datura::Helpers.should_update?(file, hour_ago)

    hour_future = Time.now + 60*60
    file = FileUtils.touch(test_file).first
    refute Datura::Helpers.should_update?(file, hour_future)
  end

end
