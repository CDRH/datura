require 'fileutils'  # built-in Ruby library
require 'rspec'
require_relative '../../../scripts/ruby/lib/helpers.rb'

this_dir = File.dirname(__FILE__)
fixtures = "#{this_dir}/../fixtures"

RSpec.describe "Helper Test:" do

  describe "get_directory_files" do
    context "given real directory" do
      it "should return array" do
        4.times { |i| FileUtils.touch("#{fixtures}/tmp/#{i}.txt")}
        files = get_directory_files("#{fixtures}/tmp")
        expect(files.length).to equal(4)
      end
    end
    context "given fake directory" do
      it "should return nil" do
        expect(get_directory_files("fjkdalfd/fjdka")).to be_nil
      end
    end
    context "given no directory" do
      it "should return nil" do
        expect(get_directory_files("")).to be_nil
      end
    end
  end  # ends get_directory_files

  describe "get_url" do
    context "given real url" do
      it "should return 200" do
        expect(get_url("http://www.unl.edu/").code).to eq("200")
      end
    end
    context "given fake url" do
      it "should return error" do
        expect(get_url("http://rosie.unl.edu/fake_thing").code).to eq("404")
      end
    end
    context "given super messed up url" do
      it "should throw an error" do
        begin
          get_url("fjdfjdakfda")
          # shouldn't get this far
          expect(false).to be_truthy
        rescue
          expect(true).to be_truthy
        end
      end
    end
  end  # ends get_url

  describe "get_input" do
    context "given real input the first time" do
      it "will return input" do
        expect(get_input("hello", "msg")).to eq("hello")
      end
    end
    context "given nil input, then real input" do
      it "will return the second input"
      # TODO will need to figure out how to fake STDIN
    end
  end

  describe "regex_files" do
    test_files = ["/path/to/cody.book.001.xml", 
                  "/path/to/cody.book.002.xml", 
                  "/path/to/cody.news.001.xml",
                  "/path/to/transmiss.mem.001.xml"]
    context "given incomplete info" do
      it "should return empty array when no files" do
        files = regex_files([], "d")
        expect(files.length).to be(0)
      end
      it "should return original array when no regex" do
        files = regex_files(test_files)
        expect(files.length).to be(test_files.length)
      end
    end
    context "given complete info" do
      it "should return only cody files" do
        files = regex_files(test_files, "cody")
        expect(files.length).to be(3)
        expect(files[0]).to eq("/path/to/cody.book.001.xml")
      end
      it "should return only transmiss files" do
        files = regex_files(test_files, "miss")
        expect(files.length).to be(1)
        expect(files[0]).to eq("/path/to/transmiss.mem.001.xml")
      end
      it "should return only books" do
        files = regex_files(test_files, "book\.")
        expect(files.length).to be(2)
      end
      it "should return all news or mem" do
        files = regex_files(test_files, "news|mem")
        expect(files.length).to be(2)
        expect(files[0]).to eq("/path/to/cody.news.001.xml")
        expect(files[1]).to eq("/path/to/transmiss.mem.001.xml")
      end
    end
  end  # ends regex_files


  describe "should_update?" do
    context "given file and time" do
      it "should return true for newer files" do
        hour_ago = Time.now - 60*60
        file = FileUtils.touch("#{fixtures}/update_file.xml").first
        expect(should_update?(file, hour_ago)).to be_truthy
      end
      it "should return false for older files" do
        file = FileUtils.touch("#{fixtures}/update_file.xml").first
        hour_future = Time.now + 60*60
        expect(should_update?(file, hour_future)).to be_falsey
      end
    end
    context "missing information" do
      it "if file and no time should return true" do
        file = FileUtils.touch("#{fixtures}/update_file.xml").first
        expect(should_update?(file)).to be_truthy
      end
      it "should return ??? if no file"  # TODO ???
    end
  end  # ends should_update?


end  # ends RSpec Helper Test describe