require 'rspec'
require_relative '../../../scripts/ruby/lib/options.rb'
require_relative '../../../scripts/ruby/lib/transformer.rb'
require_relative '../../../scripts/ruby/lib/solr_poster.rb'

this_dir = File.dirname(__FILE__)
repo_dir = "#{this_dir}/../../../"
fixtures = "#{this_dir}/../fixtures"
general_config = "#{fixtures}/configs/general.yml"
collection_simple = "#{fixtures}/configs/collection_simple.yml"
options = Options.new({"environment" => "development", "collection" => "test_data"}, general_config, collection_simple).all
solr = SolrPoster.new("http://rosie.unl.edu:8080/solr/jessica_testing/update")

tei = "#{fixtures}/tei.xml"
solr_xml = "#{fixtures}/solr_data/Photographs.xml"

# TODO the below could use some more testing and attempts to break it

RSpec.describe "Transformer Test:" do
  before(:each) do
    @t = Transformer.new(repo_dir, solr, options)
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

  describe "_transform_and_post" do
    context "given good tei and xsl" do
      it "should transform (and not post)" do
        errors = @t._transform_and_post(tei, options["tei_xsl"], false)
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
      new_params = @t._stringify_params(options["xsl_params"])
      expect(new_params.length).to be > 0
      expect(new_params).to eq("fig_location=http://server.unl.edu/data_images/collections/example/figures/ file_location=http://server.unl.edu/data/collections/ figures=true fw=true pb=true collection=full_name_of_collection slug=short_name_of_collection")
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
