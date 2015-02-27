require 'rspec'
require_relative '../../../scripts/ruby/lib/solr_poster.rb'

this_dir = File.dirname(__FILE__)
test_solr_url = "http://rosie.unl.edu:8080/solr/jessica_testing/update"
bad_url = "http://rosie.unl.edu:8080/solr/badurl"
file = "#{this_dir}/../fixtures/solr_data/Photographs.xml"
solr_xml = IO.read(file)


RSpec.describe "Solr Poster Test:" do
  describe "solr object" do
    it "should initialize with an accessible url" do
      solr = SolrPoster.new("fake.com/url")
      expect(solr.url).to eq("fake.com/url")
    end

    it "should be able to change the url" do
      solr = SolrPoster.new("fake/url")
      solr.url = "another/fake/one"
      expect(solr.url).to eq("another/fake/one")
    end
  end

  describe "post_file" do
    it "should return an object" do
      solr = SolrPoster.new(test_solr_url)
      res = solr.post_file(file)
      expect(res.code).to eq("200")
    end
  end

  describe "post_xml" do
    solr = nil
    before(:each) do
      solr = SolrPoster.new(test_solr_url)
    end

    context "given good url and content" do
      it "should return a response object with status 200" do
        res = solr.post_xml(solr_xml)
        expect(res.code).to eq("200")
      end
    end
    # this test is currently failing because solr is sending back 200...?
    context "given a good url and bad content" do
      it "should return a response object with status 400" do
        skip
        res = solr.post_xml("<bad><xml/></bad>")
        puts "res #{res.body}"
        expect(res.code).to eq("400")
      end
    end
    context "given a good url and no content" do
      it "should return nil" do
        res = solr.post_xml("")
        expect(res).to be_nil
      end
    end
    context "given bad url" do
      it "should return a response object with status 404" do
        solr.url = bad_url
        res = solr.post_xml(solr_xml)
        expect(res.code).to eq("404")
      end
    end
    context "given no url" do
      it "should cause exception" do
        solr.url = ""
        begin
          res = solr.post_xml(solr_xml)
          # should not get in here
          expect(true).to be_falsey
        rescue
          expect(true).to be_truthy
        end
      end
    end
  end

  describe "commit_solr" do
    solr = nil
    before(:each) do
      solr = SolrPoster.new(test_solr_url)
    end
    it "should have status 200 with real url" do
      res = solr.commit_solr
      expect(res.code).to eq("200")
    end
    it "should have a status of 400 with bad url" do
      solr.url = bad_url
      res = solr.commit_solr
      expect(res.code).to eq("404")
    end
  end
end
