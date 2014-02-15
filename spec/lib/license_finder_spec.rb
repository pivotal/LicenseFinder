require 'spec_helper'

describe LicenseFinder do
  describe ".config" do
    let(:config) do
      {
        'whitelist' => %w(MIT Apache),
        'ignore_groups' => %w(test development)
      }
    end

    before do
      LicenseFinder::Configuration.stub(:config_file_exists?).and_return(true)
      LicenseFinder::Configuration.stub(:persisted_config_hash).and_return(config)
    end

    after do
      LicenseFinder.instance_variable_set(:@config, nil)
    end

    it "should handle a missing configuration file" do
      LicenseFinder::Configuration.stub(:config_file_exists?).and_return(false)
      File.should_not_receive(:open).with('./config/license_finder.yml')

      LicenseFinder.config.whitelist.should == []
      LicenseFinder.config.ignore_groups.should == []
      LicenseFinder.config.dependencies_dir.should == './doc/'
    end

    it "should load the configuration exactly once" do
      LicenseFinder::Configuration.should_receive(:persisted_config_hash).once.and_return(config)

      LicenseFinder.config.whitelist
      LicenseFinder.config.whitelist
    end

    describe "#whitelist" do
      it "should load a whitelist from license_finder.yml" do
        LicenseFinder.config.whitelist.should =~ %w(MIT Apache)
      end

      it "should load an empty whitelist from license_finder.yml when there are no whitelist items" do
        LicenseFinder::Configuration.stub(:persisted_config_hash).and_return(config.merge('whitelist' => nil))

        LicenseFinder.config.whitelist.should =~ []
      end
    end

    describe "#ignore_groups" do
      it "should load a ignore_groups list from license_finder.yml" do
        LicenseFinder.config.ignore_groups.should == ["test", "development"]
      end

      it "should load an empty ignore_groups list from license_finder.yml when there are no ignore groups" do
        LicenseFinder::Configuration.stub(:persisted_config_hash).and_return(config.merge('ignore_groups' => nil))

        LicenseFinder.config.ignore_groups.should == []
      end
    end

    describe "#dependencies_dir" do
      it 'should allow the dependencies file directory to be configured' do
        LicenseFinder::Configuration.stub(:persisted_config_hash).and_return(config.merge('dependencies_file_dir' => './elsewhere'))

        config = LicenseFinder.config
        config.dependencies_dir.should == './elsewhere'
        config.dependencies_yaml.should == './elsewhere/dependencies.yml'
        config.dependencies_text.should == './elsewhere/dependencies.csv'
        config.dependencies_html.should == './elsewhere/dependencies.html'
      end

      it 'should default the dependency files when the directory is not provided' do
        config = LicenseFinder.config
        config.dependencies_dir.should == './doc/'
        config.dependencies_yaml.should == './doc/dependencies.yml'
        config.dependencies_text.should == './doc/dependencies.csv'
        config.dependencies_html.should == './doc/dependencies.html'
      end
    end
  end
end
