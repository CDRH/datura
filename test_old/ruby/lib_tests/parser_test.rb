require 'rspec'
require_relative '../../../scripts/ruby/lib/parser.rb'

this_dir = File.dirname(__FILE__)
parser_command = "#{this_dir}/../fixtures/parser_executable.rb"


RSpec.describe "Parser Test:" do
  # TODO going to need to figure out a better 
  # way of testing this functionality
  describe "call it" do
    it "should respond" do
      test = `ruby #{parser_command} -h`
      expect(test.length).to be > 0
    end
  end

  describe "timify" do
    context "given incomplete date time" do
      it "should return nil for year only" do
        time = Parser.timify("2014")
        expect(time).to be_nil
      end
      it "should return nil for year / month only" do
        time = Parser.timify("2014-01")
        expect(time).to be_nil
      end
      it "should return nil for year/month/day and partial time" do
        time = Parser.timify("2014-01-01T16")
        expect(time).to be_nil
      end
      it "should return a time for year/month/day" do
        time = Parser.timify("2014-01-01")
        expect(time).to eq(Time.new("2014-01-01"))
      end
    end

    context "given complete date time" do
      it "should work despite various combos of - T :" do
        time1 = Parser.timify("2014:01:01:15:43")
        expect(time1).to eq(Time.new("2014", "01", "01", "15", "43"))
        time2 = Parser.timify("2014-01-01T15:43")
        expect(time2).to eq(Time.new("2014", "01", "01", "15", "43"))
      end
      it "should work with shortened months (1 vs 01)" do
        time = Parser.timify("2014-1-1T15:43")
        expect(time).to eq(Time.new("2014", "01", "01", "15", "43"))
      end
    end
  end
end


