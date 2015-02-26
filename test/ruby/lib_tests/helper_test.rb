require 'fileutils'  # built-in Ruby library
require 'rspec'
require_relative '../../../scripts/ruby/lib/helpers.rb'

this_dir = File.dirname(__FILE__)
fixtures = "#{this_dir}/../fixtures"

RSpec.describe "Helper Test:" do
  
  describe "clear_tmp_directory" do
    context "given a good directory" do
      4.times { |i| FileUtils.touch("#{fixtures}/tmp/#{i}.txt")}
      it "should remove files inside" do
        # check that the new files are there first
        expect(Dir["#{fixtures}/tmp/*"].length).to equal(4)
        # now remove them
        expect(clear_tmp_directory("#{fixtures}")).to be_truthy
        expect(Dir["#{fixtures}/tmp/*"].length).to equal(0)
      end
    end
    context "given a bad directory" do
      it "should raise exception" do
        begin
          clear_tmp_directory(".")
        rescue RuntimeError => e
          expect(true).to be_truthy
        else
          # should not have gotten to this step
          expect(true).to be_falsey 
        end
      end
    end
  end  # ends clear_tmp_directory


  describe "create_temp_name" do
    path = "/var/log"
    ext = "xml"
    context "given directory and extension" do
      it "should return a file name" do
        res = create_temp_name(path, "xml")
        expect(res).to end_with ext
        expect(res).to start_with path
      end
    end
    context "lacking directory and/or extension" do
      it "TODO"
    end
  end  # ends create_temp_name


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


  describe "read_configs" do
    context "given path and project" do
      it "should return config files with :main and :proj"
    end
    context "missing information" do
      it "should ...exit???"  do # TODO 
        begin
          read_configs("jfkd", "fake")
        rescue SystemExit => e
          expect(e.status).to be(0)
        else
          # should not have gotten to this step
          expect(true).eq false 
        end
      end
    end
  end  # ends read_configs

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


  describe "summary_errors" do
    it "should not return anything but also could cause exception"
  end  # ends summarize_errors

end  # ends RSpec Helper Test describe