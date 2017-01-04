require 'rspec'
require_relative '../../../scripts/ruby/lib/options.rb'
require_relative '../test_setup.rb'

params = {"environment" => "development", "project" => "test_data"}
this_dir = File.dirname(__FILE__)
fixtures = "#{this_dir}/../fixtures"
general_config = "#{fixtures}/configs/general"
project_simple = "#{fixtures}/configs/project_simple"
project_complex = "#{fixtures}/configs/project_complex"
options_test = Options.new(params, general_config, project_simple)

describe "initialize" do
  context "in a happy world" do
    it "should make a new object with an attribute" do
      options = Options.new(params, general_config, project_simple)
      expect(options.all).to be
      expect(options.all["solr_core"]).to eq("jessica_testing")
    end

    it "should override general config with project config" do
      options = Options.new(params, general_config, project_complex)
      expect(options.all).to be
      expect(options.all["solr_path"]).to eq("http://testserver.unl.edu:8080/solr/")
      expect(options.all["tei_solr_xsl"]).to eq("scripts/xslt/cdrh_to_solr/solr_transform_tei.xsl")
      expect(options.all["vra_solr_xsl"]).to eq("scripts/xslt/cdrh_to_solr/solr_transform_vra.xsl")
    end
  end
end

describe "read_config" do
  context "given a bad file path" do
    it "should not exit the program" do
      begin
        options_test.read_config("this/is/a/fake/yml.yml")
        expect(true).to be_truthy
      rescue
        expect(true).to be_falsey
      end
    end
  end
  context "given a good file path" do
    it "should read the stuff" do
      config = options_test.read_config("#{general_config}/public.yml")
      expect(config["default"]["log_old_number"]).to eq(4)
    end
  end
end

describe "remove_environments" do
  context "given new config" do
    it "should remove the production environment and flatten development" do
      new_config = {
        "default" => {
          "a" => "thing",
        },
        "development" => {
          "dev" => "true"
        },
        "production" => {
          "dev" => "false",
          "another" => "hello"
        }
      }
      # options_test is preset to development environment
      output = options_test.remove_environments(new_config)
      expect(output["development"]).to be_nil
      expect(output["production"]).to be_nil
      expect(output["a"]).to eq("thing")
      expect(output["dev"]).to eq("true")
      expect(output["another"]).to be_nil
    end
  end
  # context "given new production param" it "should remove the development environment"
end

# TODO test smash_configs, also?  Already kind of being tested with initialize
