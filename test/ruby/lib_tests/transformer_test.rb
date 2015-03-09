require 'rspec'
require_relative '../../../scripts/ruby/lib/transformer.rb'
require_relative '../../../scripts/ruby/lib/solr_poster.rb'

this_dir = File.dirname(__FILE__)
repo_dir = "#{this_dir}/../../../"
fixtures = "#{this_dir}/../fixtures"
solr = SolrPoster.new("http://rosie.unl.edu:8080/solr/jessica_testing/update")

tei = "#{fixtures}/tei.xml"
solr_xml = "#{fixtures}/solr_data/Photographs.xml"

xslt_location = {
  "tei" => "test/ruby/fixtures/tei.xsl",
  "dc" => "test/ruby/fixtures/dc.xsl",
  "vra" => "test/ruby/fixtures/vra.xsl",
}

xslt_params = {
  "figures" => true,
  "fw" => true,
  "pb" => false
}

# TODO the below could use some more testing and attempts to break it

RSpec.describe "Transformer Test:" do
  before(:each) do
    @t = Transformer.new(repo_dir, "test_data", xslt_location, solr, false, xslt_params, nil)
  end
  describe "transformer object" do
    it "should initialize with accessible features" do
      expect(@t.saxon_errors).to eq([])
      expect(@t.solr_errors).to eq([])
      expect(@t.solr_failed_files).to eq([])
    end
    it "should have setters" do
      @t.solr_errors << "This is an error"
      expect(@t.solr_errors).to eq(["This is an error"])
    end
  end

  describe "_post" do
    it "should post a file without an error" do
      @t._post(tei, solr_xml)
      expect(@t.solr_failed_files.length).to be(0)
    end
    it "should cause exception if file does not exist" do
      begin
        @t._post(tei, nil)
        expect(true).to be_falsey
      rescue
        expect(true).to be_truthy
      end
    end
  end

  describe "_transform_and_post" do
    context "given good tei and xsl" do
      it "should transform (and not post)" do
        errors = @t._transform_and_post(tei, xslt_location["tei"], false)
        expect(errors).to be_nil
        # TODO test the posting portion
      end
    end
    context "given bad tei and or xsl" do
      it "should return an error with the file name" do
        errors = @t._transform_and_post(tei, "test/ruby/fixtures/non_existent.xsl", false)
        expect(errors.length).to be > 0
      end
    end
  end

  describe "transform" do
    it "TODO"
  end

  describe "_stringify_params" do
    it "should return key=value with spaces between" do
      new_params = @t._stringify_params(xslt_params)
      expect(new_params.length).to be > 0
      expect(new_params).to eq("figures=true fw=true pb=false")
    end
  end

  describe "_transform_tei_html" do
    it "TODO"
  end

  describe "_transform_vra" do
    it "TODO"
  end

  describe "_transform_dc" do
    it "TODO"
  end

end