require "test_helper"
require "nokogiri"

class Datura::HelpersTest < Minitest::Test

  def test_get_directory_files
    # real directory
    files = Datura::Helpers.get_directory_files("#{File.dirname(__FILE__)}/fixtures")
    assert_equal 3, files.length

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
