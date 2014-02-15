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
      LicenseFinder.instance_variable_set(:@config, nil)
      LicenseFinder::Configuration.stub(:config_file_exists?).and_return(true)
      LicenseFinder::Configuration.stub(:persisted_config_hash).and_return(config)
    end

    after do
      LicenseFinder.instance_variable_set(:@config, nil)
    end

    it "should load the configuration exactly once" do
      LicenseFinder::Configuration.should_receive(:persisted_config_hash).once.and_return(config)

      LicenseFinder.config.whitelist
      LicenseFinder.config.whitelist
    end
  end
end
