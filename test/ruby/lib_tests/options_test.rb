require 'rspec'
require_relative '../../../scripts/ruby/lib/options.rb'

this_dir = File.dirname(__FILE__)
fixtures = "#{this_dir}/../fixtures"
general_config = "#{fixtures}/configs/general.yml"
project_simple = "#{fixtures}/configs/project_simple.yml"
project_complex = "#{fixtures}/configs/project_complex.yml"
params = {:environment => "development", :project => "test_data"}


describe "initialize" do
  context "in a happy world" do
    it "should make a new object with an attribute" do
      options = Options.new(params, general_config, project_simple)
      expect(options.all).to be
      expect(options.all["solr_core"] == "jessica_testing").to be_truthy
    end

    it "should override general config with project config" do
      options = Options.new(params, general_config, project_complex)
      expect(options.all).to be
      expect(options.all["solr_path"] == "http://different.unl.edu:port/solr/").to be_truthy
      expect(options.all["tei_xsl"] == "newplace.xsl").to be_truthy
      expect(options.all["vra_xsl"] == "scripts/xslt/cdrh_to_solr/solr_transform_vra.xsl").to be_truthy
    end
  end
end

# TODO should make some more tests for the specific methods


