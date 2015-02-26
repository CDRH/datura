require 'rspec'
require_relative '../../../scripts/ruby/lib/solr_poster.rb'

this_dir = File.dirname(__FILE__)
test_solr_url = "http://rosie.unl.edu:8080/solr/jessica_testing/update"
bad_url = "http://rosie.unl.edu:8080/solr/badurl"
solr_xml = file = IO.read("#{this_dir}/../fixtures/solr_data/Photographs.xml")

RSpec.describe "Solr Poster Test:" do
  describe "post_xml" do
    context "given good url and content" do
      it "should return a response object with status 200" do
        res = post_xml(test_solr_url, solr_xml)
        expect(res.code).to eq("200")
      end
    end
    # this test is currently failing because solr is sending back 200...?
    context "given a good url and bad content" do
      it "should return a response object with status 400" do
        res = post_xml(test_solr_url, "<bad><xml/></bad>")
        puts "res #{res.body}"
        expect(res.code).to eq("400")
      end
    end
    context "given a good url and no content" do
      it "should return nil" do
        res = post_xml(test_solr_url, "")
        expect(res).to be_nil
      end
    end
    context "given bad url" do
      it "should return a response object with status 404" do
        res = post_xml(bad_url, solr_xml)
        expect(res.code).to eq("404")
      end
    end
    context "given no url" do
      it "should return nil" do
        res = post_xml("", solr_xml)
        expect(res).to be_nil
      end
    end
  end

  describe "commit_solr" do
    it "should have status 200 with real url" do
      res = commit_solr(test_solr_url)
      expect(res.code).to eq("200")
    end
    it "should have a status of 400 with bad url" do
      res = commit_solr(bad_url)
      expect(res.code).to eq("404")
    end
  end
end
